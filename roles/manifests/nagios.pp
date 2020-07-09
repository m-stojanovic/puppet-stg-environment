class roles::nagios{

  motd::register { 'roles::nagios': }

  include nagios
  
}