

# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.05    |20.03.2001| JSTENZEL | adapted to tag templates;
#         |01.06.2001| JSTENZEL | adapted to modified lexing algorithm which takes
#         |          |          | "words" as long as possible;
#         |05.06.2001| JSTENZEL | adapted to further optimized lexing;
# 0.04    |09.12.2000| JSTENZEL | new namespace: "PP" => "PerlPoint";
# 0.03    |05.10.2000| JSTENZEL | parser takes a Safe object now;
# 0.02    |15.04.2000| JSTENZEL | adapted;
# 0.01    |08.04.2000| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# pragmata
use strict;

# load modules
use Carp;
use Safe;
use Test;
use PerlPoint::Backend;
use PerlPoint::Parser 0.34;
use PerlPoint::Constants;

# prepare tests
BEGIN {plan tests=>9;}

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream  => \@streamData,
             files   => ['t/simple.pp'],
             safe    => new Safe,
             trace   => TRACE_NOTHING,
             display => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    =>'installation test: simple tokens',
                                   trace   =>TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (DIRECTIVE_BLOCK .. DIRECTIVE_SIMPLE);

# now run the backend
$backend->run(\@streamData);

# perform checks
shift(@results) until $results[0] eq DIRECTIVE_SIMPLE;

# these checks are straight forward
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Simple tokens are supplied for simple words');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, ' ');
ok(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'and include words AND whitespaces.');



# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
