
package ST28;
use  strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my @list;
my $q = new CGI;
my $student	= $q->param('student');
my $event = $q->param('event');
my $dbh;	

sub st28 {

	my ($q, $global) = @_;
	print $q->header(-type=>"text/html",-charset=>"windows-1251");
	
	$dbh = DBI->connect("DBI:mysql:database=data;host=localhost","root", "root", {'RaiseError' => 1, 'AutoCommit' => 1});
	$dbh->do("SET NAMES cp1251");
	print "<a href=\"$global->{selfurl}\">В главное меню</a>";
	my %menu = (
	"add" => \&add,
	"addnote" => \&addnote,
	"edit" => \&edit,
	"doedit" => \&doedit,
	"delete" => \&delete,
	"loadDBM" => \&loadDBM);	
	
	if ($event eq 'loadDBM')
	{
		loadDBM();
		loadSQL();
		show();
	} else {if ($menu{$event}) 
	{
		$menu{$event}->();     
	}	else {
		loadSQL();
		show();
		}	
	}
	$dbh->disconnect();
}


sub addnote
{
my ($global) = @_;
my $b = $q->param('b');
if ($q->param('b') eq 'emploee'){

	print "
			<form method = 'post'>
			<input type = 'hidden' name = 'student' value = '$student'/>
			<input type='hidden' name='event' value='add'>

			<P>Имя:
			<input type = 'text' name = 'name'> <BR>
			<P>Возраст:
			<input type = 'text' name = 'age'><BR>
			<P>Должность:
			<input type = 'text' name = 'post'><BR>
			<P>Зарплата:
			<input type = 'text' name = 'salary'><BR>
			<P><input type = 'submit' value = 'Добавить'> </form>";
	}
	else { 
	print "
			<form method = 'post'>
			<input type = 'hidden' name = 'student' value = '$student'/>
			<input type='hidden' name='event' value='add'>

			<P>Имя:
			<input type = 'text' name = 'name'> <BR>
			<P>Возраст:
			<input type = 'text' name = 'age'><BR>
			<P>Должность:
			<input type = 'text' name = 'post'><BR>
			<P>Зарплата:
			<input type = 'text' name = 'salary'><BR>
			<P>Испыт.срок:
			<input type = 'text' name = 'probation'><BR>
			<P><input type = 'submit' value = 'Добавить'> </form>";
		}
	
	print "<br><a href=\"$global->{selfurl}?student=$student\">Назад</a>";		
}
sub add 
{
	my $name = $q->param('name');
	my $age = $q->param('age');
	my $post = $q->param('post');
	my $salary = $q->param('salary');
	my $probation;
	if ($q->param('probation'))
		{ $probation = $q->param('probation'); }
		else { $probation = ""; }
	my $sth = $dbh->prepare("INSERT INTO emploee (name, age, post, salary, probation) VALUES (?,?,?,?,?)");
	$sth->bind_param(1,$name);
	$sth->bind_param(2,$age);
	$sth->bind_param(3,$post);
	$sth->bind_param(4,$salary);
	$sth->bind_param(5,$probation);
	$sth->execute();
	$sth->finish();
	loadSQL();
	show();
}

sub edit 
{   
	loadSQL();
	show();
}

sub doedit 
{
	my $name = $q->param('name');
	my $age = $q->param('age');
	my $post = $q->param('post');
	my $salary = $q->param('salary');
	my $probation = $q->param('probation');	
	my $id = $q->param('id'); 
	my $sth = $dbh->prepare("update emploee set name=?, age=?, post=?, salary=?, probation=? where id=?");
	$sth->bind_param(1,$name);
	$sth->bind_param(2,$age);
	$sth->bind_param(3,$post);
	$sth->bind_param(4,$salary);
	$sth->bind_param(5,$probation);
	$sth->bind_param(6,$id);
	$sth->execute();
	$sth->finish();
	loadSQL();
	show();
}

 sub show 
 {
	if ($event eq 'edit')	
	{	
	my $name = $q->param('name');
	my $age = $q->param('age');
	my $post = $q->param('post');
	my $salary = $q->param('salary');
	my $probation = $q->param('probation');	
	my $id = $q->param('id'); 
	print "
	<form method = 'post'>
	<input type = 'hidden' name = 'student' value = '$student'/>
	<input type='hidden' name='event' value='doedit'>
	<input type='hidden' name='id' value='$id'>
	<P>Имя:
	<input type = 'text' name = 'name' value='$name'><BR>
	<P>Возраст:
	<input type = 'text' name = 'age' value='$age'><BR>
	<P>Должность:
	<input type = 'text' name = 'post' value='$post'><BR>
	<P>Зарплата:
	<input type = 'text' name = 'salary' value='$salary'><BR>";
	if (defined $q->param('probation'))
	{print "<P>Испыт.срок:
			<input type = 'text' name = 'probation' value='$probation'><BR>";}
	print "<P><input type = 'submit' value = 'Редактировать'></form>";
	
	}
	else
		{
		print "<table><table ><tr bgcolor = #FDF5E6>
		<td>
		<form method = 'post'>
		<input type = 'hidden' name = 'student' value = '$student'/>
		<input type='hidden' name='event' value='loadDBM'>
		<input type = 'submit' value = 'Загрузить из DBM-файла '>
		<p>Добавить данные к текущей БД<input type='checkbox' name='dbm'><br>
		</td>
		</form>
		</tr>
		
		<tr>
		<td>
		<form method='post'>
		<input type = 'hidden' name = 'student' value = '$student'/>
		<input type='hidden' name='event' value='addnote'>
		<p><b>Добавить запись:</b><Br>
		<input type='radio' name='b' value='emploee' checked> Сотрудник <Br>
		<input type='radio' name='b' value='trainee'> Стажер <Br>
		<p><input type = 'submit' value = 'Добавить'>
		</td>
		</form>
		</tr>
		</table>
		</table>
		";
	}

	print "
		<table>
		<tr bgcolor = #F0FAFF>
		<th>ID</th><th>Имя</th><th>Возраст</th><th>Должность</th>
		<th>Зарплата</th><th>Исп.срок</th><th>Изменить</th></tr>";
	my $n=1;
	foreach my $arg(@list)
	{	
		print "<tr><td>$n</td>
		<td>$arg->{Name}</td>
		<td>$arg->{Age}</td>
		<td>$arg->{Post}</td>
		<td>$arg->{Salary}</td>
		<td>$arg->{Probation}</td>
		<td><table><tr><td>
		
		<form method = 'post'>
		<input type = 'hidden' name = 'student' value = '$student'/>
		<input type='hidden' name='event' value='edit'>
		<input type='hidden' name='id' value='$arg->{Id}'>
		<input type='hidden' name='name' value='$arg->{Name}'>
		<input type='hidden' name='age' value='$arg->{Age}'>
		<input type='hidden' name='post' value='$arg->{Post}'>
		<input type='hidden' name='salary' value='$arg->{Salary}'>";
		
		if (defined $arg->{Probation})
		{print "<input type='hidden' name='probation' value='$arg->{Probation}'>";}
		print "<input type = 'submit' value = 'Edit'></td>
		
		</form><td>
		<form method = 'post'>
		<input type = 'hidden' name = 'student' value = '$student'/>
		<input type='hidden' name='event' value='delete'>
		<input type='hidden' name='id' value='$arg->{Id}'>
		<input type = 'submit' value = 'Delete'></td>
		
		</tr>
		</table>
		</form>
		</tr>";
		$n++;
	}
	print "</table>";	
	

}

sub delete 
{
	my $id = $q->param('id');
	$dbh->do("DELETE FROM emploee WHERE id=$id");		 
	loadSQL();
	show();
}


 sub loadSQL
 {
	my $sth = $dbh->prepare ("SELECT * FROM emploee;");
	$sth->execute();
	@list=();
	while(my $ref = $sth->fetchrow_hashref())
	{
	my $man={
			Id=>$ref->{id}, 
			Name=>$ref->{name},
			Age=>$ref->{age},
			Post=>$ref->{post},
			Salary => $ref->{salary},
			Probation => $ref->{probation}
		};
    push (@list,$man);
	}
	$sth->finish();

}	
sub loadDBM {
	my %hash=();
	if (defined $q->param('dbm')){}
	else {$dbh->do("truncate table emploee");}
	dbmopen(my %hash, "dbmfile", 0644);
	@list=();
	
		while (( my $key,my $value) = each(%hash))
	{
		my @arg=split(/:/,$hash{$key});
		my $sth = $dbh->prepare("INSERT INTO emploee (name,age,post,salary,probation) VALUES (?,?,?,?,?)");
		$sth->execute($arg[0],$arg[1],$arg[2],$arg[3],$arg[4]);
		$sth->finish();
	}
	
	dbmclose(%hash);
}	

 return 1;