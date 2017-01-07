# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2016, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER, THE UNITED STATES
# GOVERNMENT, OR ANY CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

require 'rest-client'
require 'json'

# See the GitHub API reference at https://developer.github.com/v3/
# Get the set of all tags from GitHub's API
url = 'https://api.github.com/repos/nrel/openstudio/tags'
r = RestClient::Request.execute(method: :get, timeout: 10, headers: {accept: :json}, url: url)
r = JSON.parse(r.body, {symbolize_names: true})

# Pick out the 1.x latest release and iteration
release_versions = r.select{ |set| set[:name].split('.')[0] == 'v1' }.
    map{ |set| set[:name].split('.')[1] }.
    map{ |str| Integer(str) }
latest_one_release_version = "1.#{release_versions.max}.0"
iteration_versions = r.select{ |set| set[:name].split('.')[0] == 'v1' }.
    select{ |set| set[:name].split('.')[1] == String(release_versions.max) }.
    map{ |set| set[:name].split('.')[2] }.
    map{ |str| Integer(str) }
latest_one_iteration_version = "1.#{release_versions.max}.#{iteration_versions.max}"

# Pick out the 2.x latest release and iteration
release_versions = r.select{ |set| set[:name].split('.')[0] == 'v2' }.
    map{ |set| set[:name].split('.')[1] }.
    map{ |str| Integer(str) }
latest_two_release_version = "2.#{release_versions.max}.0"
iteration_versions = r.select{ |set| set[:name].split('.')[0] == 'v2' }.
    select{ |set| set[:name].split('.')[1] == String(release_versions.max) }.
    map{ |set| set[:name].split('.')[2] }.
    map{ |str| Integer(str) }
latest_two_iteration_version = "2.#{release_versions.max}.#{iteration_versions.max}"

# Get the latest 1.x release SHA
url = "https://api.github.com/repos/nrel/openstudio/releases/tags/v#{latest_one_release_version}"
r = RestClient::Request.execute(method: :get, timeout: 10, headers: {accept: :json}, url: url)
r = JSON.parse(r.body, {symbolize_names: true})
latest_one_release_sha = r[:assets][0][:name].split('.')[3].split('-')[0]

# Get the latest 1.x iteration SHA
if latest_one_release_version == latest_one_iteration_version
  latest_one_iteration_sha = latest_one_release_sha
else
  url = "https://api.github.com/repos/nrel/openstudio/releases/tags/v#{latest_one_iteration_version}"
  r = RestClient::Request.execute(method: :get, timeout: 10, headers: {accept: :json}, url: url)
  r = JSON.parse(r.body, {symbolize_names: true})
  latest_one_iteration_sha = r[:assets][0][:name].split('.')[3].split('-')[0]
end

# Get the latest 2.x release SHA
url = "https://api.github.com/repos/nrel/openstudio/releases/tags/v#{latest_two_release_version}"
r = RestClient::Request.execute(method: :get, timeout: 10, headers: {accept: :json}, url: url)
r = JSON.parse(r.body, {symbolize_names: true})
latest_two_release_sha = r[:assets][0][:name].split('.')[3].split('-')[0]

# Get the latest 2.x iteration SHA
if latest_two_release_version == latest_two_iteration_version
  latest_two_iteration_sha = latest_two_release_sha
else
  url = "https://api.github.com/repos/nrel/openstudio/releases/tags/v#{latest_two_iteration_version}"
  r = RestClient::Request.execute(method: :get, timeout: 10, headers: {accept: :json}, url: url)
  r = JSON.parse(r.body, {symbolize_names: true})
  latest_two_iteration_sha = r[:assets][0][:name].split('.')[3].split('-')[0]
end

# Write the commands to load the env vars to file depending on POSIX/LINUX vs NT
if ENV.keys.include? 'HAS_JOSH_K_SEAL_OF_APPROVAL'
  cmds = ['#!/bin/bash']
  cmds << "export OPENSTUDIO_ONE_RELEASE=#{latest_one_release_version}/OpenStudio-#{latest_one_release_version}.#{latest_one_release_sha}"
  cmds << "export OPENSTUDIO_ONE_ITERATION=#{latest_one_iteration_version}/OpenStudio-#{latest_one_iteration_version}.#{latest_one_iteration_sha}"
  cmds << "export OPENSTUDIO_TWO_RELEASE=#{latest_two_release_version}/OpenStudio-#{latest_two_release_version}.#{latest_two_release_sha}"
  cmds << "export OPENSTUDIO_TWO_ITERATION=#{latest_two_iteration_version}/OpenStudio-#{latest_two_iteration_version}.#{latest_two_iteration_sha}"
  filename = File.join(File.absolute_path(File.dirname(__FILE__)), 'exports.sh')
  File.open(filename, 'wb') do |f|
    f.puts(cmds)
  end
else
  cmds = []
  cmds << "SET OPENSTUDIO_ONE_RELEASE=#{latest_one_release_version}/OpenStudio-#{latest_one_release_version}.#{latest_one_release_sha}"
  cmds << "SET OPENSTUDIO_ONE_ITERATION=#{latest_one_iteration_version}/OpenStudio-#{latest_one_iteration_version}.#{latest_one_iteration_sha}"
  cmds << "SET OPENSTUDIO_TWO_RELEASE=#{latest_two_release_version}/OpenStudio-#{latest_two_release_version}.#{latest_two_release_sha}"
  cmds << "SET OPENSTUDIO_TWO_ITERATION=#{latest_two_iteration_version}/OpenStudio-#{latest_two_iteration_version}.#{latest_two_iteration_sha}"
  filename = File.join(File.absolute_path(File.dirname(__FILE__)), 'sets.cmd')
  File.open(filename, 'wb') do |f|
    f.puts(cmds)
  end
end
