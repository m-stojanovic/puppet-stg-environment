class reporting(
  $reportroot,
) {

  # Standard root location for any report scripts 
  file { $reportroot:
    ensure => directory,
  }

}
