class hadoop::roles::nodemanager(
  $packages,
  $configuration_files,
  $data_mounts,
  $data_mounts_attr,
  $data_mounts_subdirs,
) {

  motd::register { 'hadoop::roles::nodemanager':}

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

  $data_mounts.each |$dm| {
    $mapdirs = concat([""], $data_mounts_subdirs)
    $dirs = $mapdirs.map |$sd| {
      "${dm}/${sd}"
    }

    $dirs.each |$dir| {
      if ! defined(File[$dir]) {
        file { $dir:
          * => $data_mounts_attr,
        }
      }
    }
  }
}
