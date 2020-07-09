class datastore::applications::batchuser::snapshotcreator (
  $package,
  $version,
  $properties,
) {

  motd::register{ 'datastore::batchuser::snapshotcreator': }
  
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

  file { "/opt/batch-user-snapshot-creator/conf/snapshot-creator.properties":
    ensure  => file,
    content => template("datastore/batchuser/snapshot-creator.erb"),
    mode    => '644',
    owner   => 'root',
    group   => 'root',
  }

}

