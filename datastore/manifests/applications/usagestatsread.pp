class datastore::applications::usagestatsread (
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
  $hbase_stats_table,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::usagestatsread': }
  
  # Main dependencies
  include datastore
  
  package { $package:
    ensure => $version,
    notify  => Service['datastore-usagestats-read'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-usagestats-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/usagestats-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-usagestats-read'],
  }
   
  file { '/opt/datastore-usagestats-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/usagestats-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-usagestats-read'],
  }
  
  file { '/etc/default/datastore-usagestats-read':
    ensure  => present,
    content => template ('datastore/etc/usagestats-read/datastore-usagestats-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-usagestats-read'],
  }  

  service { 'datastore-usagestats-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
