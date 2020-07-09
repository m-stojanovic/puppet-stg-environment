class datastore::applications::userresponseread (
  $package,
  $version,            
  $announce_timeout,
  $shard,
  $enabled,
  $admin_port,
  $service_port,
  $announce_path,
  $protocol,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::userreaponseread': }

  # Main dependencies
  include datastore
  
  package { $package:
    ensure => $version,
    notify  => Service['datastore-userresponse-read'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-userresponse-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/userresponse-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-userresponse-read'],
  }
   
  file { '/opt/datastore-userresponse-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/userresponse-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-userresponse-read'],
  }
  
  file { '/etc/default/datastore-userresponse-read':
    ensure  => present,
    content => template ('datastore/etc/userresponse-read/datastore-userresponse-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-userresponse-read'],
  }  

  service { 'datastore-userresponse-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
