#!/usr/local/bin/perl

use strict;
use v5.10.1;
use LWP::UserAgent;
use Encode qw(encode decode);

my $menu="\n1.Add book\n2.Show all books\n3.Delete book\n4.Edit book\n5.Save file\n6.Read file\n7. Send\n8.Exit\n";
my @functions = (\&add, \&show, \&delete, \&edit, \&save, \&read, \&send, \&exit);
my @books;


	print "st43:st43\n";
	while (1){
		
		print "$menu";
		chomp (my $selection=<STDIN>); 
		if (($selection>0)&&($selection<9))
		{
			$functions[$selection-1]->();
		}
		else
		{
			print "Try another selection\n"
		}
	}


sub add{
	print "Enter book name\n";
	chomp (my $bookname=<STDIN>);
	print "Enter publishing year\n";
	chomp (my $publishYear=<STDIN>);
	print "Enter publishing house\n";
	chomp (my $publishHouse=<STDIN>);
	my %Tem=(BOOKNAME => $bookname,PUBLISHYEAR => $publishYear,PUBLISHHOUSE => $publishHouse);
	push (@books, \%Tem);
	#print $books[0];
	
}

sub show{
	if (@books){
		my $arrayBooks=@books;
		for (my $i=0; $i<$arrayBooks; $i++)
		{
			my $k=$i+1;
			print $k.". ".$books[$i]->{BOOKNAME}."; ".$books[$i]->{PUBLISHYEAR}."; ".$books[$i]->{PUBLISHHOUSE}.".\n";
		}
	}
	else 
	{
		print "There isn't books yet\n";
	}
}

sub delete{
	if (@books){
		print "\nSelect number of book, that you need to delete\n";
		$functions[1]->();
		chomp (my $num = <STDIN>); 
		splice(@books,$num-1,1);
		print "\nNow your list is:\n";
		$functions[1]->();
		}
	else 
	{
		print "Nothing to delete";
	}
}

sub edit{
	if (@books){
		print "\nSelect number of book, that you need to edit\n";
		$functions[1]->();
		chomp (my $num1 = <STDIN>); 
		print "\nSelect property, that you need to edit\n1. Book name\n2. Publishing year\n3. Publishing house\n";
		chomp (my $num2 = <STDIN>);
		given ($num2){
			when (1){
				print "Print new book name\n";
				chomp (my $prop = <STDIN>);
				$books[$num1-1]->{BOOKNAME}=$prop;
			}
			when (2){
				print "Print new publishing year\n";
				chomp (my $prop = <STDIN>);
				$books[$num1-1]->{PUBLISHYEAR}=$prop;
			}
			when (3){
				print "Print new publishing house\n";
				chomp (my $prop = <STDIN>);
				$books[$num1-1]->{PUBLISHHOUSE}=$prop;
			}
		}
		print "\nNow your list is:\n";
		$functions[1]->();
		}
	else 
	{
		print "Nothing to edit";
	}
}

sub save{
	my %dbhash=();
	dbmopen(%dbhash, "file", 0666);
	my $arrayBooks=@books;
		for (my $i=0; $i<$arrayBooks; $i++)
		{
			$dbhash{$i}= join (";",$books[$i]->{BOOKNAME},$books[$i]->{PUBLISHYEAR},$books[$i]->{PUBLISHHOUSE});
		}
		dbmclose %dbhash;
	print "\nDone\n";
}

sub read{
	@books=();
	my %dbhash=();
	dbmopen(%dbhash,"file",0666);
	foreach my $key (keys %dbhash)
	{
		my @a = split(/;/,$dbhash{$key});
		my $bookname = $a[0];
		my $publishYear = $a[1];
		my $publishHouse=$a[2];
		my %Tem=(BOOKNAME => $bookname,PUBLISHYEAR => $publishYear,PUBLISHHOUSE => $publishHouse);
		push (@books, \%Tem);
	}
	dbmclose %dbhash;
	print "\nDone\n";
}
sub exit{
	last;
}

sub StrEscaped{
	my ($str) = @_;
	$str = ~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
	return $str;
}

sub encode{
	my ($str) = @_;
	Encode::from_to($str, 'cp866', 'cp1251');
	StrEscaped($str);
	return $str;
}

sub send{
	my $url = "http://localhost/cgi-bin/lab3.cgi";
	my $ua = LWP::UserAgent->new;
	if (@books)
	{
		for (my $i = 0; $i < @books; $i++)
		{
			$ua->post($url, 
			{
			'student' => 1,
			'Bookname' => encode($books[$i]->{BOOKNAME}),
			'publishYear' => encode($books[$i]->{PUBLISHYEAR}),
			'publishHouse' => encode($books[$i]->{PUBLISHHOUSE}),
			'Action' => 'Add'
			});
		}
		print "\nData has been sent";
	}
	else {print "\nThe list is empty\n";}
}




