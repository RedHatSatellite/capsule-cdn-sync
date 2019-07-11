class Satellite 

	def initialize(username,password,capsule_name)
		@username = username
		@password = password
		@capsule = capsule_name

	end
	def getcapsuleId
		params = {"search"=>"name = #{@capsule}"}
		result = sendRequest('/katello/api/capsules','GET',params)
		capsule_id = JSON.parse(result)["results"][0]["id"]
		return capsule_id
	end
	def get_lifecycle_environments
		capsule_id = getcapsuleId
		result = sendRequest("/katello/api/capsules/#{capsule_id}/content/lifecycle_environments", "GET",nil)
		environments = []
		JSON.parse(result)["results"].each do |environment|
			environments << environment['id']
		end
		return environments
	end
	def get_repository
		allrepositories = []
		capsule_orgs = get_capsule_organization
		environments = get_lifecycle_environments
		capsule_orgs.each do |org_id|
			environments.each do |env|
				results = sendRequest("/katello/api/organizations/#{org_id}/environments/#{env}/repositories","GET",nil)
				results = JSON.parse(results)
				results["results"].each do |repo|
					if allrepositories.none?{|hash| hash['base_url'] == repo['url']}
						singlerepo =  {'reponame' => repo['name'],'base_url' => repo['url'],'label' => repo['label'], 'product_id' => repo['product']['cp_id']}
						allrepositories << singlerepo
					end
				end
			end
		end
		return allrepositories
	end

	def get_capsule_organization
		capsule_id = getcapsuleId
		result = sendRequest("/katello/api/capsules/#{capsule_id}","GET",nil)
		organizations = []
		JSON.parse(result)['organizations'].each do |org|
			organizations << org["id"]
		end
		return organizations

	end

	def sendRequest(api, req_method, params)
		req = HttpRequest.new(@username,@password)
		result = req.sendRequest(api, req_method, params)
		return result
	end

end