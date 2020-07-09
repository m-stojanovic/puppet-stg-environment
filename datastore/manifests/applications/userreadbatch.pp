class datastore::applications::userreadbatch (
  $enabled,
  $admin_port,
  $service_port,
  $scheme,
  $announce_path,
  $announce_timeout,
  $protocol,
  $shard,
  $hbase_znode,
  $hbase_speed_table,
  $hbase_batch_table,
  $log_level,
  $log_stderr,
  $log_stdout,
) {

  motd::register{ datastore::userreadbatch: }

  # Main dependencies
  include 'datastore'

  # Module specific dependencies
  require 'datastore::applications::userread'

  # Module does not install any package - need to build directory structure
  file { '/opt/datastore-user-read-batch/':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755'
  }

  # Create links to userread folders
  file { '/opt/datastore-user-read-batch/bin':
    ensure  => link,
    target  => '/opt/datastore-user-read/bin',
    require => File['/opt/datastore-user-read-batch'],
  }

  file { '/opt/datastore-user-read-batch/lib':
    ensure => link,
    target => '/opt/datastore-user-read/lib',
    require => File['/opt/datastore-user-read-batch'],
  }

  # Place config files

  file { '/etc/init.d/datastore-user-read-batch':
    content => template('datastore/etc/user-read-batch/init.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-user-read-batch'],
  }

  file { '/opt/datastore-user-read-batch/application.conf':
    ensure  => present,
    content => template('datastore/opt/user-read-batch/application.conf.yml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-user-read-batch'],
  }

  file { '/opt/datastore-user-read-batch/logback.xml':
    ensure  => present,
    content => template('datastore/opt/user-read-batch/logback.xml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-user-read-batch'],
  }

  file { '/etc/default/datastore-user-read-batch':
    ensure  => present,
    content => template('datastore/etc/user-read-batch/default.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-user-read-batch'],
  }

  # Start service

  service { 'datastore-user-read-batch':
    ensure  =>  'running',
    enable  =>  true,
  }

}
