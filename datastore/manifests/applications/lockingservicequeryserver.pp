class datastore::applications::lockingservicequeryserver (
  $package,
  $version,
  $announce_timeout,
  $shard,
  $hbase_table,
  $enabled,
  $port,
  $announce_path,
  $protocol,
  $log_level,
  $hbase_znode,
  $storage,
  $notactivesince,
  $stalledafterminutes,
  $blacklistservice,
) { 

  motd::register{ 'datastore::lockingservicequeryserver': }

  # Main dependencies
  include 'datastore'

  package { $package:
    ensure => $version,
    notify => Service['locking-service-query-server'],
  }

  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/locking-service-query-server/application.conf':
    ensure  => present,
    content => template ('datastore/opt/locking-service-query-server/application.conf.yml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['locking-service-query-server'],
  }

  service { 'locking-service-query-server':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
