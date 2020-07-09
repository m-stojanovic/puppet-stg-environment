# this module is screwed up for purpose.

class motd (
  $motd = '/etc/motd',
) {

  concat { $motd:
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }
  
  #$i = motd::random(10)

  case $agent_specified_environment {
    'bigdatal3','bigdataemc','bigdatacroc': {
      concat::fragment{ 'motd_header':
        target  => $motd,
        content => template("motd/motd0.erb"),
        order   => '01'
      }
    }
    'forge': {
      concat::fragment{ 'motd_header':
        target  => $motd,
        content => template("motd/motd1.erb"),
        order   => '01'
      }      
    }
     'bigdatalab': {
      concat::fragment{ 'motd_header':
        target  => $motd,
        content => template("motd/motd2.erb"),
        order   => '01'
      }
    }
     'monitoring': {
      concat::fragment{ 'motd_header':
        target  => $motd,
        content => template("motd/motd3.erb"),
        order   => '01'
      }   
    }
  }
  
  concat::fragment{ 'motd_header_modules':
    target  => $motd,
    content => "Puppet profiles and modules on this server:\n",
    order   => '02'
  }

  concat::fragment{ 'motd_end':
    target  => $motd,
    content => "-------------------------------------------------------------------------------\n",
    order   => '99'
  }
}

