ass datastore::applications::batchuser::snapshotcreatorflink (
  $package,
  $version,
  $properties,
) {

  motd::register{ 'datastore::batchuser::snapshotcreatorflink': }
  
  # Main dependencies
  include 'datastore'

  package { $package:
    ensure => $version,
    install_options => ['--allow-unauthenticated'],
  }

  apt::pin { $package:
    packages => $package,
    version => $version,
    priority => '1001',
  }

  file { "/opt/batch-user-snapshot-creator-flink/conf/snapshot-creator-flink.properties":
    ensure  => file,
    content => template("datastore/batchuser/snapshot-creator-flink.erb"),
    mode    => '644',
    owner   => 'root',
    group   => 'root',
  }

}

