class datastore::applications::mobileresponseread (
  $package,
  $version,            
  $announce_timeout,
  $shard,
  $enabled,
  $admin_port,
  $service_port,
  $announce_path,
  $protocol,
  $hbase_znode,
  $hbase_markers_table,
  $hbase_stats_table,
  $hbase_pushstats_table,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::mobileresponseread': }
  
  # Main dependencies
  include datastore
  
  package { $package:
    ensure => $version,
    notify  => Service['datastore-mobileresponse-read'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-mobileresponse-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/mobileresponse-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-mobileresponse-read'],
  }
   
  file { '/opt/datastore-mobileresponse-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/mobileresponse-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-mobileresponse-read'],
  }
  
  file { '/etc/default/datastore-mobileresponse-read':
    ensure  => present,
    content => template ('datastore/etc/mobileresponse-read/datastore-mobileresponse-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-mobileresponse-read'],
  }  

  service { 'datastore-mobileresponse-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
