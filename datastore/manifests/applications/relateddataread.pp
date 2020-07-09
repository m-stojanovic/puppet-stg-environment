class datastore::applications::relateddataread (
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
  $hbase_fast_table,
  $hbaseclient_rpc_timeout,
  $hbaseclient_scanner_timeout,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::relateddataread': }

  # Main dependencies
  include datastore
  
  package { $package:
    ensure => $version,
    notify  => Service['datastore-relateddata-read'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-relateddata-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/relateddata-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
  }
   
  file { '/opt/datastore-relateddata-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/relateddata-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-relateddata-read'],
  }
  
  file { '/etc/default/datastore-relateddata-read':
    ensure  => present,
    content => template ('datastore/etc/relateddata-read/datastore-relateddata-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-relateddata-read'],
  }  

  service { 'datastore-relateddata-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
