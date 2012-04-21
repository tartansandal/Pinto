package Pinto::ActionResult;

# ABSTRACT: The result from running one Action

use Moose;

use MooseX::Types::Moose qw(Bool);

#-----------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

has made_changes => (
    is        => 'ro',
    isa       => Bool,
    writer    => '_set_made_changes',
    default   => 0,
);

has is_success => (
    is         => 'ro',
    isa        => Bool,
    writer     => '_set_is_success',
    default    => 1,
);

#-----------------------------------------------------------------------------

sub failed {
    my ($self) = @_;
    $self->_set_is_success(0);
    return $self;
}

#-----------------------------------------------------------------------------

sub changed {
    my ($self) = @_;
    $self->_set_made_changes(1);
    return $self;
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------
1;

__END__