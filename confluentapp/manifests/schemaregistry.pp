class confluentapp::schemaregistry (
  $packages,
  $url,
  $kafkastoretopic,
  $bootstrapservers,
  $groupid,
  $port,
  $hname,
) {

  include 'confluentapp'
  motd::register{ 'confluentapp::schemaregistry': }

  $packages.each |$p, $a| {
    package { $p:
      * => $a,
    }

    if $a['ensure'] {
      apt::pin { $p:
        packages => $p,
        version => $a['ensure'],
        priority => 1001,
      }
    }
  }

  file { '/etc/schema-registry/schema-registry.properties':
    ensure  => present,
    content => template ('confluentapp/schemaregistry/schema-registry.properties.erb'),
    owner   => root,
    group   => root,
  }
  
  file { '/etc/schema-registry/connect-avro-distributed.properties':
    ensure  => present,
    content => template ('confluentapp/schemaregistry/connect-avro-distributed.properties.erb'),
    owner   => root,
    group   => root,
  }

  file { '/etc/schema-registry/connect-avro-standalone.properties':
    ensure  => present,
    content => template ('confluentapp/schemaregistry/connect-avro-standalone.properties.erb'),
    owner   => root,
    group   => root,
  }

  service { 'confluent-schema-registry':
    enable => true,
    ensure => 'running',
  }
}
