name "openstudio-server"
description "Install and configure OpenStudio for use with Ruby on Rails"

run_list([
             # Default iptables setup on all servers.
             "role[base]",
             "role[ruby]",
             "role[web_base]",
             "role[r-project]",
             "recipe[mongodb::server]",
             "recipe[openstudio]",
             "recipe[energyplus]",
             "recipe[openstudio_server]"
         ])


default_attributes(
    :openstudio => {
        #:version => "1.0.2.efb742a74c",
        :version => "1.0.2.Unknown", # this is openstudio with ruby 2.0 support
        #:checksum => "9180659c77a7fc710cb9826d40ae67c65db0d26bb4bce1a93b64d7e63f4a1f2c"
    },
    :energyplus => {
        :version => "800008",
        #:checksum => "c1ec1499f964bad8638d3c732c9bd10793dd4052a188cd06bb49288d3d962e09"
    }
)