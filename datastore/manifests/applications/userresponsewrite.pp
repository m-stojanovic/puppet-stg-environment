class datastore::applications::userresponsewrite (             
  $package,
  $version,
  $announce_timeout,
  $shard,
  $processor,
  $topic,
  $enabled,
  $admin_port,
  $service_port,
  $announce_path,
  $encoder,
  $protocol,
  $log_level,
  $log_stdout,
  $log_stderr,

) {

  motd::register{ 'datastore::userresponsewrite': }

  # Main dependencies
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-userresponse-write'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-userresponse-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/userresponse-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-userresponse-write'],
  }

  file { '/opt/datastore-userresponse-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/userresponse-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-userresponse-write'],
  }

  file { '/etc/default/datastore-userresponse-write':
    ensure  => present,
    content => template ('datastore/etc/userresponse-write/datastore-userresponse-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-userresponse-write']
  }

  service { 'datastore-userresponse-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
