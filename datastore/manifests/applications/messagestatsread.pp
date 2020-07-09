class datastore::applications::messagestatsread (
  $package,
  $version,
  $enabled,
  $service_port,
  $announce_path,
  $shard,
  $announce_timeout,
  $protocol,
  $hbase_znode,
  $hbase_stats_table,
  $hbase_domain_stats_table,
  $admin_port,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::messagestatsread': }

  # Main dependencies
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-messagestats-read'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-messagestats-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/messagestats-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-messagestats-read'],
  }

  file { '/opt/datastore-messagestats-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/messagestats-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-messagestats-read'],
  }

  file { '/etc/default/datastore-messagestats-read':
    ensure  => present,
    content => template ('datastore/etc/messagestats-read/datastore-messagestats-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-messagestats-read'],
  }

  service { 'datastore-messagestats-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
