# Datastore user write application
class datastore::applications::membershipwrite(
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
  $topic,

) {

  motd::register{ 'datastore::membershipwrite': }

  # Main dependencies
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-membership-write'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-membership-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/membership-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-membership-write'],
  }
  
  file { '/opt/datastore-membership-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/membership-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-membership-write'],
  }
   
  file { '/etc/default/datastore-membership-write':
    ensure  => present,
    content => template ('datastore/etc/membership-write/datastore-membership-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-membership-write'],
  }

  service { 'datastore-membership-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
