package st42;
use strict;

use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub st42
{
	my ($q, $global) = @_;
	print $q->header(-type => "text/html", -charset => "windows-1251");
	print $q->start_html(-title => "Umnikov Dmitry АСМ-15-04");
	print "<a href=\"$global->{selfurl}\">Back</a>";
	my %menu = (
	"Import from file" => \&convert,
	"Add to list" => \&add,
	"Edit" => \&edit,
	"Delete" => \&delete_object);
	
	my $db = DBI->connect("DBI:mysql:database=data;host=localhost","root","",{'RaiseError' => 1});						
	$db->do("SET NAMES cp1251");

	
	sub add
	{	
	if ($q->param('name') ne "" && $q->param('surname') ne "" && $q->param('hometown') ne "")
	{
	my $sth = $db->prepare("INSERT INTO st42 (name,surname,hometown,status) VALUES (?,?,?,?)");
	;
	my $status = $q->param('status');
	if (!$status)  {$status = "no info";};
	$sth->execute(
		$q->param('name'),
		$q->param('surname'), 
		$q->param('hometown'),
		$status);
	$sth->finish();
	}	
	$q->delete_all();
	}
	
	sub delete_object
	{
	my $sth = $db->prepare("DELETE FROM st42 WHERE item = ?");
	$sth->execute($q->param('item'));
	$sth->finish();
	

	$q->delete_all();
	}
	
	sub convert
	{	
		dbmopen(my %hash,$q->param('mylist'),0644) or die;
		foreach my $k (sort keys %hash)
		{

			my @val = split(/::/,$hash{$k});
			$q->param(-name=>'name',-value=>$val[0]);
			$q->param(-name=>'surname',-value=>$val[1]);
			$q->param(-name=>'hometown',-value=>$val[2]);
			add();	
		}
		dbmclose (%hash);
	}
	
	sub edit
	{
	if ($q->param('name') ne "" && $q->param('surname') ne "" && $q->param('hometown') ne "")
	{
	my $sth = $db->prepare("UPDATE st42 SET name = ?,surname = ?,hometown = ?, status = ? WHERE item = ?");
	$sth->execute(
		$q->param('name'),
		$q->param('surname'), 
		$q->param('hometown'),
		$q->param('status'),
		$q->param('item'));
	$sth->finish();
	}

	$q->delete_all();
	}
	
	sub show 
	{
		print $q->h1("List of Person");
		print $q->start_form;
		print $q->table(
			$q->Tr("Fill this fields:"),
			$q->Tr(
				$q->td($q->textfield(-name => "name",-placeholder => "Name of person", -size => 30)),
				$q->td($q->textfield(-name => "surname",-placeholder => "Surname of person", -size => 30)),
				$q->td($q->textfield(-name => "hometown",-placeholder => "Hometown", -size => 30)),
				$q->td($q->textfield(-name => "status",-placeholder => "Status", -size => 30)),
				$q->td($q->submit(-name=>'action',-value => "Add to list"))
			)
		);
		
		print $q->hidden('person',$global->{'person'});

		print $q->br;
		print $q->hr;
		print $q->submit(-name=>'action',-value => "Import from file");
		print '  ';
		print $q->textfield(-name => "mylist",-placeholder => "Name of file (path to file)", -size => 50);
		print $q->br;
		print $q->br;
		print $q->end_form;
		
		print $q->start_table();	
		
		print $q->Tr ( 
		$q->th("№"),
		$q->th("Nam eof person"),
		$q->th("Surname of person"),
		$q->th("Hometown"),
		$q->th()
		);
		
		my $i = 1;		
		my $sth = $db->prepare("SELECT * FROM st42");
		$sth->execute();
		
		while (my $hash_ref = $sth->fetchrow_hashref())
		{	
			print $q->start_form;
			print $q->hidden(-name => 'item', -value => $hash_ref->{'item'});
			print $q->hidden('person',$global->{'person'});
			
			print $q->Tr ( 
			$q->td($i),
			$q->td($q->textfield(-name => "name",-size => 30, -value => $hash_ref->{'name'})),
			$q->td($q->textfield(-name => "surname",-size => 30, -value => $hash_ref->{'surname'})),
			$q->td($q->textfield(-name => "hometown",-size => 30, -value => $hash_ref->{'hometown'})),
			$q->td($q->textfield(-name => "status",-size => 30, -value => $hash_ref->{'status'})),
			$q->td($q->submit(-name=>'action',-value => "Edit"),
					$q->submit(-name=>'action',-value => "Delete"))
			);	
			print $q->end_form;
			$i++;
		}
		if ($i == 1) 
		{
			print $q->Tr ($q->td({-colspan => 5}, "The list is empty"));
		}
		$sth->finish();
		print $q->end_table;
	}
	if ($menu{$q->param('action')}) {$menu{$q->param('action')}->();} 
	show();
	$db->disconnect();
	print $q->end_html;
}
1;
