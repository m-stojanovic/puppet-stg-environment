class datastore::applications::schemarepository(
  $package,
  $version,
  $announce_timeout,
  $shard,
  $enabled,
  $admin_port,
  $service_port,
  $announce_path,
  $protocol,
  $storage,
  $caching,
  $log_level,
  $log_stdout,
  $log_stderr,

) {

  motd::register{ 'datastore::schemarepository': }

  # Main dependencies
  include 'datastore'

  package { $package:
    ensure => $version,
    notify => Service['schema-repository'],
  }
  
  apt::pin { $package:
    packages => $package,
    version  => $version,
    priority => '1001',
  }

  file { '/opt/schema-repository/application.conf':
    ensure  => present,
    content => template ('datastore/opt/schema-repository/application.conf.yml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['schema-repository'],
  }
  
  file { '/opt/schema-repository/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/schema-repository/logback.xml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['schema-repository'],
  }
  
  file { '/etc/default/schema-repository':
    ensure  => present,
    content => template ('datastore/etc/schema-repository/schema-repository.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['schema-repository'],
  }
  
  service { 'schema-repository':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[$package],
  }


}
