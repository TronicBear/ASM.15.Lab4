#!C:/Perl64/bin/perl

package ST29;

use strict;
use Encode;
use LWP::UserAgent;
my $ua = LWP::UserAgent->new();

my @spisok;

sub hexe {
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
					my $sr;
					if($pers->{dolzh} eq 1){
						$sr = "Manager"; 
					}else{
					$sr = "Employee"; 
					}
                    print ++$i.") Name - ".$pers->{name}."; Age = ".$pers->{age}." Dolzh = ".$sr." Company = ".$pers->{comp}."\n";
                }
            }
            else{
                foreach my $pers (@spisok) {
				my $sr;
					if($pers->{dolzh} eq 1){
						$sr = "Manager"; 
					}else{
					$sr = "Employee"; 
					}
                    print "Name - ".$pers->{name}."; Age = ".$pers->{age}." Dolzh = ".$sr." Company = ".$pers->{comp}."\n";
                }
            }
            return 1
    }
    else{
        print "Nobody in da list\n";
        return 0
    }
};
 
sub check_name {
    my $str;
    if ($_[0]) {
        $str = "Edit  (".$_[0].") = ";
    }
    else{
        $str = "Enter = ";
    }
    print  $str;
    my $name = <STDIN>;
    chomp($name);
    while($name =~ /[^a-zA-Z]/ || length($name) == 0){
        print "The name must be literal\n". $str;
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
        print "The Age must be digit\n".$str;
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
            print "Repeat entering!!!\nChoose the number of record = ";
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
			dolzh => 0,
			comp => "-",
            );
        push(@spisok, \%spi);
		$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexe($spi{'name'}),'age'=>hexe($spi{'age'}),'dolzh'=>hexe($spi{'dolzh'}),'comp'=>hexe($spi{'comp'}),'button'=>'add'});
    },
	2 => sub {
        my %spi = (
            name => &check_name(),
            age => &check_age(),
			dolzh => 1,
			comp => &check_name(),
            );
        push(@spisok, \%spi);

		$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexe($spi{'name'}),'age'=>hexe($spi{'age'}),'dolzh'=>hexe($spi{'dolzh'}),'comp'=>hexe($spi{'comp'}),'button'=>'add'});
    },
    3 => sub {
        if(&show(1) == 1){
            my $num = &get_num();
            my $rec = $spisok[$num-1];
            print "Edit Name of record $num!\n";
            $rec -> {name} = &check_name($rec -> {name});
            print "Edit Age of record $num!\n";
            $rec -> {age} = &check_age($rec -> {age});
			if(($rec -> {dolzh}) eq 1){
				print "Edit Company of record $num!\n";
				$rec -> {comp} = &check_name($rec -> {comp});
			}
			my $par = "dorep".--$num;
			$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexe($rec -> {name}),'age'=>hexe($rec -> {age}),'dolzh'=>hexe($rec -> {dolzh}),'comp'=>hexe($rec -> {comp}),'button'=>$par});
        }
    },
    4 => sub {
        if(&show(1) == 1){
            my $num = &get_num();
            splice(@spisok, --$num, 1);
			my $par = "dodelete".++$num;

			$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'button'=>$par});
            print "Record number ".$num." has been deleted\n\n" ;

			
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
                $A{++$i} = join('::::', $pers -> {name}, $pers -> {age}, $pers -> {dolzh},$pers -> {comp});
            }
            dbmclose(%A);
            print "Complete!!!!\n"
        }
        else{
            print "Nobody in da list\n"
        }
    },
    7 => sub {
        my %A;
        my $i = -1;
        @spisok = ();
        dbmopen(%A, "file", 0666) or die "can't fight this love";
        while ( my ($key, $value) = each(%A) ) {
            (my $name, my $age, my $dolzh, my $comp) = split('::::', $value);
            my %spi = (
                name => $name,
                age => $age,
				dolzh => $dolzh,
				comp => $comp
            );
            push(@spisok, \%spi);
			$ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'fio'=>hexe($spi{'name'}),'age'=>hexe($spi{'age'}),'dolzh'=>hexe($spi{'dolzh'}),'comp'=>hexe($spi{'comp'}),'button'=>'add'});
        }
        dbmclose(%A);
        print "Read complete!!!\n\n"
        
    },
	8 => sub {
        $ua->post( "http://asm.15.lab3/lab3.cgi",{'student'=>5,'button'=>'ex'});
		last
    }
);
 
 
 
sub menu(){
    print "Choose your destiny\n1)Add\n2)Add manager\n3)Edit\n4)Delete\n5)Show List\n6)Write *.dbm\n7)Read from file\n8)Exit\n";
    my $choice = <STDIN>;
    chomp($choice);
    if (($choice =~ /\D/) || ($choice>8) || ($choice<1)){
        print "Repeat entering!!!\n"
    }
    else{
        $arr_fun{$choice}->()
    }
}

sub st29{ 
    while(1){
        &menu();
    }
}

st29();