class hadoop::install (
  $java_version,
  $common_packages,
){

  include 'hadoop'
  require 'java'

  $common_packages.each |$n,$a| {
    if ! defined(Package[$n]) {
      package { $n:
        * => $a,
      }

      apt::pin { $n:
        packages => $n,
        version  => $a['ensure'],
        priority => '1001',
      }
    }
  }
}
