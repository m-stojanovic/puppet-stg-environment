ass datastore::applications::batchuser::snapshotmaintenance (
  $package,
  $version,
  $properties,
) {

  motd::register{ 'datastore::batchuser::snapshotmaintenance': }
  
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

  file { "/opt/batch-user-snapshot-maintenance/conf/snapshot-maintenance.properties":
    ensure  => file,
    content => template("datastore/batchuser/snapshot-maintenance.erb"),
    mode    => '644',
    owner   => 'root',
    group   => 'root',
  }

}

