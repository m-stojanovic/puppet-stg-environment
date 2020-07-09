class ha(
  $nodes,
  $keepalive,
  $deadtime,
  $warntime,
  $initdead,
  $udpport,
  $autofailback,
  $preferednode,
  $kafkanlbaddress,
) {

  motd::register { 'bigdata::ha': }

  # Query puppetdb to obtain ip of resource nodes
  $qhosts = join(["[", $nodes.map |$v| {"\'$v.$domain\'"}.join(','), "]"],'')
  $ipaddr_query = "facts{name = 'ipaddress_eth0' and certname in $qhosts}"
  $ipaddr = puppetdb_query($ipaddr_query)

  package { 'heartbeat':
    ensure => installed,
  }

  file { '/etc/ha.d/ha.cf':
    ensure => file,
    content => template('ha/ha.cf.erb'),
    require => Package['heartbeat'],
  }

  file { '/etc/ha.d/haresources':
    ensure => file,
    content => template('ha/haresources.erb'),
    require => Package['heartbeat'],
  }

  file { '/etc/ha.d/authkeys':
    ensure => file,
    content => template('ha/authkeys.erb'),
    require => Package['heartbeat'],
    mode => '0600',
    owner => 'root',
    group => 'root',
  }
  
  service { 'heartbeat':
    ensure => running,
    require => File[ '/etc/ha.d/ha.cf','/etc/ha.d/haresources','/etc/ha.d/authkeys' ],
  }

}
