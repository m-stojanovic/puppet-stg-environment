class datastore::applications::batchuser::esindexonlinecreator (
  $package,
  $version,
  $properties,
) {
  
  motd::register{ 'datastore::batchuser::esindexonlinecreator': }
  
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
    
  file { "/opt/batch-user-es-index-online-creator/conf/es-index-online-creator.properties":
    ensure  => file,
    content => template("datastore/batchuser/es-index-online-creator.erb"),
    mode    => '644',
    owner   => 'root',
    group   => 'root',
  }

}
