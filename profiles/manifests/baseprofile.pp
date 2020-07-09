class profiles::baseprofile(
  $files_upload = undef,
  $ntp_servers_list,
  $packages,
  $timezone,
  $ssh_keys,
  #$dns,
) {

  include 'apt'
  include 'motd'
  include 'sudo'
  include 'limits'
  include 'cron'
  include 'puppet_agent'
  
  create_resources('ssh_authorized_key', $ssh_keys)

  motd::register{ 'profiles::baseprofile': }
  
  # Package wrapper - installs particular version of package
  # place pin if defined.
  
  $packages.each |$k,$v| {
    package{ $k:
      ensure => $v['version'],
      install_options => ['-f'],
    }

    if $v['pin'] == true {

      apt::pin { $k:
        packages => $k,
        version  => $v['version'],
        priority => '1001',
      }
    }

  }
  
  class { 'ntp':
    servers => $ntp_servers_list,
  }
  
  class { 'timezone':
    timezone => $timezone,
  }
  
  file { ['/etc/profile.d/Z00-ds-apz.sh','/etc/profile.d/Z00-hadoop-zookeeper.sh','/etc/profile.d/Z00-ds-queue.sh','/etc/nagios/puppet_nrpe.d','/etc/profile.d/Z01-hadoop-common.sh','/etc/profile.d/Z00-ds-api.sh','/etc/profile.d/Z00-storm-master.sh','/etc/profile.d/Z00-storm-slave.sh','/etc/profile.d/Z00-hadoop-slave.sh']:
    ensure => absent,
    force  => true,
  }
  
  # Create list of hosts entries from puppetdb
  # Two quesries exists as /^dsapi/ hosts has to point to eth1 interface placed in DMZ
 
  $query = "facts{name in ['ipaddress_eth0','ipaddress_bond0','ipaddress_eno1','ipaddress_extbr0'] and ! (certname ~ '^dsapi' or certname ~ '^mp13dsapi') and environment = \'$agent_specified_environment\' order by certname asc}"
  $query_dmz = "facts{name in ['ipaddress_eth1','ipaddress_bond0'] and (certname ~ '^dsapi' or certname ~ '^mp13dsapi') and environment = \'$agent_specified_environment\' order by certname asc}"
  $ips = puppetdb_query($query)
  $ips_dmz = puppetdb_query($query_dmz)

  file { '/etc/hosts':
    ensure => file,
    content => template("profiles/hosts.erb"),
  }
  
  # temporaruly hashed - working on template code
  # Manage common name resolution settings
  # file { '/etc/resolv.conf':
  #    ensure => file,
  #  content => template("profiles/resolv.conf.erb"),
  #}


  # Adding custom profiles/bash.bashrc 
  case $agent_specified_environment {
    'bigdatal3':           { $ps_color = '32'; $location = "L3" }
    'bigdatastg':          { $ps_color = '37'; $location = "STG" }
    'bigdataemc':           { $ps_color = '36'; $location = "EMC" }
    'bigdata_bigdatacroc':           { $ps_color = '34'; $location = "CROC" }
    'forge':           { $ps_color = '33'; $location = "FORGE" }
    'monitoring':           { $ps_color = '31'; $location = "MON" }
    'bigdatalab':      { $ps_color = '35'; $location = "LAB" }
  }
  
  file { '/etc/bash.bashrc':
    ensure => file,
    content => template("profiles/bash.bashrc.erb"),
  }

  if $files_upload {
    $files_upload.each |$fn,$opts| {
      if ! defined(File[$fn]) {
        file { "${fn}":
          ensure => file,
          content => file("${module_name}/baseprofile/${fn}"),
          * => $opts,
        }
      }
    }
  }

}
