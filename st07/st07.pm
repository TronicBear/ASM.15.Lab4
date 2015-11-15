#!perl.exe

package ST07;
use strict;
use CGI;
use DBI;
use Scalar::Util qw(looks_like_number);

sub st07 {
	my ($page, $global) = @_;

	my @MainList = ();
	my $db = DBI->connect(
		"DBI:mysql:database=lab3;host=localhost",
		"root", 
		"",
		{'RaiseError' => 1}
	);
	$db->do("SET NAMES cp1251");	
	
	sub hex_decode {
		my ($result) = @_;
		$result =~s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		return $result;
	}
	
	sub add {
		my $name = hex_decode($page->param('name'));	
		my $surename = hex_decode($page->param('surename'));
		my $patronymic = $page->param('patronymic');
		if ( ( $name ne "" ) && ( $surename ne "") ){
			my $sql = $db->prepare("
				INSERT INTO 
					st07
				(name, surename, patronymic) 
				VALUES 
					(?, ?, ?)");
			$sql->execute($name,$surename,$patronymic);
			$sql->finish();
		}
	};
	sub edit {
		my $name = $page->param('name');	
		my $surename = $page->param('surename');
		my $patronymic = $page->param('patronymic');
		my $id = $page->param('id');
		if ( ( $name ne "" ) && ( $surename ne "") ){
			my $sql = $db->prepare("
				UPDATE 
					st07
				SET 
					name=?, 
					surename=?, 
					patronymic=?
				WHERE
					id=?");
			$sql->execute($name,$surename,$patronymic,$id);
			$sql->finish();
		}
	}
	sub delete {
		my $id = $page->param('id');
		my $sql = $db->prepare("
			DELETE FROM 
				st07
			WHERE
				id=?");
		$sql->execute($id);
		$sql->finish();
	}	
	sub import {
		my $file = $page->param('file');	
		if ( $file ne "" ){
			my %h;
			dbmopen(%h, $file, 0644);
			for (my $i = 0; ; $i++){
				if (exists $h{$i}){
					my ($name, $surename) = split(/--/, $h{$i});
					my $sql = $db->prepare("
						INSERT INTO 
							st07
						(name, surename) 
						VALUES 
							(?, ?)");
					$sql->execute($name,$surename);
					$sql->finish();
				} else {
					last;
				}		
			}
			dbmclose(%h);
		}	
	}	
	my @functions = (
		\&add,
		\&edit,
		\&delete,
		\&import
	);

	if (looks_like_number($page->param('action'))){
		$functions[$page->param('action')]();
	}

	sub load {	
		my $sql = $db->prepare("SELECT * FROM st07");
		$sql->execute();
		while (my $ref = $sql->fetchrow_hashref()) {
			my %a = (
				id => $ref->{'id'}, 
				name => $ref->{'name'}, 
				surename => $ref->{'surename'}
			);
			if ($ref->{'patronymic'} ne undef){
				%a->{'patronymic'} = $ref->{'patronymic'};
			}
			push @MainList, \%a;
		}
		$sql->finish();
	};
	
	sub show_page {
		print '
			<table width="100%" border=2 style="margin-bottom:10px;">
				<tr>
					<td colspan=6 style="font-size:30px; text-align: center;">
						СПИСОК СТУДЕНТОВ
					</td>
				</tr>
			<tr>
				<td  style="font-size:16px; text-align: center;">
					<b>
					№
					</b>
				</td>
				<td  style="font-size:16px; text-align: center;">
					<b>
						Имя
					</b>
				</td>
				<td  style="font-size:16px; text-align: center;">
					<b>
						Фамилия
					</b>
				</td>
				<td  style="font-size:16px; text-align: center;">
					<b>
						Отчество
					</b>
				</td>
				<td  colspan=2 style="font-size:16px; text-align: center;">
					<b>
						Действия
					</b>
				</td>
			</tr>';	
		print $page->start_form();
		print '
			<tr>
				<td  style="font-size:16px; text-align: center;">
					<b>';
		print $page->hidden('student',$global->{'student'});
		print '			</b>
				</td>
				<td  style="font-size:16px; text-align: center;">
					<b>';
		print $page->textfield('name',"",30,100);
		print '
					</b>
				</td>
				<td  style="font-size:16px; text-align: center;">
					<b>';
		print $page->textfield('surename',"",30,100);		
		print '
					</b>
				</td>				<td  style="font-size:16px; text-align: center;">
					<b>';
		print $page->textfield('patronymic',"",30,100);		
		print '
					</b>
				</td>
				<td  colspan=2 style="font-size:16px; text-align: center;">
					<b>
					<button name="action" value=0 type="submit">Добавить</button>
					</b>
				</td>
			</tr>';	
		print $page->end_form;		
		if (scalar @MainList == 0){
			print '<tr>
					<td colspan=5 style="font-size:24px; text-align: center;">
						<b>Список пуст</b>
					</td>
				</tr>';	
		} else {
			for (my $i = 0; $i < scalar @MainList; $i++) {
				print $page->start_form();
				print '
					<tr>
						<td  style="font-size:16px; text-align: center;">
							<b>';
				print $page->hidden('id',$MainList[$i]->{'id'});
				print $page->hidden('student',$global->{'student'});
				print $i+1;
				print '
							</b>
						</td>
						<td  style="font-size:16px; text-align: center;">
							<b>';
				print $page->textfield('name',$MainList[$i]->{'name'},30,100);
				print '
							</b>
						</td>
						<td  style="font-size:16px; text-align: center;">
							<b>';
				print $page->textfield('surename',$MainList[$i]->{'surename'},30,100);		
				print '
							</b>
						</td>
						<td  style="font-size:16px; text-align: center;">
							<b>';
				if (exists($MainList[$i]->{'patronymic'})){
					print $page->textfield('patronymic',$MainList[$i]->{'patronymic'},30,100);
				}
				else{
					print '-';
				};
				print '
							</b>
						</td>
						<td  style="font-size:16px; text-align: center;">
							<b>
							<button name="action" value=1 type="submit">Редактировать</button>
							</b>
						</td>
						<td  style="font-size:16px; text-align: center;">
							<b>
							<button name="action" value=2 type="submit">Удалить</button>
							</b>
						</td>
					</tr>';	
				print $page->end_form;
			}	
		}					
		print '
			</table>';		
		print $page->start_form();
		print $page->textfield('file',"",30,100);
		print $page->hidden('student',$global->{'student'});
		print '<button name="action" value=3 type="submit" style="margin-left:5px">Импорт из файла</button>';
		print $page->end_form;	
		print	'<a href="'.$global->{'selfurl'}.'"><<Назад</button>';		
	}

	print $page->header( -type => "text/html", -charset => "windows-1251");
	print $page->start_html( -title => "Горинов Р.М." );
	print $page->delete_all();
	load;
	show_page;
	print $page->end_html;
}

return 1;
