class ExtractManifest 
	def initialize(manifest_location, working_location, entitlement_location)
		@manifest = manifest_location
		@workingdir = working_location
		@entitlement_dir = entitlement_location

		FileUtils.mkdir_p @workingdir
		extract_zip(@manifest, @workingdir)
		extract_zip(@workingdir+"/consumer_export.zip", @workingdir)

		Dir.foreach(@workingdir+'export/entitlements/') do |file|
			if File.file?(File.join(@workingdir+'export/entitlements/', file))
				x = File.join(@workingdir+'export/entitlements/', file) unless File.exist?(file)
				require_data = entitlements(x) unless File.exist?(file)
				require_data = JSON[require_data]
				FileUtils.mkdir_p @entitlement_dir
				create_ssl_key_file(file,require_data)
				create_ssl_cert_file(file,require_data)
				create_ssl_ca_cert_file(file, require_data)
				create_alternate_source(file, require_data)
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

	def entitlements(file)
		x = File.read(file)
		data_hash = JSON.parse(x)
		products =  data_hash['pool']['providedProducts']
		repositories = getrepositories(products)
		ssl_key = data_hash['certificates'][0]['key']
		ssl_cert = data_hash['certificates'][0]['cert']
		ssl_ca_cert = File.read('/etc/rhsm/ca/redhat-uep.pem')
		require_data = {'repositories' => repositories,'ssl_key' => ssl_key,'ssl_cert' => ssl_cert,'ssl_ca_cert' => ssl_ca_cert}
		return JSON[require_data]
	end

	def getrepositories(products)
		allrepositories = []
		products.each do |product|
			productfile = File.read(@workingdir+'export/products/'+product['productId']+'.json')
			data_hash = JSON.parse(productfile)
			data_hash['productContent'].each do |repository|
				singlerepo =  {'reponame' => repository['content']['name'],'base_url' => 'https://cdn.redhat.com'+repository['content']['contentUrl'],'label' => repository['content']['label']}
				allrepositories << singlerepo
			end	
		end
		return allrepositories
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
	def create_ssl_ca_cert_file(file, require_data)
		f = File.new(@entitlement_dir+File.basename(file, ".*")+'_ca.cert', 'w')
		f.write(require_data['ssl_ca_cert'])
		f.close	
	end
	def create_alternate_source(file, require_data)
		f = File.open('/etc/pulp/content/sources/conf.d/cdn.conf', 'a')
		require_data['repositories'].each { |repository| 
			f.write "[#{repository['label']}] \nenabled: 1 \npriority: 0 \nexpires: 3d \nname: #{repository['reponame']} \ntype: yum \nbase_url: #{repository['base_url']} \nssl_ca_cert: #{@entitlement_dir+File.basename(file, ".*")}_ca.cert \nssl_client_key: #{@entitlement_dir+File.basename(file, ".*")}.key \nssl_client_cert: #{@entitlement_dir+File.basename(file, ".*")}.cert \n\n" 
		}
		f.close
	end
end