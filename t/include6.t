
# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.01    |22.02.2002| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# pragmata
use strict;

# load modules
use Carp;
use Test::More qw(no_plan);
use PerlPoint::Backend;
use PerlPoint::Parser 0.37;
use PerlPoint::Constants;

# declare variables
my (@streamData, @results);

# init library path
$ENV{PERLPOINTLIB}='includelib';

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream  => \@streamData,
             files   => ['t/include6.pp'],
             filter  => 'pp|perl|anything',
             safe    => 0,
             libpath => [qw(includelib2)],
             trace   => TRACE_NOTHING,
             display => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: path search of included files',
                                   trace   => TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (
                                           DIRECTIVE_BLOCK,
                                           DIRECTIVE_COMMENT,
                                           DIRECTIVE_DOCUMENT,
                                           DIRECTIVE_DPOINT,
                                           DIRECTIVE_HEADLINE,
                                           DIRECTIVE_LIST_LSHIFT,
                                           DIRECTIVE_LIST_RSHIFT,
                                           DIRECTIVE_OPOINT,
                                           DIRECTIVE_TAG,
                                           DIRECTIVE_TEXT,
                                           DIRECTIVE_UPOINT,
                                           DIRECTIVE_VERBATIM,
                                           DIRECTIVE_SIMPLE,
                                          );

# now run the backend
$backend->run(\@streamData);

# perform checks
is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'include6.pp');

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This is a text from an included source found via PERLPOINTLIB.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This is a text from an included source found via libpath.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'include6.pp');


# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
