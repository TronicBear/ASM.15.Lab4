
package ST11;
use strict;

  sub st11
{ 

  print "st11:st11\n";
  my @spisok=();
  my $kolvo=0;
  my @mass= (
  \&quit,
  \&add,         
  \&edit,
  \&delete,
  \&showlist,    
  \&saveto,
  \&loadfrom,
  \&fromdbmtobd
             );
  sub encoude_to{
  
    
  }

  sub fromdbmtobd{
     my $browser = LWP::UserAgent->new;
     my %buf;
     dbmopen(%buf, "spisokelementov", 0777);
     @list = ();
        while ( (my $key, my $value) = each %buf )
       {
         my ($persname, $perssurname) = split(/--/, $value);
         
          Encode::from_to($persname, 'windows-866', 'windows-1251');
          Encode::from_to($perssurname, 'windows-866', 'windows-1251');
            my $response = $browser->post(
              'http://localhost/cgi-bin/st11.pl',
              [
                'persname'  => $persname,
                'perssurname' => $perssurname,
                'degree' => ' ',
                'action' => 'to_add'
              ],
            );
         
       }
     dbmclose(%buf);
  } 
  sub add{
            print "Vvedite imya novogo elementa \n";
            my $persname = <STDIN>;
   	        chomp($persname);
            print "Vvedite familiyu novogo elementa\n";
            my $perssurname = <STDIN>;
   	        chomp($perssurname);
            my %person= ( name => $persname, surname => $perssurname);
            push(@spisok, \%person);
            $kolvo++;
  }
  sub showlist{
            if (@spisok>0){
              my $i=0;
                print "Spisok elementov:\n";
                 foreach my $person(@spisok)
        		    	{
        		    		  ++$i;
        		    		print "#$i. ".$person->{name}." ".$person->{surname}."\n";
        		    	}
              }
  else {print "Spisok pust\n ";}
      }

  sub edit{  
    if (@spisok>0){
              print "Vvedite nomer elementa kotoryi vy khotite redaktirovat'\n";
              my $elemnum = <STDIN>;
               chomp($elemnum);
               if( $elemnum<=$kolvo and $elemnum>0){
                 my $editelem=$spisok[$elemnum-1];
               
                print "Tekushee imya: ".$editelem->{name}.", vvedite novoe imya\n";
                 my $persname = <STDIN>;
               chomp($persname);
                print "Tekushaya familiya: ".$editelem->{surname}.", vvedite novuyu familiyu\n";
                 my $perssurname = <STDIN>;
                chomp($perssurname);
                 
                 $spisok[$elemnum-1]->{name}=$persname;
                 $spisok[$elemnum-1]->{surname}=$perssurname;
                 }else {print "Neverno vvedeny dannie\n";}
                }
  else {print "Spisok pust\n ";}
               
  }
  sub delete{
         if (@spisok>0){
           print "Vvedite nomer elementa kotoryi vy khotite udalit'\n";
                my $elemnum = <STDIN>;
               chomp($elemnum);
                if( $elemnum<=$kolvo and $elemnum>0){
               splice (@spisok, $elemnum - 1, 1); }
               else {print "Neverno vvedeny dannie\n";}
               }
        else {print "Spisok pust\n ";}
  }
  sub saveto{
         if (@spisok>0){
         my $i=0;
         my %buf;
         dbmopen (%buf, "spisokelementov", 0666) or die print "cant open file\n";
         foreach my $person(@spisok)
              {
                  $buf{$i} = join('--', $person->{name}, $person->{surname});
                  ++$i;
              }
        dbmclose(%buf);
     }
           else {print "Spisok pust\n ";}
  }
  sub loadfrom{
    
     my %buf;
     dbmopen(%buf, "spisokelementov", 0666);
     @spisok = ();
        while ( (my $key, my $value) = each %buf )
       {
         my ($persname, $perssurname) = split(/--/, $value);
         my %person = (name => $persname,surname => $perssurname);
         push(@spisok, \%person);
       }
     dbmclose(%buf);
  }
   
   sub quit{
    print "Zaversheno\n";
   return 1;
   }
  
  	while(1){
    
       print "\n
                1.Dobavit' novyi element\n 
    	          2.Redaktirovat'\n 
    	          3.Udalit'\n 
      	        4.Pokazat' ves' spisok\n 
     	          5.Zapisat' vo vneshniy fayl\n 
    	          6.Zagruzit' iz vneshnego fayla\n 
                7.Zagruzit iz dbm v bd(lab4).
                0.Vikhod\n ";
      
       my $ch = <STDIN>;
         chomp($ch); 
               if(defined $mass[$ch])
             { 
               $mass[$ch]->();
             }
             else
             {
               return;
             }
        
    }

}

return 1;