# ABSTRACT: Delete archives from the repository

package Pinto::Action::Delete;

use Moose;
use MooseX::Types::Moose qw(Bool);

use Pinto::Exception qw(throw);
use Pinto::Types qw(DistSpecList);

use namespace::autoclean;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

extends qw( Pinto::Action );

#------------------------------------------------------------------------------

with qw( Pinto::Role::Transactional );

#------------------------------------------------------------------------------

has targets   => (
    isa      => DistSpecList,
    traits   => [ qw(Array) ],
    handles  => {targets => 'elements'},
    required => 1,
    coerce   => 1,
);


has force => (
    is        => 'ro',
    isa       => Bool,
    default   => 0,
);

#------------------------------------------------------------------------------


sub execute {
    my ($self) = @_;

    for my $target ( $self->targets ) {
        my $dist = $self->repo->get_distribution(spec => $target);
        throw "Distribution $target is not in the repository" if not $dist;
        $self->repo->delete(dist => $dist, force => $self->force);
    }

    return $self->result->changed;
}

#------------------------------------------------------------------------------

sub message_title {
    my ($self) = @_;

    my $targets  = join ' ', $self->targets;
    my $force    = $self->force ? ' with force' : '';

    return "Deleted$force $targets.";
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------

1;

__END__