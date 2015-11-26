package ST32;
use strict;

use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub st32
{
	my ($q, $global) = @_;
	print $q->header(-type => "text/html", -charset => "windows-1251");
	print $q->start_html(-title => "Пятахина АСМ-15-04");
	print "<a href=\"$global->{selfurl}\">Back</a>";
	my %menu = (
	"Импортировать из файла:" => \&convert,
	"Добавить в список" => \&add,
	"Редактировать" => \&edit,
	"Удалить" => \&delete_object);
	
	my $db = DBI->connect("DBI:mysql:database=data;host=localhost","root","",{'RaiseError' => 1});						
	$db->do("SET NAMES cp1251");

	
	sub add
	{	
	if ($q->param('name') ne "" && $q->param('nickname') ne "" && $q->param('team') ne "")
	{
	my $sth = $db->prepare("INSERT INTO st32 (name,nickname,team,status) VALUES (?,?,?,?)");
	;
	my $status = $q->param('status');
	if (!$status)  {$status = "no info";};
	$sth->execute(
		$q->param('name'),
		$q->param('nickname'), 
		$q->param('team'),
		$status);
	$sth->finish();
	}	
	$q->delete_all();
	}
	
	sub delete_object
	{
	my $sth = $db->prepare("DELETE FROM st32 WHERE item = ?");
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
			$q->param(-name=>'nickname',-value=>$val[1]);
			$q->param(-name=>'team',-value=>$val[2]);
			add();	
		}
		dbmclose (%hash);
	}
	
	sub edit
	{
	if ($q->param('name') ne "" && $q->param('nickname') ne "" && $q->param('team') ne "")
	{
	my $sth = $db->prepare("UPDATE st32 SET name = ?,nickname = ?,team = ?, status = ? WHERE item = ?");
	$sth->execute(
		$q->param('name'),
		$q->param('nickname'), 
		$q->param('team'),
		$q->param('status'),
		$q->param('item'));
	$sth->finish();
	}

	$q->delete_all();
	}
	
	sub show 
	{
		print $q->h1("Список участников соревнований");
		print $q->start_form;
		print $q->table(
			$q->Tr("Заполните форму:"),
			$q->Tr(
				$q->td($q->textfield(-name => "name",-placeholder => "Имя участника", -size => 30)),
				$q->td($q->textfield(-name => "nickname",-placeholder => "Никнейм участника", -size => 30)),
				$q->td($q->textfield(-name => "team",-placeholder => "Название команды", -size => 30)),
				$q->td($q->textfield(-name => "status",-placeholder => "Статус участника", -size => 30)),
				$q->td($q->submit(-name=>'action',-value => "Добавить в список"))
			)
		);
		
		print $q->hidden('student',$global->{'student'});
		
		
		
		print $q->br;
		print $q->hr;
		print $q->submit(-name=>'action',-value => "Импортировать из файла:");
		print '  ';
		print $q->textfield(-name => "mylist",-placeholder => "Имя файла (без расширения, полный путь)", -size => 50);
		print $q->br;
		print $q->br;
		print $q->end_form;
		
		print $q->start_table();
		
		
		print $q->Tr ( 
		$q->th("№"),
		$q->th("Имя участника"),
		$q->th("Никнейм"),
		$q->th("Название команды"),
		$q->th()
		);
		
		my $i = 1;
		
		my $sth = $db->prepare("SELECT * FROM st32");
		$sth->execute();
		
		while (my $hash_ref = $sth->fetchrow_hashref())
		{	
			print $q->start_form;
			print $q->hidden(-name => 'item', -value => $hash_ref->{'item'});
			print $q->hidden('student',$global->{'student'});
			
			print $q->Tr ( 
			$q->td($i),
			$q->td($q->textfield(-name => "name",-size => 30, -value => $hash_ref->{'name'})),
			$q->td($q->textfield(-name => "nickname",-size => 30, -value => $hash_ref->{'nickname'})),
			$q->td($q->textfield(-name => "team",-size => 30, -value => $hash_ref->{'team'})),
			$q->td($q->textfield(-name => "status",-size => 30, -value => $hash_ref->{'status'})),
			$q->td($q->submit(-name=>'action',-value => "Редактировать"),
					$q->submit(-name=>'action',-value => "Удалить"))
			);	
			print $q->end_form;
			$i++;
		}
		if ($i == 1) 
		{
			print $q->Tr ($q->td({-colspan => 5}, "Список пуст"));
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
