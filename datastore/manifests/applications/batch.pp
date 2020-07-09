class datastore::applications::batch (
  $packages,
  $properties,

) {

  # install packages from list
  $packages.each |$p,$v| {
 
    package { $p:
      ensure => $v,
      install_options => ['--allow-unauthenticated'],
    }

    apt::pin { $p:
      packages => $p,
      version => $v,
      priority => '1001',
    }

  }

  # update configuration files
  $properties.each |$p,$v| {

    $changes = prefix(join_keys_to_values($v, ' '), 'set ')
    $conffile = regsubst("$p",'batch-',' ')

    augeas { "/opt/${p}/conf/${conffile}.properties":
      incl    => "/opt/${p}/conf/${conffile}.properties",
      lens    => 'Properties.lns',
      changes => $changes,
    }

  }

}

