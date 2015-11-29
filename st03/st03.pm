

package ST03;
use strict;
use CGI;
use DBI;
use Data::Dump qw(dump);

sub st03
{
	my ($q, $global) = @_;
	my @list = ();
	my @menu = (\&add, \&edit, \&delete, \&import, \&showTable, \&showBut);
	my %hash;
	
	my $database = DBI->connect(
		"DBI:mysql:database=database03;host=localhost",
		"root", 
		"",
		{'RaiseError' => 1}
	);
	$database->do("SET NAMES cp1251");
	
	sub hex_decode {
		my ($result) = @_;
		$result =~s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		return $result;
	}
	
	sub showBut{
		my $name = undef;
		my $diplom = undef;
		my $dipRuk = undef;
		my $file = undef;
		print "<form method=\"post\">
			<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">
			<h1>List of diploma's themes</h1><br>";
			print "	<button name=\"action\" type=\"submit\" value=\"3\">Import from dbm-file</button><br>";
			
			print "Student name: <input type=\"text\" name=\"name\" value=\"$name\"><br>";
			print "Student diploma theme: <input type=\"text\" name=\"diplom\" value=\"$diplom\"><br>";
			print "Student diploma rukovoditel: <input type=\"text\" name=\"dipRuk\" value=\"$dipRuk\">";
			
			print "	<button name=\"action\" type=\"submit\" value=\"0\">Add</button>";
			print "</form>";
	}
	
 	sub showTable{
		my $sql = $database->prepare("SELECT * FROM st03");
		$sql->execute();	
			print "<table width = '100%' border=1>			
			<tr align = center>
				<td width = '10%' >ID</td>
				<td width = '30%'>Student</td>
				<td>Theme</td>
				<td>Teacher</td>
				<td width = '20%'>Actions</td>
			</tr>";
			while (my $ref = $sql->fetchrow_hashref()) 
			{
				my $key = $ref->{'key'};
				my $name = $ref->{'name'}; 
				my $diplom = $ref->{'diplom'};
				my $dipRuk = $ref->{'dipRuk'};
				print "<tr>
					<form method=\"post\">
					<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">
							
										
					
						<td>	
							<input type=\"text\" name=\"key\" value=\"$key\"><br>						
						</td>
						<td>	
							<input type=\"text\" name=\"name1\" readonly value=\"$name\"><br>						
						</td>
						<td>
							<input type=\"text\" name=\"diplom1\" value=\"$diplom\"><br>
						</td>
						<td>
							<input type=\"text\" name=\"dipRuk1\" value=\"$dipRuk\"><br>
						</td>
						<td>
							<button name=\"action\" type=\"submit\" value=\"1\">Edit</button>
							<button name=\"action\" type=\"submit\" value=\"2\">Delete</button>
						</td>
				 	</form>
				 	<tr>";
				
			}
			
		
		# else
		# {
			# print "<tr colspan = 999><h2>List is empty</h2></tr>";
		# }
		print"</table>";
		$sql->finish();
	}
	
	sub add{
	
		my $name = hex_decode($q->param('name'));
		my $diplom =  hex_decode($q->param('diplom'));
		my $dipRuk =  hex_decode($q->param('dipRuk'));
		if ($diplom ne undef && $name ne undef){
			my $sql = $database->prepare("
				INSERT INTO 
					st03
				(name, diplom, dipRuk) 
				VALUES 
					(?, ?, ?)");
			$sql->execute($name,$diplom,$dipRuk);
			$sql->finish();
		}
	}
	
	sub edit{
		my $name = $q->param('name1');
		my $diplom =  $q->param('diplom1');
		my $dipRuk =  $q->param('dipRuk1');
		my $key =  $q->param('key');
		if ($diplom ne undef && $name ne undef){
			my $sql = $database->prepare("
				UPDATE 
					`database03`.`st03`
				SET 
					`st03`.`name`=?, 
					`st03`.`diplom`=?, 
					`st03`.`dipRuk`=?
				WHERE
					`st03`.`key`= ? ");	
					
			$sql->execute($name,$diplom,$dipRuk,$key);
			$sql->finish();
		}
	}
	
	sub delete{
	
		my $id = $q->param('key');
		my $sql = $database->prepare("
			DELETE FROM `database03`.`st03` WHERE `st03`.`key` = ?
				");
		$sql->execute($id);
		$sql->finish();
	}
	sub import {	
		my %hash;
		dbmopen(%hash, "dbm_03", 0666);
		while ( my ($key, $value) = each %hash )
			{
				my ($name, $diplom,$dipRuk) = split(/--/, $value);
				my $sql = $database->prepare("
					INSERT INTO 
						 `database03`.`st03`
					(
					
					`name` ,
					`diplom` 			
					)
					VALUES 
						(?, ?)");
				$sql->execute($name,$diplom);
				$sql->finish();
			} 

		dbmclose(%hash);
		
	}	
	
	print $q->header;

	
	my $com = $q->param('action');
	if($com>=0 && $com<=3)
		{	
			@menu[$com]->();
		}
	@menu[5]->();
	@menu[4]->();
	print "<a href=\"$global->{selfurl}\">Back to main menu</a>";

}
1;