#!C:/Perl64/bin/perl

use strict;
use Person;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Encode;


my @group;  
my $res = 1;
my $filename = "st26db";

#helper functions
my $check_input = sub { 
    while( my $choice = <STDIN> ) {
            chomp $choice;
            if ( $choice =~ m/\d+/ && $choice <= @group && $choice>0 ) {
                return $choice;
            }

            print "\nInvalid input\n\nYour choice: ";
       }    
};

my $group_IsNull = sub { 
    if(@group >0)
    {
        return 1;
    }
    else
    {
        print "\n######### Group is empty. Create or load group !!! ########\n" ;
        return 0;
    }
};

#menu function 
sub menu {
    my @items = @_;
    my $count = 0;
    for my $item( @items ) {
        printf "%d: %s\n", ++$count, $item->{text};
    }

    print "\nYour choice: ";

    while( my $line = <STDIN> ) {
        chomp $line;
        if ( $line =~ m/\d+/ && $line <= @items && $line>0 ) {
            return $items[ $line - 1 ]{code}();
        }

        print "\nInvalid input\n\nYour choice: ";
    }
};

#print students function 
my $print_students = sub { 
    if(&$group_IsNull == 1)
    {
        print "\n######### Print Group ########\n" ;
        my $count = 0;
        for my $item( @group ) {
        	(my $f, my $l,my $stid,my $deg,my $cou,my $id )= split(/::@::/,$item->getPerson());
            printf "%d: FName:%s LName:%s stid:%d degree:%s course:%s \n", ++$count, $f,$l,$stid,$deg,$cou;
        }
        print "\n";
    }
};

#add student function 
my $add_student = sub { 
    print "\n########## Add Student  #########\n" ;
    print "First Name :\n";
    chomp (my $f_name = <STDIN>);
    print "Last Name :\n";
    chomp (my $l_name = <STDIN>);
    print "ST_ID: \n";
    chomp (my $stid = <STDIN>);
    print "Degree: \n";
    chomp (my $degree = <STDIN>);
    print "Course: \n";
    chomp (my $cou = <STDIN>);
    push(@group,Person->new($f_name, $l_name, $stid,$degree,$cou));
    &$print_students(); 


    Encode::from_to($f_name, "cp866", "windows-1251");
    $f_name=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg; 
   
    Encode::from_to($l_name, "cp866", "windows-1251");
    $l_name=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg; 

	Encode::from_to($degree, "cp866", "windows-1251");
    $degree=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg; 

    Encode::from_to($cou, "cp866", "windows-1251");
    $cou=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;

    my $ua = LWP::UserAgent->new;
    my $req = POST 'http://asm.15.lab3-master/lab3.cgi',
    [ search => 'www', errors => 0,student=>3,f_name=>"$f_name",l_name=>"$l_name",degree=>"$degree",course=>"$cou",stid=>"$stid",action=>'add' ];
	$ua->request($req); 

    
};

#edit student function 
my $edit_student = sub { 
    if(&$group_IsNull == 1)
    { 
        print "\n########## Edit Student  #########\n" ;
        &$print_students(); 
        print "Enter student number:\n";
        my $choice = &$check_input();
        print "First Name :\n";
        chomp (my $f_name = <STDIN>);
        $group[$choice-1]->setFirstName($f_name); 
        print "Last Name :\n";
        chomp (my $l_name = <STDIN>);;
        $group[$choice-1]->setLastName($l_name); 
        print "STID: \n";
        chomp (my $stid = <STDIN>);
        $group[$choice-1]->setID($stid); 
	    print "Course: \n";
	    chomp (my $cou = <STDIN>);
	    $group[$choice-1]->setCourse($cou);
        &$print_students();

        Encode::from_to($f_name, "cp866", "windows-1251");
	    $f_name=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg; 
	   
	    Encode::from_to($l_name, "cp866", "windows-1251");
	    $l_name=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg; 

	    Encode::from_to($cou, "cp866", "windows-1251");
	    $cou=~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;

        my $ua = LWP::UserAgent->new;
	    my $req = POST 'http://asm.15.lab3-master/lab3.cgi',
	    [search => 'www', errors => 0,student=>3,f_name=>"$f_name",l_name=>"$l_name",course=>"$cou",stid=>"$stid",n_row=>"$choice",action=>'do_edit' ];
		$ua->request($req); 

    }
};

#delete_student function 
my $del_student = sub { 
    if(&$group_IsNull == 1)
    {
        print "\n######### Delete Student ########\n" ;
        &$print_students(); 
        print "Enter student number:\n";
        my $choice = &$check_input();
        splice @group,$choice-1,1;
        &$print_students();

        my $ua = LWP::UserAgent->new;
	    my $req = POST 'http://asm.15.lab3-master/lab3.cgi',
	    [search => 'www', errors => 0,student=>3,n_row=>"$choice",action=>'delete' ];
		$ua->request($req); 

    }  
};

#save students to dbm file function 
my $save_students = sub { 
    if(&$group_IsNull == 1)
    {
        print "\n######### Save Group ########\n";
        dbmopen(my %data, $filename, 0666) or die "Cant open $filename file\n";
        %data = ();
        my $count = 0;
        foreach (@group) { 
            $count+=1;
            my $tmp =  Encode::encode('windows-1251', Encode::decode('cp866',$_->getPerson()));
            $data{"$count"} =$tmp ;
        }     
        dbmclose(%data);
    }
};

#load students from dbm file function 
my $load_students = sub { 
        undef(@group);
        print "\n######### Load Group ########\n" ;
        dbmopen(my %data, $filename, 0444) or die "Cant open $filename file\n";  
        foreach my $key ( keys %data ) {
        	my $tmp = Encode::encode('cp866', Encode::decode('windows-1251', $data{$key}));
            (my $f, my $l,my $stid,my $deg,my $cou,my $id )= split(/::@::/,$tmp);
            push(@group,Person->new($f, $l, $stid,$deg, $cou,$id));
        }
        dbmclose(%data);
        &$print_students(); 
};

my $send_todb = sub {
	my $ua = LWP::UserAgent->new;
	foreach ( @group ) {
		my $pers = Encode::encode('windows-1251', Encode::decode('cp866', $_->getPerson()));		
		(my $f, my $l,my $stid,my $deg,my $cou,my $id ) = split(/::@::/,$pers);
		my $req = POST 'http://asm.15.lab3-master/lab3.cgi',
		[ search => 'www', errors => 0,student=>3,f_name=>"$f",l_name=>"$l",degree=>"$deg",course=>"$cou",stid=>"$stid",n_row=>"$id",action=>'client' ];
		$ua->request($req); 
	}
	
};

# menu 
my @menu_choices = (
    { text  => 'add student to db',
      code  =>  $add_student},
    { text  => 'edit student in db',
      code  =>  $edit_student},
    { text  => 'delete student in db',
      code  => $del_student },
    { text  => 'print group',
      code  => $print_students },
    { text  => 'save',
      code  => $save_students },
    { text  => 'load',
      code  => $load_students },
    { text  => 'exit',
      code  =>  sub { $res = 0;}}
);

sub st26 
{
    $res = 1;
	while($res)
	{
		menu( @menu_choices );
	}
};

st26();