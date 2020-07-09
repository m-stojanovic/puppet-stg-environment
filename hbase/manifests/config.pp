class hbase::config(
  $alternatives,
  $classpath,
  $compactions_offpeak_enable,
  $compactions_offpeak_end_hour,
  $compactions_offpeak_start_hour,
  $common_fad,
  $common_links,
  $configuration_directory,
  $configuration_files,
  $coprocessor_classes,
  $extralibs,
  $gclogs,
  $heapsize_in_mb,
  $master_heapsize_in_mb,
  $java_home,
  $libdir,
  $max_direct_memory_size_mb,
  $max_direct_memory_size_switch_bool,
  $min_regionservers_to_start,
  $master_cluster_dfs,
  $zookeeper_znode_parent = undef,
) {

  include hbase
  require hbase::install 
  
  $common_fad.each |$n,$a| {
    file { $n:
      * => $a,
    }
  }

  $configuration_files.each |$f| {
    file { $f:
      ensure => file,
      owner => 'root',
      group => 'root',
      mode => '0644',
      content => template("${module_name}${f}.erb"),
      require => File[ $configuration_directory ]
    }
  }

  $common_links.each |$n,$a| {
    file { $n:
      * => $a,
    }
  }

  $extralibs.each |$f| {
    file { $f:
      ensure => file,
      path => "$libdir/$f",
      mode => '0755',
      owner => 'root',
      group => 'root',
      source => "puppet:///modules/hbase/libs/$f"
    }
  }

  $alternatives['entries'].each |$n,$v| {
    alternative_entry { $n:
      * => $v,
    }
  }

  $alternatives['set'].each |$n,$v| {
    alternatives { $n:
      * => $v,
    }
  }
}
