#!/usr/bin/perl

use warnings;
use strict;
use Redis;
use Date::Format;
use Data::Dumper;

my $nagios_ret = -1;
my $nagios_str = '';
my $THREDSHOLD_LLEN_LOGSTASH = 1000;
my $llen = 0;
my $redis = eval {Redis->new;}; # localhost:6379
if ($@) {
	$nagios_ret = 2;
	$nagios_str = "Could not connect to Redis server";
} elsif (! $redis->ping) {
	$nagios_ret = 2;
	$nagios_str = "Could not ping Redis server";
} elsif (($llen=$redis->llen('logstash')) >= $THREDSHOLD_LLEN_LOGSTASH) {
	$nagios_ret = 2;
	$nagios_str = "There are too many logstash events in Redis list (queue) 'logstash'";
} else {
	$nagios_ret = 0;
}

if ($nagios_ret == 0) {
	print "STATUS OK - There are $llen logstash events in Redis list (queue) 'logstash'.\n";
	exit 0;
} elsif ($nagios_ret ==2) {
	print "STATUS CRITICAL - $nagios_str.\n";
	exit 2;
} else {
	print "STATUS CRITICAL - Redis server check failed\n";
	exit 2;
}

