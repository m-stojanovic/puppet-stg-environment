class hadoop::roles::hadoopclient(
  $packages,
  $configuration_files,
) {

  motd::register { 'hadoop::roles::hadoopclient': }

  include 'hadoop'
  require 'hadoop::config'
  
  $packages.each |$n,$a| {
    if ! defined(Package[$n]) {
      package { $n:
        * => $a,
      }
    }
  }

  $configuration_files.each |$t,$c| {
    $c.each |$n,$a| {
      if ! defined(File[$n]) {
        file { $n:
          ensure => 'present',
          content => template("${module_name}${n}.erb"),
          * => $a,
        }
      }
    }
  }
}