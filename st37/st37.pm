package ST37;

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

use Data::Dumper;
use DBI;

use constant {
    USERNAME => 'root',
    PASSWORD => '',
    CHMOD_RW => 0666,
};

sub st37 {

    my ( $q, $global ) = @_;

    my $filename = "st37";
    my $add_edit = "Add";
    my @library;

    my %menu = (
        "Add"    => \&add,
        "Edit"   => \&pre_edit,
        "Change" => \&edit,
        "Delete" => \&delete,
        "Upload" => \&save_file_to_db,
    );

    sub show_form {
        print $q->start_form(-method => "post");

            print $q->hidden('student', $global->{'student'});

            my $number = $q->param('number') - 1;

            if ( $q->param('action') eq 'Edit' ) {
                print $q->h3( "Change record" );
            }
            else {
                print $q->h3("Add new phone");
            }

            print $q->hidden('id', $q->param('id'));

            print $q->start_table;

                print $q->Tr(
                    $q->td('Phone: '),
                    $q->td(
                        $q->textfield(
                            -name => "phone",
                            -size => 40,
                        ),
                    ),
                );

                print $q->Tr(
                    $q->td('Model: '),
                    $q->td(
                        $q->textfield(
                            -name => "model",
                            -size => 40,
                        ),
                    ),
                );

                print $q->Tr(
                    $q->td('Year: '),
                    $q->td(
                        $q->textfield(
                            -name => "year",
                            -size => 40,
                        ),
                    ),
                );

                print $q->Tr(
                    $q->td(
                        $q->checkbox(
                            -name  => 'in_use',
                            -label => 'Using NOW',
                        ),
                    ),
                );

                print $q->Tr(
                    $q->td(
                        '<br>',
                        $q->submit(
                            -name  => 'action',
                            -value => "$add_edit",
                        ),
                    ),
                );

            print $q->end_table;

        print $q->end_form;
    };


    sub add {
        my $phone  = $q->param('phone');
        my $model  = $q->param('model');
        my $year   = $q->param('year');
        my $in_use = $q->param('in_use');

        if ( $in_use ) {
            unuse_now_phone();
            $in_use = 1;
        }

        return unless $phone && $model && $year;

        db_write( $phone, $model, $year, $in_use );

        $q->delete_all;

        print $q->redirect(
            -uri => '/cgi-bin/lab3.cgi?student=37',
        );
    };

    sub read_list_from_db {

        my $res = dbh->()->selectall_hashref(qq/
            SELECT *
            FROM library
        /, 'id');

        for my $key ( sort { $a <=> $b } keys %$res ) {
            push @library, {
                Id    => $res->{$key}->{id},
                Phone => $res->{$key}->{phone},
                Model => $res->{$key}->{model},
                Year  => $res->{$key}->{year},
                Use   => $res->{$key}->{in_use},
            };
        }

    };

    sub show_table {
        print $q->start_table({-border => 1});

            print $q->Tr(
                $q->th(),
                $q->th( {-align => "center"}, "Id"     ),
                $q->th( {-align => "center"}, "Phone" ),
                $q->th( {-align => "center"}, "Model" ),
                $q->th( {-align => "center"}, "Year"  ),
                $q->th( {-align => "center"}, "Using now"  ),
            );

            for my $id ( 0..scalar @library - 1 ) {
                print $q->start_form(-method => "post");

                    print $q->hidden('student', $global->{'student'});
                    print $q->hidden(
                        -name  => 'number',
                        -value => $library[$id]{Id},
                    );

                    print $q->Tr(
                        $q->td(
                            $q->submit(
                                -name  => 'action',
                                -value => "Edit",
                            ),
                            $q->submit(
                                -name  => 'action',
                                -value => "Delete",
                            ),
                        ),
                        $q->td( {-align => "center"}, $id + 1              ),
                        $q->td( {-align => "center"}, $library[$id]{Phone} ),
                        $q->td( {-align => "center"}, $library[$id]{Model} ),
                        $q->td( {-align => "center"}, $library[$id]{Year}  ),
                        $q->td( {-align => "center"}, $library[$id]{Use} ? '<b>YES</b>' : 'NO'  ),
                    );

                print $q->end_form;
            }

        print $q->end_table;
    };

    sub delete {

        db_delete( $q->param('number') );

        $q->delete_all;

        print $q->redirect(
            -uri => '/cgi-bin/lab3.cgi?student=37',
        );
    }

    sub pre_edit {
        my $number = $q->param('number');

        my ( $row ) = grep { $_->{Id} == $number } @library;

        $q->param(
            -name  => 'id',
            -value => $row->{Id},
        );

        $q->param(
            -name  => 'phone',
            -value => $row->{Phone},
        );

        $q->param(
            -name  => 'model',
            -value => $row->{Model},
        );

        $q->param(
            -name  => 'year',
            -value => $row->{Year},
        );

        $q->param(
            -name => 'in_use',
            -value => $row->{Use} ? 'on' : undef,
        );

        $add_edit = "Change";
    }

    sub edit {

        my $id     = $q->param('id');
        my $phone  = $q->param('phone');
        my $model  = $q->param('model');
        my $year   = $q->param('year');
        my $in_use = $q->param('in_use');

        $in_use = $in_use ? 1 : 0;

        db_update( $id, $phone, $model, $year, $in_use );

        $q->delete_all();

        print $q->redirect(
            -uri => '/cgi-bin/lab3.cgi?student=37',
        );
    }


    sub show_uploader {
        print $q->start_form(-method => 'post');

            print $q->hidden('student', $global->{'student'});

            print $q->textfield( -name => 'dbfilename' );

            print $q->submit(
                -name  => 'action',
                -value => "Upload",
            );

        print $q->end_form;
    }


    sub save_file_to_db {
        my $fn = $q->param('dbfilename');

        dbmopen(my %dbm_hash, $fn, CHMOD_RW) or die $!;

        while ( my ( $k, $v ) = each %dbm_hash ) {

            my ( $phone, $model, $year ) = split(/::/,$v);

            db_write( $phone, $model, $year );

        }

        dbmclose(%dbm_hash);

        $q->delete_all;

        print $q->redirect(
            -uri => '/cgi-bin/lab3.cgi?student=37',
        );
    }

    sub db_write {
        my ( $phone, $model, $year, $in_use ) = @_;

        my $sth = dbh->()->prepare(qq/
            INSERT INTO library(phone, model, year, in_use)
            VALUES (?, ?, ?, ?)
        /) or die dbh->()->errstr;

        $sth->execute( $phone, $model, $year, $in_use ) or die dbh->()->errstr;
    }

    sub db_update {
        my ( $id, $phone, $model, $year, $in_use ) = @_;

        my $sth = dbh->()->prepare(qq/
            UPDATE library
            SET phone = ?, model = ?, year = ?, in_use = ?
            WHERE id = ?
        /) or die dbh->()->errstr;

        $sth->execute( $phone, $model, $year, $in_use, $id ) or die dbh->()->errstr;
    }


    sub db_delete {
        my ( $id ) = @_;

        my $sth = dbh->()->prepare(qq/
            DELETE FROM library
            WHERE id = ?
        /);

        $sth->execute( $id );
    }

    sub unuse_now_phone {
        my $sth = dbh->()->prepare(qq/
            UPDATE library
            SET in_use = 0
            WHERE in_use = 1
        /);

        $sth->execute or die dbh->()->errstr;
    }

    sub dbh {
        return DBI->connect('dbi:mysql:database=st37', USERNAME, PASSWORD);
    }


    read_list_from_db;

    $menu{ $q->param('action') }->() if $menu{ $q->param('action') };


    print $q->header(
        -type    => "text/html",
        -charset => "windows-1251",
    );

    print $q->start_html(
        -title   => "Вадим Станкевич. АСМ-1504",
    );

    print "<a href=\"$global->{selfurl}\">Back</a>";
    print $q->h1("Phones list");

    show_uploader;
    show_form;

    print $q->hr;
    print $q->delete_all;

    show_table;

    print $q->end_html;

}

1;
