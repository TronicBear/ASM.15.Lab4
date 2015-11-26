#!/usr/bin/perl

package ST29;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
sub hexd{
		my $str = $_[0];
		$str =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		return $str;
	}

my @spisok;

sub st29
{
	my ($q, $global) = @_;
	&printHeader($q, $global);
	my $database = "lab3";
	my $login = "root";
	my $password = "";
	my $table = "st29";
	my $db = DBI->connect(
									"DBI:mysql:$database",
									$login,
									$password,
									{'RaiseError' => 1, 'AutoCommit' => 1}
	);
	$db->do("SET NAMES utf8");
	my %menu = (
			'add' => \&DoAdd,
 			'doedit' => \&DoEdit,
			'dodelete' => \&DoDelete,
			'ex' => \&DoEx

	);
    	if($q->param('button') =~ /dorep/){
    		$menu{'doedit'}->($q, $global, $db, $table);
    	}
    	else{
	    	if($q->param('button') =~ /dodelete/){
				$menu{'dodelete'}->($q, $global, $db, $table);
	    	}
	    	else{if(defined $menu{$q->param('button')} ){
				$menu{$q->param('button')}->($q, $global, $db, $table);
	    	}
	    	}


    }
	&Showform($q, $global, $db, $table);
	&printFooter($q, $global);
	$db -> disconnect();
	print "<a href=\"$global->{selfurl}\">Назад</a>";
};
sub DoEx{
	my ($q, $global, $db, $table) = @_;
	my $query = $db->prepare("truncate table $table");
	$query->execute();
	$query->finish();
}
sub DoLoad{
		my ($db, $table) = @_;
 		my %A;
    my $i = -1;
    @spisok = ();
		my $query = $db->prepare("select * from $table");
		$query->execute();
		while (my $fields = $query->fetchrow_hashref()) {
				my $id = $fields->{id};
				my $fio = $fields->{fio};
				my $age = $fields->{age};
				my $dolzh = $fields->{dolzh};
				my $company = $fields->{comp};
				my %rec = (
        				id => $id,
                		name => $fio,
                		age => $age,
						dolzh => $dolzh,
						comp => $company
            );
        push(@spisok, \%rec);
		}
		$query->finish();
};


sub Showform{
	my ($q, $global, $db, $table) = @_;
	&DoLoad($db, $table);
	my $lld = $q->param('id');
	if($#spisok == -1){
		print <<ENDHTML;
		<form method = "POST">
		<input hidden="true" name="student" value="$global->{student}">
		<label>ФИО:</label>
		<input type="text" name="fio" placeholder="Введите ФИО" style="margin-left: 50px; margin-bottom: 5px; width: 250px " required> <br>
		<label>Возраст:</label>
		<input type="number" name="age" min="1" max="200" placeholder="Введите возраст" style="margin-left: 30px; margin-bottom: 5px; width: 250px" required> <br>
		<input type="submit" name="button" value="add">
		</form>
ENDHTML
}
	else{
		print <<ENDHTML;
		<form method = "POST">
		<input hidden="true" name="student" value="$global->{student}">
		<table>
                   <tr>
                   <th>Индекс</th>
                   <th>ФИО</th>
                   <th>Возраст</th>
									 <th>Должность</th>
									 <th>Компания</th>
                   <th></th>
                   <th></th>
                   </tr>
ENDHTML
		my $k = 1;
	 foreach my $pers (@spisok) {
		 		my $dolzh;
		 		if($pers->{dolzh} eq "0"){
					$dolzh = "Рабочий";
				}
				else{
					$dolzh = "Менеджер";
				}
	 			print <<ENDHTML;
                   <tr>
                   <input type="hidden" name="id" value="$pers->{id}">
                   <td>$k</td>
                   <td>$pers->{name}</td>
                   <td>$pers->{age}</td>
									 <td>$dolzh</td>
									 <td align="center">$pers->{comp}</td>
                   <td><button type="submit" name="button" value="edit$k">Edit</button></td>
                   <td><button type="submit" name="button" value="dodelete$k">Delete</button></td>
                   </tr>
ENDHTML
									$k++;
                }
                print "</table>";
	if ($q->param('button') =~ /edit/){
		my $num = $q->param('button');
		$num=~ s/edit//;
		$num--;
		my $f = @spisok[$num]->{name};
		my $a = @spisok[$num]->{age};
		my $d = @spisok[$num]->{dolzh};
		my $c = @spisok[$num]->{comp};
		if($d eq 0){
		print <<ENDHTML;
		<input hidden="true" name="student" value="$global->{student}">
		<label>Рабочий</label><br>
		<label style="margin-bottom: 5px; margin-top: 5px;">ФИО:</label>
		<input type="text" name="fio" value="$f" placeholder="Введите ФИО" style="margin-left: 50px; margin-bottom: 5px; width: 250px " > <br>
		<label>Возраст:</label>
		<input type="number" name="age" value="$a" min="1" max="200" placeholder="Введите возраст" style="margin-left: 30px; margin-bottom: 5px; width: 250px" > <br>
		<input type="text" hidden="true" name="comp" value="-">
		<td><button type="submit" name="button" value="dorep@spisok[$num]->{id}">Edit</button></td>
		</form>
ENDHTML
}
else{
	print <<ENDHTML;
	<input hidden="true" name="student" value="$global->{student}">
	<label>Менеджер</label><br>
	<label style="margin-bottom: 5px; margin-top: 5px;">ФИО:</label>
	<input type="text" name="fio" value="$f" placeholder="Введите ФИО" style="margin-left: 50px; margin-bottom: 5px; width: 250px " > <br>
	<label>Возраст:</label>
	<input type="number" name="age" value="$a" min="1" max="200" placeholder="Введите возраст" style="margin-left: 30px; margin-bottom: 5px; width: 250px" > <br>
	<label>Компания:</label>
	<input type="text" name="comp" value="$c"  style="margin-left: 15px; margin-bottom: 5px; width: 250px" > <br>
	<td><button type="submit" name="button" value="dorep@spisok[$num]->{id}">Edit</button></td>
	</form>
ENDHTML

}
	}
	else{


		print <<ENDHTML;
		<label>Должность:</label>
		<select name="dolzh" id="dolzh" style="margin-left: 10px; margin-top: 5px; margin-bottom: 5px; width: 250px">
						<option value="0">Рабочий</option>
						<option value="1">Менеджер</option>
		</select><br>
		<label>ФИО:</label>
		<input type="text" name="fio" placeholder="Введите ФИО" style="margin-left: 50px; margin-bottom: 5px; width: 250px " > <br>
		<label>Возраст:</label>
		<input type="number" name="age" min="1" max="200" placeholder="Введите возраст" style="margin-left: 30px; margin-bottom: 5px; width: 250px" > <br>
		<input type="text" hidden="true" id="comp" name="comp" value="">
		<input type="submit" name="button" value="add" onClick="getComp()">
		</form>
ENDHTML
	}}
};

sub DoAdd{
	my ($q, $global, $db, $table) = @_;
	my $comp;

	if($q->param('dolzh') eq 1){
		$comp = $q->param('comp');
	}
	else{
		$comp = "-";
	}
	my $query = $db->prepare("insert into $table (fio,age,dolzh,comp) values(?,?,?,?)");
	my $f = hexd($q->param('fio'));
	my $a = hexd($q->param('age'));
	my $d = hexd($q->param('dolzh'));
	my $c = hexd($comp);
	$query->execute($f,$a,$d,$c);
	$query->finish();
};

sub DoEdit{
	my ($q, $global, $db, $table) = @_;
	my $num = $q->param('button');
	$num=~ s/dorep//;
	my $comp;
	if($q->param('dolzh') eq 1){
		$comp = $q->param('comp');
	}
	else{
		$comp = "-";
	}
	my $f = hexd($q->param('fio'));
	my $a = hexd($q->param('age'));
	my $d = hexd($q->param('dolzh'));
	my $c = hexd($comp);
	DoLoad($db, $table);
	my $numm = @spisok[$num--]->{id};
	my $query = $db->prepare("update $table set fio=?, age=?, comp=? where id = ?");
	$query->execute($f, $a, $c, $numm);
	$query->finish();
};

sub DoDelete{
	my ($q, $global, $db, $table) = @_;
	my $num = $q->param('button');
	$num =~ s/dodelete//;
	$num--;
	DoLoad($db, $table);
	my $numm = @spisok[$num--]->{id};
	my $query = $db->prepare("delete from $table where id = ?");
	$query->execute($numm);
	$query->finish();
};

sub printHeader{
	my ($q, $global) = @_;
	print $q->header( -type=>"text/html",
        				-charset=>"UTF-8");
	print <<ENDHTML;
<html>
<head>
<script>
function getComp()
	{
		if(document.getElementById("dolzh").value == 1){
			 var comp = prompt('Введите компанию');
			 if(comp != null)
			 	document.getElementById("comp").value = comp;
			else
document.getElementById("comp").value = "";
		};

  }
</script>
<style>
	td,th {border:0px; padding:15px}
	table {padding-bottom:15px}
</style>
<title>
Лабораторная 2
</title>
</head>
<body>
ENDHTML
};

sub printFooter{
	my ($q, $data) = @_;
	print <<ENDHTML;
</body>
</html>
ENDHTML
};

return 1;
