#!wperl.exe
package ST45;
use 5.010;
use strict;
use warnings;
use URI;
use LWP::UserAgent;
use utf8;
use open qw(:std :encoding(cp1251));

sub st45
{
	`chcp 1251`;
	print "st45:st45\n";
		my $menu = "		Card file\n
			** Select necessery number **\n
			1. Add element;\n
			2. Edit element;\n
			3. Delete element;\n
			4. Show list;\n
			5. Save list to file;\n
			6. Download list from file;\n
			7. Send to server.\n
			8. Exit.\n";		

	my @card_file = ();
	my @functions = (\&add, \&edit, \&delete, \&show, \&save, \&download, \&send);
	my %hdb = ();
	while(1){
		print "$menu";
		my $snum = <STDIN>;
		chomp $snum;
		if($snum >= 1 && $snum <= 8){
			if($snum==8){
				last;
			} else{
				$functions[$snum-1]->();
			}
		}else{
			print "Invalid value!\n";
		}
	}

	sub add{
		my($name, $surname, $group, $salary, $href);
		print "Enter name: "; $name = <STDIN>; chomp $name; editValue($name);
		print "Enter surname: "; $surname = <STDIN>; chomp $surname; editValue($surname);
		print "Enter group: "; $group = <STDIN>; chomp $group; editValue($group);
		print "Enter salary: "; $salary = <STDIN>; chomp $salary; editValue($salary);
		$href = {
				"name",   $name,
				"surname",$surname,
				"group",  $group,
				"salary", $salary
				};
		push(@card_file, $href);
		return 1;
	}

	sub edit{
		my $num;
		print "\tThere are ".scalar(@card_file)." elements in card file.\n
		Please select number of element which you would like to edit: ";
		$num = <STDIN>; chomp $num;
		if($num < 1 || $num > scalar(@card_file)){
			return 0;
		}
		while((my $key, my $value) = each(%{$card_file[$num-1]})){
			print "\n\t\tCurrent $key:	".${$card_file[$num-1]}{$key}."\n
			Enter $key: "; 
			$value = <STDIN>; chomp $value;
			if($value ne ""){
				${$card_file[$num-1]}{$key} = $value;
			}
		}
		return 1;
	}
	
	sub editValue{
		$_[0] =~ s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
		return 1;
	}

	sub delete{
		my $num;
		print "\tThere are ".scalar(@card_file)." elements in card file.\n
		Please select number of element whic you would like to delete: ";
		$num = <STDIN>; chomp $num;
		if($num < 1 || $num > scalar(@card_file)){
			return 0;
		}
		splice(@card_file,$num-1,1);
		return 1;
	}

	sub show{
		for(my $i = 0; $i < scalar(@card_file); $i++){
			print "person ".($i+1)."\n";
			while((my $key, my $value) = each(%{$card_file[$i]})){
				print "	$key: $value\n";
			}
		}
		return 1;
	}

	sub save{
		dbmopen(%hdb, "dbfile", 0666) || die "can't open DBM file!\n";
		my $s; %hdb = ();
		for(my $i = 0; $i < scalar(@card_file); $i++){
			$hdb{"el".$i} = join("::",${$card_file[$i]}{"name"},
									  ${$card_file[$i]}{"surname"},
									  ${$card_file[$i]}{"group"},
									  ${$card_file[$i]}{"salary"});
		}
		dbmclose(%hdb);
		return 1;
	}

	sub download{
		@card_file = ();
		my ($name,$surname,$group,$salary,$href);
		dbmopen(%hdb, "dbfile", 0666) || die "can't open DBM file!\n";
		while((my $key, my $value) = each(%hdb)){
			($name,$surname,$group,$salary) = split(/::/,$value);
			$href = {
					"name",   $name,
					"surname",$surname,
					"group",  $group,
					"salary",  $salary
					};
			push(@card_file, $href);
		}
		dbmclose(%hdb);
		return 1;
	}
	
	sub send{
		my $url = URI->new('http://ASM.15.Lab3/lab3.cgi');
		my $browser = LWP::UserAgent->new();
		for(my $i = 0; $i < scalar(@card_file); $i++){
			$url->query_form(
					'student' => 45,
					'name' => ${$card_file[$i]}{"name"},
					'surname' => ${$card_file[$i]}{"surname"},
					'group' => ${$card_file[$i]}{"group"},
					'salary' => ${$card_file[$i]}{"salary"}
					);
			my $response = $browser->get($url);
			die "$url error: ", $response->status_line
				unless $response->is_success;
		}
	}
}
return 1;
