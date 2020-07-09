class hbase::roles::master(
  $packages,  
) {
  
  motd::register { 'hbase::roles::master': }
  
  require 'hbase::config'
  require 'hbase::maintenance::master'

  $packages.each |$p,$v| {
    package { $p:
      ensure => $v,
    }

    apt::pin { $p:
      packages => $p,
      version => $v,
      priority => '1001',
    }
  } 
}