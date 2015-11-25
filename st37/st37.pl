#!/usr/bin/perl

use LWP::UserAgent;
use URI;

use constant {
    CHMOD_RW => "0666",
    MAIN_URL => 'http://127.0.0.1/cgi-bin/lab4.cgi',
    STUDENT  => 37,
};

sub read_dbm {
    my ( $fn ) = @_;

    my @res;

    dbmopen(my %dbm_hash, $fn, CHMOD_RW) or die $!;

    for my $key ( @{ [sort { $a <=> $b } keys %dbm_hash] } ) {
        my @values = split( /::/,$dbm_hash{$key} );

        push @res, {
            phone => $values[0],
            model => $values[1],
            year  => $values[2],
        };

    }

    dbmclose (%dbm_hash);

    return \@res;
}

sub make_request {
    my ( $url, %params ) = @_;

    my $ua = LWP::UserAgent->new;

    $url = URI->new( $url );

    $url->query_form(
        student => STUDENT,
        phone  => $params{phone},
        model  => $params{model},
        year   => $params{year },
        action => "Add",
    );

    my $resp = $ua->get($url);

    if ( $resp->is_success ) {
        print "Done for phone: $params{phone}, model: $params{model}, year: $params{year}\n";
    }
    else {
        print "ERROR " . $resp->status_line . " for phone: $params{phone}, model: $params{model}, year: $params{year}\n";
    }

}


my $url = MAIN_URL;

while (1) {
    print "Type filename: ";

    chomp ( my $fn = <> );

    unless ( -f "$fn.pag" ) {
        print "No file. Write again.\n";
        next;
    };

    print "It's a right URL for query: $url [Y/n]: ";
    chomp( my $ans = <> );

    if ( $ans eq 'n' ) {
        print "Type URL: ";
        chomp( $url = <> );
    }

    print "Start writing\n";

    my $dbm = read_dbm( $fn );

    for my $row ( @$dbm ) {
        make_request( $url, %$row );
    }

    print "Done? [y/N]: ";
    chomp ( $ans = <> );

    exit if $ans eq 'y';
}
