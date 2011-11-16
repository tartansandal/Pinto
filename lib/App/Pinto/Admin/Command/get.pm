package App::Pinto::Admin::Command::get;

# ABSTRACT: get selected distributions from a remote repository

use strict;
use warnings;

use Pinto::Util;

#------------------------------------------------------------------------------

use base 'App::Pinto::Admin::Command';

#------------------------------------------------------------------------------

# VERSION

#-----------------------------------------------------------------------------

sub command_names { return qw( get fetch ) }

#-----------------------------------------------------------------------------

sub opt_spec {
    my ($self, $app) = @_;

    return (
        [ 'message|m=s' => 'Prepend a message to the VCS log' ],
        [ 'nocommit'    => 'Do not commit changes to VCS' ],
        [ 'noinit'      => 'Do not pull/update from VCS' ],
        [ 'tag=s'       => 'Specify a VCS tag name' ],
    );
}

#------------------------------------------------------------------------------

sub usage_desc {
    my ($self) = @_;

    my ($command) = $self->command_names();

    my $usage =  <<"END_USAGE";
%c --repos=PATH $command [OPTIONS] MODULE_NAME ...
%c --repos=PATH $command [OPTIONS] < LIST_OF_MODULE_NAMES
END_USAGE

    chomp $usage;
    return $usage;
}

#------------------------------------------------------------------------------

sub execute {
    my ($self, $opts, $args) = @_;

    my @args = @{$args} ? @{$args} : Pinto::Util::args_from_fh(\*STDIN);
    return 0 if not @args;

    $self->pinto->new_batch(%{$opts});
    $self->pinto->add_action('Get', %{$opts}, module => $_) for @args;
    $self->pinto->add_action('Clean') if $self->pinto->config->cleanup();
    my $result = $self->pinto->run_actions();

    return $result->is_success() ? 0 : 1;
}

#------------------------------------------------------------------------------

1;

__END__

=head1 SYNOPSIS

  pinto-admin --repos=/some/dir get [OPTIONS] MODULE_NAME ...
  pinto-admin --repos=/some/dir get [OPTIONS] < LIST_OF_MODULE_NAMES

=head1 DESCRIPTION

This command adds a local distribution archive and all its packages to
the repository and recomputes the 'latest' version of the packages
that were in that distribution.

When a distribution is first added to the repository, the author
becomes the owner of the distribution (actually, the packages).
Thereafter, only the same author can add new versions or remove those
packages.  However, this is not strongly enforced -- you can change
your author identity at any time using the C<--author> option.

=head1 COMMAND ARGUMENTS

Arguments to this command are paths to the distribution files that you
wish to add.  Each of these files must exist and must be readable.  If
a path looks like a URL, then the distribution first retrieved
from that URL and stored in a temporary file, which is subsequently
added.

You can also pipe arguments to this command over STDIN.  In that case,
blank lines and lines that look like comments (i.e. starting with "#"
or ';') will be ignored.

=head1 COMMAND OPTIONS

=over 4

=item --message=MESSAGE

Prepends the MESSAGE to the VCS log message that L<Pinto> generates.
This is only relevant if you are using a VCS-based storage mechanism
for L<Pinto>.

=item --nocommit

Prevents L<Pinto> from committing changes in the repository to the VCS
after the operation.  This is only relevant if you are
using a VCS-based storage mechanism.  Beware this will leave your
working copy out of sync with the VCS.  It is up to you to then commit
or rollback the changes using your VCS tools directly.  Pinto will not
commit old changes that were left from a previous operation.

=item --noinit

Prevents L<Pinto> from pulling/updating the repository from the VCS
before the operation.  This is only relevant if you are using a
VCS-based storage mechanism.  This can speed up operations
considerably, but should only be used if you *know* that your working
copy is up-to-date and you are going to be the only actor touching the
Pinto repository within the VCS.

=item --tag=NAME

Instructs L<Pinto> to tag the head revision of the repository at NAME.
This is only relevant if you are using a VCS-based storage mechanism.
The syntax of the NAME depends on the type of VCS you are using.

=back

=head1 DISCUSSION

Using the 'add' command on a distribution you got from another
repository (such as CPAN mirror) effectively makes that distribution
local.  So you become the owner of that distribution, even if the
repository already contains a copy that was pulled from another
repository by the 'update' command.

Local packages are always considered 'later' then any foreign package
with the same name, even if the foreign package has a higher version
number.  So a foreign package will not become 'latest' until all
versions of the local package with that name have been removed.

=cut
