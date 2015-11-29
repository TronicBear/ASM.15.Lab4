#!/usr/bin/perl
package ST02;
use strict;

use LWP::UserAgent;
use Encode qw(encode decode);

sub st02
{
	print "st02:st02\n";
	my @group;

sub add{
	print "\nEnter student name\n";
	chomp(my $name = <STDIN>);
	print "Enter student age\n";
	my $age = <STDIN>;
	print "Enter student email\n";
	chomp(my $email = <STDIN>);
	my $student = {NAME => $name, AGE => $age, EMAIL => $email};
	push @group, $student;
}

sub edit{
	print "\nSelect item to edit (enter student name):\n";
	chomp(my $edit_name = <STDIN>);
	my $flag = 0; 
	
	for (my $i = 0; $i < @group; $i++)
	{
		if (($group[$i]->{NAME}) eq $edit_name)
		{
			print "\nDo you want to change student name(0)/age(1)?:\n";
			chomp(my $select = <STDIN>);
			if ($select)
			{
				print "\nEnter new student age:\n";
				my $age = <STDIN>;
				$group[$i]->{AGE} = $age;
				$flag = 1;
				print "\nStudent age successfully changed!\n";
			}
			else
			{
				print "\nEnter new student name:\n";
				chomp(my $name = <STDIN>);
				$group[$i]->{NAME} = $name;
				$flag = 1;
				print "\nStudent name successfully changed!\n";
			}
			last;
		}
	}
	if (!$flag){print "\nNo such element in the list\n";}
}

sub delete{
	print "\nSelect item to delete (enter student name):\n";
	chomp(my $del_name = <STDIN>);
	my $flag = 0; 
	
	for (my $i = 0; $i < @group; $i++)
	{
		if (($group[$i]->{NAME}) eq $del_name)
		{
			delete ($group[$i]);
			$flag = 1;
			print "\nElement deleted\n";
			last;
		}
	}
	if (!$flag){print "\nNo such element in the list\n";}
} 

sub display{
	if (@group)
	{
		for (my $i = 0; $i < @group; $i++)
		{
			print "\nName: ".$group[$i]->{NAME}."\nAge: ".$group[$i]->{AGE}."Email: ".$group[$i]->{EMAIL}."\n---------";
		}
	}
	else {print "\nThe list is empty\n";}
}

sub save{
	dbmopen(my %HASH,"data.txt",0666)or die "Can't open file: $!\n";
	%HASH = ();
	for (my $i = 0; $i < @group; $i++)
	{
		$HASH{$i} = join("##",$group[$i]->{NAME},$group[$i]->{AGE},$group[$i]->{EMAIL});
	}
	dbmclose %HASH;
	print "\nThe list is successfully saved in a file!\n";
}

sub load{
	for (my $i = 0; $i < @group; $i++)
	{
		delete ($group[$i]);
	}
	dbmopen(my %HASH,"data.txt",0666)or die "Can't open file: $!\n";
	foreach my $key (keys %HASH)
	{
		my ($name, $age, $email) = split(/##/,$HASH{$key});
		my $student = {NAME => $name, AGE => $age, EMAIL => $email};
		push @group, $student;
	}
	dbmclose %HASH;
	print "\nThe data is successfully loaded from a file!\n";
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
	if (@group)
	{
		for (my $i = 0; $i < @group; $i++)
		{
			$ua->post($url, 
			{
			'student' => 02,
			'name' => encode($group[$i]->{NAME}),
			'age' => encode($group[$i]->{AGE}),
			'email' => encode($group[$i]->{EMAIL}),
			'action' => 'add'
			});
		}
		print "\nData has been sent";
	}
	else {print "\nThe list is empty\n";}
}

while(1)
{
	print "
\nChoose:\n
1. Add item
2. Edit
3. Delete
4. Display list
5. Save to file
6. Download file
7. Send to Lab3
8. Exit

Your choice: ";

	my @MENU = (\&add, \&edit, \&delete, \&display, \&save, \&load, \&send);
	my $in = <STDIN>;
	if (($in > 0)&&($in < 8)){
		$MENU[$in-1]->();
	}
	elsif ($in == 8){
		last;
	}
	else{
		print "Incorrect command\n";
	}
}
}
return 1;
