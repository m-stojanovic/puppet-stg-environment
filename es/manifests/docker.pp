class es::docker{

  include 'es'
  include 'firewall'
  
  motd::register { 'es::docker': }
  
  # Add pipework for docker images ip adress management
  file { '/sbin/pipework':
    ensure => file,
    source => 'puppet:///modules/es/pipework',
    mode => '0700',
    owner => 'root',
  }
  
  # purge firewall rules and change forwad policy to accept to allow traffic from docker containers.
  resources { 'firewall':
     purge => true,
  }

  firewallchain { 'FORWARD:filter:IPv4':
    purge    => true,
    policy => 'accept',
  }

  $common_es_conf = lookup("es::docker::commonconf", "default_value" => "")

  $es_common_settings = lookup("es::common_settings", "default_value" => [])

  $instances = lookup("es::docker::$hostname", merge => hash)

  $instances.each |$instance, $params| {
  
      motd::register { "$instance": }

      $is_master = $params['is_master']
      $is_node = $params['is_node']
      $data_mounts = $params['d_volumes']
      $auto_create_index = $params['auto_create_index']
      $instance_ip = $params[ 'd_ipaddr' ]
      $instance_subnet = $params['d_subnet']
      $datapath = $params['d_path']
      $heap_size_mb = $params['heapsizemb']
      $gateway = $params['d_gateway']
      $disk_type = $params['disk_type']
      $discovery_zen_ping_timeout = $params['discovery_zen_ping_timeout']
      $allocation_balance_shard = $params['allocation_balance_shard']

      # note: top scope vars from main class
        $confdirs = [
                   "/opt/$instance",
                   "/opt/$instance/etc/","/opt/$instance/limits","/opt/$instance/default"
                   ]

       file { $confdirs:
          ensure  => directory,
          recurse => true,
          owner   => $fs_es_user,
          group   => $fs_es_group,
          mode    => '0755'
       }

       file { "/opt/$instance/etc/elasticsearch.yml":
        ensure  => present,
        content => template ('es/etc/elasticsearch/elasticsearch_docker.yml.erb'),
        owner   => $fs_es_user,
        group   => $fs_es_group,
        mode    => '0755'
      }

       file { "/opt/$instance/etc/jvm.options":
         ensure  => present,
         content => template ('es/etc/elasticsearch/jvm.options.erb'),
         owner   => $fs_es_user,
         group   => $fs_es_group,
         mode    => '0755'
       }

       file { "/opt/$instance/etc/log4j2.properties":
         ensure  => present,
         content => template ('es/etc/elasticsearch/log4j2.properties'),
         owner   => $fs_es_user,
         group   => $fs_es_group,
         mode    => '0755'
       }

       file { "/opt/$instance/limits/10-elasticsearch.conf":
         ensure  => present,
         content => template ('es/etc/security/limits.d/10-elasticsearch.conf.erb'),
         owner   => root,
         group   => root,
         mode    => '0755'
       }
       
       file { "/opt/$instance/default/elasticsearch":
         ensure  => present,
         content => template ('es/default/elasticsearch'),
         owner   => root,
         group   => root,
         mode    => '0755'
       }
       
       docker::run { "$hostname-$instance":
         image                  => $params['d_image'],
         volumes                => ["/opt/$instance/limits/10-elasticsearch.conf:/etc/security/limits.d/10-elasticsearch.conf","/opt/$instance/etc:/etc/elasticsearch", "/opt/$instance/default/elasticsearch:/etc/default/elasticsearch" , $params['d_volumes'] ],
         net                    => $es::network_mode,
         restart_service        => false,
         privileged             => true,
         pull_on_start          => true,
         hostname               => "$hostname-$instance",
         extra_parameters       => [ '--cap-add=NET_ADMIN','--cap-add=IPC_LOCK','--ulimit memlock=-1:-1' ],
         health_check_interval  => 10,
       }
       
       if $es::network_mode == 'bridge' {
       exec { "$instance-networking":
         command => "/bin/sleep 10 && /sbin/pipework extbr0 $hostname-$instance $instance_ip/$instance_subnet@$gateway",
         returns => [ 0,10 ],
         require => [ Docker::Run["$hostname-$instance"], File['/sbin/pipework'] ],
       }

       es::docker::pipework{ "$hostname-$instance":
         interface => 'extbr0',
         ipaddress => $instance_ip,
         mask      => $instance_subnet,
         gateway   => $gateway,
       }
     }
  }
}
