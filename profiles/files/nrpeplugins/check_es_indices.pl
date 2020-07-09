#!/usr/bin/perl

use warnings;
use strict;
use HTTP::Request::Common;
use LWP;
use JSON;
use Date::Format;
use Data::Dumper;

#my $today = time2str("%Y.%m.%d", time);
my $url = 'https://es100.muc.domeus.com/_cluster/stats';

my $ua = LWP::UserAgent->new;
$ua->ssl_opts(verify_hostname => 0);
my $response = $ua->get($url);
my $res;
if ($response->is_success) {
	$res = from_json($response->decoded_content);  # or whatever
	#die Dumper($res);
} else {
	die $response->status_line;
}

my $health = $res->{status};
my $n_open = $res->{indices}{count};

my $THREDSHOLD_OPEN_INDICES = 16;
my $nagio_ret = -1;
if ($health eq 'red' || $n_open >= $THREDSHOLD_OPEN_INDICES) {
	$nagio_ret = 2;
} elsif ($health eq 'yellow') {
	$nagio_ret = 1;
} else {
	$nagio_ret = 0;
}

if ($nagio_ret == 0) {
	print "STATUS OK - ES cluster health: $health, #opened indices: $n_open.\n";
	exit 0;
} elsif ($nagio_ret == 1) {
	print "STATUS WARNING - ES cluster health: $health, #opened indices: $n_open.\n";
	exit 1;
} elsif ($nagio_ret ==2) {
	print "STATUS CRITICAL - ES cluster health: $health, #opened indices: $n_open (>= $THREDSHOLD_OPEN_INDICES?).\n";
	exit 2;
} else {
	print "STATUS CRITICAL - ES cluster health check failed\n";
	exit 2;
}

