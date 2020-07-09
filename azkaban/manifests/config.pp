class azkaban::config(
  $projects,
) {

  include 'dsglobals'

  $projects.each |$project,$components| {

    motd::register{"azkaban::flow::$project":}

    # Lnstall project jobs and upload them to azkaban.
    # Only package installation triggers upload (by notifying defined type).
    
    # variable holding list of packages containing jobs - to keep list of packages which will later be required by conf files.
    $packages = [ $components['jobs'].keys.map |$package| { $package } ]
    
    $components['jobs'].each |$p,$v| {

      package{ $p:
        ensure => $v,
        notify => Azkaban::Upload[$project],
      }

    }

    # loop through configurations - place files
    $components['configuration'].each |$flow,$conf| {

      if $conf['package_name'] {
        package{ $conf['package_name']:
          ensure => $conf['package_version'],
        }
      }

      if $conf['files'] {
        
        $conf['files'].each |$file,$p| {
          file{$file:
            ensure => file,
            content => template("${module_name}${file}"),
            require => Package[ $conf['package_name'], $packages ],
            notify => Azkaban::Upload[$project],
          }
        }
        
      }
      
      # templates - for config files that needs to keep specific formatting in file
      if $conf['templates'] {
      
        $conf['templates'].each |$templ, $vars| {
        
          file { $templ:
            ensure => file,
            content => template("${module_name}${templ}"),
            require => Package[ $conf['package_name'], $packages ],
            notify => Azkaban::Upload[$project],
          }
        
        }
      
      }

      # if schedule is not empty schedule application.
      # In order to connect change of schedule file containing schedule span is created.
      # Schedule action notifies defined schedule type on file change.
      if $conf['schedule'] {

        file { "${azkaban::schedulefolder}/${flow}_schedule":
          ensure => file,
          content => $conf['schedule'],
          notify => Azkaban::Schedule[$flow],
        }

      } 

      azkaban::schedule{ $flow:
        project => $project,
        flow => $flow,
        span => $conf['schedule'],
      }

    } 

    azkaban::upload{ $project:
      project => $project,
    }

  } 
    
}
