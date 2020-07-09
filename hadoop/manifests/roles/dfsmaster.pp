class hadoop::roles::dfsmaster (
  $packages,
  $configuration_files,
  $files_and_dirs
) {

  motd::register { 'hadoop::roles::dfsmaster': }

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

  $files_and_dirs.each |$n,$a| {
    file { $n:
      * => $a,
    }
  }
}
