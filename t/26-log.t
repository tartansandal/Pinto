#!perl

use strict;
use warnings;

use Test::More;

use Pinto::Tester;
use Pinto::Globals;
use Pinto::Tester::Util qw(make_dist_archive);

#------------------------------------------------------------------------------

my $t = Pinto::Tester->new;
$t->set_current_time(0); # Fix time to the beginning of the epoch

$t->run_ok(Add => {stack    => 'master',
	               archives => make_dist_archive("ME/Foo-0.01 = Foo~0.01") });

$t->run_ok(Copy => {from_stack => 'master', 
	                to_stack   => 'branch'} );

$t->run_ok(Add => {stack    => 'branch',
				   archives => make_dist_archive("ME/Bar-0.02 = Bar~0.02") });

#------------------------------------------------------------------------------

{

  my $buffer = '';
  my $stack  = 'master';
  my $out    = IO::String->new(\$buffer);

  $t->run_ok(Log => {stack => $stack, out => $out});
  
  my $msgs =()= $buffer =~ m/commit [0-9a-f\-]{36}/g;

  is $msgs, 1, "Stack $stack has correct message count";
  like $buffer, qr/Foo-0.01.tar.gz/,    'Log message has Foo archive';

  # TODO: Consider adding hook to set username on the Tester;
  like $buffer, qr/User: USERNAME/,     'Log message has correct user';

  # This test might not be portable, based on timezone and locale settings:
  like $buffer, qr/Date: Dec 31, 1969/, 'Log message has correct date';

}

#------------------------------------------------------------------------------

{

  my $buffer = '';
  my $stack  = 'branch';
  my $out    = IO::String->new(\$buffer);

  $t->run_ok(Log => {stack => $stack, out => $out});

  my $msgs =()= $buffer =~ m/commit [0-9a-f\-]{36}/g;

  is $msgs, 2, "Stack $stack has correct message count";
  like $buffer, qr/Foo-0.01.tar.gz/, 'Log messages have Foo archive';
  like $buffer, qr/Bar-0.02.tar.gz/, 'Log messages have Bar archive';

}

#-----------------------------------------------------------------------------

done_testing;
