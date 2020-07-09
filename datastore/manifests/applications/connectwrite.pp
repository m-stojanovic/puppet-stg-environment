# Datastore connect write application
class datastore::applications::connectwrite(
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

  motd::register{ 'datastore::connectwrite': }

  # Main dependencies
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-connect-write'],
  }

  apt::pin { 'datastore-connect-write':
    packages => 'datastore-connect-write',
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-connect-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/connect-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-connect-write'],
  }

  file { '/opt/datastore-connect-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/connect-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-connect-write'],
  }

  file { '/etc/default/datastore-connect-write':
    ensure  => present,
    content => template ('datastore/etc/connect-write/datastore-connect-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-connect-write'],
  }

  service { 'datastore-connect-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
