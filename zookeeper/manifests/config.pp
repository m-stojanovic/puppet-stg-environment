class zookeeper::config (
  $clientport,
  $peerport,
  $leaderport,
  $quorum,
  $jute_maxbuffer,
  $snapretaincount,
  $jvmflags,
  $datadir,
  $alternative,
  $configuration_directory,
  $ticktime,
  $initlimit,
  $synclimit,
  $purgeinterval,
  $maxclientcnxns,
) {

  if $env == 'UNDEF' or $env == '' {
    fail('Error determining environment')
  }

  motd::register  { "zookeeper": }

  $my_id = $quorum[$fqdn]

  file { $configuration_directory:
    ensure  => directory,
    recurse => true,
    purge   => true,
  }
  
  file { 'zoo.cfg':
    path    => "${configuration_directory}/zoo.cfg",
    content => template('zookeeper/etc/zookeeper/conf-puppet/zoo.cfg.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    ensure  => file,
    require => File[$configuration_directory],
  }
  
  file { 'configuration.xsl':
    path    => "${configuration_directory}/configuration.xsl",
    content => template('zookeeper/etc/zookeeper/conf-puppet/configuration.xsl.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    ensure  => file,
    require => File[$configuration_directory],
  }
  
  file { 'log4j.properties':
    path    => "${configuration_directory}/log4j.properties",
    content => template('zookeeper/etc/zookeeper/conf-puppet/log4j.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    ensure  => file,
    require => File[$configuration_directory],
  }
  
  file { $datadir :
    ensure => directory,
    owner  => zookeeper,
    group  => zookeeper,
    mode   => '0775',
  }
  
  file { "${datadir}/myid" :
    content => "$my_id",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    ensure  => present,
    require => File[$datadir],
  }

  file { 'zookeeper-server' :
    path    => '/usr/bin/zookeeper-server',
    content => template('zookeeper/usr/bin/zookeeper-server.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    ensure  => file,
  }
  
  exec { 'install-zookeeper-alternative':
    command => "update-alternatives --install /etc/zookeeper/conf ${alternative} ${configuration_directory} 50",
    path    => '/usr/sbin/'
  }
  
  alternatives { $alternative:
    path => $configuration_directory,
    require => Exec['install-zookeeper-alternative'],
  }
  
  service { 'zookeeper-server':
    enable => true,
    ensure => running,
  }
}
