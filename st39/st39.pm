package ST39;
use strict;

use CGI;
use CGI::Carp qw(fatalsToBrowser);

sub st39
{
	my ($q, $global) = @_;
	
	my $db = DBI->connect("DBI:mysql:database=data;host=localhost",
							"root",
							"",
							{'RaiseError' => 1});
							
	$db->do("SET NAMES cp1251");


	sub show_interface {
	
		print $q->start_form;
		print $q->hidden(-name => 'student', -value => $global->{'student'});

		print $q->h1({-align => 'center'},'Cписок воспроизведения');
		
		print $q->start_table({-border => 1, -align => 'center',-bgcolor => "#ff8c8c", -bordercolor => "black"});
		
		print $q->Tr($q->td(),
		$q->td($q->textfield(-name => "file", -size => 41, -placeholder => "Введите имя файла"),
		$q->submit(-name=>'action',-value => "Импорт")));
		
		print $q->start_Tr;
		print $q->start_td;
		
		print $q->start_table({-border => 1,-height => '100%', -bordercolor => "black"});
		print $q->Tr($q->th('Добавить композицию:')	);

		
		print $q->Tr($q->td({-align=>'center'},
			$q->submit(-name=>'action',-value => "Удалить")));
			
		
		my $sth = $db->prepare("SELECT * FROM st39");
		$sth->execute();
		my $count = $sth->rows();
		my $listref = $sth->fetchall_arrayref([]);
		$sth->finish();
		
		for( my $i = 0; $i < $count; $i++)
		{
			print $q->Tr($q->td({-align=>'center', -height => 25}, $q->checkbox(-name=>'check', -value=>$listref->[$i][0], -label=>'')));
		}
		
		print $q->end_table;
		print $q->end_form;
		
		print $q->end_td;
		
		print $q->start_td;
		
		print $q->start_table({-border => 1,-height => '100%',-bgcolor => "black", -bordercolor => "black"});
		
		print $q->start_form;
		print $q->hidden(-name => 'student', -value => $global->{'student'});
		
		print $q->Tr(
		$q->td($q->textfield(-name => "performer", -size => 40, -placeholder => "Введите имя исполнителя")),
		$q->td($q->textfield(-name => "song", -size => 40, -placeholder => "Введите название песни")),
		$q->td($q->textfield(-name => "date", -size => 20, -placeholder => "Введите дату релиза")),
		$q->td($q->submit(-name=>'action',-value => "Отправить"))
		);
		
		print $q->end_form;

		print $q->Tr({-bgcolor => "#ff8c8c"},
		$q->th({-align => 'center'},'Исполнитель'),
		$q->th({-align => 'center'},'Композиция'),
		$q->th()
		);
		
		
		 for( my $i = 0; $i < $count; $i++)
		{
			print $q->start_form;
			print $q->hidden(-name => 'student', -value => $global->{'student'});
			
			print $q->hidden(-name => 'id', -value => $listref->[$i][0]);
			print $q->Tr(
				$q->td({ -height => 25},$q->textfield(-name => "performer", -size => 40, -value => $listref->[$i][1])),
				$q->td({ -height => 25},$q->textfield(-name => "song", -size => 40, -value => $listref->[$i][2])),
				$q->td({ -height => 25},$q->textfield(-name => "date", -size => 20, -value => $listref->[$i][3])),
				$q->td({-align=>'center', -height => 25},$q->submit(-name=>'action',-value => "Изменить"))
			);
			
			
			print $q->end_form;
		}
		
		
		print $q->end_table;
		
		print $q->end_td;
		print $q->end_Tr;
		print $q->end_table;

	};
	
	sub send {
	my $performer = $q->param('performer');
	my $song = $q->param('song');
	my $date = $q->param('date');
	my $id = $q->param('id');
	my ($sql,$sth);
	
	if (($performer ne "") && ($song ne "")) {
	if (!$id) {
	$sql="INSERT INTO st39 (performer,song,date,id) VALUES (?,?,?,?)";
	$id = $sth->{insertid};
	} else {

	$sql="UPDATE st39 SET performer=?,song=?,date=? WHERE id=?";
	}
	$sth = $db->prepare($sql);
	$sth->execute($performer,$song,$date,$id);
	$sth->finish();
	}
	print $q->delete('performer','song','date');
	};

	
	sub delete {
	my @items = $q->param('check');
	my $sth = $db->prepare("dELETE FROM st39 WHERE id=?");
	foreach my $i (@items) {
	$sth->execute($i);
	}
	$sth->finish();
	print $q->delete('check');
	};
	
	
	my $trackfile = "tracklist";
	
	
	sub import {
	my $trackfile = $q->param('file');
	
	my $sth = $db->prepare("INSERT INTO st39 (performer,song) VALUES (?,?)");
	dbmopen(my %hash,$trackfile,0644) || die "Can't open file!\n";
	foreach my $k (sort keys %hash) {
		my @v = split(/__/,$hash{$k});
		$sth->execute($v[0],$v[1]);
		}
	dbmclose (%hash);
	$sth->finish();
	};
	
	my %menu = ( "Отправить" => \&send, "Изменить" => \&send,"Удалить" => \&delete, "Импорт" => \&import, 'send' => \&send,);
	

	print $q->header(-type => "text/html", -charset => "windows-1251");
	print $q->font({-color=>'black', -face=>'trebuchet ms'});
	print "<a href=\"$global->{selfurl}\">Назад</a>";
	
	print $q->start_html(-title => "Ступин Игорь",  -bgcolor => "#ede0ce");
	
	$menu{$q->param('action')}->() if ($menu{$q->param('action')}); 
	
	show_interface;
	
	print $q->end_html;
	$db->disconnect();
}

1;

