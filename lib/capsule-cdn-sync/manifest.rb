class Manifest 
	def initialize(manifest_location, working_location, entitlement_location, alternate_source_file)
		@manifest = manifest_location
		@workingdir = working_location
		@entitlement_dir = entitlement_location
		@alternate_source_file = alternate_source_file

		clear_files
		FileUtils.mkdir_p @workingdir
		FileUtils.mkdir_p @entitlement_dir
		extract_zip(@manifest, @workingdir)
		extract_zip(@workingdir+"/consumer_export.zip", @workingdir)

		Dir.foreach(@workingdir+'export/entitlements/') do |file|
			file_path = File.join(@workingdir+'export/entitlements/', file)
			if File.file?(file_path)
				require_data = entitlements_certs(file_path)
				require_data = JSON[require_data]	
				create_ssl_key_file(file,require_data)
				create_ssl_cert_file(file,require_data)
				create_ssl_ca_cert_file
			end
		end
	end	

	def extract_zip(file, destination)
		FileUtils.mkdir_p(destination)
		Zip::File.open(file) { |zip_file|
			zip_file.each { |f|
				f_path=File.join(destination, f.name)
				FileUtils.mkdir_p(File.dirname(f_path))
				zip_file.extract(f, f_path) unless File.exist?(f_path)
			}
		}
	end

	def match_product(allrepositories)
		Dir.foreach(@workingdir+'export/entitlements/') do |file|
			file_path = File.join(@workingdir+'export/entitlements/', file)
			if File.file?(file_path)
				final_repositories = []
				x = File.read(file_path)
				data_hash = JSON.parse(x)
				products =  []
				data_hash['pool']['providedProducts'].each do |product|
					products << product['productId']
				end
				
				allrepositories.each do |repo|
					if products.include?(repo["product_id"]) 
						repo["ssl_key"] = @entitlement_dir+File.basename(file, ".*")+'.key'
						repo["ssl_cert"] = @entitlement_dir+File.basename(file, ".*")+'.cert'
						final_repositories << repo
					else
						puts "ERROR: Few repositories did not match. Make sure you are using the same manifest which is upload in satellite"
						clear_files
						exit 1
					end
				end
				
				return final_repositories
			end
		end

	end

	def entitlements_certs(file)
		x = File.read(file)
		data_hash = JSON.parse(x)
		ssl_key = data_hash['certificates'][0]['key']
		ssl_cert = data_hash['certificates'][0]['cert']
		require_data = {'ssl_key' => ssl_key,'ssl_cert' => ssl_cert}
		return JSON[require_data]
	end


	def create_ssl_key_file(file,require_data)
		f = File.new(@entitlement_dir+File.basename(file, ".*")+'.key', 'w')
		f.write(require_data['ssl_key'])
		f.close	
	end
	def create_ssl_cert_file(file,require_data)
		f = File.new(@entitlement_dir+File.basename(file, ".*")+'.cert', 'w')
		f.write(require_data['ssl_cert'])
		f.close	
	end
	def create_ssl_ca_cert_file	
		f = File.new(@entitlement_dir+'cdn_ca.cert', 'w')
		ca = File.read("/etc/rhsm/ca/redhat-uep.pem")
		f.write(ca)
		f.close	
	end
	def create_alternate_source(repo_data)
		
		f = File.open(@alternate_source_file, 'a')
		repo_data.each { |repository| 
			f.write "[#{repository['label']}] \nenabled: 1 \npriority: 0 \nexpires: 3d \nname: #{repository['reponame']} \ntype: yum \nbase_url: #{repository['base_url']} \nssl_ca_cert: #{@entitlement_dir}cdn_ca.cert \nssl_client_key: #{repository['ssl_key']} \nssl_client_cert: #{repository['ssl_cert']} \n\n" 
		}
		f.close
	end
	def clear_files
		FileUtils.rm_rf(@workingdir)
		FileUtils.rm_rf(@entitlement_dir)
		File.delete(@alternate_source_file) if File.exist?(@alternate_source_file)
	end
end