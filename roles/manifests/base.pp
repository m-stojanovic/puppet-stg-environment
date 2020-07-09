class roles::base {

  contain profiles::baseprofile
  contain profiles::collectd
  contain profiles::nrpe
  include profiles::pamd
  include profiles::sysctl
  
  Class['profiles::baseprofile'] -> Class['profiles::collectd'] -> Class['profiles::nrpe']

}