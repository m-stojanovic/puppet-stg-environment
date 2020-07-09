class profiles::collectd {

  motd::register { 'profiles::collectd': }

  class { 'collectd':
    require => Class['apt'],
  }

  # location for custom collectd scripts / plugins
  file { '/usr/lib/collectd/custom_plugins':
    ensure  => directory,
    recurse => true,
    purge => false,
    mode    => '0755',
    source  => 'puppet:///modules/profiles/collectdplugins',
  }
  
  # Put script templates 
  $scripts = lookup('collectd::plugin::python::script_templates', undef, unique, "")
  
  if $scripts {
  
    $scripts.each |$template| {
      file { "/usr/lib/collectd/custom_plugins/${template}":
        ensure => file,
        content => template("profiles/collectdplugins/${template}.erb"),
      }
    }
  
  }

  # Include plugins 
  lookup('collectd_plugins', Array, unique, []).include

  # processes resources
  $processes = lookup('collectd::plugin::processes::process', Hash, hash, {})
  if $processes {
    create_resources('collectd::plugin::processes::process', $processes)
  }
  
  # processes match resources
  $processes_match = lookup('collectd::plugin::processes::processmatch', Hash, hash, {})
  if $processes_match {
    create_resources('collectd::plugin::processes::processmatch', $processes_match)
  }

  # Create mbean resources
  $mbean = lookup('collectd::plugin::genericjmx::mbean', Hash, hash, {})
  if $mbean {
    create_resources('collectd::plugin::genericjmx::mbean', $mbean)
  }
  
  # Create jmx connection resources
  $jmxconnection = lookup('collectd::plugin::genericjmx::connection', Hash, hash, {})
  if $jmxconnection {
    create_resources('collectd::plugin::genericjmx::connection', $jmxconnection)
  }

  # curl_json resources
  $curl_json = lookup('collectd::plugin::curl_json', Hash, hash, {})
  if $curl_json {
    create_resources('collectd::plugin::curl_json', $curl_json)
  }
  
  # Custom types
  $typesdb = lookup('collectd::typesdb', undef, undef, "")
  if $typesdb {
    $typesdb.each |$db| {
      collectd::typesdb { $db: }
    }

    $ctypes = lookup('collectd::type', Hash, hash, {})
    if $ctypes {
      create_resources('collectd::type', $ctypes)
    }
  }
  
}
