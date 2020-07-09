# Datastore stats collector
class datastore::applications::statscollector(
  $package,
  $version,
  $announce_path,
  $announce_timeout,
  $enabled,
  $admin_port,
  $service_port,
  $processor,
  $protocol,
  $topic,
  $shard,
  $log_level,
  $log_stdout,
  $log_stderr,

) {

  motd::register{ 'datastore::statscollector': }
 
  # Main dependencies 
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-user-read'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-stats-collector/application.conf':
    ensure  => present,
    content => template ('datastore/opt/stats-collector/application.conf.yml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-stats-collector'],
  }
  
  file { '/opt/datastore-stats-collector/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/stats-collector/logback.xml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-stats-collector'],
  }
  
  file { '/etc/default/datastore-stats-collector':
    ensure  => present,
    content => template ('datastore/etc/stats-collector/datastore-stats-collector.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-stats-collector'],
  }

  service { 'datastore-stats-collector':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
