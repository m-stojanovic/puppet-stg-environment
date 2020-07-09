class datastore::applications::kpiread (
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
  $hbase_customerkpis_table,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::kpiread': }
  
  # Main dependencies
  include datastore
  
  package { $package:
    ensure => $version,
    notify  => Service['datastore-kpi-read'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/datastore-kpi-read/application.conf':
    ensure  => present,
    content => template ('datastore/opt/kpi-read/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-kpi-read'],
  }
   
  file { '/opt/datastore-kpi-read/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/kpi-read/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[ $package ],
    notify  => Service['datastore-kpi-read'],
  }
  
  file { '/etc/default/datastore-kpi-read':
    ensure  => present,
    content => template ('datastore/etc/kpi-read/datastore-kpi-read.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Service['datastore-kpi-read'],
  }  

  service { 'datastore-kpi-read':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }

}
