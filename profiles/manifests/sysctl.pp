# Separate sysctl profile to allow merging per env.
class profiles::sysctl {

  motd::register{ 'profiles::sysctl': }

  $sysctlent = lookup('sysctl::entries', {merge => hash})
  create_resources('sysctl', $sysctlent)

}


