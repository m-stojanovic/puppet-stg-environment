class profiles::nrpe(
  $checks = {"undef"=>{"ensure"=>undef, "command"=>undef, "sudo"=>undef},},
) {

  motd::register { 'profiles::nrpe': }

  class { 'nrpe': }

  file { '/usr/local/scripts':
    ensure => directory,
  }
  ->
  file { '/usr/lib/nagios/plugins':
    ensure  => directory,
    recurse => true,
    purge => false,
    mode    => '0755',
    source  => 'puppet:///modules/profiles/nrpeplugins',
  }

  create_resources('nrpe::command', $checks)

}

