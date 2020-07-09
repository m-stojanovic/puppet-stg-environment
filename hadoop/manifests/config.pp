class hadoop::config(
  $alternative_link,
  $alternative_name,
  $common_fad,
  $configuration_directory,
  $datanode_heap_mb,
  $dfs_client_read_shortcircuit,
  $dfs_client_read_shortcircuit_buffer_size,
  $dfs_client_read_shortcircuit_streams_cache_size,
  $dfs_client_read_shortcircuit_streams_cache_size_expiry_ms,
  $dfs_datanode_failed_volumes_tolerated = 1,
  $enable_fairscheduler,
  $extra_opts_hadoop_env_malloc_arena_max,
  $fairshare_cust_minmaps,
  $fairshare_cust_minreduces,
  $fairshare_cust_minshare_preemption_timeout,
  $fairshare_def_minshare_preemption_timeout,
  $fairshare_preemption_timeout,
  $hadoop_client_opts,
  $heapsize_in_mb,
  $jobtracker_heap_mb,
  $mapreduce_framework_name,
  $mapreduce_map_java_opts,
  $mapreduce_map_memory_mb,
  $mapreduce_reduce_java_opts,
  $mapreduce_reduce_memory_mb,
  $master_historyserver,
  $master_jobtracker1,
  $master_jobtracker1_alias,
  $master_jobtracker2,
  $master_jobtracker2_alias,
  $master_namenode1,
  $master_namenode1_alias,
  $master_namenode2,
  $master_namenode2_alias,
  $master_resourcemanager,
  $metrics_ganglia_host,
  $metrics_ganglia_udp_port,
  $metrics_sampling_period,
  $metrics_use_ganglia,
  $namenode_heap_mb,
  $namenode_rpc_port,
  $preemption_interval,
  $preemption_onlylog,
  $tasktracker_heap_mb,
  $topology,
  $uber_logging,
  $update_interval,
  $yarn_app_mapreduce_am_resource_mb,
  $yarn_app_mapreduce_am_staging_dir,
  $yarn_log_aggregation_enable,
  $yarn_nodemanager_remote_app_log_dir,
  $yarn_nodemanager_resource_cpu_vcores,
  $yarn_nodemanager_resource_memory_mb,
  $yarn_resourcemanager_am_max_attempts,
  $yarn_resourcemanager_zk_state_store_parent_path,
  $yarn_scheduler_capacity_maximum_am_resource_percent,
  $yarn_scheduler_capacity_maximum_applications,
  $yarn_scheduler_capacity_queues_settings,
  $yarn_scheduler_capacity_root_queues,
  $yarn_scheduler_maximum_allocation_mb,
  $yarn_scheduler_maximum_allocation_vcores,
  $yarn_scheduler_minimum_allocation_mb,
  $zkfc_sshfence_params,
) {  

  include 'hadoop'
  require 'hadoop::install'

  # create directories
  $common_fad.each |$n,$a| {
    file { $n:
      * => $a,
    }
  }

  # set alternative
  alternative_entry { $configuration_directory:
    ensure   => present,
    altlink  => $alternative_link,
    altname  => $alternative_name,
    priority => 50,
  }

  alternatives { $alternative_name:
    path => $configuration_directory
  }

  file { '/etc/hadoop/conf/topology.csv':
    ensure  => present,
    mode    => '0640',
    owner   => $hadoop::user_dfs,
    group   => $group,
    content => template('hadoop/etc/hadoop/conf-puppet/topology.csv.erb'),
  }
}
