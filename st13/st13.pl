#!C:/Perl64/bin/perl

package ST13;

use strict;
use Encode;
use LWP::UserAgent;
my $ua = LWP::UserAgent->new();

my @spisok;

sub hexz {
	my $str = $_[0];
	Encode::from_to($str,'cp866','cp1251');
	$str =~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
	return $str;
}

sub show {
    if( $#spisok != -1){
        my $i = 0;
            if ($_[0] == 1) {
                foreach my $pers (@spisok) {
					my $pos;
					if($pers->{pos} eq 1){
						$pos = "Boss"; 
					}else{
					$pos = "Intern"; 
					}
                    print ++$i.") Name - ".$pers->{name}."; Age = ".$pers->{age}." Pos = ".$pos." Wage = ".$pers->{wage}."\n";
                }
            }
            else{
                foreach my $pers (@spisok) {
				my $sr;
					if($pers->{pos} eq 1){
						$sr = "Boss"; 
					}else{
					$sr = "Intern"; 
					}
                    print "Name - ".$pers->{name}."; Age = ".$pers->{age}." Pos = ".$pos." Wage = ".$pers->{wage}."\n";
                }
            }
            return 1
    }
    else{
        print "There is nobody in the list\n";
        return 0
    }
};
 
sub check_name {
    my $str;
    if ($_[0]) {
        $str = "Edit the Name (".$_[0].") = ";
    }
    else{
        $str = "Enter the Name = ";
    }
    print  $str;
    my $name = <STDIN>;
    chomp($name);
    while($name =~ /[^a-zA-Z]/ || length($name) == 0){
        print "Name have to be in the literal form\n". $str;
        $name = <STDIN>;
        chomp($name);
    }
    return $name
};
 
sub check_age {
    my $str;
    if ($_[0]) {
        $str = "Edit Age (".$_[0].") = ";
    }
    else{
        $str = "Enter Age = ";
    }
    print  $str;
    my $age = <STDIN>;
    chomp($age);
    while($age =~ /\D/ || $age == ""){
        print "Age have to be in the digital form\n".$str;
        $age = <STDIN>;
        chomp($age);    
    }
    return $age
};

sub get_num {
    my $length = $#spisok;
    $length++;
    if($length == 1){
        return 1
    }
    else{
        print "Choose the number of record = ";
        my $choice = <STDIN>;
        chomp($choice);
        while($choice > $length || $choice =~ /\D/ || $choice == ""){
            print "Repeat your choice.\nChoose the number of the record = ";
            $choice = <STDIN>;
            chomp($choice);
        }
        return $choice
    }
}
 
my %arr_fun = (
    1 => sub {
        my %spi = (
            name => &check_name(),
            age => &check_age(),
			pos => 0,
			wage => "0",
            );
        push(@spisok, \%spi);
		$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexz($spi{'name'}),'age'=>hexz($spi{'age'}),'pos'=>hexz($spi{'pos'}),'wage'=>hexz($spi{'wage'}),'button'=>'add'});
    },
	2 => sub {
        my %spi = (
            name => &check_name(),
            age => &check_age(),
			pos => 1,
			wage => &check_age(),
            );
        push(@spisok, \%spi);

		$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexz($spi{'name'}),'age'=>hexz($spi{'age'}),'pos'=>hexz($spi{'pos'}),'wage'=>hexz($spi{'wage'}),'button'=>'add'});
    },
	
    3 => sub {
        if(&show(1) == 1){
            my $num = &get_num();
            my $rec = $spisok[$num-1];
            print "Edit Name of the record $num!\n";
            $rec -> {name} = &check_name($rec -> {name});
            print "Edit Age of the record $num!\n";
            $rec -> {age} = &check_age($rec -> {age})
			if(($rec -> {pos}) eq 1){
				print "Edit wage from the record $num!\n";
				$rec -> {wage} = &check_name($rec -> {wage});
			}
			my $par = "dorep".--$num;
			$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexz($rec -> {name}),'age'=>hexz($rec -> {age}),'pos'=>hexz($rec -> {pos}),'wage'=>hexz($rec -> {wage}),'button'=>$par});
        
        }
    },
    4 => sub {
        if(&show(1) == 1){
            my $num = &get_num();
            splice(@spisok, --$num, 1);
			my $par = "dodelete".++$num;

			$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'button'=>$par});
            print "Record number ".++$num." has been deleted\n\n" 
        }
    },
    5 => sub {
        &show();
    },
    6 => sub {
        if($#spisok != -1){
            my %A;
            my $i = -1;
            dbmopen(%A, "file", 0666);
            foreach my $pers (@spisok){
                $A{++$i} = join('::::', $pers -> {name}, $pers -> {age}, $pers -> {pos},$pers -> {wage});
            }
            dbmclose(%A);
            print "Successful.\n"
        }
        else{
            print "There is nobody in the list\n"
        }
    },
    7 => sub {
        my %A;
        my $i = -1;
        @spisok = ();
        dbmopen(%A, "file", 0666) or die "ERROR";
          while ( my ($key, $value) = each(%A) ) {
            (my $name, my $age, my $pos, my $wage) = split('::::', $value);
            my %spi = (
                name => $name,
                age => $age,
				pos => $pos,
				wage => $wage
            );
            push(@spisok, \%spi);
			$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexz($spi{'name'}),'age'=>hexz($spi{'age'}),'pos'=>hexz($spi{'pos'}),'wage'=>hexz($spi{'wage'}),'button'=>'add'});
        }
        dbmclose(%A);
        print "Successful.\n\n"
        
    },
    8 => sub {
        $ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'button'=>'ex'});
		last
    }
);
 
 
 
sub menu(){
    print "Menu\n1)Add\n2)Appoint the boss\n3)Edit\n4)Delete\n5)Show List\n6)Write *.dbm\n7)Read from file\n8)Exit\n";
    my $choice = <STDIN>;
    chomp($choice);
    if (($choice =~ /\D/) || ($choice>8) || ($choice<1)){
        print "Repeat your choice.\n"
    }
    else{
        $arr_fun{$choice}->()
    }
}

sub ST13{ 
    while(1){
        &menu();
    }
}

st13();