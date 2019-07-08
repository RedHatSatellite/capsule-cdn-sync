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
		#=======================================================================================================================
		# Need to continue from here. Logic -  Get all organizations where capsule is in and then nested loop with env to get all the repository info.
		#=======================================================================================================================

		
		# environments = get_lifecycle_environments
		# result = sendRequest("/katello/api/organizations/1/environments/2/repositories")
	end

	def sendRequest(api, req_method, params)
		req = HttpRequest.new(@username,@password)
		result = req.sendRequest(api, req_method, params)
		return result
	end

end