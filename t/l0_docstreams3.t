
# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.02    |27.12.2004| JSTENZEL | adapted to new headline path data;
#         |28.12.2004| JSTENZEL | adapted to dotted texts;
# 0.01    |02.03.2002| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# PerlPoint test script


# pragmata
use strict;
use lib qw(t);

# helper lib
use testlib;

# load modules
use Cwd;
use Carp;
use Safe;
use Test::More qw(no_plan);
use PerlPoint::Backend;
use PerlPoint::Parser 0.37;
use PerlPoint::Constants 0.16;

# declare variables
my (@streamData, @results);

# build parser
my ($parser)=new PerlPoint::Parser;

# and call it
$parser->run(
             stream          => \@streamData,
             files           => ['t/docstreams.pp'],
             filter          => 'pp|perl|anything',
             docstreams2skip => ['The ignored docstream'],
             docstreaming    => DSTREAM_IGNORE,
             safe            => new Safe,
             trace           => TRACE_NOTHING,
             display         => DISPLAY_NOINFO+DISPLAY_NOWARN,
            );

# build a backend
my $backend=new PerlPoint::Backend(
                                   name    => 'installation test: document streams (except for the main stream)',
                                   trace   => TRACE_NOTHING,
                                   display => DISPLAY_NOINFO,
                                  );

# register a complete set of backend handlers
$backend->register($_, \&handler) foreach (
                                           DIRECTIVE_BLOCK,
                                           DIRECTIVE_COMMENT,
                                           DIRECTIVE_DOCUMENT,
                                           DIRECTIVE_DPOINT,
                                           DIRECTIVE_DSTREAM_ENTRYPOINT,
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

# variable hash
my $varhash={_STARTDIR=>cwd(), _PARSER_VERSION=>$PerlPoint::Parser::VERSION, _SOURCE_LEVEL=>1};

# perform checks
is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_START, 'docstreams.pp');

is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 1, 'A two stream doc', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'HASH');
 is(join(' ', sort keys %$docstreams), '');
 checkHeadline(\@results, 1, ['A two stream doc'], ['A two stream doc'], [1], [1], $varhash);
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'A two stream doc');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 1);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'This document compares two imaginary objects');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 2, 'Advantages', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'HASH');
 is(join(' ', sort keys %$docstreams), '');
 checkHeadline(\@results, 2, ['A two stream doc', 'Advantages'], ['A two stream doc', 'Advantages'], [1, 1], [1, 2], $varhash);
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Advantages');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 2);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'What they are good in');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 2, 'Suggestions', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'HASH');
 is(join(' ', sort keys %$docstreams), '');
 checkHeadline(\@results, 2, ['A two stream doc', 'Suggestions'], ['A two stream doc', 'Suggestions'], [1, 2], [1, 3], $varhash);
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Suggestions');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 2);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Talks about things to be improved');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_START, 2, 'Conclusion', '');
{
 my $docstreams=shift(@results);
 is(ref($docstreams), 'HASH');
 is(join(' ', sort keys %$docstreams), '');
 checkHeadline(\@results, 2, ['A two stream doc', 'Conclusion'], ['A two stream doc', 'Conclusion'], [1, 3], [1, 4], $varhash);
}
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'Conclusion');
is(shift(@results), $_) foreach (DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, 2);

is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_START);
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, 'What the editors think and suggest');
is(shift(@results), $_) foreach (DIRECTIVE_SIMPLE, DIRECTIVE_START, '.');
is(shift(@results), $_) foreach (DIRECTIVE_TEXT, DIRECTIVE_COMPLETE);

is(shift(@results), $_) foreach (DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, 'docstreams.pp');


# SUBROUTINES ###############################################################################

# headline handler: store what you found
sub handler
 {
  # simply store what you received
  push(@results, @_);
 }
