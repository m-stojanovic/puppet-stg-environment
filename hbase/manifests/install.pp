class hbase::install(
  $packages
) {

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