#!C:/perl/bin/perl
package ST24;
use strict;
use LWP::Simple;
use LWP::UserAgent;
use Encode;
  sub st24
{ 
  print "st24:st24\n";
  my @list=();
  my $elemnumber=0;
  sub add{
            print "Enter the name of a new person\n";
            my $newname = <STDIN>;
   	        chomp($newname);
            print "Enter age of a new person\n";
            my $newage = <STDIN>;
   	        chomp($newage);
            my %nameage= ( name => $newname, age => $newage);
            push(@list, \%nameage);
            $elemnumber++;
  }
  sub showlist{
            if (@list>0){
              my $i=0;
                print "Full list:\n";
                 foreach my $nameage(@list)
        		    	{
        		    		  ++$i;
        		    		print "#$i. ".$nameage->{name}." ".$nameage->{age}."\n";
        		    	}
              }
  else {print "List is empty\n ";}
      }

  sub edit{  
    if (@list>0){
              print "Enter the number of element that you want to edit\n";
              my $elemnum = <STDIN>;
               chomp($elemnum);
               if( $elemnum<=$elemnumber and $elemnum>0){
                 my $editelem=$list[$elemnum-1];
               
                print "Curr name: ".$editelem->{name}.", enter new name\n";
                 my $newname = <STDIN>;
               chomp($newname);
                print "Curr age: ".$editelem->{age}.", enter new age\n";
                 my $newage = <STDIN>;
                chomp($newage);
                 
                 $list[$elemnum-1]->{name}=$newname;
                 $list[$elemnum-1]->{age}=$newage;
                 }else {print "There are just ".$elemnumber." elements\n";}
                }
  else {print "List is empty\n ";}
               
  }
  sub delete{
         if (@list>0){
           print "Enter the number of element that you want to delete\n";
                my $elemnum = <STDIN>;
               chomp($elemnum);
                if( $elemnum<=$elemnumber and $elemnum>0){
               splice (@list, $elemnum - 1, 1); }
               else {print "There are just ".$elemnumber." elements\n";}
               }
        else {print "List is empty\n ";}
  }
  sub saveto{
         if (@list>0){
         my $i=0;
         my %buf;
         dbmopen (%buf, "file", 0644) or die print "cant open file\n";
         foreach my $nameage(@list)
              {
                  $buf{$i} = join('--', $nameage->{name}, $nameage->{age});
                  ++$i;
              }
        dbmclose(%buf);
     }
           else {print "List is empty\n ";}
  }
  sub loadfrom{
     my %buf;
     dbmopen(%buf, "file", 0777);
     @list = ();
        while ( (my $key, my $value) = each %buf )
       {
         my ($name, $age) = split(/--/, $value);
         my %nameage = (name => $name,age => $age);
         push(@list, \%nameage);
       }
     dbmclose(%buf);
  }
   
	sub encoude_to{
   my $browser = LWP::UserAgent->new;
    my $name=$_[0];
    my $age=$_[1];
    Encode::from_to($name, 'windows-866', 'windows-1251');
    Encode::from_to($age, 'windows-866', 'windows-1251');
            my $response = $browser->post(
              'http://localhost/cgi-bin/st24lab3.pl',
              [
                'namein'  => $name,
                'agein' => $age,
                'carmarkin' => ' ',
                'action' => 'add_elem'
              ],
            );

      #if($response->is_success) 
      #{ 
       # my $text = $response->content; 
       #print "success".$text;
      #} 
  }

  sub load_to_cgi{
     my %buf;
     dbmopen(%buf, "file", 0777);
     @list = ();
        while ( (my $key, my $value) = each %buf )
       {
         my ($name, $age) = split(/--/, $value);
         
             encoude_to($name, $age);
         
       }
     dbmclose(%buf);
  } 
  
   sub quit{
    print "Programm is end\n";
   return 1;
   }
  my @funcs= (
  \&quit,
  \&add,         
  \&edit,
  \&delete,
  \&showlist,    
  \&saveto,
  \&loadfrom,
  \&load_to_cgi
             );
  
  	for(;;){
    
       print "\n 
              1.Add new person\n 
    	      2.Edit element\n 
    	      3.Delete element\n 
      	      4.Show full list\n 
     	      5.Save to file\n 
    	      6.Load from file\n 
    	      7.Load from dbm to cgi\n 
              0.Exit\n ";
      
       my $line = <STDIN>;
         chomp($line); 
               if(defined $funcs[$line])
             { 
               $funcs[$line]->();
             }
             else
             {
               return;
             }
        
    }

}

return 1;