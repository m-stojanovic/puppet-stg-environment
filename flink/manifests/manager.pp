class flink::manager (
  $apps,
  $apps_defaults,
  $configuration_directory,
  $packages,
) {

  $packages.each |$p, $a| {
    package { $p:
      * => $a,
    }

    if $a['ensure'] {
      apt::pin { $p:
        packages => $p,
        version => $a['ensure'],
        priority => 1001,
      }
    }
  }

  $options = $apps_defaults
  file { "${configuration_directory}/defaults.conf":
    ensure => file,
    content => template("${module_name}${configuration_directory}/flink-manager.conf.erb"),
    owner => 'root',
    mode => '0644',
  }

  $apps.each |$user, $instances| {
    user { $user:
      ensure => present,
      shell => '/bin/bash',
      home => "/home/${user}",
      managehome => true,
    }

    file { "${configuration_directory}/${user}":
        ensure => directory,
        owner => 'root',
        mode => '0755',
    }

    $instances.each |$instance, $options| {
      file { "${configuration_directory}/${user}/${instance}.conf":
          ensure => file,
          content => template("${module_name}${configuration_directory}/flink-manager.conf.erb"),
          owner => 'root',
          mode => '0644',
          require => File["${configuration_directory}/${user}"],
      }
    }
  }
}
