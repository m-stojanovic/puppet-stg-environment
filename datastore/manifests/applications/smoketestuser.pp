class datastore::applications::smoketestuser(
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
