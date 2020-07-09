# Datastore mobile write application
class datastore::applications::mobilewrite(
  $package,
  $version,
  $announce_path,
  $announce_timeout,
  $topic,
  $shard,
  $enabled,
  $admin_port,
  $service_port,
  $processor,
  $encoder,
  $protocol,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::mobilewrite': }

  # Main dependencies 
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-mobile-write'],
  }
  
  apt::pin { 'datastore-mobile-write':
    packages => 'datastore-mobile-write',
    version  => $version,
    priority => '1001',
  }
  
  file { '/opt/datastore-mobile-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/mobile-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-mobile-write'],
  }
  
  file { '/opt/datastore-mobile-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/mobile-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-mobile-write'],
  }
   
  file { '/etc/default/datastore-mobile-write':
    ensure  => present,
    content => template ('datastore/etc/mobile-write/datastore-mobile-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-mobile-write'],
  }

  service { 'datastore-mobile-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
