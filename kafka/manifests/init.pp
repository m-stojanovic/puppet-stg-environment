class kafka(
  $auto_create_topics_enable,
  $broker_port,
  $brokers,
  $group,
  $heap_opts,
  $inter_broker_protocol_version,
  $jmx_port,
  $jvm_performance_opts,
  $log_dirs,
  $log_flush_interval_messages,
  $log_flush_interval_ms,
  $log_message_format_version,
  $log_retention_hours,
  $log_segment_bytes,
  $log4jlogdir,
  $nofiles_ulimit,
  $num_io_threads,
  $num_network_threads,
  $num_partitions,
  $num_replica_fetchers,
  $packages,
  $socket_receive_buffer_bytes,
  $socket_send_buffer_bytes,
  $user,
  $zookeeper_chroot,
){
  
  motd::register { 'kafka': }
  
  include 'dsglobals'
  require 'java'
  
  $broker_id   = $brokers[$fqdn]['id']

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
  
  file { $log_dirs:
    ensure => directory,
    owner => $user,
    group => $group,
    mode => '0750',
  }

  file { '/etc/kafka/server.properties':
    ensure  => file,
    content => template('kafka/etc/kafka/server.properties.erb'),
  }

  file { '/etc/kafka/log4j.properties':
    ensure  => file,
    content => template('kafka/etc/kafka/log4j.properties.erb'),
  }

  file { '/etc/systemd/system/confluent-kafka.service.d/':
    ensure  => directory,
  }

  file { '/etc/systemd/system/confluent-kafka.service.d/10-environment.conf':
    ensure  => present,
    content => template('kafka/etc/systemd/system/confluent-kafka.service.d/10-environment.conf.erb'),
    require => File[ '/etc/systemd/system/confluent-kafka.service.d' ],
  }
  ~> exec { '/bin/systemctl daemon-reload':
    refreshonly => true,
  }

  file { $log4jlogdir:
    ensure => directory,
    owner => $user,
    group => $group,
    mode => '0750',
  }

  service { 'confluent-kafka':
    enable     => 'true',
    ensure     => 'running',
    require    => File['/etc/kafka/server.properties','/etc/kafka/log4j.properties', '/etc/systemd/system/confluent-kafka.service.d/10-environment.conf', $log_dirs ],
    hasrestart => true,
    hasstatus  => true,
  }
}

