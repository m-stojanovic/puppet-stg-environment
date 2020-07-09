class datastore::applications::etlservicemaintainer (
  $package,
  $version,
  $templates,
  $tools,
  $log_stdout,
  $log_level,
) {

  motd::register{ 'datastore::etlservicemaintainer': }

  # Main dependencies
  include 'datastore'

  package { $package:
    ensure => $version,
    install_options => ['--allow-unauthenticated'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  $templates.each |$template,$settings| {
    file { "/opt/etl-server/config/$template":
      ensure  => file,
      content => template("datastore/opt/etl-service/$template.erb"),
      group   => 'root',
      mode    => '0644',
      require => Package[ $package ],
    }
  }
  
  # if not tools had been defined notify about that fact
  if $tools == '' {

    notify{'ETL Service Maintainer tools':
      message => 'No tools will be installed',
    }
  
  }
  else {
  
    $tools.each |$t,$v| {
      package { $t:
        ensure => $v,
        install_options => ['--allow-unauthenticated'],
      }
      
      apt::pin { $t:
        packages => $t,
        version => $v,
        priority => 1001,
      }
   
    }

  }

#  service { 'etl-service':
#    enable  => true,
#    ensure  => 'running',
#    require => Package[ $package ],
#  }
  

}
