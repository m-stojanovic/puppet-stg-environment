class hadoop::roles::flinkmanager(
  $configuration_files,
) {

  motd::register { 'hadoop::roles::flinkmanager': }

  include 'hadoop'
  require 'hadoop::config'

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
