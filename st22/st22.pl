#!"C:\Perl\bin\perl.exe"
use strict;
no warnings qw( experimental::autoderef ); 
use LWP::UserAgent;
use HTML::Entities;
use Encode qw(encode decode);

my @list;

my %menu = (
	1 => \&add,
	2 => \&edit,
	3 => \&delete_object,
	4 => \&display_the_entire_list,
	5 => \&save_file,
	6 => \&download_file
	7 => \&to_server
);

sub f
{
	my $func = undef;
	while (1) 
		{
		$func = <STDIN>;
		chomp($func);
		$func =~ /^$/ ? next: last;
		}
	return $func;
}


sub add
{
	my ($a) = @_;
	print "Enter name :";
	my $name = f;
	print "Enter nickname :";
	my $nickname = f;
	print "Enter team: ";
	my $team = f;
	my $add = {"Name", $name, "Nickname", $nickname, "Team", $team};
	push @$a,$add;
}


sub edit
{
	my ($a) = @_;
	print "Enter the number ";
	my $n = f;
	print "\n";
	
	if (!(%$a[$n-1]))
	{
		print "Not Found $n\n";
		return ;
	}
	my $num = $n-1;
	
	print "Enter new name\n";
	for my $k (sort keys %$a[$num])
	{
		my $v = $$a[$num]{$k};
		print "$k new  -> ";
		$v = f;
		$$a[$num]{$k} = $v ;
	}	
	print "Done!\n";
}


sub delete_object
{
	my ($a) = @_;
	
	print "Enter the number ";
	my $n = f;
	print "\n";
	
	if (!(%$a[$n-1]))
	{
		print "Not Found $n\n";
		return ;
	}
	
	my $num = $n-1;
	splice(@$a,$num,1);
	print "Done!\n";
}


sub display_the_entire_list
{
	my ($a) = @_;
	my $a1 = @$a;
	
	if (@$a!= ())
	{
		for (my $i=0; $i<$a1; $i++)
		{
		print (($i+1).'. ');
		print "\n";
			foreach my $k (sort keys %$a[$i])
			{print "$k -> $$a[$i]{$k}\n";}
		}
	}
	else
	{
		print "Nothing Found\n";
	}
}


sub save_file
{
	my ($a) = @_;
	my $a1 = @$a;
	
	dbmopen(my %hash,"mylist",0666) or die "Can't open dbm-file !\n";
	%hash = ();
	for (my $i=0; $i<$a1; $i++)
	{
		$hash{$i} = join("::",
		$$a[$i]{Name},
		$$a[$i]{Nickname}, 
		$$a[$i]{Team});
	}
	dbmclose (%hash);
	print "Save file 'mylist'\n";
	
}


sub download_file
{
		my ($a) = @_;
	@$a = ();	
	
	dbmopen(my %hash,"mylist",0666) or die "Can't open dbm-file !\n";
	my $i = 0;
	while ( (my $k,my $v) = each %hash) 
	{
		my @val = split(/::/,$hash{$k});
		
		$$a[$i]{Name}=$val[0];
		$$a[$i]{Nickname}=$val[1];
		$$a[$i]{Team}=$val[2];
		$i++;
			
	}
	dbmclose (%hash);
	print "File 'mylist' read\n";
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
	my ($a) = @_;
	my $browser = LWP::UserAgent->new;
	my $url = "http://ASM.15.Lab3/lab3.cgi";
	
	my $a1 = @$a;
	
	if (@$a != ())
	{
		for (my $i=0; $i<$a1; $i++)
		{
			$browser->post( $url,
						   {
						    'name' => encode_for_html($$a[$i]{Name}),
							'nickname' => encode_for_html($$a[$i]{Nickname}),
							'team' => encode_for_html($$a[$i]{Team}),
							'action' => 'add_from_client',
							'student' => 2
						   }
							);
			
	
		}
		print "Done\n";
	}
	else
	{
		print "Nothing Found\n";
	}

}






 
 print "Hello, World!\n";
print "Menu:\n\n";
print"1--add\n";
print"2--edit\n";
print"3--delete object\n";
print"4--display the entire list\n";
print"5--save file\n";
print"6--download file\n";
print"7--send to server\n";
 my $b;
 
 while (1)
 {
	
	print "Enter the number of menu or another for exit\n";
	$b = f;
	print "\n";
	if ($menu{$b}) 
	{
		$menu{$b}->(\@list);
	} 
	
	else
	{
		last;
	}
 }
 
 

 
 
return 1;
