#!/usr/bin/perl

package ST13;
use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use DBI;

my @spisok;

sub hexz{
		my $str = $_[0];
		$str =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		return $str;
	}

sub st13
{
	my ($q, $global) = @_;
	&printHeader($q, $global);
	my $database = "st13";
	my $login = "root";
	my $password = "";
	my $table = "st13";
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
			'dodelete' => \&DoDelete
			'doexecute' => \&DoExecute
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
				my $pos = $fields->{pos};
				my $wage = $fields->{wage};
				my %rec = (
        				id => $id,
                name => $fio,
                age => $age,
								pos => $pos,
								wage => $wage
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
									 <th>Зарплата</th>
                   <th></th>
                   <th></th>
                   </tr>
ENDHTML
		my $k = 1;
	 foreach my $pers (@spisok) {
		 		my $pos;
		 		if($pers->{pos} eq "0"){
					$pos = "Стажер";
				}
				else{
					$pos = "Босс";
				}
	 			print <<ENDHTML;
                   <tr>
                   <input type="hidden" name="id" value="$pers->{id}">
                   <td>$k</td>
                   <td>$pers->{name}</td>
                   <td>$pers->{age}</td>
									 <td>$pos</td>
									 <td align="center">$pers->{wage}</td>
                   <td><button type="submit" name="button" value="edit$k">Edit</button></td>
                   <td><button type="submit" name="button" value="dodelete$pers->{id}">Delete</button></td>
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
		my $p = @spisok[$num]->{pos};
		my $w = @spisok[$num]->{wage};
		if($p eq 0){
		print <<ENDHTML;
		<input hidden="true" name="student" value="$global->{student}">
		<label>Стажер</label><br>
		<label style="margin-bottom: 5px; margin-top: 5px;">ФИО:</label>
		<input type="text" name="fio" value="$f" placeholder="Введите ФИО" style="margin-left: 50px; margin-bottom: 5px; width: 250px " > <br>
		<label>Возраст:</label>
		<input type="number" name="age" value="$a" min="1" max="200" placeholder="Введите возраст" style="margin-left: 30px; margin-bottom: 5px; width: 250px" > <br>
		<input type="text" hidden="true" name="wage" value="0">
		<td><button type="submit" name="button" value="dorep@spisok[$num]->{id}">Edit</button></td>
		</form>
ENDHTML
}
else{
	print <<ENDHTML;
	<input hidden="true" name="student" value="$global->{student}">
	<label>Босс</label><br>
	<label style="margin-bottom: 5px; margin-top: 5px;">ФИО:</label>
	<input type="text" name="fio" value="$f" placeholder="Введите ФИО" style="margin-left: 50px; margin-bottom: 5px; width: 250px " > <br>
	<label>Возраст:</label>
	<input type="number" name="age" value="$a" min="1" max="200" placeholder="Введите возраст" style="margin-left: 30px; margin-bottom: 5px; width: 250px" > <br>
	<label>Зарплата:</label>
	<input type="text" name="wage" value="$w"  style="margin-left: 15px; margin-bottom: 5px; width: 250px" > <br>
	<td><button type="submit" name="button" value="dorep@spisok[$num]->{id}">Edit</button></td>
	</form>
ENDHTML

}
	}
	else{


		print <<ENDHTML;
		<label>Должность:</label>
		<select name="pos" id="pos" style="margin-left: 10px; margin-top: 5px; margin-bottom: 5px; width: 250px">
						<option value="0">Стажер</option>
						<option value="1">Босс</option>
		</select><br>
		<label>ФИО:</label>
		<input type="text" name="fio" placeholder="Введите ФИО" style="margin-left: 50px; margin-bottom: 5px; width: 250px " > <br>
		<label>Возраст:</label>
		<input type="number" name="age" min="1" max="200" placeholder="Введите возраст" style="margin-left: 30px; margin-bottom: 5px; width: 250px" > <br>
		<input type="text" hidden="true" id="wage" name="wage" value="">
		<input type="submit" name="button" value="add" onClick="getWage()">
		</form>
ENDHTML
	}}
};

sub DoAdd{
	my ($q, $global, $db, $table) = @_;
	my $wage;
	if($q->param('pos') eq 1){
		$wage = $q->param('wage');
	}
	else{
		$wage = "0";
	}
	my $query = $db->prepare("insert into $table (fio,age,pos,wage) values(?,?,?,?)");
	my $f = hexz($q->param('fio'));
	my $a = hexz($q->param('age'));
	my $p = hexz($q->param('pos'));
	my $w = hexz($wage);
	$query->execute($f,$a,$p,$w);
	$query->finish();
};

sub DoEdit{
	my ($q, $global, $db, $table) = @_;
	my $num = $q->param('button');
	$num=~ s/dorep//;
	my $wage;
	if($q->param('pos') eq 1){
		$wage = $q->param('wage');
	}
	else{
		$wage = "0";
	}
	my $f = hexd($q->param('fio'));
	my $a = hexd($q->param('age'));
	my $p = hexd($q->param('pos'));
	my $w = hexd($wage);
	DoLoad($db, $table);
	my $numm = @spisok[$num--]->{id};
	my $query = $db->prepare("update $table set fio=?, age=?, wage=? where id = ?");
	$query->execute($f, $a, $w, $numm);
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

sub DoExecute{
	my ($q, $global, $db, $table) = @_;
	my $query = $db->prepare("truncate table $table");
	$query->execute();
	$query->finish();
}

sub printHeader{
	my ($q, $global) = @_;
	print $q->header( -type=>"text/html",
        				-charset=>"UTF-8");
	print <<ENDHTML;
<html>
<head>
<script>
function getWage()
	{
		if(document.getElementById("pos").value == 1){
			 var wage = prompt('Установите зарплату');
			 if(wage != null)
			 	document.getElementById("wage").value = wage;
			else
document.getElementById("wage").value = "";
		};

  }
</script>
<style>
	td,th {border:0px; padding:15px}
	table {padding-bottom:15px}
</style>
<title>
Злотников, лабораторная №2. TronicBear
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
