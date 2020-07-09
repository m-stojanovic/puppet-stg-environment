class flink (
  $alternative_name,
  $alternative_link,
  $configuration_directory,
  $configuration_files,
  $packages,
  $env_java_home,
  $env_java_opts,
  $taskmanager_preallocate_heap,
  $parallelism_default,
  $jobmanager_web_port,
  $jobmanager_web_submit_enabled,
  $state_backend,
  $state_backend_checkpointdir,
  $taskmanager_network_numberOfBuffers,
  $fs_hdfs_hadoopconf,
  $taskmanager_tmp_dir,
  $taskmanager_tmp_in_subdir,
  $yarn_application_attempts,
  $flink_metrics_enabled = false,
) {

  motd::register { 'flink': }

  include 'dsglobals'
  include 'hadoop'
  
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

  file { $configuration_directory:
    ensure => directory,
  }

  alternative_entry { $configuration_directory:
    ensure   => present,
    altlink  => $alternative_link,
    altname  => $alternative_name,
    priority => 50,
    require  => Package[$package],
  }

  alternatives { $alternative_name:
    path => $configuration_directory
  }

  if $taskmanager_tmp_in_subdir {
    $taskmanager_tmp_location = $hadoop::data_mounts
    $taskmanager_tmp_dirs = $taskmanager_tmp_location.map |$taskmanager_tmp_loc| { "${taskmanager_tmp_loc}${taskmanager_tmp_dir}" }.join(':')
  } else {
    $taskmanager_tmp_dirs = $taskmanager_tmp_dir
  }

  $configuration_files.each |$f| {
    file { $f:
      content => template("${module_name}${f}.erb"),
      owner   => $user,
      group   => $group,
      mode    => '0644',
      require => Package['flink'],
    }
  }
}
