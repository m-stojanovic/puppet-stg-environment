class confluentapp::kafkarest(
  $package,
  $version,
  $schemaregistryurl,
  $compression_type,
  $consumer_request_max_bytes,
  $port,
  $debug,
  $javaheapopts,
  $jvmperfoptions,
) {

  include 'confluentapp'
  motd::register{ 'bigdata-kafkarest': }
  
  package { $package: 
    ensure => $version,
  }
    
  apt::pin {$package:
    packages => $package,
    version => $version,
    priority => '1001',
  }

  file { '/etc/kafka-rest/kafka-rest.properties':
    ensure => present,
    content => template('confluentapp/kafkarest/kafka-rest.properties.erb'),
    owner   => root,
    group   => root,
    notify  => Service['confluent-kafka-rest'],
    require => Package[ $package ],
  }

  file { '/usr/bin/kafka-rest-run-class':
    ensure => present,
    content => template('confluentapp/kafkarest/kafka-rest-run-class.erb'),
    notify => Service['confluent-kafka-rest'],
  }
  
  file { '/lib/systemd/system/confluent-kafka-rest.service':
    ensure => present,
    source => 'puppet:///modules/confluentapp/confluent-kafka-rest.service',
  }
  
  file {'/etc/rsyslog.d/confluent-kafka-rest.conf':
    ensure => present,
    source => 'puppet:///modules/confluentapp/confluent-kafka-rest.conf',
    notify => Service['rsyslog','confluent-kafka-rest'],
  }

  service { 'confluent-kafka-rest':
    ensure  =>  'running',
    enable  =>  true,
    require => File['/lib/systemd/system/confluent-kafka-rest.service', '/etc/rsyslog.d/confluent-kafka-rest.conf'],
  }

}

