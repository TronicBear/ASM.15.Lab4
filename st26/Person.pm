package Person;

use strict;
sub new
{
    my $class = shift;
    my $self = {
        _firstName => shift,
        _lastName  => shift,
        _stid => shift,
        _degree =>shift,
        _course => shift,
        _id       => shift
    };
   
    bless $self, $class;
    return $self;
}


sub setFirstName {
    my ( $self, $firstName ) = @_;
    $self->{_firstName} = $firstName if defined($firstName);
    return $self->{_firstName};
}

sub setLastName {
    my ( $self, $lastName ) = @_;
    $self->{_lastName} = $lastName if defined($lastName);
    return $self->{_lastName};
}

sub setSTID{
    my ( $self, $st_id ) = @_;
    $self->{_stid} = $st_id  if defined($st_id );
    return $self->{_stid};
}

sub setDegree{
    my ( $self, $degree ) = @_;
    $self->{_degree} = $degree if defined($degree );
    return $self->{_degree};
}

sub setCourse{
    my ( $self, $course ) = @_;
    $self->{_course} = $course if defined($course );
    return $self->{_course};
}

sub setID{
    my ( $self, $id ) = @_;
    $self->{_id} = $id if defined($id);
    return $self->{_id};
}

sub getFirstName {
    my( $self ) = @_;
    return $self->{_firstName};
}

sub getLastName {
    my( $self ) = @_;
    return $self->{_lastName};
}

sub getSTID {
    my( $self ) = @_;
    return $self->{_stid};
}

sub getDegree {
    my( $self ) = @_;
    return $self->{_degree};
}

sub getCourse {
    my( $self ) = @_;
    return $self->{_course};
}

sub getID {
    my( $self ) = @_;
    return $self->{_id};
}

sub getPerson{
    my( $self ) = @_;
    return $self->{_firstName}."::@::".$self->{_lastName}."::@::".$self->{_stid}."::@::".$self->{_degree}."::@::".$self->{_course}."::@::".$self->{_id};

}
return 1;