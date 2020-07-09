class es::docker::collectd::curl_json {
  motd::register { 'es::docker::collectd::curl_json': }

  if $facts['docker'] {
    $containers = $facts['docker']['network']['bridge']['Containers']
    $containers.each |$id, $settings| {
      case $settings['Name'] {
        /^dsesm[[:digit:]]{3,4}-es[[:digit:]]+/: {
          if $settings['Name'] =~ /^dsesm[[:digit:]]{3,4}-es1/ {
            es::docker::collectd::curl_json::dsesm { "${settings['Name']}": }
          } else {
            notify { "'${settings['Name']}' will not have metrics enabled because we enable them only for 'es1' containers.": }
          }
        }
        /^dsesd[[:digit:]]{3,4}-es[[:digit:]]+/: {
#          es::docker::collectd::curl_json::dsesd { "${settings['Name']}": } - Borys - for you :)
        }
        default: {
          notify { "'${settings['Name']}' is neither dsesm nor dsesd node.": }
        }
      }
    }
  } else {
    warning("'docker' fact doesn't exist, if Docker is going to be set later - ignore")
  }
}
