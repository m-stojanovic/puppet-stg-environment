class datastore::applications::etlservice (
  $package,
  $version,
  $templates,
  $log_stdout,
  $log_level,
) {

  motd::register{ 'datastore::etlservice': }

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

#  service { 'etl-service':
#    enable  => true,
#    ensure  => 'running',
#    require => Package[ $package ],
#  }
  

}
