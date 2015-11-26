#!/usr/bin/perl
package ST27;
use strict;
use v5.10.0;
use LWP::Simple;
use LWP::UserAgent;
use Encode;
use URI;


  sub st27{
print "st27:st27\n";

my $menu = 
	"	             Library`s Kartoteka\n
       !-----------------------------------------------!
	1. Add user;	      6. Download list from file;\n
	2. Edit user;         7. LWP; \n
	3. Delete user;       8. LWP1, add one person; \n
	4. Show list;         9. Exit.\n
	5. Save list to file;\n\n";

my @mass = ();
my %hash = ();
sub add_rec{
my $name; my $book; my $book_id;my $record;
	print "Enter name: "; 
	$name = <STDIN>; chomp $name; #simbols($name);
	print "Enter book: "; 
	$book = <STDIN>; chomp $book;#simbols($book);
	print "Enter book_id: "; 
	$book_id = <STDIN>; chomp $book_id;#simbols($book_id);
	if ($book_id !~ /\d/ ) {print "Please, input number!!!!\n";
		return 0;}
	$record = {"name",$name,"book",$book,"book_id",$book_id};
	print "Before: ".scalar @mass."\n";
	push(@mass, $record);
	print "After: ".scalar @mass."\n";
	return 1;}


sub show_kartoteka{
if (scalar @mass == 0) {
	print "Kartoteka is empty!!!\n";
	return 0;}
for(my $i = 0; $i < ($#mass + 1); $i++)
{print "record ".($i+1)."\n";
while((my $key, my $value) = each(%{$mass[$i]})){
	print "	$key: $value\n";}}
}

sub edit_rec{my $num_rec;
	print "Number of records in kartoteka:  ".(scalar @mass )."\n
	Select what you need: ";
	$num_rec = <STDIN>; chomp $num_rec;
	if($num_rec < 1 || $num_rec > (scalar @mass)){
		print "Fatal Error!!! Record does not exist \n ";
		return 0;}
	while((my $key, my $value) = each(%{$mass[$num_rec-1]})){
		print "\n Current $key:	".${$mass[$num_rec-1]}{$key}."\n";
		print "Enter new $key: "."\n"; 
		$value = <STDIN>; chomp $value;
		if($value ne ""){${$mass[$num_rec-1]}{$key} = $value;}}
		return 1;}


sub del_rec{
		my $rec;
		if (scalar @mass == 0) {print "Kartoteka is Empty!!!\n"; return 0;}
		else{
		print "Number of records in kartoteka:  \n".(scalar @mass )."\n";
		print "Please select number of element which you would like to delete: ";
		$rec = <STDIN>; chomp $rec;
		if($rec < 1 || $rec > (scalar @mass)){
			return 0;
		}
		splice(@mass,$rec-1,1);
		return 1;}
	}       
sub exit{last;}


sub save_kart
{dbmopen(%hash, "lib_kart", 0666) || die "can't open DBM file!\n";
##if(-e $lib_kart) {print "OK\n";}
	my $f; %hash = ();
for(my $i = 0; $i < (scalar @mass ); $i++)
{$f = join("##",${$mass[$i]}{"name"}, ${$mass[$i]}{"book"},${$mass[$i]}{"book_id"});
		  $hash{"rec".$i} = $f;}
		dbmclose(%hash);
		return 1;
}	

sub load_kart{my $name,my $book,my $book_id,my $record;
@mass = ();
dbmopen(%hash, "lib_kart", 0666) || die "can't open DBM file!\n";
while((my $key, my $value) = each(%hash)){
($name, $book, $book_id) = split(/##/,$value);
$record = {	"name",   $name,"book",$book,"book_id",  $book_id};
push(@mass, $record);}
	dbmclose(%hash);
		return 1;}	
	
my @Func = (\&add_rec, 
\&edit_rec, 
\&del_rec, 
\&show_kartoteka,
\&save_kart,
\&load_kart,
\&LWP
);
	
	sub LWP{my $name,my $book,my $book_id,my $record;
		#@mass = ();
	dbmopen(%hash, "lib_kart", 0666) || die "can't open DBM file!\n";
	while((my $key, my $value) = each(%hash)){
		($name, $book, $book_id) = split(/##/,$value);
		Encode_($name, $book, $book_id);
	}
	dbmclose(%hash);
		return 1;
	}


	sub Encode_{
	my $name = $_[0];
	my $book = $_[1];
	my $book_id = $_[2];
	
		Encode::from_to($name, 'cp866', 'cp1251');
		Encode::from_to($book, 'cp866', 'cp1251');
		Encode::from_to($book_id, 'cp866', 'cp1251');
		
		my $browser = LWP::UserAgent->new;
		my $url = URI->new( 'http://localhost:8080/cgi-bin/st27(3).pl' );
		
		$url->query_form(  
		'name'    => $name,
		'book' => $book,
		'book_id' => $book_id,
		'author' => '',
		);
	my $response = $browser->get($url);	
		

		if($response->is_success) 
      { 
        my $text = $response->content; 
      print "success\n";
      }
  		
	}
	
	sub simbols{
		$_[0] =~ s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
		return 1;
		}
	
	sub LWP1{
	my $name; my $book; my $book_id;my $record;
	print "Enter name: "; 
	$name = <STDIN>; chomp $name;
	print "Enter book: "; 
	$book = <STDIN>; chomp $book;
	print "Enter book_id: "; 
	$book_id = <STDIN>; chomp $book_id;

		Encode::from_to($name, 'cp866', 'cp1251');
		Encode::from_to($book, 'cp866', 'cp1251');
		Encode::from_to($book_id, 'cp866', 'cp1251');
		
		my $browser = LWP::UserAgent->new;
		my $url = URI->new( 'http://localhost:8080/cgi-bin/st27(3).pl' );
		
		$url->query_form(  
		'student'=>27,
		'name'    => $name,
		'book' => $book,
		'book_id' => $book_id,
		'author' => '',
		);
	my $response = $browser->get($url);	
		

		
	}

	
	
	sub main{
while(1)
{
print $menu;
my $choice = <STDIN>; chomp $choice;

if ($choice <1 || $choice>9) 
	{print "Please, input a number [1-7]\n"; 
	next };
##$Func[$choice-1]->();
if ($choice == 1) {$Func[0]->()};
if ($choice == 2) {$Func[1]->()};
if ($choice == 3) {$Func[2]->()};
if ($choice == 4) {$Func[3]->()};
if ($choice == 5) {$Func[4]->()};
if ($choice == 6) {$Func[5]->()};
if ($choice == 7) {$Func[6]->()};
if ($choice == 8) {LWP1};
if ($choice == 9) {last};

}
print "Good Bye...";
}


main()
}

1;