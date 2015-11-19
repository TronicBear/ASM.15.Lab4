#!"D:\Progs\Perl64\bin\perl.exe"

use strict;
no warnings qw( experimental::autoderef ); 
use LWP::UserAgent;
use HTML::Entities;
use Encode qw(encode decode);


sub get_input
{
	my $input = undef;
	while (1) 
		{
		$input = <STDIN>;
		chomp($input);
		$input =~ /^$/ ? next: last;
		}
	return $input;
}

sub add
{
	my ($libref) = @_;
	print "Enter the name of the book...";
	my $name = get_input;
	print "Enter the author's second name...";
	my $author = get_input;
	print "Enter the year of publication...";
	my $year = get_input;
	my $new_record = {Name => $name, Author => $author, Year => $year};
	push @$libref,$new_record;
}


sub to_screen
{
	my ($libref) = @_;
	my $n_records = @$libref;
	
	if (@$libref != ())
	{
		for (my $i=0; $i<$n_records; $i++)
		{
		print (($i+1).'. ');
			for my $k (sort keys %$libref[$i])
			{
				my $v = $$libref[$i]{$k};
				print "$k: $v\n";
			}
			print "\n";
	
		}
	}
	else
	{
		print "Library is empty!\n";
	}
}

sub choose_book
{
	my ($libref) = @_;
	print "Enter the number of the book record...";
	my $record = get_input;
	print "\n";
	
	if (!(%$libref[$record-1]))
	{
		print "No such record number: $record\n";
		return -1;
	}
	return $record-1;
}

sub edit
{
	my ($libref) = @_;
	my $record = choose_book($libref);
	return if ($record == -1);
	
	print "Write new field value or '-' if value remains unchanged:\n";
	for my $k (sort keys %$libref[$record])
	{
		my $v = $$libref[$record]{$k};
		print "$k (current value '$v')...";
		$v = get_input;
		$v ne "-" ? $$libref[$record]{$k} = $v : next;
	}	
	print "Successfully edited!\n";
}

sub delete_book
{
	my ($libref) = @_;
	my $record = choose_book($libref);
	return if ($record == -1);
	splice(@$libref,$record,1);
	print "Book has been deleted from library.\n";
}

sub to_file
{
	my ($libref) = @_;
	my $n_records = @$libref;
	do {print "Library is empty!\n"; return;} if ($n_records == 0);
	
	print "Enter the name of file: ";
	my $file = get_input;
	dbmopen(my %dbm_hash,$file,0666) || die "Can't open dbm-file for writing!\n";
	%dbm_hash = ();
	for (my $i=0; $i<$n_records; $i++)
	{
		$dbm_hash{$i} = join("::",$$libref[$i]{Name},$$libref[$i]{Author}, $$libref[$i]{Year});
	}
	dbmclose (%dbm_hash);
	print "Library has been written to the file.\n";
	
}

sub from_file
{
	my ($libref) = @_;
	@$libref = ();	
	print "Enter the name of file: ";
	my $file = get_input;
	if (!(-e "$file.pag"))
	{
		print "No such file: $file\n";
		return;
	}
	dbmopen(my %dbm_hash,$file,0666) || die "Can't open dbm-file for reading!\n";
	my $i = 0;
	while ( (my $k,my $v) = each %dbm_hash) 
	{
		my @values = split(/::/,$v);
		$$libref[$i]{Name}=$values[0];
		$$libref[$i]{Author}=$values[1];
		$$libref[$i]{Year}=$values[2];
		$i++;
	}

	dbmclose (%dbm_hash);
	print "Library has been read from the file.\n";
}


sub encode_for_html
{
	my ($str) = @_;
	$str = encode_entities($str);
	Encode::from_to($str, 'cp866', 'cp1251');
	return $str;
}

sub to_server
{
	my ($libref) = @_;
	my $browser = LWP::UserAgent->new;
	my $url = "http://ASM.15.Lab3/lab3.cgi";
	
	my $n_records = @$libref;
	
	if (@$libref != ())
	{
		for (my $i=0; $i<$n_records; $i++)
		{
			$browser->post( $url,
						   {
						    'name' => encode_for_html($$libref[$i]{Name}),
							'author' => encode_for_html($$libref[$i]{Author}),
							'year' => encode_for_html($$libref[$i]{Year}),
							'action' => 'add_from_client',
							'student' => 2
						   }
							);
			
	
		}
		print "Library has been sent to the server.\n";
	}
	else
	{
		print "Library is empty!\n";
	}

}

my @library;

my %menu = (
	1 => \&add,
	2 => \&edit,
	3 => \&delete_book,
	4 => \&to_screen,
	5 => \&to_file,
	6 => \&from_file,
	7 => \&to_server
);

my $menu_text = "
Choose :
 1 - Add book to library
 2 - Edit record about book
 3 - Delete record about book
 4 - Show library contents on the screen
 5 - Write library to file
 6 - Read library from file
 7 - Send library to server
 8 - Quit\n
";



 my $choice;
 
 print $menu_text;
 while (1)
 {
	
	print "Enter the number of chosen position or 'm' to see the menu...";
	$choice = get_input;
	print "\n";
	if ($menu{$choice}) 
	{
		$menu{$choice}->(\@library);
	} 
	elsif ($choice == 8)
	{
		last;
	}
	elsif ($choice == "m")
	{
		print $menu_text;
	}
	else
	{
		print "No such menu item: $choice\n";
	}
 }
 
 
 
1;
