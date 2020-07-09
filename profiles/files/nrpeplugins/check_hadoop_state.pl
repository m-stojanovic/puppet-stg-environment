#!/usr/bin/perl -w
# oramge@ecircle 2010-04-22
# mantunov updated 2014, added experimental handlers
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

my $overloads=0;
my $active_send_handlers=0;
my $active_execute_handlers=0;
my $messages_per_min=0;
my $avg_exec_time=0;
my $active_experimental_execute_handlers=0;


my $data=$res->decoded_content;

#$overload=

#print $data;

($overloads) = $data =~ /Overloads: (\d+)/;
($active_send_handlers) = $data =~ /Active Send Handlers: (\d+)/;
($active_execute_handlers) = $data =~ /Active Execute Handlers: (\d+)/;
($messages_per_min) = $data =~ /Operations\/Min: (\d+)/;
($avg_exec_time) = $data =~ /Avg. Exec Time: (\d+)/;
($active_experimental_execute_handlers) = $data =~ /Active Experimental Execute Handlers: (\d+)/;


print "Hadoop state - Overloads: $overloads Active Send Handlers: $active_send_handlers Active Execute Handlers: $active_execute_handlers Messages/Min: $messages_per_min Avg. Exec Time: $avg_exec_time Active Experimental Execute Handlers: $active_experimental_execute_handlers|overloads=$overloads"."c"." active_send_handlers=$active_send_handlers active_execute_handlers=$active_execute_handlers messages_per_min=$messages_per_min avg_exec_time=$avg_exec_time active_experimental_execute_handlers=$active_experimental_execute_handlers\n";

exit(0);
