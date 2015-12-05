package ST18;
use strict;
use warnings;
use 5.010;
use URI;
use LWP::UserAgent;
use utf8;
use open qw(:std :encoding(cp1251));


my %DbmFileHash =();
my @data;
my $i;

my %MenuHash =
				(
					"1" =>  \& LoadList,
					"2" =>  \& ShowList,
					"3" =>	\&AddElement,
					"4" =>	\&DelElement,
					"5" =>	\&EditRecord,
					"6" =>	\&SavetoDbm,
					"7" =>	\&SendToServer
				);



sub LoadList
{
	    dbmopen (%DbmFileHash, "dbmfile_18",0666);
		@data = ();
		while (my ($key, $value) = each(%DbmFileHash))
		{

			my ($name, $mail, $phone) = split(/--/, $value);
			my %record = (
				name => $name,
				mail => $mail,
				phone => $phone
			);
			push(@data, \%record);
		}
	dbmclose %DbmFileHash;
	return 1;		
}

sub ShowList
{
	$i=0;
    if(@data)
    {
        print "\nGroup\n" ;
		foreach my $record(@data) 
		    	{
		    		++$i;
		    		print "$i. "."name: ".$record->{name}." mail: ".$record->{mail}." phone: ".$record->{phone}."\n";
		    	}
    }
    else
    {
    	print "No elements or list is not loaded\n";
    }
    return 1;
}


sub editValue
{
		$_[0] =~ s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
		return 1;
}

sub AddElement
{
	print "Insert person name:\n";
	my $tmpName = <STDIN>;
	chomp $tmpName;
	editValue($tmpName);

	print "Insert person mail:\n";
	my $tmpmail = <STDIN>;
	chomp $tmpmail;
	editValue($tmpmail);

	print "Insert person phone:\n";
	my $tmpphone = <STDIN>;
	chomp $tmpphone;
	editValue($tmpphone);

	my %record =
	(
			name => $tmpName,
			mail => $tmpmail,
			phone => $tmpphone
	);
    push(@data, \%record);
    return 1;
 }

sub DelElement
{
	my $tmpdel;
	print "Insert number:\n";
	$tmpdel = <STDIN>;
	chomp $tmpdel;
	while($tmpdel < 0 || $tmpdel > @data)
	{
			print "Enter right number of element \n";
			$tmpdel = <STDIN>;
			chomp $tmpdel;
	}
	splice @data, $tmpdel - 1, 1;
	return 1;
}

sub EditRecord
{
	my $tmpedit;
	print "Insert record number:\n";
	$tmpedit = <STDIN>;
	chomp $tmpedit;
	while($tmpedit < 0 || $tmpedit > @data)
	{
			print "Enter right number of element \n";
			$tmpedit = <STDIN>;
			chomp $tmpedit;
	}
	my $record = $data[$tmpedit - 1];
	print "Insert new person name (current name: ".$record->{name}.") or press \"Enter\":\n";
	my $value = <STDIN>;
	if($value)
	{
	 	$record->{name} = $value;
	}
	print "Insert new mail (current mail: ".$record->{mail}.") or just press \"Enter\":\n";
	$value = <STDIN>;
	if($value)
	{
		$record->{mail} = $value;
	}
	print "Insert new phone (current phone: ".$record->{phone}.") or just press \"Enter\":\n";
	$value = <STDIN>;
	if($value)
	{
		$record->{phone} = $value;
	}
	return 1;
}


sub SendToServer
{
	my $url = URI->new('http://localhost/ASM.15.Lab3/lab3.cgi');
	#my $url = URI->new('http://localhost/cgi-bin/lab3.cgi');
	my $browser = LWP::UserAgent->new();
	if(@data==0){
		print "No obj to send \n";
	}
	else
	{
		foreach my $record(@data)
		{
			$url->query_form
			(
				'student' => 18,
				'name' => $record->{name},
				'mail' => $record->{mail},
				'phone' => $record->{phone}
			);
			my $response = $browser->get($url);
			die "$url error: ", $response->status_line
			unless $response->is_success;
		}
		print 'Completed';
	}
	return 1;
}


sub SavetoDbm
{
	my %buffer =();
	dbmopen (%buffer, "dbmfile_18",0666);
	$i = 0;
	foreach my $record(@data) 
	{
		$buffer{$i} = join('--', $record->{name}, $record->{mail}, $record->{phone});
		++$i;
	}
	dbmclose(%buffer);
	return 1;
}



sub st18
{
	
	print "\n"."Action:\n"."1)Load list\n"."2)Show list\n"."3)Add record\n"."4)Delete record\n"."5)Edit record\n"."6)Save list\n"."7)Send to server\n"."8)Exit\n";
	while (my $line=<STDIN>)
	{ 

		chomp $line;
		last if $line eq "8";
		
		given($line){
			when (1) {$MenuHash{"1"}->();}
			when (2) {$MenuHash{"2"}->();}
			when (3) {$MenuHash{"3"}->();}
			when (4) {$MenuHash{"4"}->();}
			when (5) {$MenuHash{"5"}->();}
			when (6) {$MenuHash{"6"}->();}
			when (7) {$MenuHash{"7"}->();}
			when (8) {last;}
			default {print "No such command";}
		}
		

		
		
	}

}

#st18();
return 1;