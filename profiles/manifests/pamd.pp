# Separate pamd profile - allow merging pamd options
class profiles::pamd {

  motd::register { 'pamd': }

  $pamopt = lookup('pam::options', {merge => hash})
  create_resources('pam', $pamopt)

}
