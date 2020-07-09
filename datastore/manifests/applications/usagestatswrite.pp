# Datastore user write application
class datastore::applications::usagestatswrite(
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

  motd::register{ 'datastore::usagestatswrite': }

  # Main dependencies 
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-usagestats-write'],
  }
  
  apt::pin { 'datastore-usagestats-write':
    packages => 'datastore-usagestats-write',
    version  => $version,
    priority => '1001',
  }
  
  file { '/opt/datastore-usagestats-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/usagestats-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-usagestats-write'],
  }
  
  file { '/opt/datastore-usagestats-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/usagestats-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-usagestats-write'],
  }
   
  file { '/etc/default/datastore-usagestats-write':
    ensure  => present,
    content => template ('datastore/etc/usagestats-write/datastore-usagestats-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-usagestats-write'],
  }

  service { 'datastore-usagestats-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
