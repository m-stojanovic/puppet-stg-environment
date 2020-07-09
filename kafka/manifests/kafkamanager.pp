class kafka::kafkamanager(
  $packages,
) {
  motd::register { 'kafkamanager': }
  
  include 'dsglobals'

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

  file { '/etc/kafka-manager/application.conf':
    ensure  => file,
    content => template('kafka/etc/kafka-manager/application.conf.erb'),
  }
}
