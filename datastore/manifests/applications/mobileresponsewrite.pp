# Datastore user write application
class datastore::applications::mobileresponsewrite(
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

  motd::register{ 'datastore::mobileresponsewrite': }

  # Main dependencies 
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-mobileresponse-write'],
  }
  
  apt::pin { 'datastore-mobileresponse-write':
    packages => 'datastore-mobileresponse-write',
    version  => $version,
    priority => '1001',
  }
  
  file { '/opt/datastore-mobileresponse-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/mobileresponse-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-mobileresponse-write'],
  }
  
  file { '/opt/datastore-mobileresponse-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/mobileresponse-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-mobileresponse-write'],
  }
   
  file { '/etc/default/datastore-mobileresponse-write':
    ensure  => present,
    content => template ('datastore/etc/mobileresponse-write/datastore-mobileresponse-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-mobileresponse-write'],
  }

  service { 'datastore-mobileresponse-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
