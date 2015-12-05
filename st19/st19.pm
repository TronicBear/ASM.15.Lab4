#!C:/perl/bin/perl
package ST24;
use strict;
use LWP::Simple;
use LWP::UserAgent;
use Encode;
  sub st19
{ 
  print "st19:st19\n";
  
  
   
	

  sub fromdbmtobase{
    my $browser = LWP::UserAgent->new;
     my %buf;
     dbmopen(%buf, "file_const", 0777);
     my @list = ();
        while ( (my $key, my $value) = each %buf )
       {
         my ($nsurname, $nnumingroup) = split(/--/, $value);
         
              
              Encode::from_to($nsurname, 'windows-866', 'windows-1251');
              Encode::from_to($nnumingroup, 'windows-866', 'windows-1251');
              my $response = $browser->post(
              'http://localhost/cgi-bin/st19.pl',
              [
                'surname'  => $nsurname,
                'numingroup' => $nnumingroup,
                'married' => ' ',
                'action' => 'addelem'
              ],
            );
         
       }
     dbmclose(%buf);
  } 
  
  
  my @funcs= (
  
  \&fromdbmtobase
             );
  
  	for(;;){
    
       print "\n 
              1.Load from dbm to base\n 
              ";
      
       my $line = <STDIN>;
         chomp($line); 
               if(defined $funcs[$line])
             { 
               $funcs[$line-1]->();
             }
             else
             {
               return;
             }
        
    }

}

return 1;