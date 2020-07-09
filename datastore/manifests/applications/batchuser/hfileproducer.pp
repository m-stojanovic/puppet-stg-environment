ass datastore::applications::batchuser::hfileproducer (
  $package,
  $version,
  $properties,
) {

  motd::register{ 'datastore::batchuser::hfileproducer': }
  
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

  file { "/opt/batch-user-hfile-producer/conf/hfile-producer.properties":
    ensure  => file,
    content => template("datastore/batchuser/hfile-producer.erb"),
    mode    => '644',
    owner   => 'root',
    group   => 'root',
  }

}

