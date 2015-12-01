#!"usr\bin\perl.exe"

use strict;
use feature qw(say switch);
use LWP::UserAgent;
use Encode qw(encode decode);


sub encode_str
{
	my ($str) = @_;
	Encode::from_to($str, 'cp866', 'cp1251');
	$str =~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
	return $str;
}


my $f_input;
	
my @tracklist;
my $menu = "\nMenu:\n1. Add new song\n2. Change song info\n3. Delete song\n4. Show tracklist\n5. Save tracklist\n6. Load tracklist\n7. Send to the server\n8. Exit\n";


my $f_new = sub {
my $performer = &$f_input("the performer");
my $song = &$f_input("the song name");
push @tracklist, {performer => $performer, song => $song};
say;
};
	
$f_input = sub {
my ($obj,$skip) = @_;
my $in;
print $skip;
do {
	print "Waiting for input - $obj: ";
	$in = <STDIN>;
	chomp($in); } 
until (($skip) || !($in eq ''));
return $in;
};

my $f_delete = sub {
my $index = &$f_input("the index number of the song")-1;
if ($tracklist[$index]) {
splice(@tracklist,$index,1);
} else {
	say "Choose from existing songs";
}
};

my $f_change = sub {
my $index = &$f_input("the index number of the song")-1;
if ($tracklist[$index]) {
	$tracklist[$index]->{performer} = $_  if $_ = &$f_input("change the performer or skip", 1);
	$tracklist[$index]->{song} = $_  if $_ = &$f_input("change the song name or skip", 1);
} else {
	say "Choose from existing songs";
}
};

my $f_save = sub {
my $n = @tracklist;
if ($n != 0) {
	my $trackfile = &$f_input("the filename");
	dbmopen(my %hash,$trackfile,0666) || die "Can't open file!\n";
	%hash = ();
	for (my $i=0;$i<$n;$i++){
		$hash{$i} = join("__",$tracklist[$i]->{performer},$tracklist[$i]->{song}); };
	dbmclose (%hash);
} else {
	say "No songs in tracklist";
}
};

my $f_load = sub {
@tracklist = ();
my $trackfile = &$f_input("the filename");
if (-e "$trackfile.pag" && -e "$trackfile.dir") {
	dbmopen(my %hash,$trackfile,0666) || die "Can't open file!\n";
	foreach my $k (sort keys %hash) {
		my @v = split(/__/,$hash{$k});
		$tracklist[$k]->{performer}=$v[0];
		$tracklist[$k]->{song}=$v[1];}
	dbmclose (%hash);
} else {
	say "No file with this name";
}
};

my $f_show = sub {
my $n = @tracklist;
if ($n != 0) {
	for (my $i=0;$i<$n;$i++) {
	say "".($i+1).') "'.$tracklist[$i]->{song}.'", performed by '.$tracklist[$i]->{performer}; };
} else {
	say "No songs in tracklist";
}
};



my $f_server = sub {
my $n = @tracklist;

my $browser = LWP::UserAgent->new;
my $url = "http://cgi-bin/lab3/lab3.cgi";


if ($n!= 0)
{
	for (my $i=0; $i<$n; $i++)
	{
		$browser->post( $url,
					   {
						'performer' => encode_str($tracklist[$i]->{performer}),
						'song' => encode_str($tracklist[$i]->{song}),
						'action' => 'send',
						'student' => 10
					   }
						);
		

	}
	print "Sent to the server.\n";
}
else
{
	say "No songs in tracklist";
}
};


my @menu = ( $f_new, $f_change, $f_delete, $f_show, $f_save, $f_load, $f_server, sub {last;});

my $in;


	while (1) {
	say $menu;
	$in = (&$f_input("action number"))-1;
	
	unless (!$menu[$in]) {
	&{$menu[$in]};}
	else {
	say "Choose from existing";}
} 


1;
