# available at https://github.com/patrick-hudson/ohai-plugins-rackspace
#
# Copyright:: Copyright (c) 2017 Rackspace, Inc.
# Author:: Patrick Hudson <patrick.hudson@rackspace.com>
# Version:: 1.0
#
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'net/http'

Ohai.plugin(:PublicIPInfo) do
  provides 'public_ip_info'

  collect_data(:linux) do
    uri = URI.parse('http://ipv4.icanhazip.com')
    # Handle errors and no response for whoami.rackops.org
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.get(uri.request_uri).body
    rescue
      uri = URI.parse('http://ipv4bot.whatismyipaddress.com')
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.get(uri.request_uri).body
    end
    reg = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
    results = response.gsub("\n","")
    if results.nil?
      Ohai::Log.debug('Failed to return Public_info results')
    elsif reg !~ results
      Ohai::Log.debug('Failed match returned IP address with regex pattern match')
    else
      public_ip_info Mash.new
      public_ip_info[:remote_ip] = results
    end
  end
end
