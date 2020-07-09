# Datastore user read application
class datastore::applications::userread(
  $package,
  $version,
  $announce_path,
  $announce_timeout,
  $shard,
  $enabled,
  $admin_port,
  $service_port,
  $processor,
  $protocol,
  $hbase_znode,
  $hbase_speed_table,
  $hbase_batch_table,
  $log_level,
  $log_stdout,
  $log_stderr,
  $redis_host,
  $redis_port,
  $redis_password,
) {

  motd::register{ 'datastore::userread': }
 
  # Main dependencies 
  include datastore

  apt::pin { 'datastore-user-read':
    packages => 'datastore-user-read',
    version  => $version,
    priority => '1001',
  }

  package { $package:
    ensure => $version,
    notify  => Service['datastore-user-read'],
  }

  file { '/opt/datastore-user-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/user-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-user-read'],
  }
  
  file { '/opt/datastore-user-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/user-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-user-read'],
  }
   
  file { '/etc/default/datastore-user-read':
    ensure  => present,
    content => template ('datastore/etc/user-read/datastore-user-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-user-read'],
  }

  service { 'datastore-user-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
