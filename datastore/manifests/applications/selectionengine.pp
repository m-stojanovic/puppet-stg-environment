# Datastore user read application
class datastore::applications::selectionengine(
  $package,
  $version,
  $node_counter,
  $node_count_timeout,
  $tenant_whitelist,
  $scroll_timeout,
  $supported_user_data_types,
  $announce_path,
  $announce_timeout,
  $shard,
  $service_port,
  $log_level,
  $log_stdout,
  $log_stderr,
  $java_opts,
  $limit_nofile,
  $admin_port,
  $async_store_path,
  $async_hdfs_store_path,
  $async_expire_order_after_minutes,
  $async_clean_finished_after_hours,
  $async_clean_all_after_days,
  $async_cleanup_bulk_size,
  $postgres_host_port,
  $postgres_dbname,
  $postgres_login,
  $postgres_password,
  $postgres_pool_size,
  $postgres_default_timeout_sec,
  $postgres_validate_timeout_sec,
  $postgres_test_on_borrow,
  $postgres_max_idle,
  $postgres_max_total,
  $postgres_max_wait_millis,
  $postgres_max_conn_lifetime_millis,
  $postgres_test_while_idle,
  $quartz,
  $rd_query_scroll_size,
  $rd_query_timeout,
  $rd_node_calculation_timeout,
  $rd_fixed_thread_pool,
  $rd_number_of_elements_in_chunk,
  $rd_max_selection_parallelism,
  $rd_await_node_enabled,
  $rd_chunk_max_parallelism,
  $es_connection_timeout,
  $es_socket_timeout,
  $rd_node_count_timeout,
  $async_selection_timeout,
  $scroll_page_size,
  $async_selection_max_parallelism,
  $optimizer_enabled,
  $threadpool_io_size,
  $threadpool_cpu_size,
  $skip_rd
) {

  motd::register{ 'datastore::selectionengine': }
  
  # Main dependencies
  include datastore
  
    package { $package:
    ensure => $version,
    notify  => Service['selection-engine-application'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/etc/systemd/system/selection-engine-application.service.d':
    ensure => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { '/etc/systemd/system/selection-engine-application.service.d/selection-engine-application.conf':
    ensure  => present,
    content => template ("datastore/etc/selection-engine/selection-engine-application.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/opt/selection-engine-application/application.conf':
    ensure  => present,
    content => template ('datastore/opt/selection-engine/application.conf.yml.erb'),
    owner   => 'selection-engine',
    group   => 'selection-engine',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['selection-engine-application'],
  }
  
  file { '/opt/selection-engine-application/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/selection-engine/logback.xml.erb'),
    owner   => 'selection-engine',
    group   => 'selection-engine',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['selection-engine-application'],
  }

  $quartz['schedulers'].each |$scheduler,$variables| {
    file { "/opt/selection-engine-application/${scheduler}-quartz.properties":
      ensure  => present,
      content => template ('datastore/opt/selection-engine/quartz.properties.erb'),
      owner   => 'selection-engine',
      group   => 'selection-engine',
      mode    => '0660',
      require =>  Package[ $package ],
      notify  => Service['selection-engine-application'],
    }
  }

  service { 'selection-engine-application':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
