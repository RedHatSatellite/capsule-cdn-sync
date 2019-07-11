#!/usr/bin/ruby
require 'zip'
require 'json'
require 'net/http'
require 'openssl'
require 'socket'
require_relative 'capsule-cdn-sync/httpRequest'
require_relative 'capsule-cdn-sync/satellite'
require_relative 'capsule-cdn-sync/manifest'


class CapsuleSync
	
	def initialize(manifest_location, working_location, entitlement_location, alternate_source_file, username, password)
		
		#puts Socket.gethostname
 		capsule = "vm254-117.gsslab.pnq2.redhat.com"
 		@satellite = Satellite.new(username,password,capsule)
 		@manifest = Manifest.new(manifest_location, working_location, entitlement_location, alternate_source_file)

		configure_alternate_source

		
 	end

 	def configure_alternate_source
 		capsule_repositories = @satellite.get_repository
 		capsule_repositories_with_ssl = @manifest.match_product(capsule_repositories)
 		@manifest.create_alternate_source(capsule_repositories_with_ssl)

 	end

	

end