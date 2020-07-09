class datastore::applications::dsreader (
  $package,
  $version,
  $admin_port,
  $service_port,
  $hbase_znode,
  $hbase_table,
  $hbase_domain_table,
  $hbase_userresponse_table,
  $hbase_conversion_table,
  $appname,
  $jwt_secret_key,
  $internal_security_token,
  $scan_strategy,
  $logback,
  $logging_config,
  $xssfilter_enabled = false,
  $java_xms,
  $java_xmx,
  $limit_nofile,
  $max_threads,
) {

  motd::register{ 'datastore::dsreader': }

  # Main dependencies
  include datastore
  
  package { $package:
    ensure => $version,
#    notify  => Service['ds-reader'],
  }
  
  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/etc/systemd/system/ds-reader.service.d':
    ensure => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { '/etc/systemd/system/ds-reader.service.d/ds-reader.conf':
    ensure  => present,
    content => template ("datastore/etc/ds-reader/ds-reader.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/opt/ds-reader/config/application.yml':
    ensure  => present,
    content => template ('datastore/opt/ds-reader/application.conf.yml.erb'),
    owner   => 'ds-reader',
    group   => 'ds-reader',
    mode    => '0660',
    require =>  Package[ $package ],
#    notify  => Service['ds-reader'],
  }
  
  file { '/opt/ds-reader/config/bootstrap.yml':
    ensure  => present,
    content => template ('datastore/opt/ds-reader/bootstrap.yml.erb'),
    owner   => 'ds-reader',
    group   => 'ds-reader',
    mode    => '0660',
    require =>  Package[ $package ],
#    notify  => Service['ds-reader'],
  }

  file { '/opt/ds-reader/config/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/ds-reader/logback.xml.erb'),
    owner   => 'ds-reader',
    group   => 'ds-reader',
    mode    => '0660',
    require =>  Package[ $package ],
#    notify  => Service['ds-reader'],
  }

#  service { 'ds-reader':
#    ensure  =>  'running',
#    enable  =>  true,
#    require =>  Package[ $package ],
#  }

}
