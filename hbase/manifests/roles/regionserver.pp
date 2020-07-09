class hbase::roles::regionserver(
  $packages,
) {
  
  motd::register { 'hbase::roles::regionserver': }
  
  include 'hbase'
  require 'hbase::config'

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