class datastore::applications::relateddatawrite (
  $package,
  $version,            
  $announce_timeout,
  $shard,
  $enabled,
  $admin_port,
  $service_port,
  $announce_path,
  $protocol,
  $processor,
  $encoder,
  $topic,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::relateddatawrite': }

  # Main dependencies
  include datastore
  
  package { $package:
    ensure => $version,
    notify  => Service['datastore-relateddata-write'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-relateddata-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/relateddata-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-relateddata-write'],
  }
   
  file { '/opt/datastore-relateddata-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/relateddata-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-relateddata-write'],
  }
  
  file { '/etc/default/datastore-relateddata-write':
    ensure  => present,
    content => template ('datastore/etc/relateddata-write/datastore-relateddata-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-relateddata-write'],
  }  

  service { 'datastore-relateddata-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
