package ST01;

use strict;
use CGI;

use CGI::Carp qw(fatalsToBrowser);


sub st01
{
my ($q, $global) = @_;


my $add_edit = "Добавить";

my $db = DBI->connect("DBI:mysql:database=data;host=localhost","root", "",
						{'RaiseError' => 1, 'AutoCommit' => 1});
$db->do("SET NAMES cp1251");


sub show_form
{
	print $q->start_form(-method => "post");
	print $q->hidden('student',$global->{'student'});
	print 'Введите имя файла без расширения: ';
	print $q->textfield(-name => "filename", -value=> "st01_lib", -size => 40);
	print $q->submit(-name=>'action',-value => "Импортировать из dbm-файла");
 	
	my $n = undef;
	if ($q->param('number'))
	{
		$n = $q->param('number');
		print $q->h3("Изменить запись о книге №".($n));
	}
	else
	{
		print $q->h3("Добавить запись о книге");
	}
	print $q->hidden('edit_number',$n);

	print $q->start_table;
	
		print $q->Tr(
		$q->td('Введите название книги:'),
		$q->td($q->textfield(-name => "name", -size => 40))
		);

		print $q->Tr(
		$q->td('Введите фамилию автора:'),
		$q->td($q->textfield(-name => "author", -size => 40))
		);
	
		print $q->Tr(
		$q->td('Введите год издания:'),
		$q->td($q->textfield(-name => "year", -size => 40))
		);
		
		print $q->Tr(
		$q->td('Введите версию издания:'),
		$q->td($q->textfield(-name => "edition", -size => 40))
		);
	
		print $q->Tr(
		$q->td('<br>',$q->submit(-name=>'action',-value => "$add_edit")));
	
	print $q->end_table;
	print $q->end_form;
};

sub check_input
{
	my ($in) = @_;
	$in =~ /^$/ ? return 0: return 1;
};
	
sub add 
{
	my $name = $q->param('name');
	my $author = $q->param('author');
	my $year = $q->param('year');
	my $edition = $q->param('edition');
	
	return if (check_input($name)+check_input($author)+check_input($year)<3);
	
	my $sth = $db->prepare("insert into st01 (name,author,year,edition) values (?,?,?,?)");
	$sth->execute($name,$author,$year,$edition);
	$sth->finish();
	print $q->delete_all();
	
};


sub show_table
{
	print $q->start_table({-border => 1});

	print $q->Tr(
	$q->th(),
	$q->th({-align => "center"},"№"),
	$q->th({-align => "center"},"Название книги"),
	$q->th({-align => "center"},"Автор"),
	$q->th({-align => "center"},"Год издания"),
	$q->th({-align => "center"},"Версия издания")
	);
	
	my $sth = $db->prepare("select * from st01");
	$sth->execute();
	my $i;
	
	while (my @row = $sth->fetchrow_array())
	{
		print $q->start_form(-method => "post");
		print $q->hidden('student',$global->{'student'});
		print $q->hidden(-name=>'number', -value=>$row[0] );
		print $q->Tr(
		$q->td($q->submit(-name=>'action',-value => "Редактировать"),
		$q->submit(-name=>'action',-value => "Удалить")),
		$q->td({-align => "center"},$row[0]),
		$q->td({-align => "center"},$row[1]),
		$q->td({-align => "center"},$row[2]),
		$q->td({-align => "center"},$row[3]),
		$q->td({-align => "center"},$row[4])
		);
		print $q->end_form;

	}
	$sth->finish();
	

	print $q->end_table;
};
	
sub delete
{
	my $number = $q->param('number');
	my $sth = $db->prepare("delete from st01 where number=?");
	$sth->execute($number);
	$sth->finish();
	
	$sth = $db->prepare("update st01 set number=number-1 where number>?");
	$sth->execute($number);
	$sth->finish();
	
	my $sth = $db->prepare("alter table st01 AUTO_INCREMENT = 1");
	$sth->execute();
	$sth->finish();

	print $q->delete_all();
}	

sub pre_edit
{
	my $number = $q->param('number');
	my $sth = $db->prepare("select * from st01 where number=?");
	$sth->execute($number);
	my @row = $sth->fetchrow_array();
	
	$q->param(-name=>'name',-value=>$row[1]);
	$q->param(-name=>'author',-value=>$row[2]);
	$q->param(-name=>'year',-value=>$row[3]);
	$q->param(-name=>'edition',-value=>$row[4]);
	
	$sth->finish();
	$add_edit = "Изменить";
};

sub edit
{
	my $sth = $db->prepare("update st01 set name=?,author=?,year=?,edition=? where number=?");
	$sth->execute($q->param('name'),$q->param('author'),
					$q->param('year'),$q->param('edition'),$q->param('edit_number'));
	$sth->finish();
	print $q->delete_all();
}

sub import
{
	my $filename = $q->param('filename');
	if (!(-e "$filename.pag"))
	{	
		return;
	}
	
	
	my $sth = $db->prepare("truncate table st01");
	$sth->execute();
	$sth->finish();
	
	$sth = $db->prepare("insert into st01 (name,author,year) values (?,?,?)");
	
	
	dbmopen(my %dbm_hash,$filename,0666) || die;
	while ( (my $k,my $v) = each %dbm_hash) 
	{
		my @values = split(/::/,$v);
		$sth->execute($values[0],$values[1],$values[2]);
	}
	$sth->finish();
	dbmclose (%dbm_hash);
}
	
my %menu = (
	'add_from_client' => \&add,
	"Добавить" => \&add,
	"Редактировать" => \&pre_edit,
	"Изменить" => \&edit,
	"Удалить" => \&delete,
	"Импортировать из dbm-файла" => \&import
);	

print $q->header(-type => "text/html", -charset => "windows-1251", );
print $q->start_html(-title => "Багликова Ю. АСМ-15-04",  -bgcolor => "DAE8B5");
print "<a href=\"$global->{selfurl}\">Назад к выбору программы</a>";
print $q->h1("Библиотека");




if ($menu{$q->param('action')}) 
{
	
	
	$menu{$q->param('action')}->();     
}


show_form();
print $q->delete_all();
print $q->hr;  

show_table();

print $q->end_html;

$db->disconnect();

}

return 1;
