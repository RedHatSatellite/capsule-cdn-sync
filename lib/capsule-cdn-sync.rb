#!/usr/bin/ruby
require 'zip'
require 'json'
require 'net/http'
require 'openssl'
require 'socket'
require_relative 'capsule-cdn-sync/httpRequest'
require_relative 'capsule-cdn-sync/satellite'
require_relative 'capsule-cdn-sync/extractManifest'


class CapsuleSync
	
	def initialize(manifest_location, working_location, entitlement_location)
		
		#puts Socket.gethostname
 	# 	capsule = "vm254-117.gsslab.pnq2.redhat.com"
 	# 	@x = Satellite.new(username,password,capsule)
		# getCapsuleInfo

		ExtractManifest.new(manifest_location, working_location, entitlement_location)

 	end

 	# def getCapsuleInfo
 	# 	@x.get_lifecycle_environments
 	# end

	

end