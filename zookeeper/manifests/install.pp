class zookeeper::install (
  $basepackage,
  $serverpackage,
  $baseversion,
  $serverversion,
) {

  package { $basepackage:
    ensure => $baseversion,
    install_options => ['--allow-unauthenticated'],
  }
 
  package { $serverpackage:
    ensure => $serverversion,
    install_options => ['--allow-unauthenticated'],
    require => Package[ $basepackage ],
  }
  
  apt::pin { $basepackage:
    packages => $basepackage,
    version => $baseversion,
    priority => '1001',
  }
  
  apt::pin { $serverpackage:
    packages => $serverpackage,
    version => $serverversion,
    priority => '1001',
  }

}
