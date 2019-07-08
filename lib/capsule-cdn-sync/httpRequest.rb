class HttpRequest 
	def initialize(username, password)
		@username = username
		@password = password
	end	

	def sendRequest(url,method,params)
		satellite_hostname = File.open('/etc/rhsm/rhsm.conf').grep(/hostname/)[1].split[2]
		uri = URI('https://'+satellite_hostname+url)
		if params
			uri.query = URI.encode_www_form(params)
		end
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth @username, @password
		res = http.request(request)
		if res.code == '401'
			puts 'Wrong username or password'
			exit 1
		else
			return res.body
		end
	end
end