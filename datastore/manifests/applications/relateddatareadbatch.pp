class datastore::applications::relateddatareadbatch (
  $enabled,
  $admin_port,
  $service_port,
  $announce_path,
  $announce_timeout,
  $protocol,
  $shard,
  $hbase_znode,
  $hbase_table,
  $log_level,
  $log_stderr,
  $log_stdout,
) {

  motd::register{ datastore::relateddatareadbatch: }

  # Main dependencies
  include 'datastore'

  # Module specific dependencies
  require 'datastore::applications::relateddataread'

  # Module does not install any package - need to build directory structure
  file { '/opt/datastore-relateddata-read-batch/':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755'
  }

  # Create links to relateddataread folders
  file { '/opt/datastore-relateddata-read-batch/bin':
    ensure  => link,
    target  => '/opt/datastore-relateddata-read/bin',
    require => File['/opt/datastore-relateddata-read-batch'],
  }

  file { '/opt/datastore-relateddata-read-batch/lib':
    ensure => link,
    target => '/opt/datastore-relateddata-read/lib',
    require => File['/opt/datastore-relateddata-read-batch'],
  }

  # Place config files

  file { '/etc/init.d/datastore-relateddata-read-batch':
    content => template('datastore/etc/relateddata-read-batch/init.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-relateddata-read-batch'],
  }
  
  file { '/opt/datastore-relateddata-read-batch/application.conf':
    ensure  => present,
    content => template('datastore/opt/relateddata-read-batch/application.conf.yml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-relateddata-read-batch'],
  }
   
  file { '/opt/datastore-relateddata-read-batch/logback.xml':
    ensure  => present,
    content => template('datastore/opt/relateddata-read-batch/logback.xml.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-relateddata-read-batch'],
  }
   
  file { '/etc/default/datastore-relateddata-read-batch':
    ensure  => present,
    content => template('datastore/etc/relateddata-read-batch/default.erb'),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['datastore-relateddata-read-batch'],
  }

  # Start service
  
  service { 'datastore-relateddata-read-batch':
    ensure  =>  'running',
    enable  =>  true,
  }

}
