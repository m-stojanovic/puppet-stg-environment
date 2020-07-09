# Datastore mobile read application
class datastore::applications::mobileread(
  $package,
  $version,
  $admin_port,
  $announce_path,
  $announce_timeout,
  $shard,
  $enabled,
  $service_port,
  $protocol,
  $hbase_znode,
  $hbase_table,
  $redis_host,
  $redis_port,
  $redis_password,
) {

  motd::register{ 'datastore::mobileread': }

  # Main dependencies 
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-mobile-read'],
  }
  
  apt::pin { 'datastore-mobile-read':
    packages => 'datastore-mobile-read',
    version  => $version,
    priority => '1001',
  }
  
  file { '/opt/datastore-mobile-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/mobile-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-mobile-read'],
  }
  
  file { '/opt/datastore-mobile-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/mobile-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-mobile-read'],
  }
   
  file { '/etc/default/datastore-mobile-read':
    ensure  => present,
    content => template ('datastore/etc/mobile-read/datastore-mobile-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-mobile-read'],
  }

  service { 'datastore-mobile-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
