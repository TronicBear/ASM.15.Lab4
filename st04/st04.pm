package ST04;
use strict;
use LWP::UserAgent;
use Encode;
#use Data::Dumper;
#############Global Variables#############
my $count=0;
my $run=1;
my $cache={};
my $currentkeys=["Name","Status","Address","E-Mail"];
#############Subroutines###############
sub shortshow #get list with existed items
{
    print "\n=======\n";
    while (my ($key,$val)= each (%$cache)){
	print "\t$key:$val->{'Name'}\n";
    }
    print "=======\n";
}
sub itemPrint{
    print "\n=======\n";
    my ($aim)=@_;
    foreach (@$currentkeys){
	print "\t$_:$aim->{$_}\n";
    }
    print "=======\n";
}
#############
# getUID - generate unique number for store in $cashe
# INPUT: none
# OUTPUT: NUMBER uid
#############
sub getUID{
    my $UID=0;
    for (keys %$cache) {
	$UID=$_ if $UID<$_;
    }
    return $UID+1;
}
#############
# add - call menu for interactively add new item in the $cashe'
# INPUT: none
# OUTPUT: none
# return in st04
############
sub add{
    
    my $menu="\n\nNow you can interactively add items in table\nTo cancel adding type 'abort'\n";
    my @temp=();
    print $menu;
    foreach (@$currentkeys) {
	print "$_:";
	my $val=<STDIN>;
	chomp $val;
	return if ($val=~/^abort$/);
	@temp=(@temp,$_,$val);
    }
   
    my $uid = getUID();
    $cache->{$uid}={@temp};
    $count++;
	
}

#############
# correct - call menu for interactively correct existed item in the $cache
# INPUT: none
# OUTPUT: none
# return in st04
############
sub correct{
    my $menu="\n\nType 'shortshow' to get item's list.\n Type 'correct <UID>'  to get item for correction.\n Return to main menu type 'abort'\n";
    my $correcting=1;
    while ($correcting){
	print $menu;
	my $line=<STDIN>;
	chomp $line;
	if ($line=~ m/shortshow/i){
	    shortshow();
	}
	if ($line=~m/correct ([0-9]+)/i){
	    my $UID=$1;
	    if (defined $cache->{$UID}){	    
		my $aim=$cache->{$UID};
		itemPrint($aim);
		print "To correct type:\nAttribute:Value\n Type 'end' to finish correction.\n";
		my $act=1;	   
		while($act){ 
		    my $row=<STDIN>;
		    chomp $row;
		    if ($row=~ m/(\w+)\s*:\s*(.+)/){
			$aim->{$1}=$2 if (defined $aim->{$1});
		    }
		    $act=!($row=~m/^end$/i);
		}
	    }else{
		print "Item with UID=$UID not exist.\n"
	    }
	}
	$correcting=!($line=~m/^abort$/i);
    }
}

#############
# delete - call menu for interactively delete existed item in the $cache
# INPUT: none
# OUTPUT: none
# return in st04
############
sub delete{
    my $menu="\n\nType 'shortshow' to get item's list.\n Type 'delete  <UID>'  to get item away from table.\n Return to main menu type 'abort'\n";
   
    my $deleting=1;
    do{
	print $menu;
	my $line=<STDIN>;
	chomp $line;
	if ($line=~ m/shortshow/i){
	    shortshow();
	}
	if ($line=~m/delete ([0-9]+)/i){
	    my $UID=$1;
	    if (defined $cache->{$UID}){
		print "Item with UID=$UID will be deleted, proceed?(y/n)";
		my $answ=<STDIN>;	    
		delete $cache->{$UID} if ($answ=~m/y|yes/i);
		$count--;
		print "Done deletion $UID\n";}
	    else{
		print "Item with UID=$UID, not exist.\nChoose existed item.\n";
	    }
	}
	$deleting=!($line=~m/^abort$/i);
    }while ($deleting);
}

#############
# show - call menu for interactively show items in the $cache
# INPUT: none
# OUTPUT: none
# return in st04
############

sub show{
    my $menu="\n\nType 'shortshow' to get item in short format\nUID:First field\n. Type 'watch <UID>'  to get item with all filed in format\nUID\n\tfirst field\n\tsecond ...\n\tetc.\nto cancel and return to main menu type 'abort'\n";
   
    my $showmustgoon=1;
    do {
	print $menu;
	my $line=<STDIN>;
	chomp $line;
	if ($line=~ m/shortshow/i){
	    shortshow();
	}
	if ($line=~m/watch ([0-9]+)/i){
	    if (defined $cache->{$1}){
		print "UID:$1\n";
		my $aim=$cache->{$1};
		itemPrint($aim);
	    }else{
		print "======Not existed item======\n";
	    }
	}
	$showmustgoon=!($line=~m/^abort$/i);
    }while ($showmustgoon);
}

#############
# save - call menu for interactively save $cache to dbm file
# INPUT: none
# OUTPUT: none
# return in st04
############
sub save{
    my $menu="\n\nType 'save filename' to save current data to file.Be aware that existed file will be overwritten.\nTo cancel and return to main menu type 'abort'\n";
    
    my $saving=1;
    do {
	print $menu;
	my $line=<STDIN>;
	chomp $line;
	if ($line=~ m/save (\w+)/i){
	    my $filename="st04/". $1;
	    $filename.="\.dbm" unless ($1=~m/\w+.dbm/);
	    my %localdbm;
	    dbmopen(%localdbm,"$filename",0777) or print "Can't create $filename";
	    for (keys %{$cache}) {	
		my @data=();
		while (my ($key,$val)=each %{$cache->{$_}}){
		    push @data, ($key. ':::' .$val);
		}
		$localdbm{$_}=join (':::',@data);
	    }
	    dbmclose(%localdbm);
	    $saving=0;
	}
	else{
	    $saving=!($line=~m/^abort$/i);
	}
    }while ($saving);
}

#############
# load - call menu for interactively load data from dbm file and put it to $cache
# INPUT: none
# OUTPUT: none
# return in st04
############
sub load{
    my $menu="\n\nType 'open filename' to load data from file.File must be present in module folder.\nTo cancel and return to main menu type 'abort'\n";
    
    my $loading=1;
    while ($loading){
	print $menu;
	my $line=<STDIN>;
	chomp $line;
	if ($line=~ m/open (\w+)/i){
	    if (keys %{$cache}){
		print "Current table will be droped! Proceed?(y/n)\n";
		my $ans=<STDIN>;
		unless ($ans=~m/y|yes/i){
		    continue;
		}
	    }
	    $cache={};
	    my $filename="st04/". $1 unless ($1=~m|st04/\w+|);
	    $filename.="\.dbm" unless ($1=~m/\w+.dbm/);
	    my %localdbm;
	    dbmopen(%localdbm,"$filename",0) or print "Can't open $filename";
	    while (my ($key,$val) = each %localdbm) {
		my @data=split ':::', $val;
		my %dataconv=@data;
		my $de=defined $cache->{$key};
		$count++ unless (defined $cache->{$key});
		$cache->{$key} =\%dataconv;
	    }

	    dbmclose(%localdbm);
	    $loading=0;
	}
	else{
	    $loading=!($line=~m/^abort$/i);
	}
    }
}

#############
# quit - exit point from st04
# INPUT: none
# OUTPUT: none
# return in st04
############
sub quit{
    $run=0;
}
sub enCode{
  my ($tmp)=@_;
  Encode::from_to($tmp,'cp866','cp1251');
  return $tmp;
}
############
# push - push data to lab3
############
sub push_to_server{
  my $UA=LWP::UserAgent->new;
  my $resp=$UA->get("http://localhost/cgi-bin/lab3.cgi");
  $resp->{'_content'}=~ m/student=(\w)">04. Borisenko/;
  print "Start sending tables to lab3...\n";
  while(my ($key,$val)=each %$cache){
    my $Resp=$UA->post( 
		"http://localhost/cgi-bin/lab3.cgi",
		[
		  'student' =>$1,
		  'Name' => enCode($val->{'Name'}),
		  'Status' => enCode($val->{'Status'}),
		  'Address' => enCode($val->{'Address'}),					
		  'EMail' => enCode($val->{'E-Mail'}),					
		  'action' => 'Add'
		]
	      );
     print  "\t".$val->{'Name'}." was sent\n";
     
     #print Dumper($Resp);
  }
  print "data was sent\n";
}
my $menuEntry={
    1=>\&add,
    2=>\&correct,
    3=>\&delete,
    4=>\&show,
    5=>\&save,
    6=>\&load,
    7=>\&push_to_server,
    0=>\&quit
};

sub st04
{
    my $Menu="Menu:\nAdd(1),Corect(2),Delete(3),Show list(4),Save to file(5),Load from file(6), Push to server with lab3(7),Qiut(0)\n";
    while ($run) {    
	print "$Menu"."There are $count items in a table\n";
	my $choice=<STDIN>;
	chomp $choice;
	$menuEntry->{$choice}->() if defined $menuEntry->{$choice};
    }
    
}

return 1;
