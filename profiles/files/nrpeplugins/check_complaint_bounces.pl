#!/usr/bin/perl

use warnings;
use strict;
use HTTP::Request::Common;
use LWP;
use JSON;
use Date::Format;
use Data::Dumper;

my $today = time2str("%Y.%m.%d", time, 'UTC');
my $url = 'https://es100.muc.domeus.com/logstash-' . $today . '/_count?size=1&pretty';

#print $url . "\n";
#print query_count_complaints() . "\n";

my $ua = LWP::UserAgent->new;
$ua->ssl_opts(verify_hostname => 0);
my $response = $ua->post($url, Content => query_count_complaints());
my $complaints_count;
if ($response->is_success) {
	my $res = from_json($response->decoded_content);  # or whatever
	$complaints_count = $res->{count};
	#warn Dumper($res);
} else {
	die $response->status_line;
}

use constant THREDSHOLD => 1000;
if ($complaints_count > THREDSHOLD) {
	print "STATUS OK - there are $complaints_count complaint bounces so far today.\n";
	exit 0;
} else {
	print "STATUS CRITICAL - there are too few ($complaints_count) complaint bounces so far today.\n";
	exit 2;
}


sub query_count_complaints {
	#my $cluster = shift;
	my $q =  {
	    query => {
		filtered => {
		    query => {
			query_string => {
			    query => "COMPLAINT"
			}
		    },
		    filter => {
			bool => {
				must => [
					{term => { type => "dmc"}},
					{term => { "logger_name" => "REPORT_BOUNCE"}},
					#{term => { "colocation.raw"  => $cluster }}
				]
			}
		    }
		}
	    }
	};

	return to_json($q);
}

