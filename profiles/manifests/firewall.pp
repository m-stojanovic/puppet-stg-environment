class profiles::firewall{

  motd::register{ 'profiles::firewall': }

  # initiate FW module and purge existing rules
  include 'firewall'
  resources { 'firewall':
    purge => true,
  }

  # Find rules for ipv4 and ipv6 stacks
  $chainsipv4 = lookup("profiles::firewall::chainipv4", "default_value" => "empty")
  $rulesipv4 = lookup("profiles::firewall::rules::ipv4", merge => hash, "default_value" => "empty")
  $chainsipv6 = lookup("profiles::firewall::chainipv6", "default_value" => "empty")
  $rulesipv6 = lookup("profiles::firewall::rules::ipv6", merge => hash, "default_value" => "empty")

  # push ipv4 chanins and rules
  if $chainsipv4 == "empty" {
    notify { "Firewall ipv4 - chain - message":
      message => "No chain rules defined",
    }
  }
  else{

    $chainsipv4.each |$k,$v| {

      firewallchain { "$k:filter:IPv4":
        purge    => true,
        policy => $v,
      }

    }

  }

  if $rulesipv4 == "empty" {
    notify { "Firewall ipv4 - rules - message":
      message => "No rules defined",
    }
  }
  else{

      create_resources('firewall', $rulesipv4)

  }

  # Push ipv6 chains and rules
    if $chainsipv6 == "empty" {
    notify { "Firewall ipv6 - chain -message":
      message => "No chain rules defined",
    }
  }
  else{

    $chainsipv6.each |$k,$v| {

      firewallchain { "$k:filter:IPv6":
        purge    => true,
        policy => $v,
      }

    }

  }

  if $rulesipv6 == "empty" {
    notify { "Firewall ipv6 - rules - message":
      message => "No rules defined",
    }
  }
  else{

      create_resources('firewall', $rulesipv6, { 'provider' => 'ip6tables' })

  }

}

