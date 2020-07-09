ass datastore::applications::batchuser::esmapping (
  $package,
  $version,
  $properties,
) {

  motd::register{ 'datastore::batchuser::esmapping': }
  
  # Main dependencies
  include 'datastore'

  package { $package:
    ensure => $version,
    install_options => ['--allow-unauthenticated'],
  }

  apt::pin { $p:
    packages => $p,
    version => $v,
    priority => '1001',
  }

  file { "/opt/batch-user-es-mapping/conf/es-mapping.properties":
    ensure  => file,
    content => template("datastore/batchuser/es-mapping.erb"),
    mode    => '644',
    owner   => 'root',
    group   => 'root',
  }

}

