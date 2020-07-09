class profiles::dockerengine(
  $registries,
) {

  require 'docker'

  motd::register{ 'profiles::dockerengine': }
  
  file { '/etc/docker/certs.d':
    ensure => directory,
  }
  
  # if registries are defined add appropriate folder with certs 
  if $registries {
    $registries.each |$r| {
    
      file { "/etc/docker/certs.d/$r":
        ensure => directory,
      }
      
      file { "/etc/docker/certs.d/$r/$r.crt":
        ensure => file,
        source => "puppet:///modules/profiles/docker/$r.crt",
      }
    }
  }

}

