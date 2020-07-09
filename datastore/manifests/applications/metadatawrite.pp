# Datastore metadata write application
class datastore::applications::metadatawrite(
  $package,
  $version,
  $announce_path,
  $announce_timeout,
  $topic,
  $shard,
  $enabled,
  $admin_port,
  $service_port,
  $processor,
  $encoder,
  $protocol,
  $log_level,
  $log_stdout,
  $log_stderr,
) {

  motd::register{ 'datastore::metadatawrite': }

  # Main dependencies 
  include datastore

  package { $package:
    ensure => $version,
    notify  => Service['datastore-metadata-write'],
  }
  
  apt::pin { 'datastore-metadata-write':
    packages => 'datastore-metadata-write',
    version  => $version,
    priority => '1001',
  }
  
  file { '/opt/datastore-metadata-write/application.conf':
    ensure  => present,
    content => template ('datastore/opt/metadata-write/application.conf.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-metadata-write'],
  }
  
  file { '/opt/datastore-metadata-write/logback.xml':
    ensure  => present,
    content => template ('datastore/opt/metadata-write/logback.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    require =>  Package[ $package ],
    notify  => Service['datastore-metadata-write'],
  }
   
  file { '/etc/default/datastore-metadata-write':
    ensure  => present,
    content => template ('datastore/etc/metadata-write/datastore-metadata-write.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0660',
    notify  => Service['datastore-metadata-write'],
  }

  service { 'datastore-metadata-write':
    ensure  =>  'running',
    enable  =>  true,
    require =>  Package[ $package ],
  }


}
