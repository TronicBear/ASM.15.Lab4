package ST26;

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use lab3::st26::Person;
use DBI;

sub st26
{
    my ($q, $global) = @_;
    my $filename = "st26db";
    my $dbname = "st26";
    my $tbname = "lab3";
    my $rc;
    my $db = DBI->connect(
                    "DBI:mysql:database=$dbname;host=localhost",
                    "root", 
                    "",
                    {'RaiseError' => 1, 'AutoCommit' => 1}
    );
    $db->do("SET NAMES cp1251");
    
    my @group;  
    my %actions = (
       'add' => \&add,
       'do_edit' => \&do_edit,
       'delete' =>\&del,
       'create_form' =>\&create,
       'edit' =>\&create,
       'save2dbm' =>\&save,
       'import_from_dbm' =>\&import_fdbm,
    );

    #create different types of forms
    sub create {
        my $f_name = "";
        my $l_name = "";
        my $course = "";
        my $stid = "";
        my $btn_tex = "add";
        my $type = "";
        my $n =  $q->param('n_row');
        if ($q->param('action') eq 'edit')
        {
            print "<h3> Edit Student Form </h3>";
            $btn_tex = "do_edit";
           
            if(defined  $group[$n-1])
            {
                $f_name = $group[$n-1]->getFirstName();
                $l_name = $group[$n-1]->getLastName();
                $type = $group[$n-1]->getDegree();
                $course = $group[$n-1]->getCourse();
                $stid = $group[$n-1]->getSTID();
            }
            
        }
        print $q->start_table;
        print $q->start_form( -method  => 'POST');
        print "<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">";
        print  "<input type=\"hidden\" name=\"n_row\" value=\"$n\">";
        if($q->param('group1') eq "B")
        {
            print "<h3> Add Bachelor Student Form </h3>";
            print "<input type=\"hidden\" name=\"degree\" value=\"Бакалавр\">";
        }
        elsif($q->param('group1') eq "M"){
            print "<h3> Add Master Student Form </h3>";
            print "<input type=\"hidden\" name=\"degree\" value=\"Магистр\">";
        }
        print $q->Tr(
                $q->td('First Name:'),
                $q->td("<input type=\"text\" name=\"f_name\" value=\"$f_name\">"));
        print $q->Tr(
                $q->td('Last Name:'),
                $q->td("<input type=\"text\" name=\"l_name\" value=\"$l_name\">"));
        print $q->Tr(
               $q->td('ST_ID:'),
               $q->td("<input type=\"text\" name=\"stid\" value=\"$stid\">"));
        if($q->param('group1') eq "M" || $type eq "Магистр")
        {
            print $q->Tr(
               $q->td('Course:'),
               $q->td("<input type=\"text\" name=\"course\" value=\"$course\">"));
        }
        print $q->Tr(
              $q->td( $q->submit(-name=> 'action',-value => "$btn_tex")
              ));
        print $q->end_form;
        print $q->end_table;
        print "<hr>";
    };

    #load students from dbm file function 
    sub load{ 
        undef(@group);
        my $pq = $db->prepare("select * from $tbname");
        $pq->execute; 
        while (my $ref = $pq->fetchrow_hashref()) {
            my $f = $ref->{f_name};
            my $l = $ref->{l_name};
            my $stid = $ref->{st_id};
            my $degree = $ref->{degree};
            my $course = $ref->{course};
            my $id = $ref->{id};
            push(@group,Person->new($f, $l, $stid,$degree,$course,$id));
        }
        $rc = $pq->finish;
    };

    #save students to dbm file 
    sub save{   
       if(@group>0)
        {
            dbmopen(my %data, $filename, 0644) or die "Cant open $filename file\n";
            %data = ();
            my $count = 0;
            for(@group) { 
                $data{++$count} =$_->getPerson();
            }     
            dbmclose(%data);
        }
    };

    #import students from dbm file to database 
    sub import_fdbm{ 
        undef(@group);
        dbmopen(my %data, $filename, 0644) or die "Cant open $filename file\n";  
        foreach my $key ( keys %data ) {
            (my $f, my $l,my $stid,my $degree,my $course)= split(/::@::/,$data{$key});
            my $pq = $db->prepare("insert into lab3 (f_name,l_name,st_id,degree,course) values (?,?,?,?,?) ");
            $pq->execute($f,$l,$stid,$degree,$course); 
        }
        dbmclose(%data);
        load();
    };

    #add student function 
    sub add {
        my $f_name = $q->param('f_name');
        $f_name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg; 
        my $l_name = $q->param('l_name');
        $l_name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        my $stid = $q->param('stid');
        my $degree = $q->param('degree');
        $degree =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        my $course = (defined $q->param('course')) ? $q->param('course') : "";
        $course=~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        my $pq = $db->prepare("insert into $tbname (f_name,l_name,st_id,degree,course) values (?,?,?,?,?) ");
        $pq->execute($f_name,$l_name,$stid,$degree,$course); 
        $rc = $pq->finish;
        load();
    };

    #edit student function 
    sub do_edit{
        my $num =  $q->param('n_row');
        my $pq = $db->prepare("UPDATE $tbname
                               SET f_name = ?,
                                   l_name = ?, 
                                   st_id = ?,
                                   degree =?,
                                   course =?
                               WHERE id = ?");
        
        my $f_name = $q->param('f_name');
        $f_name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg; 
        my $l_name = $q->param('l_name');
        $l_name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

        my $course = (defined $q->param('course')) ? $q->param('course') : "";
        $pq->bind_param(1, $f_name);
        $pq->bind_param(2, $l_name);
        $pq->bind_param(3,$q->param('stid'));
        $pq->bind_param(4,$group[$num-1]->getDegree());
        my $course = (defined $q->param('course')) ? $q->param('course') : "";
        $course=~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $pq->bind_param(5,$course);
        $pq->bind_param(6,$group[$num-1]->getID());
        $pq->execute();
        $rc = $pq->finish;
        load();
    };

    #delete_student function 
    sub del{
        my $num_row =  $q->param('n_row');
        my $pq = $db->prepare("DELETE FROM $tbname WHERE id=?");
        $pq->execute(@group[$num_row-1]->getID()); 
        $rc = $pq->finish;
        load();
    };

    #select form type function 
    sub show_form{   
        print $q->start_table;
        print $q->start_form( -method  => 'POST');
        print "<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">";
        print $q->Tr($q->td("<input type=\"radio\" name=\"group1\" value=\"B\" checked>  Bachelor"),
                       $q->td("<input type=\"radio\" name=\"group1\" value=\"M\" > Master"));
        print $q->Tr("<br>");
        print $q->Tr( $q->td($q->submit(-name=> 'action',-value => "create_form")));
        print $q->Tr("<br>");
        print $q->end_form;
        print $q->end_table;
    };

    #print students function 
    sub show_group{
        print "<h1> Группа студентов </h1>"; 
        print $q->start_form(-method  => 'POST');
        print "<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">";
        print $q->Tr(
              $q->td( $q->submit(-name=> 'action',-value => "save2dbm")),
              $q->td( $q->submit(-name=> 'action',-value => "import_from_dbm")
                ));
        print $q->end_form();

        print $q->Tr("<br>");
        print $q->start_table({-border=>1, -cellspacing=>0, -cellpadding=>1});
        print $q->Tr("<br>");
        print "<tr>
                    <th>-№-</th>
                    <th>-FirstName-</th>
                    <th>-LastName-</th>
                    <th>-Student ID-</th>
                    <th>-Degree-</th>
                    <th>-Course-</th>
                    <th>-Actions-</th>
                </tr>";
        my $count = 0;
        foreach (@group) { 
            ++$count;
            print $q->Tr(
                    $q->start_form(-method  => 'POST').
                    "<input type=\"hidden\" name=\"student\" value=\"".$global->{student}."\">
                     <input type=\"hidden\" name=\"n_row\" value=\"$count\">".
                     $q->td([$count,$_->getFirstName(), 
                                    $_->getLastName() ,
                                    $_->getSTID(), 
                                    $_->getDegree(), 
                                    $_->getCourse(), 
                                    $q->submit(-name=> 'action',-value => 'edit')."  ".$q->submit(-name=> 'action',-value => 'delete')]
                                    ).
                     $q->end_form()
                    );
        }     
        print $q->end_table;
        print "<hr>";
    };

    print $q->header(
        -type=>"text/html",
        -charset=>"windows-1251"
    );
    load();

    if(defined $actions{$q->param('action')} )
    {
        $actions{$q->param('action')}->();       
    }
    show_group();
    show_form();  
    print "<a href=\"$global->{selfurl}\">Back</a>";
    $db->disconnect();
}
return 1;