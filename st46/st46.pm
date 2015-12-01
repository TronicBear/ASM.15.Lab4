
package ST46;
use  strict;
use LWP::UserAgent;
use Encode qw(encode decode);

my %flat;

my @func =
(
	\&add,
	\&edit,
	\&delete,
	\&show,
	\&write,
	\&read,
	\&sendtoadd,
);

sub st46 {
while(1)
{
print "\nEnter the num:\n";
print 
"1.Add  
2.Edit 
3.Delete  
4.Show
5.Write to file
6.Read from file 
7.Sendtoadd
8.Exit\n";

	my $ch = <STDIN>;
	if(defined $func[$ch-1])
	{ 
		$func[$ch-1]->();
	}
	else
	{
		return;
		
	}
}
}


sub add {
	print "Enter apartment number\n";
	chomp(my $num = <STDIN>);
	if (!exists $flat{$num}) 
	{
		print "Enter number of people\n";
		chomp(my $men = <STDIN>);
		print "Enter number of rooms\n";
		chomp(my $room = <STDIN>);
		print "Enter secondname family\n";
		chomp(my $secondname = <STDIN>);
		$flat{$num}={Men => $men, Room => $room, Secondname => $secondname};
		print "added\n";
		} 
		else {
		print "!Flat with this number already exists!\n";
	}
}

sub edit {
	show();
	print "Enter apartment number\n";
	chomp(my $num = <STDIN>);
	if (exists $flat{$num})
	{ 
		foreach my $val (sort keys %{$flat{$num}} )
		{
		print "$val: ";
		chomp(my $i=<STDIN>);
		$flat{$num}->{$val}=$i;
		};
		print "changed\n";
		} 
		else {
		print "No apartment with this number\n";
	}
}

 sub show {
	foreach my $num (sort {$a<=>$b} keys %flat )
	{ 
		print "apartment number: $num \n";
		foreach my $val (sort keys %{$flat{$num}})
		{
		print "$val: $flat{$num}->{$val}\n";
		}
	}
 }

sub delete {
	show();
	print "Enter apartment number\n";
	chomp(my $n = <STDIN>);
	if (exists $flat{$n})
	{
		delete $flat{$n};
		print "Deleted\n";
		}else {
		print "No apartment with this number\n";
	}
}


 sub write
 {
	dbmopen(my %hash, "dbm", 0644);
	%hash=();
	foreach my $num(keys %flat)
	{	
		$hash{$num}=join("<>", $flat{$num}->{Men},$flat{$num}->{Room},$flat{$num}->{Secondname});
	}
	dbmclose(%hash);
	print "written\n";
 }

 sub read
 {
	dbmopen(my %hash, "dbm", 0644);
	%flat=();
	while ((my $num,my $value) = each(%hash))
	{
	my @val=split(/<>/,$hash{$num});
	$flat{$num}={Men => "$val[0]", Room => "$val[1]",Secondname => "$val[2]"};
	}
	dbmclose(%hash);
	print "read\n";
 }
 
 sub symbols{
	my ($str) = @_;
	$str =~ s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
	return $str;
}

sub encode{
	my ($str) = @_;
	Encode::from_to($str, 'cp866', 'cp1251');
	symbols($str);
	return $str;
}
sub sendtoadd{
	my $url = "http://ASM.15.Lab3/lab3.cgi";
	my $note = LWP::UserAgent->new;

		foreach my $num(keys %flat)
		{
			$note->post($url, 
			{
			'student' => 46,
			'number' => $num,
			'men' => encode($flat{$num}->{Men}),
			'room' => encode($flat{$num}->{Room}),
			'secondname' => encode($flat{$num}->{Secondname}),
			'act' => 'add'
			});
		}
		print "\send";
}

 return 1;