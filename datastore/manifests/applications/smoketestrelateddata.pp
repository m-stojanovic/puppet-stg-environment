class datastore::applications::smoketestrelateddata(
  $package,
  $version,
) {

  package { $package:
    ensure => $version,
  }

  apt::pin { $package:
    packages => $package,
     version  => $version,
    priority => '1001',
  }

}

