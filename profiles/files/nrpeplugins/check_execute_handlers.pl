#!/usr/bin/perl -w
# mantunov 2014-10-06
require HTTP::Request;
use strict;
use Getopt::Long;


my $host = "localhost";

sub check_options {
        Getopt::Long::Configure("bundling");
        GetOptions( 'H:s' => \$host, 'hostname:s' => \$host );
}

## Main ##

check_options();

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->agent("Nagios\@eCircle");


my $req = new HTTP::Request("GET",'http://' . $host . ':8085/ecmdas/state/state');
$req->header('Accept' => 'text/html');

# send request
my $res = $ua->request($req);

# check the outcome
if ($res->is_success) {
#  print $res->decoded_content;
}
 else {
    print "Error: " . $res->status_line . "\n";
 }

my $active_execute_handlers=0;
my $active_experimental_execute_handlers=0;

# Nagios treshlods
my $status=0;
my $exec_warn_treshold=40;
my $exec_crit_treshold=55;
my $exper_warn_treshold=5;
my $exper_crit_treshold=8;

my $data=$res->decoded_content;

# Extract execute part
($active_execute_handlers) = $data =~ /Active Execute Handlers: (\d+)/;
($active_experimental_execute_handlers) = $data =~ /Active Experimental Execute Handlers: (\d+)/;

$status = 1 if $active_execute_handlers >= $exec_warn_treshold || $active_experimental_execute_handlers >= $exper_warn_treshold;
$status = 2 if $active_execute_handlers >= $exec_crit_treshold || $active_experimental_execute_handlers >= $exper_crit_treshold;

# Nagios alarms
my $exit_status="UNKNOWN";
$exit_status="OK" if $status==0;
$exit_status="WARNING" if $status==1;
$exit_status="CRITICAL" if $status==2;
$exit_status="$exit_status";
print "$exit_status: Active Execute Handlers: $active_execute_handlers Active Experimental Execute Handlers: $active_experimental_execute_handlers\n";
print "\n";
exit $status;
