class flink::applications (
  $defaults,
  $list,
  $type,
) {

  include 'dsglobals'

  if $type == "streaming" {
    $kafka_brokers = $defaults['kafka_nodes'].keys.map |$node| { "${node}:${defaults['kafka_broker_port']}" }.join(',')
    $zookeeper_connect = $defaults['zookeeper_quorum'].keys.map |$node| { "${node}:${defaults['zookeeper_port']}" }.join(',')
    $zookeeper_connect_hbase = $defaults['zookeeper_quorum'].keys.map |$node| { "${node}" }.join(',')
    $zookeeper_port = $defaults['zookeeper_port']
    $elasticsearch_http_hosts = $defaults['elasticsearch_nodes'].map |$node| { "${node}:${defaults['elasticsearch_http_port']}"   }.join(',')
  }

  $list.each |$application_name, $options| {
    package { $options['package']:
      ensure => $options['version'],
    }

    apt::pin { $options['package']:
      packages => $options['package'],
      version => $options['version'],
      priority => '1001',
    }
    $options['configfiles'].each |$cfp,$variables| {
      file { "${cfp}":
        ensure => file,
        content => template("${module_name}${cfp}.erb"),
        require => Package[$options['package']],
      }
    }
  }
}
