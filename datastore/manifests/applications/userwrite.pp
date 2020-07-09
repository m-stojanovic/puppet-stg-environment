# Datastore user write application
class datastore::applications::userwrite(
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
  $log_level,
  $log_stdout,
  $log_stderr,
  $encoder,
  $kafka_topic,
  $dsattributes_topic,
  $group_topic,
) {

  motd::register{ 'datastore::userwrite': }

  # Main dependencies 
  include datastore
  
  package { $package:
    ensure => $version,
    notify  => Service['datastore-user-write'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }
  
  file { '/opt/datastore-user-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/user-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-user-write'],
  }
  
  file { '/opt/datastore-user-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/user-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-user-write'],
  }
   
  file { '/etc/default/datastore-user-write':
    ensure  => present,
    content => template ('datastore/etc/user-write/datastore-user-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-user-write'],
  }

  service { 'datastore-user-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
