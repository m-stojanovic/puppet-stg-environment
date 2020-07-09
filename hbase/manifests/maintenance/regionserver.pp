class hbase::maintenance::regionserver {

  $maintenance = lookup('hbase::maintenance')

  if $maintenance['daily'] {
    file { $maintenance['location']:
      ensure => directory,
      purge => true,
      recurse => true,
      source => "puppet:///modules/hbase/maintenance"
    }

    cron { "hbase_maintenance_daily":
      ensure  => 'present',
      command => "$maintenance['location']/$maintenance['daily_script']",
      user    => root,
      hour    => $maintenance['daily_hour'],
      minute  => $maintenance['daily_minute'],
    }
  } else {
    file { $maintenance['location']:
      ensure => absent,
    }

    cron { "hbase_maintenance_daily":
      ensure  => 'absent',
    }
  }  

  if $maintenance['oom_action_override'] {
    exec { 'override_OOM_action':
      command => "sed -i.bak -e 's|kill -9 %p|$maintenance['oom_action_script'] %p|g' /usr/lib/hbase/bin/hbase",
      path    => ["/usr/bin", "/usr/sbin", "/bin"],
      onlyif  => 'grep -q "kill -9 %p" /usr/lib/hbase/bin/hbase'
    }
  }
}