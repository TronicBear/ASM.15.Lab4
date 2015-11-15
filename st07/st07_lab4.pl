#!/usr/bin/perl

use strict;
use Encode;
use LWP::UserAgent;
use Data::Dump qw(dump);
my $ua = LWP::UserAgent->new();

my @MainList = ();

sub hex_encode {
	my ($result) = @_;
	Encode::from_to($result,'cp866','cp1251');
	$result =~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
	return $result;
}

sub show_man {
	my $man = $_[0];
	print "  Name: ".$man->{'name'}."\n  Surename: ".$man->{'surename'}."\n";
};
sub get_data {
	my @str = $_[0];
	my $null = $_[1]; #можно ли ничего не ввести
	print @str;
	my $get;
	while ( 1 ){
		$get = <STDIN>;
		chomp $get;	
		if (!$null || ( $get ne "" ) ){
			last;
		} else {
			print "You can't enter nothing \n";
			print @str;
		}
	};
	return $get;
};

sub add {
	my $name = ( get_data "Enter the name: " );	
	my $surename = ( get_data "Enter the surename: " );	
	if ( ( $name ne "" ) && ( $surename ne "") ){
		push @MainList, { name => $name, surename => $surename };
	}
};
sub edit {
	my $number = ( get_data "Enter the number of element: " );	
	if ($number > 0 && $number <= @MainList.length) {
		$number --;
		show_man $MainList[$number];
		my $val = ( get_data "Press \"Enter\" or enter new name: " );	
		if ($val){
			$MainList[$number]{'name'} = $val;
		};
		my $val = ( get_data "Press \"Enter\" or enter new surename: " );	
		if ($val){
			$MainList[$number]{'surename'} = $val;
		};
	} else {
		printf "Element does not exist \n";		
	}
};
sub delete {
	my $number = ( get_data "Enter the number of element: " );	
	if ($number > 0 && $number <= @MainList.length) {
		$number --;
		show_man $MainList[$number];
		splice(@MainList, $number, 1);
	} else {
		printf "Element does not exist \n";		
	}
};
sub show {
	if (@MainList.length == 0){
		printf "List is empty \n";	
	} else {
		while ((my $key, my $value) = each @MainList){
			my $num = $key+1;
			print $num.") \n";
			show_man $value;
		};
	}
};
sub save {
	my $file = ( get_data "Enter the filename: " );	
	if ( $file ne "" ){
		my %h;
		dbmopen(%h, $file, 0644);
		my $i = 0;
		while ((my $key, my $value) = each @MainList){
			$h{$i} = $value->{'name'};
			$h{$i+1} = $value->{'surename'};
			$i+=2;
		};
		dbmclose(%h);
	}
};
sub load {
	my $file = ( get_data "Enter the filename: " );	
	if ( $file ne "" ){
		my %h;
		dbmopen(%h, $file, 0644);
		@MainList = ();
		for ( my $i = 0 ; ; $i += 2 ){
			if (exists($h{$i})){
				push @MainList, {name => $h{$i}, surename => $h{$i+1}};
			} else {
				last;
			}
		}
		dbmclose(%h);
	}
};
sub send_list_to_server {
	if (@MainList.length == 0){
		printf "List is empty \n";	
	} else {
		while ((my $key, my $value) = each @MainList){	
			$ua->post( 
				"http://ASM.15.Lab3/lab3.cgi",
				{
					'student' => 2,
					'action' => 0,
					'name' => hex_encode($value->{'name'}),
					'surename' => hex_encode($value->{'surename'})
				}
			);
		};
	}	
};
sub exit {
	last;
};
my @functions = (
	\&add,
	\&edit,
	\&delete,
	\&show,
	\&save,
	\&load,
	\&send_list_to_server,
	\&exit
);

my $menu = "Choose action: \n 1 - add element \n 2 - edit element \n 3 - delete element \n 4 - show list \n 5 - save list to file \n 6 - load list from file \n 7 - send list to server \n 8 - exit \n";

sub st07 {
	my $n;
	while ( 1 )  {
		$n = ( get_data $menu, 1 ); 
		if ($n < 8 && $n > 0) {
			$functions[$n-1]();
		} else {
			print "Invalid command \n";
		}
	}
};

st07();