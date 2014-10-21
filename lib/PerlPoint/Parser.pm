####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package PerlPoint::Parser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

	$$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;

        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------


#line 10 "ppParser.yp"


# = HISTORY SECTION =====================================================================

# ---------------------------------------------------------------------------------------
# version | date     | author   | changes
# ---------------------------------------------------------------------------------------
# 0.44    |15.06.2006| JSTENZEL | new type "parsedexample" for \INCLUDE;
#         |06.08.2006| JSTENZEL | bugfix in parameter check of _evalTagCondition(): using
#         |          |          | "if defined $par" instead of "if $par";
#         |27.11.2006| JSTENZEL | better definition of flagSet() etc., old implementation
#         |          |          | was buggy;
# 0.43    |09.04.2006| JSTENZEL | slight code optimizations in file embedding;
#         |          | JSTENZEL | INCLUDE now has an "import" option with module API;
#         |          | JSTENZEL | included file type and embedded language now have
#         |          |          | default "pp";
#         |          | JSTENZEL | run(): new configuration parameter "importMapping";
# 0.42    |05.03.2006| JSTENZEL | non kernel tags now can be configured to be standalone,
#         |          |          | in which case a wrapping paragraph is removed from the
#         |          |          | stream (IMAGE and LOCALTOC configuration moved to tag
#         |          |          | definition);
#         |          |          | area, the wrapping paragraph is removed;
#         |07.03.2006| JSTENZEL | dummy tokens inserted by the parser now are special
#         |          |          | strings that can be filtered out by the backend module;
#         |10.03.2006| JSTENZEL | bugfix: statistics for list shifters did not work;
#         |          | JSTENZEL | Macro default parameters were not documented! Added.
# 0.41    |15.12.2005| JSTENZEL | almost all routines are internal, to avoid Pod::Coverage
#         |          |          | complaints they now begin with an underscore;
# 0.40    |12.06.2003| JSTENZEL | bugfix: delayed tokens were not reparsed when reinserted,
#         |          |          | this could cause trouble when the paragraph (special
#         |          |          | characters) context changed between the point the
#         |          |          | token was detected first and delayed, and the point
#         |          |          | the token is reinserted into the stream (especially
#         |          |          | important after file inclusion, when the stacked token
#         |          |          | is a newline, has to be evaluated in STATE_DEFAULT
#         |          |          | but was stacked in a paragraph where newlines are not
#         |          |          | ignored;
#         |          | JSTENZEL | additionally, "empty paragraphs" (*skipped* paragraphs)
#         |          |          | now are not only *really* empty paragraphs but all
#         |          |          | paragraphs containing of whitespaces only;
#         |21.06.2003| JSTENZEL | headlines provide additional data: their numerical, full
#         |          |          | and shortcut pathes;
#         |22.06.2003| JSTENZEL | _normalizeTableRows() now supplies number of columns both
#         |          |          | in title row and the maximum value;
#         |          | JSTENZEL | new warning if the maximum columns number is detected
#         |          |          | in another line than the first table line (which is the
#         |          |          | base of normalization);
#         |10.08.2003| JSTENZEL | new helper function _semerr() to report semantic errors;
#         |          | JSTENZEL | new option -criticalSemanticErrors;
#         |14.08.2003| JSTENZEL | input filters can access the source file by a variable
#         |          |          | $main::_ifilterFile now;
#         |          | JSTENZEL | fixed an "undefined value" warning;
#         |17.08.2003| JSTENZEL | bugfix: docstream "main" was ignored like any other docstream
#         |          |          | if working in the "docstream ignore" mode;
#         |10.09.2003| JSTENZEL | definition list explanations ("texts" now have an own
#         |          |          | enveloping directive (DIRECTIVE_DPOINT_TEXT);
#         |11.09.2003| JSTENZEL | LOCALTOC added to the list of standalone tags (which are
#         |          |          | stripped of of an enveloping text paragraph if they are its
#         |          |          | only contents);
#         |05.05.2004| JSTENZEL | anchors now take the number of the page they are defined in;
#         |          | JSTENZEL | tag hooks now take an additional parameter: the number of
#         |          |          | the page the tag is used on;
#         |          | JSTENZEL | bugfix: numerical pathes were built incorrectly: when entering
#         |          |          | a new sublevel, the counter was not reset to 1;
#         |          | JSTENZEL | added anchors();
#         |11.07.2004| JSTENZEL | headlines now provide a path of absolute page numbers as well
#         |          |          | and a variable snapshot;
#         |          | JSTENZEL | a reset variable is removed now (as a side effect, it is no
#         |          |          | longer possible to build variables containing spaces only);
#         |24.07.2004| JSTENZEL | added -skipcomments;
#         |10.09.2004| JSTENZEL | bugfix: words looking like symbolic variables (but not defined
#         |          |          | as such) were restored without their braces ("{}");
#         |27.12.2004| JSTENZEL | bugfix: skipped headline levels were filled with previous
#         |          |          | headline strings of those levels;
#         |28.12.2004| JSTENZEL | text paragraphs now have their own special character, but
#         |          |          | optional: a dot;
#         |24.02.2005| JSTENZEL | acceleration: the lexer built some data very often;
#         |27.02.2005| JSTENZEL | bugfix: backslashes before variables were handled incorrectly,
#         |          |          | now variables are no longer "boosted" but handled like macros
#         |          |          | - which has a performance drawback, unfortunately ...;
#         |16.05.2005| JSTENZEL | backslashes in tag options are no longer ignored but can be
#         |          |          | used to guard characters;
#         |23.08.2005| JSTENZEL | first chapter is checked for a headline now;
# 0.39    |01.02.2003| JSTENZEL | passing directive id chain of the current chapter
#         |          |          | headline to tag hook functions now;
#         |07.03.2003| JSTENZEL | several variable patterns were used explicitly instead
#         |          |          | if the precompiled ones from %lexerPatterns;
#         |          | JSTENZEL | bugfix: guarded variables were expanded;
#         |          | JSTENZEL | now it is documented that list indentation is reset
#         |          |          | automatically by a subsequent non list paragraph;
#         |26.04.2003| JSTENZEL | added "no utf8" to avoid errors under perl 5.8;
#         |01.05.2003| JSTENZEL | adding *all* composite anchors for headlines, not only
#         |          |          | for the full path;
# 0.38    |07.06.2002| JSTENZEL | restoring doubled backslashes in filtered paragraphs,
#         |          |          | restoring ">" characters as if they were guarded;
#         |04.07.2002| JSTENZEL | simplified several array field access codes;
#         |          | JSTENZEL | bugfix: empty headlines caused an infinite loop
#         |          |          | when trailing whitespaces should be removed;
#         |          | JSTENZEL | bugfix: empty headlines caused a failure when headline
#         |          |          | anchors should be stored, skipping them now;
#         |20.08.2002| JSTENZEL | improved tag streaming: stream now contains a body hint;
#         |          | JSTENZEL | bugfix: paragraph filters restored tag bodies even if
#         |          |          | there was no body;
#         |          | JSTENZEL | old caches need to be updated - adapted compatibility hint;
#         |27.08.2002| JSTENZEL | started to use precompiled lexer patterns;
#         |31.08.2002| JSTENZEL | \INCLUDE, \EMBED and \TABLE now support the _cnd_ option,
#         |          |          | like tags defined externally;
#         |04.12.2002| JSTENZEL | bugfix in pfilter retranslation: backslash reinsertion was
#         |          |          | not performed multiply;
#         |          | JSTENZEL | pfilter retranslation: backslash reinsertion now suppressed
#         |          |          | in verbatim blocks;
#         |01.01.2003| JSTENZEL | added input filter support to \EMBED, via option "ifilter";
#         |02.01.2003| JSTENZEL | added input filter support to \INCLUDE, same interface;
# 0.37    |up to     | JSTENZEL | flagSet() now takes a list of flag names;
#         |14.04.2002| JSTENZEL | names of included files are resolved to avoid trouble
#         |          |          | with links (and to avoid error messages);
#         |          | JSTENZEL | \INCLUDE searches pathes specified in environment
#         |          |          | variable PERLPOINTLIB (like perl, shells, linkers etc.);
#         |          | JSTENZEL | if tags with finish hooks are used, a paragraph will
#         |          |          | not be cached because it becomes potentially dynamic;
#         |          | JSTENZEL | anchors defined by a cached paragraph are cached now
#         |          |          | as well - and restored after a cache hit (updated cache
#         |          |          | format);
#         |          | JSTENZEL | \INCLUDE additionally searches pathes specified in an
#         |          |          | array passed to method run() via new parameter "libpath";
#         |          | JSTENZEL | Filtered paragraphs that need a parser lookahead into
#         |          |          | the next paragraph to be completely detected could cause
#         |          |          | trouble because the reinserted result was grammatically
#         |          |          | placed before the already parsed start token of the
#         |          |          | subsequent paragraph. Fixed by introducing a virtual,
#         |          |          | empty "Word" token supplied by the lexer in such cases
#         |          |          | (look for $flags{virtualParagraphStart} and
#         |          |          | $lexerFlags{cbell}). (By the way, this outdated an
#         |          |          | earlier solution using a virtual text paragraph startup
#         |          |          | and a delayed token - this former solution caused trouble
#         |          |          | when the paragraph following the filtered one was not
#         |          |          | a pure text (so even filtered texts did not work)).
#         |          | JSTENZEL | Filtered paragraphs are no longer cached - the filter
#         |          |          | makes them dynamical. Note that for combined paragraphs
#         |          |          | like compound blocks and lists this is true for the first
#         |          |          | part only, because subsequent parts can be cached in
#         |          |          | their original form (the filter will be applied when the
#         |          |          | parts will have been combined).
#         |          | JSTENZEL | paragraph filters: added retranslation of headlines and
#         |          |          | verbatim blocks;
#         |          | JSTENZEL | passing original paragraph type to filters by new variable
#         |          |          | $main::_pfilterType;
#         |          | JSTENZEL | generalized paragraph type constant to string translation;
#         |          | JSTENZEL | lexer delays to flag the end of the document source
#         |          |          | when a paragraph filter still needs to be applied
#         |          |          | (otherwise, the parser would not request more tokens
#         |          |          | because from his point of view the source was already
#         |          |          | parsed completely, so the filtering result (and the
#         |          |          | original block) would disappear from the result - it would
#         |          |          | not be reparsed);
#         |          | JSTENZEL | empty text paragraphs are no longer made part of the stream;
#         |          | JSTENZEL | blocks were streamed with a final newline, improved;
#         |          | JSTENZEL | added headline shortcuts;
#         |          | JSTENZEL | added document stream entry points;
#         |15.04.2002| JSTENZEL | added chapter docstream hints to headline stream data;
# 0.36    |10.08.2001| JSTENZEL | the stream became a more complex data structure to
#         |          |          | allow converter authors to act according to a documents
#         |          |          | structure (getting headlines without having to process
#         |          |          | all tokens, moving between chapters) - basically, it
#         |          |          | *remained* a stream (with additional structure info);
#         |29.09.2001| JSTENZEL | adapted stream initialization to intermediately
#         |          |          | modified design;
#         |          | JSTENZEL | bugfixes in _normalizeTableRows(): standalone single "0"
#         |          |          | in table cells was removed;
#         |07.10.2001| JSTENZEL | improved error messages provide an error pointer;
#         |11.10.2001| JSTENZEL | removed unused "use fields" directive;
#         |          | JSTENZEL | storing headline anchors now, depending on new
#         |          |          | flag headlineLinks;
#         |          | JSTENZEL | modified tag hook interface, tag body array is now
#         |          |          | passed by *reference*;
#         |          | JSTENZEL | passing anchor object to tag hooks;
#         |12.10.2001| JSTENZEL | added tag finish hook interface;
#         |13.10.2001| JSTENZEL | list shifts are no longer flagged by DIRECTIVE_START
#         |          |          | *and* DIRECTIVE_COMPLETED, no just by DIRECTIVE_START;
#         |          | JSTENZEL | headline start directives in the stream now provide
#         |          |          | the full (plain) headline;
#         |          | JSTENZEL | added tag conditions;
#         |14.10.2001| JSTENZEL | bugfix: passed tag options to parsing hooks instead
#         |          |          | of tag body;
#         |          | JSTENZEL | using new stream directive index constants;
#         |          | JSTENZEL | stream directives now begin with a hash reference to
#         |          |          | pass backend hints;
#         |17.10.2001| JSTENZEL | new directive format results in modified cache format,
#         |          |          | adapted automatic update;
#         |27.10.2001| JSTENZEL | list directives now contain hints about predecessing
#         |          |          | or following list shifts;
#         |29.10.2001| JSTENZEL | added paragraph filters (in a first version for verb. blocks);
#         |16.11.2001| JSTENZEL | improved _Error();
#         |          | JSTENZEL | improved lexer traces (did hide lines in verb. blocks and
#         |          |          | comments;
#         |          | JSTENZEL | Heredoc close sequence detection is no longer restricted
#         |          |          | to original source lines but also active for lines gotten
#         |          |          | from stack - this became possible because verbatim block
#         |          |          | lines are scanned in *completely* since version 0.34.
#         |          |          | As a result, it is possible now to generate verbatim
#         |          |          | blocks via active contents, but it is still impossible
#         |          |          | to do this for blocks and text paragraphs beginning with
#         |          |          | a tag or macro.
#         |17.11.2001| JSTENZEL | implemented a more general paragraph filter approach
#         |          |          | (still incomplete: needs to be extended for lists, needs
#         |          |          | retranslation of paragraph stream into text);
#         |18.11.2001| JSTENZEL | slightly improved _stackInput() (initially empty lines
#         |          |          | buffers would have been stacked, and a final buffer value
#         |          |          | of "0" would have been ignored);
#         |          | JSTENZEL | detection of block starts and text paragraphs beginning
#         |          |          | with a line now take stacked lines into consideration
#         |          |          | - this was suppressed because stacked input can begin
#         |          |          | anywhere in a real line and not just at the beginning,
#         |          |          | but now it is checked if there was a trailing \n in the
#         |          |          | previous stack entry (we do not have to check previous
#         |          |          | non stacked lines because there is no way to produce
#         |          |          | a beginning paragraph on the stack without a leading
#         |          |          | (and therefore stacked) empty line);
#         |          | JSTENZEL | text passed to paragraph filters is now retranslated from
#         |          |          | the paragraphs streams (implementation still incomplete);
#         |21.11.2001| JSTENZEL | macro definitions can now optionally take option defaults;
#         |22.11.2001| JSTENZEL | bugfix in macro definition tag option handling: no boost!;
#         |01.12.2001| JSTENZEL | tables can be filtered now;
#         |          | JSTENZEL | Compound paragraphs can be filtered now!
#         |          | JSTENZEL | lists can be filtered now, added retranslation parts;
#         |          | JSTENZEL | slightly restructered lexer parts: new _lineStartResearch();
#         |02.12.2002| JSTENZEL | slightly restructered lexer parts: new _refLexed()
#         |          |          | (to detect streamed parts placed in the input line, must
#         |          |          | have beed happened before as well??);
# 0.35    |16.06.2001| JSTENZEL | text paragraphs containing an image only are now
#         |          |          | transformed into just the image;
#         |22.07.2001| JSTENZEL | in order to make it run under 5.005 again, a pseudo
#         |          |          | hash was replaced by a pure and simple standard hash;
#         |22.07.2001| JSTENZEL | improved the "specials" pattern in lexer() by guarding "-";
#         |23.07.2001| JSTENZEL | opening input files in binmode() for Windows compatibility;
# 0.34    |14.03.2001| JSTENZEL | added parsing time report;
#         |          | JSTENZEL | slight code optimizations;
#         |20.03.2001| JSTENZEL | introduced tag templates declared via PerlPoint::Tags:
#         |22.03.2001| JSTENZEL | bugfix: macros could not contain "0":
#         |          | JSTENZEL | comments are now read at once, no longer lexed and parsed,
#         |          |          | likewise, verbatim block lines are handled as one word;
#         |25.03.2001| JSTENZEL | special character activation in tags is now nearer to the
#         |          |          | related grammatical constructs, so "<" is no longer a
#         |          |          | special after the tag body is opened;
#         |          | JSTENZEL | completed tag template interface by checks of mandatory
#         |          |          | parts and hooks into the parser to check options and body;
#         |01.04.2001| JSTENZEL | paragraphs using macros or variables are cached now -
#         |          |          | they can be reused unless macro/variable settings change;
#         |          | JSTENZEL | cache structure now stores parser version for compatibility
#         |          |          | checks;
#         |08.04.2001| JSTENZEL | removed ACCEPT_ALL support;
#         |          | JSTENZEL | improved special character handling in tag recognition
#         |          |          | furtherly: "=" is now very locally specialized;
#         |          | JSTENZEL | tag option and body hooks now take the tag occurence line
#         |          |          | number as their first argument, not the tag name which is
#         |          |          | of course already known to the hook function author;
#         |          | JSTENZEL | The new macro caching feature allowed to improve the cache
#         |          |          | another way: constructions looking like a tag or macro but
#         |          |          | being none of them were streamed and cached like strings
#         |          |          | (because they *were* strings). If later on somebody declared
#         |          |          | such a macro, the cache still found the paragraph unchanged
#         |          |          | (same checksum) and reused the old stream instead of building
#         |          |          | a new stream on base of the resolved macro. Now, if something
#         |          |          | looks like a macro, the macro cache checksum feature is
#         |          |          | activated, so every later macro definition will prevent the
#         |          |          | cached string representation of being reused. Instead of
#         |          |          | this, the new macro will be resolved, and the new resulting
#         |          |          | paragraph stream will be cached. This is by far more
#         |          |          | transparent and intuitive.
#         |11.04.2001| JSTENZEL | added predeclared variables;
#         |19.04.2001| JSTENZEL | embedded Perl code offering no code is ignored now;
#         |21.04.2001| JSTENZEL | replaced call to Parse::Yapps parser object method YYData()
#         |          |          | by direct access to its built in hash entry USER as suggested
#         |          |          | by the Parse::Yapp manual for reasons of efficiency;
#         |          | JSTENZEL | bugfix: all parts restored from @inputStack were handled as
#         |          |          | new lines which caused several unnecessay operations including
#         |          |          | line number updates, cache paragraph checksumming and
#         |          |          | removal of "leading" whitespaces (tokens recognized as Ils
#         |          |          | while we were still in a formerly started line) - this fix
#         |          |          | should accelerate processing of documents using numerous
#         |          |          | macros (when cached) and of course avoid invalid token removals;
#         |          | JSTENZEL | tables are now "normalized": if a table row contains less
#         |          |          | columns than the headline row, the missed columns are
#         |          |          | automatically added (this helps converters to detect empty columns);
#         |          | JSTENZEL | bugfix: internal table flags were not all reset if a table
#         |          |          | was completed, thus causing streams for subsequent tables
#         |          |          | being built with additional, incorrect elements;
#         |          | JSTENZEL | adapted macro handling to the new tag handling: if now options or
#         |          |          | or body was declared in the macro definition, options or body are
#         |          |          | not evaluated
#         |22.04.2001| JSTENZEL | the first bugfix yesterday was too common, improved;
#         |24.04.2001| JSTENZEL | bugfix: conditions were handled in headline state, causing
#         |          |          | backslashes to be removed; new state STATE_CONDITION added;
#         |          | JSTENZEL | added first function (flagSet()) of a simplified condition
#         |          |          | interface (SCI) which is intended to allow non (Perl) programmers
#         |          |          | to easily understand and perform common checks;
#         |27.04.2001| JSTENZEL | $^W is a global variable - no need to switch to the Safe
#         |          |          | compartment to modify it;
#         |          | JSTENZEL | added next function (varValue()) of a the SCI;
#         |29.04.2001| JSTENZEL | now the parser predeclares variables as well: first one is
#         |          |          | $_STARTDIR to flag where processing started;
#         |21.05.2001| JSTENZEL | bugfix in table handling: one column tables were not handled
#         |          |          | correctly, modified table handling partly by the way si that
#         |          |          | in the future it might become possible to have nested tables;
#         |22.05.2001| JSTENZEL | source nesting level is now reported by an internal variable _SOURCE_LEVEL;
#         |23.05.2001| JSTENZEL | table fields are trimmed now: beginning and trailing whitespaces are removed;
#         |24.05.2001| JSTENZEL | text paragraphs containing only a table become just a table now;
#         |24.05.2001| JSTENZEL | text paragraphs now longer contain a final whitespace (made from the
#         |          |          | final carriage return;
#         |25.05.2001| JSTENZEL | completed support for the new \TABLE flag option "rowseparator" which
#         |          |          | allows you to separate table columns by a string of your choice enabling
#         |          |          | streamed tables like in
#         |          |          | "Look: \TABLE{rowseparator="+++"} c1 | c2 +++ row 2, 1 | row 2, 2 \END_TABLE";
#         |          | JSTENZEL | slightly reorganized the way tag build table streams are completed,
#         |          |          | enabling a more common detection of prebuild stream parts - in fact, if
#         |          |          | this description makes no sense to you, this enables to place \END_TABLE
#         |          |          | even *in* the final table line instead of in a new line (as usually done
#         |          |          | and documented);
#         |26.05.2001| JSTENZEL | added new parser option "nestedTables" which enables table nesting if set
#         |          |          | to a true value. made nesting finally possible;
#         |          | JSTENZEL | to help converters handling nested tables, tables now provide their
#         |          |          | nesting level by the new internal table option "__nestingLevel__";
#         |27.05.2001| JSTENZEL | cache hits are no longer mentioned in the list of expected tokens displayed
#         |          |          | by _Error(), because the message is intended to be read by humans who
#         |          |          | cannot insert cache hits into a document;
#         |28.05.2001| JSTENZEL | new predeclared variable _PARSER_VERSION;
#         |          | JSTENZEL | new \INCLUDE option "localize";
#         |31.05.2001| JSTENZEL | new headline level offset keyword "base_level";
#         |01.06.2001| JSTENZEL | performance boost by lexing words no longer as real words or even
#         |          |          | characters but as the longest strings until the next special character;
#         |02.06.2001| JSTENZEL | improved table field trimming in _normalizeTableRows();
#         |05.06.2001| JSTENZEL | the last line in a source file is now lexed the optimized way as well;
#         |06.06.2001| JSTENZEL | cache structure now stores constant declarations version for compatability
#         |          |          | checks;
#         |09.06.2001| JSTENZEL | bugfix: headlines could not begin with a character that can start a
#         |          |          | paragraph - fixed by introducing new state STATE_HEADLINE_LEVEL;
#         |          | JSTENZEL | variable names can contain umlauts now;
#         |          | JSTENZEL | updated inlined module documentation (POD);
#         |          | JSTENZEL | used Storable version is now stored in cache, cache is rebuilt
#         |          |          | automatically if a different Storable version is detected;
#         |10.06.2001| JSTENZEL | added code execution by eval() (on users request);
#         |12.06.2001| JSTENZEL | code executed by eval() or do() is no started with "no strict" settings
#         |          |          | to enable unlimited access to functions, like under Safe control
#         |          |          | (also this is by no means optimal so it might be improved later);
#         |          | JSTENZEL | tag hooks can reply various values now;
#         |15.06.2001| JSTENZEL | tags take exactly *one* hook into consideration now: this simplifies
#         |          |          | and accelerates the interface *and* allows hooks for tags neither
#         |          |          | owning option nor nody;
# 0.33    |22.02.2001| JSTENZEL | slightly improved PerlPoint::Parser::DelayedToken;
#         |25.02.2001| JSTENZEL | variable values can now begin with every character;
#         |13.03.2001| JSTENZEL | bugfix in handling cache hits for continued ordered lists:
#         |          |          | list numbering is updated now;
#         |14.03.2001| JSTENZEL | added mailing list hint to POD;
#         |          | JSTENZEL | undefined return values of embedded Perl are no longer
#         |          |          | tried to be parsed, this is for example useful to
#         |          |          | predeclare functions;
#         |          | JSTENZEL | slight bugfix in internal ordered list counting which
#         |          |          | takes effect if an ordered list is *started* by "##";
# 0.32    |07.02.2001| JSTENZEL | bugfix: bodyless macros can now be used without moving
#         |          |          | subsequent tokens before the macro replacement;
#         |10.02.2001| JSTENZEL | added new special type "example" to \INCLUDE to relieve
#         |          |          | people who want to include files just as examples;
# 0.31    |30.01.2001| JSTENZEL | ordered lists now provide the entry level number
#         |          |          | (additionally to the first list point which already
#         |          |          | did this if the list was continued);
#         |01.02.2001| JSTENZEL | made POD more readable to pod2man;
#         |          | JSTENZEL | bugfix: if a headline is restored from cache, internal
#         |          |          | headline level flags need to be restored as well to
#         |          |          | make \INCLUDE{headlinebase=CURRENT_LEVEL} work when
#         |          |          | it is the first thing in a document except of headlines
#         |          |          | which are all restored from cache;
#         |          | JSTENZEL | new "smart" option of \INCLUDE tag suppresses inclusion
#         |          |          | if the file was already loaded, which is useful for alias
#         |          |          | definitions used both in a nested and the base source;
#         |02.02.2001| JSTENZEL | bugfix: circular source nesting was supressed too hard:
#         |          |          | a source could never be loaded twice, but this may be
#         |          |          | really useful to reuse files multiply - now only the
#         |          |          | currently nested sources are taken into account;
#         |03.02.2001| JSTENZEL | bugfix: continued lists did not work as expected yet,
#         |          |          | now they do (bug was detected by Lorenz), improved by
#         |          |          | the way: continued list points not really continuing
#         |          |          | are streamed now as usual list points (no level hint);
# 0.30    |05.01.2001| JSTENZEL | slight lexer improvement (removed obsolete code);
#         |          | JSTENZEL | modified the grammar a way that shift/reduce conflicts
#         |          |          | were reduced (slightly) and, more important, the grammar
#         |          |          | now passes yacc/bison (just a preparation);
#         |20.01.2001| JSTENZEL | variable settings are now propagated into the stream;
#         |          | JSTENZEL | improved syntactical error messages;
#         |23.01.2001| JSTENZEL | bugfix: embedding into tags failed because not all
#         |          |          | special settings were restored correctly, especially
#         |          |          | for ">" which completes a tag body;
#         |27.01.2001| JSTENZEL | fixed "unintialized value" warning (cache statistics);
#         |          | JSTENZEL | tag implementation is now more restrictive: according
#         |          |          | to the language definition tag and macro names now *have*
#         |          |          | to be built from capitals and underscores, thus reducing
#         |          |          | potential tag recognition confusion with ACCEPT_ALL;
#         |          | JSTENZEL | lowercased alias names in alias definitions are now
#         |          |          | automatically converted into capitals because of the
#         |          |          | modfied tag/macro recognition just mentioned before;
#         |          | JSTENZEL | POD: added a warning to the POD section that the cache
#         |          |          | should be cleansed after introducing new macros which
#         |          |          | could possibly be used as simple text before;
# 0.29    |21.12.2000| JSTENZEL | direct setting of $VERSION variable to enable CPAN to
#         |          |          | detect and display the parser module version;
#         |          | JSTENZEL | introduced base settings for active contents provided
#         |          |          | in %$PerlPoint - a new common way to pass things like
#         |          |          | the current target language;
#         |27.12.2000| JSTENZEL | closing angle brackets are to be guarded only *once*
#         |          |          | now - in former versions each macro level added the need
#         |          |          | of yet another backslash;
#         |28.12.2000| JSTENZEL | macro bodies are no longer reparsed which accelerates
#         |          |          | procesing of nested macros drastically (and avoids the
#         |          |          | overhead and dangers of rebuilding a source string and
#         |          |          | parsing it again - this way, parsing becomes easier to
#         |          |          | maintain in case of syntax extensions (nevertheless, the
#         |          |          | old code worked well!);
# 0.28    |14.12.2000| JSTENZEL | made it finally backward compatible to perl 5.005 again;
# 0.27    |07.12.2000| JSTENZEL | moved package namespace from "PP" to "PerlPoint";
# 0.26    |30.11.2000| JSTENZEL | "Perl Point" => "PerlPoint";
#         |02.12.2000| JSTENZEL | bugfix in _stackInput() which could remove input lines;
#         |          | JSTENZEL | new headline level offset keyword "current_level";
#         |03.12.2000| JSTENZEL | the parser now changes into a sourcefiles directory thus
#         |          |          | getting able to follow relative paths in nested sources;
#         |          | JSTENZEL | bugfix in input stack: must be multi levelled - we need
#         |          |          | one input stack per processed source!;
#         |          | JSTENZEL | cache data now contains headline level informations;
# 0.25    |22.11.2000| JSTENZEL | added notes about Storable updates;
#         |24.11.2000| JSTENZEL | bugfix in caching of embedded parts including empty lines;
#         |          | JSTENZEL | bugfix in modified ordered point intro handling;
#         |27.11.2000| JSTENZEL | bugfix in progress visualization;
#         |          | JSTENZEL | improved progress visualization;
#         |          | JSTENZEL | new experimental tag setting "\ACCEPT_ALL";
# 0.24    |10.11.2000| JSTENZEL | added incremental parsing ("caching");
#         |18.11.2000| JSTENZEL | slightly simplified the code;
#         |          | JSTENZEL | added ordered list continuations;
# 0.23    |28.10.2000| JSTENZEL | bugfix: indentation in embedded code was not accepted;
#         |          | JSTENZEL | using an input stack now for improved embedding;
#         |          | JSTENZEL | tracing active contents now;
# 0.22    |21.10.2000| JSTENZEL | new \INCLUDE headline offset parameter;
#         |25.10.2000| JSTENZEL | bugfixes in trace code;
#         |          | JSTENZEL | modified implementation of included file handling:
#         |          |          | reopening a handle did not work in all cases with perl5.6;
# 0.21    |11.10.2000| JSTENZEL | improved table paragraphs;
#         |14.10.2000| JSTENZEL | added alias/macro feature;
# 0.20    |10.10.2000| JSTENZEL | added table paragraphs;
# 0.19    |08.10.2000| JSTENZEL | added condition paragraphs;
#         |09.10.2000| JSTENZEL | bugfix in table handling: generated stream was wrong;
# 0.18    |05.10.2000| JSTENZEL | embedded Perl code is evaluated now, method run() takes
#         |          |          | a Safe object;
#         |07.10.2000| JSTENZEL | Perl code can now be included as well as embedded;
#         |          | JSTENZEL | variable values are now accessible by embedded and
#         |          |          | included Perl code;
#         |          | JSTENZEL | PerlPoint can now be embedded as well as included;
# 0.17    |04.10.2000| JSTENZEL | bugfix in documentation: colons have not to be guarded
#         |          |          | in definition texts;
#         |          | JSTENZEL | bugfixes in special token handling;
# 0.16    |30.09.2000| JSTENZEL | updated documentation;
#         |          | JSTENZEL | bugfix in special token handling;
#         |03.10.2000| JSTENZEL | definition list items can contain tags now;
#         |04.10.2000| JSTENZEL | added new target language filter feature;
# 0.15    |06.06.2000| JSTENZEL | there were still 5.6 specific operations, using
#         |          |          | IO::File now as an emulation under perl 5.005;
# 0.14    |03.06.2000| JSTENZEL | improved handling of special tag characters to simplify
#         |          |          | PP writing;
#         |          | JSTENZEL | bugfixes: stream contained trailing whitespaces for
#         |          |          | list points and headlines;
#         |          | JSTENZEL | bugfix: empty lines in verbatim blocks were not
#         |          |          | streamed;
#         |          | JSTENZEL | bugfix: stream contained leading newline for verbatim
#         |          |          | blocks;
#         |05.06.2000| JSTENZEL | switched back to 5.005 open() syntax to become compatible;
# 0.13    |01.06.2000| JSTENZEL | made it 5.003 compatible again;
# 0.12    |27.05.2000| JSTENZEL | leading spaces in list point lines are suppressed now;
#         |          | JSTENZEL | bugfix in run(): did not supply correct a return code;
#         |          | JSTENZEL | bugfix: last semantic action must be a true value to
#         |          |          | flag success (to the parser);
# 0.11    |20.05.2000| JSTENZEL | completed embedding feature;
#         |21.05.2000| JSTENZEL | bugfix in semantic error counting;
#         |          | JSTENZEL | added include feature;
#         |27.05.2000| JSTENZEL | added table feature (first version);
# 0.10    |17.04.2000| JSTENZEL | still incomplete embedding code added;
#         |03.05.2000| JSTENZEL | bugfix: verbatim block opener was added to stream
#         |          |          | because of the modified syntax (not completely impl.);
# 0.09    |11.04.2000| JSTENZEL | reorganized verbatim block start: spaces between "&"
#         |          |          | and "<<TERMINATOR" are no longer allowed, but text
#         |          |          | paragraphs with a startup "&" character are allowed now;
#         |          | JSTENZEL | added new paragraph type "definition list point";
#         |14.04.2000| JSTENZEL | streamed lists are embedded into list directives now;
#         |15.04.2000| JSTENZEL | modified syntax of verbatim blocks;
#         |          | JSTENZEL | added variables;
#         |          | JSTENZEL | modified tag syntax into "\TAG[{parlist}][<body>]";
# 0.08    |04.04.2000| JSTENZEL | started to implement the new pp2xy concept;
#         |07.04.2000| JSTENZEL | headlines are terminated by a REAL empty line now;
#         |          | JSTENZEL | old "points" became "unordered list points";
#         |          | JSTENZEL | added new paragraph type "ordered list point";
#         |08.04.2000| JSTENZEL | built in list shifting;
#         |09.04.2000| JSTENZEL | bugfix in text paragraph rule;
#         |10.04.2000| JSTENZEL | blocks are combined now automatically unless there is an
#         |          |          | intermediate control paragraph;
# 0.07    |25.03.2000| JSTENZEL | tag length is now 1 to 8 characters (instead of 1 to 3);
#         |          | JSTENZEL | POD fixes;
#         |          | JSTENZEL | using CPAN id's in HOC now;
# 0.06    |24.02.2000| JSTENZEL | trailing whitespaces in input lines are now removed
#         |          |          | (except of newlines!);
# 0.05    |11.10.1999| JSTENZEL | bugfix: paragraphs generated array references;
#         |          | JSTENZEL | PP::Parser::Constants became PP::Constants;
#         |          | JSTENZEL | adapted POD to pod2text (needs more blank lines);
# 0.04    |09.10.1999| JSTENZEL | moved certain constants into PP::Parser::Constants;
#         |          | JSTENZEL | completed POD;
# 0.03    |08.10.1999| JSTENZEL | started to generate intermediate data;
#         |          | JSTENZEL | simplified array access;
#         |          | JSTENZEL | bugfixes;
#         |09.10.1999| JSTENZEL | added data generation;
#         |          | JSTENZEL | all messages are written in English now;
#         |          | JSTENZEL | tags are declared outside now;
#         |          | JSTENZEL | exported the script part;
#         |          | JSTENZEL | added statistics;
#         |          | JSTENZEL | added trace and display control;
# 0.02    |07.10.1999| JSTENZEL | added C tag;
#         |          | JSTENZEL | added comment traces;
#         |          | JSTENZEL | bugfixes;
#         |          | JSTENZEL | made it pass -w;
#         |          | JSTENZEL | new "verbatim" paragraph;
# 0.01    |28.09.1999| JSTENZEL | new.
# ---------------------------------------------------------------------------------------

# = POD SECTION =========================================================================

=head1 NAME

B<PerlPoint::Parser> - a PerlPoint Parser

=head1 VERSION

This manual describes version B<0.44>.

=head1 SYNOPSIS

  # load the module:
  use PerlPoint::Parser;

  # build the parser and run it
  # to get intermediate data in @stream
  my ($parser)=new PerlPoint::Parser;
  $parser->run(
               stream => \@stream,
               files  => \@files,
              );


=head1 DESCRIPTION

The PerlPoint format, initially designed by Tom Christiansen, is intended
to provide a simple and portable way to generate slides without the need of
a proprietary product. Slides can be prepared in a text editor of your choice,
generated on any platform where you find perl, and presented by any browser
which can render the chosen output format.

To sum it up,
I<PerlPoint Software takes an ASCII text and transforms it into slides written in a certain document description language.>
This is, by tradition, usually HTML, but you may decide to use another format like
XML, SGML, TeX or whatever you want.

Well, this sounds fine, but how to build a translator which transforms ASCII
into the output format of your choice? Thats what B<PerlPoint::Parser> is made for.
It performs the first translation step by parsing ASCII and transforming it
into an intermediate stream format, which can be processed by a subsequently
called translator backend. By separating parsing and output generation we
get the flexibility to write as many backends as necessary by using the same
parser frontend for all translators.

B<PerlPoint::Parser> supports the complete I<GRAMMAR> with exception of I<certain>
tags. Tags I<are> supported the I<most common way>: the parser recognizes I<any>
tag which is declared by the author of a translator. This way the
parser can be used for various flavours of the PerlPoint language without
having to be modified. So, if there is a need of a certain new flag, it can
quickly be added without any change to B<PerlPoint::Parser>.

The following chapters describe the input format (I<GRAMMAR>) and the
generated stream format (I<STREAM FORMAT>). Finally, the class methods are
described to show you how to build a parser.


=head1 GRAMMAR

This chapter describes how a PerlPoint ASCII slide description has to be
formatted to pass B<PerlPoint::Parser> parsers.

I<Please note> that the input format does I<not> completely determine how
the output will be designed. The final I<format> depends on the backend
which has to be called after the parser to transform its output into a
certain document description language. The final I<appearance> depends on
the I<browsers> behaviour.

Each PerlPoint document is made of I<paragraphs>.

=head2 The paragraphs

All paragraphs start at the beginning of their first line. The first character
or string in this line determines which paragraph is recognized.

A paragraph is completed by an empty line (which may contain whitespaces).
Exceptions are described.

Carriage returns in paragraphs which are completed by an empty line
are transformed into a whitespace.

=over 4

=item Comments

start with "//" and reach until the end of the line.


=item Headlines

start with one or more  "=" characters.
The number of "=" characters represents the headline level.

  =First level headline

  ==Second level headline

  ===Multi
    line
   headline
  example

It is possible to declare a "short version" of the headline
title by appending a "~" and plain strings to the headline
like in

   =Very long headlines are expressive but may exceed the
    available space for example in HTML navigation bars or
    something like that ~ Long headlines

The "~" often stands for similarity, or represents the described
object in encyclopedias or dictionaries. So one may think of this
as "long title is (sometimes) similar to short title".



=item Lists

B<Points> or B<unordered lists> start with a "*" character.

  * This is a first point.

  * And, I forgot,
    there is something more to point out.

There are B<ordered lists> as well, and I<they> start with a hash sign ("#"):

  # First, check the number of this.

  # Second, don't forget the first.

The hash signs are intended to be replaced by numbers by a backend.

Because PerlPoint works on base of paragraphs, any paragraph different to
an ordered list point I<closes an ordered list>. If you wish the list to
be continued use a double hash sign in case of the single one in the point
that reopens the list.

  # Here the ordered list begins.

  ? $includeMore

  ## This is point 2 of the list that started before.

  # In subsequent points, the usual single hash sign
    works as expected again.

List continuation works list level specific (see below for level details).
A list cannot be continued in another chapter. Using "##" in the first
point of a new list takes no special effect: the list will begin as usual
(with number 1).

B<Definition lists> are a third list variant. Each item starts with the
described phrase enclosed by a pair of colons, followed by the definition
text:

  :first things: are usually described first,

  :others:       later then.

All lists can be I<nested>. A new level is introduced by
a special paragraph called I<"list indention"> which starts with a ">". A list level
can be terminated by a I<"list indention stop"> paragraph starting with a "<"
character. (These startup characters symbolize "level shifts".)

  * First level.

  * Still there.

>

  * A list point of the 2nd level.

<

  * Back on first level.

It is possible to shift more than one level by adding a number. There should be no whitespace between the
level shift character and the level number.

  * First level.

>

  * Second level.

>

  * Third level.

<2

  * Back on first level.

Level shifts are accepted between list items I<only>.

I<Please note that there is no need to shift levels back if a list is completed.> Any non list
paragraph will I<reset> list indentation, as well as the end of the source.


=item Texts

are paragraphs like points but begin I<immediately> without a startup
character:

  This is a simple text.

  In this new text paragraph,
  we demonstrate the multiline feature.

I<Optionally>, a text paragraph can be started with a special character
as well, which is a dot:

  .This is a simple text with dot.

  .In this new text paragraph,
  we demonstrate the multiline feature.

This is intended to be used by generators which translate other formats
into PerlPoint, to make sure the first character of a paragraph has no
special meaning to the PerlPoint parser.


=item Blocks

are intended to contain examples or code I<with> tag recognition.
This means that the parser will discover embedded tags. On the other hand,
it means that one may have to escape ">" characters embedded into tags. Blocks
begin with an I<indentation> and are completed by the next empty line.

  * Look at these examples:

      A block.

      \I<Another> block.
      Escape ">" in tags: \C<<\>>.

  Examples completed.

Subsequent blocks are joined together automatically: the intermediate empty
lines which would usually complete a block are translated into real empty
lines I<within> the block. This makes it easier to integrate real code
sequences as one block, regardless of the empty lines included. However,
one may explicitly I<wish> to separate subsequent blocks and can do so
by delimiting them by a special control paragraph:

  * Separated subsequent blocks:

      The first block.

  -

      The second block.

Note that the control paragraph starts at the left margin.


=item Verbatim blocks

are similar to blocks in indentation but I<deactivate>
pattern recognition. That means the embedded text is I<not> scanned for tags
and empty lines and may therefore remain as it was in its original place,
possibly a script.

These special blocks need a special syntax. They are implemented as here documents.
Start with a here document clause flagging which string will close the "here document":

  <<EOC

    PerlPoint knows various
    tags like \B, \C and \I. # unrecognized tags

  EOC


=item Tables

are supported as well, they start with an @ sign which is
followed by the column delimiter:

  @|
   column 1   |   column 2   |  column 3
    aaa       |    bbb       |   ccc
    uuu       |    vvvv      |   www

The first line is automatically marked as a  "table headline". Most converters
emphasize such headlines by bold formatting, so there is no need to insert \B
tags into the document.

If a table row contains less columns than the table headline, the "missed"
columns are automatically added. This is,

  @|
  A | B | C
  1
  1 |
  1 | 2
  1 | 2 |
  1 | 2 | 3

is streamed exactly like

  @|
  A | B | C
  1 |   |
  1 |   |
  1 | 2 |
  1 | 2 |
  1 | 2 | 3

to make backend handling easier. (Empty HTML table cells, for example, are rendered
slightly obscure by certain browsers unless they are filled with invisible characters,
so a converter to HTML can detect such cells because of normalization and handle them
appropriately.)

Please note that normalization refers to the headline row. If another line contains
I<more> columns than the headline, normalization does not care. If the maximum column
number is detected in another row, a warning is issued. (As a help for converter authors,
the title and maximum column number are made part of a table tag as internal options
C<__titleColumns__> and C<__maxColumns__>.)

In all tables, leading and trailing whitespaces of a cell are
automatically removed, so you can use as many of them as you want to
improve the readability of your source. The following table is absolutely
equivalent to the last example:

  @|
  A                |       B         |      C
  1                |                 |
   1               |                 |
    1              | 2               |
     1             |  2              |
      1            | 2               |      3

There is also a more sophisticated way to describe tables, see the tag section below.

Note: Although table paragraphs cannot be nested, tables declared by tag possibly
I<can> (and might be embedded into table paragraphs as well). To help converter authors
handling nested tables, the opening table tag provides an internal option "__nestingLevel__".


=item Conditions

start with a  "?" character. If active contents is enabled, the paragraph text
is evaluated as Perl code. The (boolean) evaluation result then determines if
subsequent PerlPoint is read and parsed. If the result is false, all subsequent
paragraphs until the next condition are I<skipped>.

Note that base data is made available by a global (package) hash reference
B<$PerlPoint>. See I<run()> for details about how to set up these data.

Conditions can be used to maintain various language versions of a presentation
in one source file:

  ? $PerlPoint->{targetLanguage} eq 'German'

Or you could enable parts of your document by date:

  ? time>$dateOfTalk

or by a special setting:

  ? flagSet('setting')

Please note that the condition code shares its variables with embedded and included
code.

To make usage easier and to improve readability, condition code is evaluated with
disabled warnings (the language variable in the example above may not even been set).

Converter authors might want to provide predefined variables such as "$language"
in the example.

Note: If a document uses I<document streams>, be careful in intermixing docstream
entry points and conditions. A condition placed in a skipped document stream will
not e evaluated. A document stream entry point placed in a source area hidden by
a false condition will not be reconized.


=item Variable assignment paragraphs

Variables can be used in the text and will be automatically replaced by their string
values (if declared).

  The next paragraph sets a variable.

  $var=var

  This variable is called $var.

All variables are made available to embedded and included Perl code as well as to
conditions and can be accessed there as package variables of "main::" (or whatever
package name the Safe object is set up to). Because a
variable is already replaced by the parser if possible, you have to use the fully
qualified name or to guard the variables "$" prefix character to do so:

  \EMBED{lang=perl}join(' ', $main::var, \$var)\END_EMBED

Variable modifications by embedded or included Perl I<do not> affect the variables
visible to the parser. (This is true for conditions as well.) This means that

  $var=10
  \EMBED{lang=perl}$main::var*=2;\END_EMBED

causes I<$var> to be different on parser and code side - the parser will still use a
value of 10, while embedded code works on with a value of 20.

=item Macro or alias definitions

Sometimes certain text parts are used more than once. It would be a relieve
to have a shortcut instead of having to insert them again and again. The same
is true for tag combinations a user may prefer to use. That's what I<aliases>
(or "macros") are designed for. They allow a presentation author to declare
his own shortcuts and to use them like a tag. The parser will resolve such aliases,
replace them by the defined replacement text and work on with this replacement.

An alias declaration starts with a "+" character followed I<immediately> by the
alias I<name> (without backslash prefix), optionally followed I<immediately>
by an option default list in "{}", followed I<immediately> by a colon.
(No additional spaces here.)

I<All text after this colon up to the paragraph closing empty line is stored as the replacement text.>
So, whereever you will use the new macro, the parser will replace it by this
text and I<reparse> the result. This means that your macro text can contain
any valid constructions like tags or other macros.

The replacement text may contain strings embedded into doubled underscores like
C<__this__>. This is a special syntax to mark that the macro takes parameters
of these names (e.g. C<this>). If a macro is used and these parameters are set,
their values will replace the mentioned placeholders. The special placeholder
"__body__" is used to mark where the macro I<body> is to place.

If a macro is used and defined options are I<unset>, but there are defaults
for them in the optional default list, these defaults will be used for the
respective options.

Here are a few examples:

  +RED:\FONT{color=red}<__body__>

  +F:\FONT{color=__c__}<__body__>

  +COLORED{c=blue}:\FONT{color=__c__}<__body__>

  +IB:\B<\I<__body__>>

  This \IB<text> is \RED<colored>.

  Defaults: first, text in \COLORED{c=red}<Red>,
  now text in \COLORED<Blue>.

  +TEXT:Macros can be used to abbreviate longer
     texts as well as other tags
  or tag combinations.

  +HTML:\EMBED{lang=html}

  Tags can be \RED<\I<nested>> into macros.
  And \I<\F{c=blue}<vice versa>>.
  \IB<\RED<This>> is formatted by nested macros.
  \HTML This is <i>embedded HTML</i>\END_EMBED.

  Please note: \TEXT

I<If no parameter is defined in the macro definition, options will not be recognized.>
The same is true for the body part.
I<Unless C<__body__> is used in the macro definition, macro bodies will not be recognized.>
This means that with the definition

  +OPTIONLESS:\B<__body__>

the construction

  \OPTIONLESS{something=this}<more>

is evaluated as a usage of C<\OPTIONLESS> without body, followed by the I<string>
C<{something=here}>. Likewise, the definition

  +BODYLESS:found __something__

causes

  \BODYLESS{something=this}<more>

to be recognized as a usage of C<\BODYLESS> with option C<something>, followed
by the I<string> C<<more>>. So this will be resolved as C<found this>. Finally,

  +JUSTTHENAME:Text phrase.

enforces these constructions

  ... \JUSTTHENAME, ...
  ... \JUSTTHENAME{name=Name}, ...
  ... \JUSTTHENAME<text>, ...
  ... \JUSTTHENAME{name=Name}<text> ...

to be translated into

  ... Text phrase. ...
  ... Text phrase.{name=Name} ...
  ... Text phrase.<text>, ...
  ... Text phrase.{name=Name}<text> ...

The principle behind all this is to make macro usage I<easier> and intuative:
why think of options or a body or of special characters possibly treated as
option/body part openers unless the macro makes use of an option or body?

An I<empty> macro text I<undefines> the macro (if it was already known).

  // undeclare the IB alias
  +IB:

An alias can be used like a tag.

Aliases named like a tag I<overwrite> the tag (as long as they are defined).


=item Document stream entry points

A document stream is a "document in document" and best explained by example.

  Consider a document talking about
  two scripts and comparing them. A
  typical review of this type is
  structured this way: headline, notes
  about script 1, notes about script 2,
  new headline to discuss another aspect,
  notes about script 1, notes about
  script 2, and so on.

Everything said about item 1 is a document stream, everything about object 2
as well. and a third stream is implicitly built by all parts outside these
two. In slide construction, each stream can have its own area, for example

  -------------------------------------
  |                                   |
  |            main stream            |
  |                                   |
  -------------------------------------
  |                 |                 |
  |  item 1 stream  |  item 2 stream  |
  |                 |                 |
  -------------------------------------

But to construct a layout like this, streams need to be distinguished, and
that is what "stream entry points" are made for.

A stream entry point starts with a "~" character, followed by a string
which is the name of the stream. This may be an internal name only, or
converters may turn it into a document part as well. The C<__ALL__> string
is reserved for internal purposes. It is recommended to treat C<__MAIN__>
as reserved as well, although it has no special meaning yet.

Once an entry point was passed, all subsequent document parts belong to the
declared stream, up to the next entry point or a headline which implicitly
switches back to the "main stream".

The parser can be instructed to ignore certain streams, see I<run()> for
details. If this feature is used, please be careful in intermixing stream
entry points and conditions. A condition placed in a skipped document
stream will not be evaluated.

I<It is up to a converter how document streams are used.> Certain converters
may ignore them at all. As a convenient solution, the parser can be instructed
to transform stream entry points into headlines (one level below the current
real headline level). See I<run()> for details.



=back

=head2 Tags

Tags are directives embedded into the text stream, commanding how certain parts
of the text should be interpreted. Tags are declared by using one or more modules
build on base of B<PerlPoint::Tags>.

  use PerlPoint::Tags::Basic;

B<PerlPoint::Parser> parsers can recognize all tags which are build of a backslash
and a number of capitals and numbers.

  \TAG

I<Tag options> are optional and follow the tag name immediately, enclosed
by a pair of corresponding curly braces. Each option is a simple string
assignment. The value has to be quoted if /^\w+$/ does not match it.

  \TAG{par1=value1 par2="www.perl.com" par3="words and blanks"}

The I<tag body> is anything you want to make the tag valid for. It is optional
as well and immediately follows the optional parameters, enclosed by "<" and ">":

  \TAG<body>
  \TAG{par=value}<body>

Tags can be I<nested>.

To provide a maximum of flexibility, tags are declared I<outside> the parser.
This way a translator programmer is free to implement the tags he needs. It is
recommended to always support the basic tags declared by B<PerlPoint::Tags::Basic>.
On the other hand,a few tags of special meaning are reserved and cannot be declared
by converter authors, because they are handled by the parser itself. These are:

=over 4

=item \INCLUDE

It is possible to include a file into the input stream. Have a look:

 \INCLUDE{type=HTML file=filename}

This imports the file "filename". The file contents is made part of the
generated stream, but not parsed. This is useful to include target language
specific, preformatted parts.

If, however, the file type is specified as "PP", the file contents is
made part of the input stream and parsed. In this case a special tag option
"headlinebase" can be specified to define a headline base level used as
an offset to all headlines in the included document. This makes it easier
to share partial documents with others, or to build complex documents by
including separately maintained parts, or to include one and the same
part at different headline levels.

 Example: If "\INCLUDE{type=PP file=file headlinebase=20}" is
          specified and "file" contains a one level headline
          like "=Main topic of special explanations"
          this headline is detected with a level of 21.

Pass the special keyword "CURRENT_LEVEL" to this tag option if you want to
set just the I<current> headline level as an offset. This results in
"subchapters".

 Example:

 ===Headline 3

 // let included chapters start on level 4
 \INCLUDE{type=PP file=file headlinebase=CURRENT_LEVEL}

Similar to "CURRENT_LEVEL", "BASE_LEVEL" sets the current I<base>
headline level as an offset. The "base level" is the level above
the current one. Using "BASE_LEVEL" results in parallel chapters.

 Example:

 ===Headline 3

 // let included chapters start on level 3
 \INCLUDE{type=PP file=file headlinebase=BASE_LEVEL}

A given offset is reset when the included document is parsed completely.

A second special option I<smart> commands the parser to include the file
only unless this was already done before. This is intended for inclusion
of pure alias/macro definition or variable assignment files.

 \INCLUDE{type=PP file="common-macros.pp" smart=1}

Included sources may declare variables of their own, possibly overwriting
already assigned values. Option "localize" works like Perls C<local()>:
such changes will be reversed after the nested source will have been
processed completely, so the original values will be restored. You can
specify a comma separated list of variable names or the special string
C<__ALL__> which flags that I<all> current settings shall be restored.

 \INCLUDE{type=PP file="nested.pp" localize=myVar}

 \INCLUDE{type=PP file="nested.pp" localize="var1, var2, var3"}

 \INCLUDE{type=PP file="nested.pp" localize=__ALL__}


PerlPoint authors can declare an I<input filter> to preprocess the
included file. This is done via option I<ifilter>:

  \INCLUDE{type=pp file="source.pod" ifilter="pod2pp()"}

An input filter is a snippet of user defined Perl code, taking the
included file via C<@main::_ifilterText> and the target type via
C<$main::_ifilterType>. The original filename can be accessed via
C<$main::_ifilterType>. It should supply its result as an array
of strings which will then be processed instead of the original file.

Input filters are Active Content. If Active Content is disabled,
\INCLUDE tags using input filters will be ignored I<completely>.


As a simplified option, C<import> allows to use I<predefined>
import filters defined in C<PerlPoint::Import::...> modules. To use
such a filter do I<not> set the C<ifilter> option, set C<import> instead.
C<import> takes the name of the source format, like "POD", or a true
number to indicate that the file extension should be used as the source
format name. The uppercased name is used as the final part of the filter
module - for "POD", the modules name would be "PerlPoint::Import::POD".
If this module is installed and has a function C<importFilter()> this
function name is used like C<ifilter>.

Here are a few examples:

  \INCLUDE{file="source.pod" import=1}

  \INCLUDE{file="source.pod" import=pod}

  \INCLUDE{file=source import=pod}

Please note that in the last example C<import=1> will not work, as the
source file has no extension that indicates its format is POD.

If C<ifilter> is used together with C<import>, C<import> is ignored.


A PerlPoint file can be included wherever a tag is allowed, but sometimes
it has to be arranged slightly: if you place the inclusion directive at
the beginning of a new paragraph I<and> your included PerlPoint starts by
a paragraph of another type than text, you should begin the included file
by an empty line to let the parser detect the correct paragraph type. Here
is an example: if the inclusion directive is placed like

  // include PerlPoint
  \INCLUDE{type=pp file="file.pp"}

and file.pp immediately starts with a verbatim block like

  <<VERBATIM
      verbatim
  VERBATIM

, I<the inclusion directive already opens a new paragraph> which is detected to
be "text" (because there is no special startup character). Now in the included
file, from the parsers point of view the included PerlPoint is simply a
continuation of this text, because a paragraph ends with an empty line. This
trouble can be avoided by beginning the included file by an empty line,
so that its first paragraph can be detected correctly.

The second special case is a file type of "Perl". If active contents is enabled,
included Perl code is read into memory and evaluated like I<embedded> Perl. The
results are made part of the input stream to be parsed.

  // execute a perl script and include the results
  \INCLUDE{type=perl file="disk-usage.pl"}

As another option, files may be declared to be of type "example" or "parsedexample".
This makes the file placed into the source as a verbatim block (with "example"), or
a standard block (with "parsedexample"), respectively, without need to copy its contents
into the source.

  // include an external script as an example
  \INCLUDE{type=example file="script.csh"}

All lines of the example file are included as they are but can be indented on request.
To do so, just set the special option "indent" to a positive numerical value equal to
the number of spaces to be inserted before each line.

  // external example source, indented by 3 spaces
  \INCLUDE{type=example file="script.csh" indent=3}

Including external scripts this way can accelerate PerlPoint authoring significantly,
especially if the included files are still subject to changes.

It is possible to filter the file types you wish to include (with exception
of "pp" and "example"), see below for details. I<In any case>, the mentioned file
has to exist.



=item \EMBED and \END_EMBED

Target format code does not necessarily need to be imported - it can be
directly I<embedded> as well. This means that one can write target language
code within the input stream using I<\EMBED>:

  \EMBED{lang=HTML}
  This is <i><b>embedded</b> HTML</i>.
  The parser detects <i>no</i> PerlPoint
  tag here, except of <b>END_EMBED</b>.
  \END_EMBED

Because this is handled by I<tags>, not by paragraphs, it can be placed
directly in a text like this:

  These \EMBED{lang=HTML}<i>italics</i>\END_EMBED
  are formatted by HTML code.

Please note that the EMBED tag does not accept a tag body (to avoid
ambiguities).

Both tag and embedded text are made part of the intermediate stream.
It is the backends task to deal with it. The only exception of this rule
is the embedding of I<Perl> code, which is evaluated by the parser.
The reply of this code is made part of the input stream and parsed as
usual.

PerlPoint authors can declare an I<input filter> to preprocess the
embedded text. This is done via option I<ifilter>:

  \EMBED{lang=pp ifilter="pod2pp()"}

  =head1 POD formatted part

  This part was written in POD.

  \END_EMBED

An input filter is a snippet of user defined Perl code, taking the
embedded text via C<@main::_ifilterText> and the target language via
C<$main::_ifilterType>. The original filename can be accessed via
C<$main::_ifilterType> (but please note that this is the source with
the \EMBED tag). It should supply its result as an array of
strings which will then be processed as usual.

Input filters are Active Contents. If Active Contents is disabled,
embedded parts using input filters will be ignored I<completely>.

It is possible to filter the languages you wish to embed (with exception
of "PP"), see below for details.


=item \TABLE and \END_TABLE

It was mentioned above that tables can be built by table paragraphs.
Well, there is a tag variant of this:

  \TABLE{bg=blue separator="|" border=2}
  \B<column 1>  |  \B<column 2>  | \B<column 3>
     aaaa       |     bbbb       |  cccc
     uuuu       |     vvvv       |  wwww
  \END_TABLE

This is sligthly more powerfull than the paragraph syntax: you can set
up several table features like the border width yourself, and you can
format the headlines as you like.

As in all tables, leading and trailing whitespaces of a cell are
automatically removed, so you can use as many of them as you want to
improve the readability of your source.

The default row separator (as in the example above) is a carriage return,
so that each table line can be written as a separate source line. However,
PerlPoint allows you to specify another string to separate rows by option
C<rowseparator>. This allows to specify a table I<inlined> into a paragraph.

  \TABLE{bg=blue separator="|" border=2 rowseparator="+++"}
  \B<column 1> | \B<column 2> | \B<column 3> +++ aaaa
  | bbbb | cccc +++ uuuu | vvvv|  wwww \END_TABLE

This is exactly the same table as above.

If parser option I<nestedTables> is set to a true value calling I<run()>,
it is possible to I<nest> tables. To help converter authors handling this,
the opening table tag provides an internal option "__nestingLevel__".

Tables built by tag are normalized the same way as table paragraphs are.

=back


=head2 What about special formatting?

Earlier versions of B<pp2html> supported special format hints like the HTML
expression "&gt;" for the ">" character, or "&uuml;" for "�". B<PerlPoint::Parser>
does I<not> support this directly because such hints are specific to the
I<output format> - if someone wants to translate into TeX, it might be curious
for him to use HTML syntax in his ASCII text. Further more, such hints can be
handled I<completely> by a backend which finds them unchanged in the produced
output stream.

The same is true for special headers and trailers. It is a I<backend> task to
add them if necessary. The parser does handle the I<input> only.


=head1 STREAM FORMAT

It is suggested to use B<PerlPoint::Backend> to evaluate the intermediate format.
Nevertheless, here is the documentation of this format.

The generated stream is an array of tokens. Most of them are very simple,
representing just their contents - words, spaces and so on. Example:

  "These three words."

could be streamed into

  "These three" + " "+ "words."

(This shows the principle. Actually this complete sentence would be replied as
I<one> token for reasons of effeciency.)

Note that the final dot I<is part> of the last token. From a document
description view, this should make no difference, its just a string containing
special characters or not.

Well, besides this "main stream", there are I<formatting directives>. They
flag the I<beginning> or I<completion> of a certain logical entity - this
means a whole document, a paragraph or a formatting like italicising. Almost
every entity is embedded into a start I<and> a completion directive - except
of simple tokens.

In the current implementation, a directive is a reference to an array of mostly
two fields: a directive constant showing which entity is related, and a start
or completion hint which is a constant, too. The used constants are declared in
B<PerlPoint::Constants>. Directives can pass additional informations by additional
fields. By now, the headline directives use this feature to show the headline
level, as well as the tag ones to provide tag type information and the document ones
to keep the name of the original document. Further more, ordered list points I<can>
request a fix number this way.

  # this example shows a tag directive
  ... [DIRECTIVE_TAG, DIRECTIVE_START, "I"]
  + "formatted" + " " + "strings"
  + [DIRECTIVE_TAG, DIRECTIVE_COMPLETE, "I"] ...

To recognize whether a token is a basic or a directive, the ref() function can be
used. However, this handling should be done by B<PerlPoint::Backend> transparently.
The format may be subject to changes and is documented for information purposes only.

Original line numbers are no part of the stream but can be provided by embedded
directives on request, see below for details.

This is the complete generator format. It is designed to be simple but powerful.


=head1 METHODS

=head2 new()

The constructor builds and prepares a new parser object.

B<Parameters:>

=over 4

=item The class name.

=back

B<Return value:>
The new object in case of success.

B<Example:>

  my ($parser)=new PerlPoint::Parser;

=cut

# = CODE SECTION ========================================================================

 # startup actions
 BEGIN
  {
   # declare startup helper function
   sub _startupGenerateConstants
     {
      # init counter
      my $c=0;

      # and generate constants
      foreach my $constant (@_)
	{eval "use constant $constant => $c"; $c++;}
     }

   # declare internal constants: action timeout types (used as array indices, sort alphabetically!)
   _startupGenerateConstants(
                            'LEXER_TOKEN',           # reply symbols token;
                            'LEXER_FATAL',           # bug: unexpected symbol;
                            'LEXER_IGNORE',          # ignore this symbol;
                            'LEXER_EMPTYLINE',       # reply the token "Empty_line";
                            'LEXER_SPACE',           # reply the token "Space" and a simple whitespace;
                           );

   # state constants
   _startupGenerateConstants(
                            'STATE_DEFAULT',         # default;
                            'STATE_DEFAULT_TAGMODE', # default in tag mode;

                            'STATE_BLOCK',           # block;
                            'STATE_COMMENT',         # comment;
                            'STATE_CONTROL',         # control paragraph (of a single character);
                            'STATE_DPOINT',          # definition list point;
                            'STATE_DPOINT_ITEM',     # definition list point item (defined stuff);
                            'STATE_EMBEDDING',       # embedded things (HTML, Perl, ...);
                            'STATE_PFILTER',         # paragraph filter installation;
                            'STATE_PFILTERED',       # "default" state after a pfilter installation;
                            'STATE_CONDITION',       # condition;
                            'STATE_HEADLINE_LEVEL',  # headline level setting;
                            'STATE_HEADLINE',        # headline;
                            'STATE_OPOINT',          # ordered list point;
                            'STATE_TEXT',            # text;
                            'STATE_UPOINT',          # unordered list point;
                            'STATE_VERBATIM',        # verbatim block;
                            'STATE_TABLE',           # table *paragraph*;
                            'STATE_DEFINITION',      # macro definition;
                           );

   # declare internal constants: list shifters
   _startupGenerateConstants(
                            'LIST_SHIFT_RIGHT',      # shift right;
                            'LIST_SHIFT_LEFT',       # shift left;
                           );

   # release memory
   undef &_startupGenerateConstants;
  }

 # requires modern perl
 require 5.00503;

 # declare module version
 $PerlPoint::Parser::VERSION=0.44;
 $PerlPoint::Parser::VERSION=$PerlPoint::Parser::VERSION; # to suppress a warning of exclusive usage only;

 # pragmata
 use strict;

 # load modules
 use Carp;
 # use Memoize;
 use IO::File;
 use File::Basename;
 use File::Spec::Functions;
 use File::Temp qw(tempfile);
 use PerlPoint::Anchors 0.03;
 use PerlPoint::Backend 0.10;
 use Cwd qw(:DEFAULT abs_path);
 use Digest::SHA1 qw(sha1_base64);
 use Storable qw(:DEFAULT dclone nfreeze);
 use PerlPoint::Constants 0.19 qw(:DEFAULT :parsing :stream :tags);

 # memoizations

 # startup declarations
 my (
     %data,                        # the collected declaration data;
     %lineNrs,                     # the lexers line number hash, input handle specific;
     %specials,                    # special character control (may be active or not);
     %lexerFlags,                  # lexer state flags;
     %lexerFlagsOfPreviousState,   # buffered lexer state flags of previous state;
     %statistics,                  # statistics data;
     %variables,                   # user managed variables;
     %flags,                       # various flags;
     %macros,                      # macros / aliases;
     %openedSourcefiles,           # a hash of all source files already opened (to enable smart inclusion);
     %paragraphTypeStrings,        # paragraph type to string translation table;

     @nestedSourcefiles,           # a list of current source file nesting (to avoid circular inclusions);
     @specialStack,                # special state stack for temporary activations (to restore original states);
     @stateStack,                  # state stack (mostly intended for non paragraph states like STATE_EMBEDDED);
     @tableSeparatorStack,         # the first element is the column separator string within a table, empty otherwise;
     @inputStack,                  # a stack of additional input lines and dynamically inserted parts;
     @inHandles,                   # a stack of input handles (to manage nested sources);
     @olistLevels,                 # a hint storing the last recent ordered list level number of a paragraph (hyrarchically);
     @inLine,                      # current *real* input line (the unexpanded line read from a source file);
     @previousStackLines,          # buffer of the last lines gotten from input stack;
     @libraryPath,                 # a collection of pathes to find files for \INCLUDE in;
     @headlineIds,                 # the hierarchical values of $directiveCounter pointing to the current chapter headline;

     $anchors,                     # anchor collector object;
     $safeObject,                  # an object of class Safe to evaluate Perl code embedded into PerlPoint;
     $sourceFile,                  # the source file currently read;
     $tagsRef,                     # reference to a hash of valid tag openers (strings without the "<");
     $resultStreamRef,             # reference to a data structure to put generated stream data in;
     $inHandle,                    # the data input stream (to parse);
     $parserState,                 # the current parser state;
     $readCompletely,              # the input file is read completely;
     $_semerr,                      # semantic error counter;
     $tableColumns,                # counter of completed table columns;
     $checksums,		   # paragraph checksums (and associated stream parts);
     $macroChecksum,               # the current macro checksum;
     $varChecksum,                 # the current user variables checksum;
     $pendingTags,                 # list of tags to be finished after parsing (collected using a structure);
     $directiveCounter,            # directive counter (just to mark stream directive pairs uniquely);
     $retranslator,                # a backend object used to restore paragraph sources to be filtered;
     $retranslationBuffer,         # buffer used in retranslation (needs to b global to avoid closure effects with lexicals in translator routines);
    );

 # ----- Startup code begins here. -----

 # prepare main input handle (obsolete when all people will use perl 5.6)
 $inHandle=new IO::File;

 # set developer data
 my ($developerName, $developer)=('J. Stenzel', 'perl@jochen-stenzel.de');

 # init flag
 $readCompletely=0;

 # prepare a common pattern
 my $patternWUmlauts=qr/[\w�������]+/;

 # prepare lexer patterns
 my $patternNlbBackslash=qr/(?<!\\)/;
 my %lexerPatterns=(
                    tag              => qr/$patternNlbBackslash\\([A-Z_0-9]+)/,
                    space            => qr/(\s+)/,
                    pfilterDelimiter => qr/$patternNlbBackslash((\|){1,2})/,
                    table            => qr/$patternNlbBackslash\\(TABLE)/,
                    endTable         => qr/$patternNlbBackslash\\(END_TABLE)/,
                    embed            => qr/$patternNlbBackslash\\(EMBED)/,
                    endEmbed         => qr/$patternNlbBackslash\\(END_EMBED)/,
                    include          => qr/$patternNlbBackslash\\(INCLUDE)/,
                    nonWhitespace    => qr/$patternNlbBackslash(\S)/,
                    colon            => qr/$patternNlbBackslash(:)/,
                    namedVarKernel   => qr/\$($patternWUmlauts)/,
                    symVarKernel     => qr/\$({($patternWUmlauts)})/,
                   );
  @lexerPatterns{qw(
                    namedVar
                    symVar
                   )
                }=(
                   qr/$patternNlbBackslash$lexerPatterns{namedVarKernel}/,
                   qr/$patternNlbBackslash$lexerPatterns{symVarKernel}/,
                  );

 # declare paragraphs which are embedded
 my %embeddedParagraphs;
 @embeddedParagraphs{
                     DIRECTIVE_UPOINT,
                     DIRECTIVE_OPOINT,
                    }=();

 # declare token descriptions (to be used in error messages)
 my %tokenDescriptions=(
                        EOL                      => 'a carriage return',
                        Embed                    => 'embedded code',
                        Embedded                 => 'an \END_EMBED tag',
                        Empty_line               => 'an empty line',
                        Heredoc_close            => 'a string closing the "here document"',
                        Heredoc_open             => 'a "here document" opener',
                        Ils                      => 'a indentation',
                        Include                  => 'an included part',
                        Named_variable           => 'a named variable',
                        Space                    => 'a whitespace',
                        StreamedPart             => undef,
                        Symbolic_variable        => 'a symbolic variable',
                        Table                    => 'a table',
                        Table_separator          => 'a table column separator',
                        Tabled                   => 'an \END_TABLE tag',
                        Tag_name                 => 'a tag name',
                        Word                     => 'a word',
                        NoToken                  => 'an internal dummy token that is finally ignored',
                       );



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'Paragraph_cache_hit' => 11,
			"||" => 4,
			'Empty_line' => 3,
			"+" => 5,
			"?" => 2
		},
		DEFAULT => -3,
		GOTOS => {
			'non_filterable_paragraph' => 1,
			'document' => 6,
			'restored_paragraph' => 7,
			'alias_definition' => 8,
			'built_paragraph' => 9,
			'optional_paragraph_filter' => 10,
			'condition' => 12,
			'paragraph' => 13
		}
	},
	{#State 1
		DEFAULT => -12
	},
	{#State 2
		DEFAULT => -33,
		GOTOS => {
			'@4-1' => 14
		}
	},
	{#State 3
		DEFAULT => -22
	},
	{#State 4
		DEFAULT => -4,
		GOTOS => {
			'@1-1' => 15
		}
	},
	{#State 5
		DEFAULT => -152,
		GOTOS => {
			'@31-1' => 16
		}
	},
	{#State 6
		ACTIONS => {
			'' => 17,
			'Paragraph_cache_hit' => 11,
			"||" => 4,
			'Empty_line' => 3,
			"+" => 5,
			"?" => 2
		},
		DEFAULT => -3,
		GOTOS => {
			'non_filterable_paragraph' => 1,
			'built_paragraph' => 9,
			'optional_paragraph_filter' => 10,
			'restored_paragraph' => 7,
			'paragraph' => 18,
			'condition' => 12,
			'alias_definition' => 8
		}
	},
	{#State 7
		DEFAULT => -9
	},
	{#State 8
		DEFAULT => -24
	},
	{#State 9
		DEFAULT => -8
	},
	{#State 10
		DEFAULT => -10,
		GOTOS => {
			'@2-1' => 19
		}
	},
	{#State 11
		DEFAULT => -25
	},
	{#State 12
		DEFAULT => -23
	},
	{#State 13
		DEFAULT => -1
	},
	{#State 14
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Tag_name' => 34,
			'Symbolic_variable' => 33,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 20,
			'basics' => 29,
			'embedded' => 31,
			'table_separator' => 25,
			'included' => 24,
			'table' => 22,
			'tag' => 26,
			'element' => 35
		}
	},
	{#State 15
		ACTIONS => {
			'Word' => 38
		},
		GOTOS => {
			'paragraph_filters' => 39
		}
	},
	{#State 16
		ACTIONS => {
			'Word' => 40
		}
	},
	{#State 17
		DEFAULT => 0
	},
	{#State 18
		DEFAULT => -2
	},
	{#State 19
		ACTIONS => {
			'Colon' => 41,
			'Named_variable' => 61,
			"\@" => 42,
			'Upoint_cache_hit' => 62,
			"~" => 43,
			'Dpoint_cache_hit' => 44,
			'Space' => 23,
			"*" => 47,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28,
			'Opoint_cache_hit' => 70,
			'Embed' => 30,
			'Table_separator' => 32,
			'Ils' => 52,
			'Block_cache_hit' => 73,
			"/" => 71,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			"=" => 74,
			'Headline_cache_hit' => 53,
			'Table' => 37,
			'Include' => 36,
			"#" => 78,
			'Heredoc_open' => 81,
			"." => 57
		},
		GOTOS => {
			'basic' => 58,
			'dlist' => 60,
			'verbatim' => 59,
			'table' => 22,
			'dlist_opener' => 63,
			'upoint' => 45,
			'literal' => 46,
			'olist' => 64,
			'ulist' => 65,
			'text' => 66,
			'opoint_opener' => 48,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26,
			'optionally_dotted_text' => 68,
			'headline_level' => 49,
			'list' => 50,
			'dstream_entrypoint' => 69,
			'compound_block' => 51,
			'embedded' => 31,
			'variable_assignment' => 72,
			'element' => 35,
			'dotted_text' => 54,
			'opoint' => 55,
			'table_paragraph' => 75,
			'comment' => 76,
			'dpoint' => 56,
			'original_paragraph' => 77,
			'list_part' => 79,
			'block' => 80,
			'headline' => 82
		}
	},
	{#State 20
		DEFAULT => -101
	},
	{#State 21
		DEFAULT => -110
	},
	{#State 22
		DEFAULT => -104
	},
	{#State 23
		DEFAULT => -109
	},
	{#State 24
		DEFAULT => -115
	},
	{#State 25
		DEFAULT => -105
	},
	{#State 26
		DEFAULT => -113
	},
	{#State 27
		DEFAULT => -108
	},
	{#State 28
		DEFAULT => -112
	},
	{#State 29
		ACTIONS => {
			'Embed' => 30,
			'Empty_line' => 84,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 83,
			'embedded' => 31,
			'included' => 24,
			'table_separator' => 25,
			'table' => 22,
			'tag' => 26,
			'element' => 35
		}
	},
	{#State 30
		DEFAULT => -147,
		GOTOS => {
			'@28-1' => 85
		}
	},
	{#State 31
		DEFAULT => -114
	},
	{#State 32
		DEFAULT => -143
	},
	{#State 33
		DEFAULT => -111
	},
	{#State 34
		DEFAULT => -124,
		GOTOS => {
			'@19-1' => 86
		}
	},
	{#State 35
		DEFAULT => -103
	},
	{#State 36
		DEFAULT => -150,
		GOTOS => {
			'@30-1' => 87
		}
	},
	{#State 37
		DEFAULT => -140,
		GOTOS => {
			'@24-1' => 88
		}
	},
	{#State 38
		DEFAULT => -6
	},
	{#State 39
		ACTIONS => {
			"|" => 90,
			"||" => 89
		}
	},
	{#State 40
		DEFAULT => -153,
		GOTOS => {
			'@32-3' => 91
		}
	},
	{#State 41
		DEFAULT => -58,
		GOTOS => {
			'@8-1' => 92
		}
	},
	{#State 42
		DEFAULT => -144,
		GOTOS => {
			'@26-1' => 93
		}
	},
	{#State 43
		DEFAULT => -80,
		GOTOS => {
			'@16-1' => 94
		}
	},
	{#State 44
		DEFAULT => -57
	},
	{#State 45
		DEFAULT => -43
	},
	{#State 46
		DEFAULT => -70,
		GOTOS => {
			'@11-1' => 95
		}
	},
	{#State 47
		DEFAULT => -52,
		GOTOS => {
			'@6-1' => 96
		}
	},
	{#State 48
		DEFAULT => -47,
		GOTOS => {
			'@5-1' => 97
		}
	},
	{#State 49
		ACTIONS => {
			"=" => 99
		},
		DEFAULT => -26,
		GOTOS => {
			'@3-1' => 98
		}
	},
	{#State 50
		ACTIONS => {
			'Colon' => 41,
			"<" => 100,
			'Dpoint_cache_hit' => 44,
			"*" => 47,
			">" => 102,
			'Upoint_cache_hit' => 62,
			'Opoint_cache_hit' => 70,
			"#" => 78
		},
		DEFAULT => -20,
		GOTOS => {
			'list_shifter' => 103,
			'dlist' => 60,
			'list_shift' => 101,
			'dlist_opener' => 63,
			'upoint' => 45,
			'opoint' => 55,
			'olist' => 64,
			'ulist' => 65,
			'dpoint' => 56,
			'opoint_opener' => 48,
			'list_part' => 104
		}
	},
	{#State 51
		ACTIONS => {
			"-" => 105,
			'Ils' => 52,
			'Block_cache_hit' => 73
		},
		DEFAULT => -19,
		GOTOS => {
			'block_flagnew' => 106,
			'block' => 107
		}
	},
	{#State 52
		DEFAULT => -65,
		GOTOS => {
			'@10-1' => 108
		}
	},
	{#State 53
		DEFAULT => -28
	},
	{#State 54
		DEFAULT => -69
	},
	{#State 55
		DEFAULT => -41
	},
	{#State 56
		DEFAULT => -45
	},
	{#State 57
		DEFAULT => -72,
		GOTOS => {
			'@12-1' => 109
		}
	},
	{#State 58
		DEFAULT => -97
	},
	{#State 59
		DEFAULT => -15
	},
	{#State 60
		ACTIONS => {
			'Colon' => 41,
			'Dpoint_cache_hit' => 44
		},
		DEFAULT => -40,
		GOTOS => {
			'dpoint' => 110,
			'dlist_opener' => 63
		}
	},
	{#State 61
		ACTIONS => {
			"=" => 111
		},
		DEFAULT => -110
	},
	{#State 62
		DEFAULT => -54
	},
	{#State 63
		DEFAULT => -55,
		GOTOS => {
			'@7-1' => 112
		}
	},
	{#State 64
		ACTIONS => {
			'Opoint_cache_hit' => 70,
			"#" => 78
		},
		DEFAULT => -38,
		GOTOS => {
			'opoint' => 113,
			'opoint_opener' => 48
		}
	},
	{#State 65
		ACTIONS => {
			"*" => 47,
			'Upoint_cache_hit' => 62
		},
		DEFAULT => -39,
		GOTOS => {
			'upoint' => 114
		}
	},
	{#State 66
		DEFAULT => -68
	},
	{#State 67
		DEFAULT => -98
	},
	{#State 68
		DEFAULT => -14
	},
	{#State 69
		DEFAULT => -17
	},
	{#State 70
		DEFAULT => -49
	},
	{#State 71
		ACTIONS => {
			"/" => 115
		}
	},
	{#State 72
		DEFAULT => -21
	},
	{#State 73
		DEFAULT => -67
	},
	{#State 74
		DEFAULT => -29
	},
	{#State 75
		DEFAULT => -18
	},
	{#State 76
		DEFAULT => -16
	},
	{#State 77
		DEFAULT => -11
	},
	{#State 78
		ACTIONS => {
			"#" => 116
		},
		DEFAULT => -50
	},
	{#State 79
		DEFAULT => -35
	},
	{#State 80
		DEFAULT => -60
	},
	{#State 81
		DEFAULT => -74,
		GOTOS => {
			'@13-1' => 117
		}
	},
	{#State 82
		DEFAULT => -13
	},
	{#State 83
		DEFAULT => -102
	},
	{#State 84
		DEFAULT => -34
	},
	{#State 85
		ACTIONS => {
			"{" => 119
		},
		GOTOS => {
			'used_tagpars' => 118
		}
	},
	{#State 86
		ACTIONS => {
			"{" => 119
		},
		DEFAULT => -127,
		GOTOS => {
			'used_tagpars' => 120,
			'optional_tagpars' => 121
		}
	},
	{#State 87
		ACTIONS => {
			"{" => 119
		},
		GOTOS => {
			'used_tagpars' => 122
		}
	},
	{#State 88
		ACTIONS => {
			"{" => 119
		},
		GOTOS => {
			'used_tagpars' => 123
		}
	},
	{#State 89
		DEFAULT => -5
	},
	{#State 90
		ACTIONS => {
			'Word' => 124
		}
	},
	{#State 91
		ACTIONS => {
			"{" => 119
		},
		DEFAULT => -127,
		GOTOS => {
			'used_tagpars' => 120,
			'optional_tagpars' => 125
		}
	},
	{#State 92
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Space' => 23,
			'Include' => 36,
			'Word' => 27,
			'StreamedPart' => 28
		},
		GOTOS => {
			'elements' => 126,
			'embedded' => 31,
			'included' => 24,
			'tag' => 26,
			'element' => 127
		}
	},
	{#State 93
		ACTIONS => {
			'Word' => 128
		},
		GOTOS => {
			'words' => 129
		}
	},
	{#State 94
		ACTIONS => {
			'Word' => 128
		},
		GOTOS => {
			'words' => 130
		}
	},
	{#State 95
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		DEFAULT => -87,
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'literals' => 131,
			'element' => 35,
			'literal' => 132,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26,
			'optional_literals' => 133
		}
	},
	{#State 96
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 46,
			'text' => 134,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 97
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 46,
			'text' => 135,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 98
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 20,
			'basics' => 136,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 99
		DEFAULT => -30
	},
	{#State 100
		DEFAULT => -86
	},
	{#State 101
		ACTIONS => {
			'Opoint_cache_hit' => 70,
			'Colon' => 41,
			"*" => 47,
			"#" => 78,
			'Upoint_cache_hit' => 62,
			'Dpoint_cache_hit' => 44
		},
		GOTOS => {
			'dlist' => 60,
			'dlist_opener' => 63,
			'upoint' => 45,
			'opoint' => 55,
			'olist' => 64,
			'dpoint' => 56,
			'ulist' => 65,
			'opoint_opener' => 48,
			'list_part' => 137
		}
	},
	{#State 102
		DEFAULT => -85
	},
	{#State 103
		DEFAULT => -82,
		GOTOS => {
			'@17-1' => 138
		}
	},
	{#State 104
		DEFAULT => -36
	},
	{#State 105
		DEFAULT => -63,
		GOTOS => {
			'@9-1' => 139
		}
	},
	{#State 106
		ACTIONS => {
			'Ils' => 52,
			'Block_cache_hit' => 73
		},
		GOTOS => {
			'compound_block' => 140,
			'block' => 80
		}
	},
	{#State 107
		DEFAULT => -61
	},
	{#State 108
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 46,
			'text' => 141,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 109
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 46,
			'text' => 142,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 110
		DEFAULT => -46
	},
	{#State 111
		DEFAULT => -76,
		GOTOS => {
			'@14-2' => 143
		}
	},
	{#State 112
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 46,
			'text' => 144,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 113
		DEFAULT => -42
	},
	{#State 114
		DEFAULT => -44
	},
	{#State 115
		DEFAULT => -78,
		GOTOS => {
			'@15-2' => 145
		}
	},
	{#State 116
		DEFAULT => -51
	},
	{#State 117
		ACTIONS => {
			'Embed' => 30,
			'Empty_line' => 148,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'literal_or_empty_line' => 147,
			'element' => 35,
			'literal' => 146,
			'literals_and_empty_lines' => 149,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26
		}
	},
	{#State 118
		DEFAULT => -148,
		GOTOS => {
			'@29-3' => 150
		}
	},
	{#State 119
		ACTIONS => {
			'Word' => 152
		},
		GOTOS => {
			'tagpars' => 151,
			'tagpar' => 153
		}
	},
	{#State 120
		DEFAULT => -128
	},
	{#State 121
		DEFAULT => -125,
		GOTOS => {
			'@20-3' => 154
		}
	},
	{#State 122
		DEFAULT => -151
	},
	{#State 123
		DEFAULT => -141,
		GOTOS => {
			'@25-3' => 155
		}
	},
	{#State 124
		DEFAULT => -7
	},
	{#State 125
		DEFAULT => -154,
		GOTOS => {
			'@33-5' => 156
		}
	},
	{#State 126
		ACTIONS => {
			'Colon' => 157,
			'Embed' => 30,
			'Named_variable' => 21,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		GOTOS => {
			'embedded' => 31,
			'included' => 24,
			'tag' => 26,
			'element' => 158
		}
	},
	{#State 127
		DEFAULT => -106
	},
	{#State 128
		DEFAULT => -118
	},
	{#State 129
		ACTIONS => {
			'Word' => 159,
			'EOL' => 160
		}
	},
	{#State 130
		ACTIONS => {
			'Empty_line' => 161,
			'Word' => 159
		}
	},
	{#State 131
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		DEFAULT => -88,
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 162,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 132
		DEFAULT => -89
	},
	{#State 133
		ACTIONS => {
			'Empty_line' => 163
		}
	},
	{#State 134
		DEFAULT => -53
	},
	{#State 135
		DEFAULT => -48
	},
	{#State 136
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			"~" => 164,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		DEFAULT => -31,
		GOTOS => {
			'basic' => 83,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'table_separator' => 25,
			'included' => 24,
			'optional_headline_shortcut' => 165,
			'tag' => 26
		}
	},
	{#State 137
		DEFAULT => -37
	},
	{#State 138
		ACTIONS => {
			'Number' => 166
		},
		DEFAULT => -116,
		GOTOS => {
			'optional_number' => 167
		}
	},
	{#State 139
		ACTIONS => {
			'Empty_line' => 168
		}
	},
	{#State 140
		ACTIONS => {
			"-" => 105,
			'Ils' => 52,
			'Block_cache_hit' => 73
		},
		DEFAULT => -62,
		GOTOS => {
			'block_flagnew' => 106,
			'block' => 107
		}
	},
	{#State 141
		DEFAULT => -66
	},
	{#State 142
		DEFAULT => -73
	},
	{#State 143
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 46,
			'text' => 169,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 144
		DEFAULT => -56
	},
	{#State 145
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		DEFAULT => -99,
		GOTOS => {
			'basic' => 20,
			'basics' => 170,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26,
			'optional_basics' => 171
		}
	},
	{#State 146
		DEFAULT => -95
	},
	{#State 147
		DEFAULT => -93
	},
	{#State 148
		DEFAULT => -96
	},
	{#State 149
		ACTIONS => {
			'Embed' => 30,
			'Empty_line' => 148,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'Heredoc_close' => 173,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'literal_or_empty_line' => 172,
			'element' => 35,
			'literal' => 146,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26
		}
	},
	{#State 150
		ACTIONS => {
			'Embed' => 30,
			'Empty_line' => 148,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		DEFAULT => -91,
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'optional_literals_and_empty_lines' => 175,
			'table' => 22,
			'literal_or_empty_line' => 147,
			'element' => 35,
			'literal' => 146,
			'literals_and_empty_lines' => 174,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26
		}
	},
	{#State 151
		ACTIONS => {
			'Space' => 177,
			"}" => 176
		}
	},
	{#State 152
		DEFAULT => -132,
		GOTOS => {
			'@21-1' => 178
		}
	},
	{#State 153
		DEFAULT => -130
	},
	{#State 154
		ACTIONS => {
			"<" => 179
		},
		DEFAULT => -137,
		GOTOS => {
			'optional_tagbody' => 180
		}
	},
	{#State 155
		ACTIONS => {
			'Embed' => 30,
			'Empty_line' => 148,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		DEFAULT => -91,
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'optional_literals_and_empty_lines' => 181,
			'table' => 22,
			'literal_or_empty_line' => 147,
			'element' => 35,
			'literal' => 146,
			'literals_and_empty_lines' => 174,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26
		}
	},
	{#State 156
		ACTIONS => {
			'Colon' => 182
		}
	},
	{#State 157
		DEFAULT => -59
	},
	{#State 158
		DEFAULT => -107
	},
	{#State 159
		DEFAULT => -119
	},
	{#State 160
		DEFAULT => -145,
		GOTOS => {
			'@27-4' => 183
		}
	},
	{#State 161
		DEFAULT => -81
	},
	{#State 162
		DEFAULT => -90
	},
	{#State 163
		DEFAULT => -71
	},
	{#State 164
		ACTIONS => {
			'Space' => 185,
			'Word' => 187
		},
		GOTOS => {
			'words_or_spaces' => 186,
			'word_or_space' => 184
		}
	},
	{#State 165
		ACTIONS => {
			'Empty_line' => 188
		}
	},
	{#State 166
		DEFAULT => -117
	},
	{#State 167
		DEFAULT => -83,
		GOTOS => {
			'@18-3' => 189
		}
	},
	{#State 168
		DEFAULT => -64
	},
	{#State 169
		DEFAULT => -77
	},
	{#State 170
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		DEFAULT => -100,
		GOTOS => {
			'basic' => 83,
			'embedded' => 31,
			'included' => 24,
			'table_separator' => 25,
			'table' => 22,
			'tag' => 26,
			'element' => 35
		}
	},
	{#State 171
		ACTIONS => {
			'Empty_line' => 190
		}
	},
	{#State 172
		DEFAULT => -94
	},
	{#State 173
		DEFAULT => -75
	},
	{#State 174
		ACTIONS => {
			'Embed' => 30,
			'Empty_line' => 148,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		DEFAULT => -92,
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'literal_or_empty_line' => 172,
			'element' => 35,
			'literal' => 146,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26
		}
	},
	{#State 175
		ACTIONS => {
			'Embedded' => 191
		}
	},
	{#State 176
		DEFAULT => -129
	},
	{#State 177
		ACTIONS => {
			'Word' => 152
		},
		GOTOS => {
			'tagpar' => 192
		}
	},
	{#State 178
		ACTIONS => {
			"=" => 193
		}
	},
	{#State 179
		DEFAULT => -138,
		GOTOS => {
			'@23-1' => 194
		}
	},
	{#State 180
		DEFAULT => -126
	},
	{#State 181
		ACTIONS => {
			'Tabled' => 195
		}
	},
	{#State 182
		DEFAULT => -155,
		GOTOS => {
			'@34-7' => 196
		}
	},
	{#State 183
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		DEFAULT => -87,
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'literals' => 131,
			'element' => 35,
			'literal' => 132,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26,
			'optional_literals' => 197
		}
	},
	{#State 184
		DEFAULT => -120
	},
	{#State 185
		DEFAULT => -123
	},
	{#State 186
		ACTIONS => {
			'Space' => 185,
			'Word' => 187
		},
		DEFAULT => -32,
		GOTOS => {
			'word_or_space' => 198
		}
	},
	{#State 187
		DEFAULT => -122
	},
	{#State 188
		DEFAULT => -27
	},
	{#State 189
		ACTIONS => {
			'Empty_line' => 199
		}
	},
	{#State 190
		DEFAULT => -79
	},
	{#State 191
		DEFAULT => -149
	},
	{#State 192
		DEFAULT => -131
	},
	{#State 193
		DEFAULT => -133,
		GOTOS => {
			'@22-3' => 200
		}
	},
	{#State 194
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'literals' => 201,
			'element' => 35,
			'literal' => 132,
			'included' => 24,
			'table_separator' => 25,
			'tag' => 26
		}
	},
	{#State 195
		DEFAULT => -142
	},
	{#State 196
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 46,
			'text' => 202,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 197
		ACTIONS => {
			'Empty_line' => 203
		}
	},
	{#State 198
		DEFAULT => -121
	},
	{#State 199
		DEFAULT => -84
	},
	{#State 200
		ACTIONS => {
			"\"" => 206,
			'Word' => 204
		},
		GOTOS => {
			'tagvalue' => 205
		}
	},
	{#State 201
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'EOL' => 67,
			'StreamedPart' => 28,
			">" => 207
		},
		GOTOS => {
			'basic' => 58,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'literal' => 162,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 202
		DEFAULT => -156
	},
	{#State 203
		DEFAULT => -146
	},
	{#State 204
		DEFAULT => -135
	},
	{#State 205
		DEFAULT => -134
	},
	{#State 206
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			'Word' => 27,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 20,
			'basics' => 208,
			'embedded' => 31,
			'table' => 22,
			'element' => 35,
			'table_separator' => 25,
			'included' => 24,
			'tag' => 26
		}
	},
	{#State 207
		DEFAULT => -139
	},
	{#State 208
		ACTIONS => {
			'Embed' => 30,
			'Named_variable' => 21,
			'Table_separator' => 32,
			'Symbolic_variable' => 33,
			'Tag_name' => 34,
			'Table' => 37,
			'Include' => 36,
			'Space' => 23,
			"\"" => 209,
			'Word' => 27,
			'StreamedPart' => 28
		},
		GOTOS => {
			'basic' => 83,
			'embedded' => 31,
			'included' => 24,
			'table_separator' => 25,
			'table' => 22,
			'tag' => 26,
			'element' => 35
		}
	},
	{#State 209
		DEFAULT => -136
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'document', 1,
sub
#line 1706 "ppParser.yp"
{
             # skip empty "paragraphs"
             unless ($_[1][0]=~/^\s*$/ or not @{$_[1][0]})
              {
               # add data to the output stream
               push(@{$resultStreamRef->[STREAM_TOKENS]}, @{$_[1][0]});

               # update tag finish memory
               _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));

  	           # update checksums (unless done before for parts)
               _updateChecksums($_[1][0], 'Paragraph_cache_hit') unless    $_[1][0][0][STREAM_DIR_TYPE]==DIRECTIVE_BLOCK
                                                                       or $_[1][0][0][STREAM_DIR_TYPE]==DIRECTIVE_DLIST
                                                                       or $_[1][0][0][STREAM_DIR_TYPE]==DIRECTIVE_OLIST
                                                                       or $_[1][0][0][STREAM_DIR_TYPE]==DIRECTIVE_ULIST
                                                                       or $_[1][0][0][STREAM_DIR_TYPE]==DIRECTIVE_HEADLINE;

               # update statistics, if necessary
               $statistics{$_[1][0][0][STREAM_DIR_TYPE]}++ unless not defined $_[1][0][0][STREAM_DIR_TYPE] or exists $embeddedParagraphs{$_[1][0][0][STREAM_DIR_TYPE]};

               # perform special headline operations
               if ($_[1][0][0][STREAM_DIR_TYPE]==DIRECTIVE_HEADLINE)
                 {
                  # update headline stream by adding the token index of the headline
                  push(@{$resultStreamRef->[STREAM_HEADLINES]}, @{$resultStreamRef->[STREAM_TOKENS]}-@{$_[1][0]});

                  # add a copy of the variables valid at the end of the page
                  $_[1][0][0][STREAM_DIR_HINTS]{vars}=dclone(\%variables);

                  # let the user know that something is going on
                  print STDERR "\r", ' ' x length('[Info] '), '... ', $statistics{&DIRECTIVE_HEADLINE}, " chapters read."
                    if     $flags{vis}
                       and not $statistics{&DIRECTIVE_HEADLINE} % $flags{vis};
                 }
                elsif ($_[1][0][0][STREAM_DIR_TYPE]!=DIRECTIVE_COMMENT)
                 {
                  # the document starts with streamed content before the first headline,
                  # this is considered an error except when this happens due to an import
                  _semerr($_[0], "$sourceFile, line $_[1][1]: the first chapter needs a headline, please add one.") unless exists $flags{complainedAbout1stHeadline};

                  # update complaint flag
                  if (exists $flags{complainedAbout1stHeadline} and $flags{complainedAbout1stHeadline} eq 'IMPORT')
                   {delete $flags{complainedAbout1stHeadline};}
                  else
                   {$flags{complainedAbout1stHeadline}=1;}
                 }

               # this is for the parser to flag success
               1;
              }
            }
	],
	[#Rule 2
		 'document', 2,
sub
#line 1758 "ppParser.yp"
{
             # skip empty "paragraphs"
             unless ($_[2][0]=~/^\s*$/ or not @{$_[2][0]})
              {
               # add data to the output stream, if necessary
               push(@{$resultStreamRef->[STREAM_TOKENS]}, @{$_[2][0]});

               # update tag finish memory
               _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));

               # update checksums, if necessary
               _updateChecksums($_[2][0], 'Paragraph_cache_hit') unless    $_[2][0][0][STREAM_DIR_TYPE]==DIRECTIVE_BLOCK
                                                                       or $_[2][0][0][STREAM_DIR_TYPE]==DIRECTIVE_DLIST
                                                                       or $_[2][0][0][STREAM_DIR_TYPE]==DIRECTIVE_OLIST
                                                                       or $_[2][0][0][STREAM_DIR_TYPE]==DIRECTIVE_ULIST
                                                                       or $_[2][0][0][STREAM_DIR_TYPE]==DIRECTIVE_HEADLINE;

               # update ordered list flag as necessary
               $flags{olist}=0 unless $_[2][0][0][STREAM_DIR_TYPE]==DIRECTIVE_OLIST;

               # update statistics, if necessary
               $statistics{$_[2][0][0][STREAM_DIR_TYPE]}++ unless exists $embeddedParagraphs{$_[2][0][0][STREAM_DIR_TYPE]};

               # perform special headline operations
               if ($_[2][0][0][STREAM_DIR_TYPE]==DIRECTIVE_HEADLINE)
                 {
                  # update headline stream by adding the token index of the headline
                  push(@{$resultStreamRef->[STREAM_HEADLINES]}, @{$resultStreamRef->[STREAM_TOKENS]}-@{$_[2][0]});

                  # add a copy of the variables valid at the end of the page
                  $_[2][0][0][STREAM_DIR_HINTS]{vars}=dclone(\%variables);

                  # let the user know that something is going on, if necessary
                  print STDERR "\r", ' ' x length('[Info] '), '... ', $statistics{&DIRECTIVE_HEADLINE}, " chapters read."
                    if     $flags{vis}
                       and not $statistics{&DIRECTIVE_HEADLINE} % $flags{vis};
                 }
               elsif (
                          $_[2][0][0][STREAM_DIR_TYPE]!=DIRECTIVE_COMMENT
                      and not @{$resultStreamRef->[STREAM_HEADLINES]}
                      and (
                              not exists $flags{complainedAbout1stHeadline}
                           or $flags{complainedAbout1stHeadline} eq 'IMPORT'
                          )
                     )
                 {
                  # the document starts with streamed content before the first headline,
                  # this is considered an error except when this happens due to an import
                  _semerr($_[0], "$sourceFile, line $_[2][1]: the first chapter needs a headline, please add one.") unless exists $flags{complainedAbout1stHeadline};

                  # update complaint flag
                  if (exists $flags{complainedAbout1stHeadline} and $flags{complainedAbout1stHeadline} eq 'IMPORT')
                   {delete $flags{complainedAbout1stHeadline};}
                  else
                   {$flags{complainedAbout1stHeadline}=1;}
                 }

               # this is for the parser to flag success
               1;
              }
            }
	],
	[#Rule 3
		 'optional_paragraph_filter', 0, undef
	],
	[#Rule 4
		 '@1-1', 0,
sub
#line 1825 "ppParser.yp"
{
                              # switch to pfiltered mode
                              _stateManager(STATE_PFILTER);
                             }
	],
	[#Rule 5
		 'optional_paragraph_filter', 4,
sub
#line 1830 "ppParser.yp"
{
                              # back to default mode
                              _stateManager(STATE_PFILTERED);

                              # supply filter list
                              $_[3];
                             }
	],
	[#Rule 6
		 'paragraph_filters', 1,
sub
#line 1842 "ppParser.yp"
{
                      # start a new filter list
                      [[$_[1][0]], $_[1][1]];
                     }
	],
	[#Rule 7
		 'paragraph_filters', 3,
sub
#line 1847 "ppParser.yp"
{
                      # append to filter list and reply updated list
                      push(@{$_[1][0]}, $_[3][0]);
                      [$_[1][0], $_[3][1]];
                     }
	],
	[#Rule 8
		 'paragraph', 1, undef
	],
	[#Rule 9
		 'paragraph', 1, undef
	],
	[#Rule 10
		 '@2-1', 0,
sub
#line 1864 "ppParser.yp"
{
                    # filter set?
                    if ($_[1])
                     {
                      # prepare an extra "token" to start the next paragraph
                      $flags{virtualParagraphStart}=1;

                      # Disable storage of a checksum. (A filter can make the paragraph depending
                      # on something outside the paragraph - the paragraph becomes dynamic.)
                      $flags{checksummed}=0;
                     }
                   }
	],
	[#Rule 11
		 'built_paragraph', 3,
sub
#line 1877 "ppParser.yp"
{
                    # reset the "extra token" flag (it already worked when the parser
                    # reaches this point)
                    $flags{virtualParagraphStart}=0;

                    # filters installed and active?
                    if ($_[1])
                      {
                       # Does the caller want to evaluate code?
                       if ($safeObject)
                         {
                          # update active contents base data, if necessary
                          if ($flags{activeBaseData})
                            {
                             no strict 'refs';
                             ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                            }

                          # peform filter call(s)
                          my $result=_pfilterCall($_[0], $_[1][0], $_[3][0], $_[3][1]);

                          # reply unmodified paragraph in case of an error
                          return $_[3] unless defined $result;

                          # make the result part of the input stream, if any
                          _stackInput($_[0], @$result) if $result;

                          # reset the "end of input reached" flag if necessary
                          $readCompletely=0 if $readCompletely;

                          # supply nothing here, the result must be reparsed first
                          ['', $_[3][2]];
                         }
                       else
                         {
                          # filters cannot be run, inform user
                          warn "[Warn] $sourceFile, line $_[1][1]: Active Content is disabled, paragraph cannot be filtered.\n" unless $flags{display} & DISPLAY_NOWARN;

                          # supply the unmodified paragraph
                          $_[3];
                         }
                      }
                    else
                      {
                       # no filter: provide paragraph data
                       $_[3];
                      }
                   }
	],
	[#Rule 12
		 'built_paragraph', 1, undef
	],
	[#Rule 13
		 'original_paragraph', 1, undef
	],
	[#Rule 14
		 'original_paragraph', 1,
sub
#line 1931 "ppParser.yp"
{
                      # remove leading dummy tokens which might have been produced by "standalone macros"
                      splice(@{$_[1][0]}, 1, 1) while @{$_[1][0]}>1 and !ref($_[1][0][1]) and $_[1][0][1] eq DUMMY_TOKEN;

                      # check if this paragraph consists of exactly one table only
                      # or exactly one tag which is allowed to exists standalone,
                      # or exactly one embedded region
                      if (
                             (
                              # starting with a table tag or standalone tag?
                                  @{$_[1][0]}>1
                              and ref($_[1][0][1]) eq 'ARRAY'
                              and $_[1][0][1][STREAM_DIR_TYPE]==DIRECTIVE_TAG
                              and (
                                      $_[1][0][1][STREAM_DIR_DATA]=~/^(TABLE)$/
                                   or (
                                           $_[1][0][1][STREAM_DIR_DATA]=~/^(\w+)$/
                                       and (
                                               (
                                                    exists $tagsRef->{$1}
                                                and exists $tagsRef->{$1}{standalone}
                                                and $tagsRef->{$1}{standalone}
                                               )
                                            or $1 eq 'EMBED'
                                           )
                                      )
                                  )

                              # ending with the same tag?
                              and ref($_[1][0][-2]) eq 'ARRAY'
                              and $_[1][0][-2][STREAM_DIR_TYPE]==DIRECTIVE_TAG
                              and $_[1][0][-2][STREAM_DIR_DATA] eq $1

                              # both building the same tag?
                              and $_[1][0][-2][STREAM_DIR_DATA+1] eq $_[1][0][1][STREAM_DIR_DATA+1]
                             )
                         )
                       {
                        # remove the enclosing paragraph stuff - just return the contents (table / tag)
                        shift(@{$_[1][0]});         # text paragraph opener
                        pop(@{$_[1][0]});           # text paragraph trailer
                       }

                      # pass (original or modified) data
                      $_[1];
                     }
	],
	[#Rule 15
		 'original_paragraph', 1, undef
	],
	[#Rule 16
		 'original_paragraph', 1, undef
	],
	[#Rule 17
		 'original_paragraph', 1, undef
	],
	[#Rule 18
		 'original_paragraph', 1, undef
	],
	[#Rule 19
		 'original_paragraph', 1, undef
	],
	[#Rule 20
		 'original_paragraph', 1, undef
	],
	[#Rule 21
		 'original_paragraph', 1, undef
	],
	[#Rule 22
		 'non_filterable_paragraph', 1, undef
	],
	[#Rule 23
		 'non_filterable_paragraph', 1, undef
	],
	[#Rule 24
		 'non_filterable_paragraph', 1, undef
	],
	[#Rule 25
		 'restored_paragraph', 1, undef
	],
	[#Rule 26
		 '@3-1', 0,
sub
#line 2002 "ppParser.yp"
{
             # switch to headline mode
             _stateManager(STATE_HEADLINE);

             # update headline level hints
             $flags{headlineLevel}=$_[1][0];

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Headline (of level $_[1][0]) starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
            }
	],
	[#Rule 27
		 'headline', 5,
sub
#line 2013 "ppParser.yp"
{
             # back to default mode
             _stateManager(STATE_DEFAULT);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[5][1]: Headline completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # remove trailing whitespaces (the final one represents the final newline)
             pop(@{$_[3][0]}) while @{$_[3][0]} and $_[3][0][-1]=~/^\s*$/;

             # abbreviation declared?
             if ($_[4][0])
              {
               # remove trailing whitespaces which separated a shortcut directive from
               # the long headline title version, if a shortcut was specified
               $_[3][0][-1]=~s/\s+$//;
               # remove leading and trailing whitespaces from the shortcut
               $_[4][0]=~s/^\s+//;
               $_[4][0]=~s/\s+$//;
              }

	     # update related data
             @olistLevels=();

             # update directive counter and the level hierarchy memory
             $#headlineIds=$flags{headlineLevel}-1;
             $headlineIds[$flags{headlineLevel}-1]=++$flags{headlinenr};

             # prepare result (data part and shortcut string)
             my %hints=(
                        nr         => ++$directiveCounter,
                        shortcut   => $_[4][0],
                        docstreams => {},
                       );
             my $data=[
                       # opener directive (including headline level)
                       [\%hints, DIRECTIVE_HEADLINE, DIRECTIVE_START, $_[1][0]],
                       # the list of enclosed literals
                       @{$_[3][0]},
                       # final directive (including headline level again)
                       [\%hints, DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, $_[1][0]]
                      ];

             # update checksums (done here because hits need special handling)
             _updateChecksums($data, 'Headline_cache_hit');

             # update pointer to the current docstream hash
             $flags{chapterDocstreams}=$hints{docstreams};

             # reply data
             [$data, $_[5][1]];
            }
	],
	[#Rule 28
		 'headline', 1,
sub
#line 2066 "ppParser.yp"
{
             # update headline level hint
             $flags{headlineLevel}=$_[1][0][0][STREAM_DIR_DATA];

             # reset chapter docstream hash and update the appropriate pointer
             $flags{chapterDocstreams}=$_[1][0][0][STREAM_DIR_HINTS]{docstreams}={};

             # supply what you got unchanged
             $_[1];
            }
	],
	[#Rule 29
		 'headline_level', 1,
sub
#line 2080 "ppParser.yp"
{
                   # switch to headline intro mode
                   _stateManager(STATE_HEADLINE_LEVEL);

                   # start new counter and reply it
                   [$flags{headlineLevelOffset}+1, $_[1][1]];
                  }
	],
	[#Rule 30
		 'headline_level', 2,
sub
#line 2088 "ppParser.yp"
{
                   # update counter and reply it
                   [$_[1][0]+1, $_[1][1]];
                  }
	],
	[#Rule 31
		 'optional_headline_shortcut', 0,
sub
#line 2096 "ppParser.yp"
{
                              # nothing declared: supply an empty shortcut string
                              ['', $lineNrs{$inHandle}];
                             }
	],
	[#Rule 32
		 'optional_headline_shortcut', 2,
sub
#line 2101 "ppParser.yp"
{
                              # reply the shortcut string
                              [join('', @{$_[2][0]}), $lineNrs{$inHandle}];
                             }
	],
	[#Rule 33
		 '@4-1', 0,
sub
#line 2109 "ppParser.yp"
{
               # switch to condition mode
               _stateManager(STATE_CONDITION);

               # trace, if necessary
               warn "[Trace] $sourceFile, line $_[1][1]: Condition paragraph starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
              }
	],
	[#Rule 34
		 'condition', 4,
sub
#line 2117 "ppParser.yp"
{
               # back to default mode
               _stateManager(STATE_DEFAULT);

               # trace, if necessary
               warn "[Trace] $sourceFile, line $_[4][1]: condition completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                # The condition is written in Perl, anything passed really?
                # And does the caller want to evaluate the code?
                if (@{$_[3][0]} and $safeObject)
                  {
                   # trace, if necessary
                   warn "[Trace] Evaluating condition ...\n" if $flags{trace} & TRACE_SEMANTIC;

                   # update active contents base data, if necessary
                   if ($flags{activeBaseData})
                     {
                      no strict 'refs';
                      ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                     }

                   # make the Perl code a string and evaluate it
                   my $perl=join('', @{$_[3][0]});
                   $^W=0;
                   warn "[Trace] $sourceFile, line $_[3][1]: Evaluating condition code:\n\n$perl\n\n\n" if $flags{trace} & TRACE_ACTIVE;
                   my $result=ref($safeObject) ? $safeObject->reval($perl) : eval(join(' ', '{package main; no strict;', $perl, '}'));
                   $^W=1;

                   # check result
                   if ($@)
                     {_semerr($_[0], "$sourceFile, line $_[3][1]: condition code could not be evaluated: $@.");}
                   else
                     {
                      # trace, if necessary
                      warn "[Trace] Condition is ", (defined $result and $result) ? 'true, parsing continues' : 'false, parsing is temporarily suspended', ".\n" if $flags{trace} & TRACE_ACTIVE or $flags{trace} & TRACE_SEMANTIC;

                      # success - configure parser behaviour according to result
                      $flags{skipInput}=1 unless (defined $result and $result);
                     }
                  }
                else
                  {
                   # trace, if necessary
                   warn "[Trace] Condition is not evaluated because of disabled active contents.\n" if $flags{trace} & TRACE_SEMANTIC;
                  }

               # we have to supply something, but it should be nothing (note that this is a *paragraph*, so reply a *string*)
               ['', $_[4][1]];
              }
	],
	[#Rule 35
		 'list', 1, undef
	],
	[#Rule 36
		 'list', 2,
sub
#line 2171 "ppParser.yp"
{
         # update token list and reply it
         push(@{$_[1][0]}, @{$_[2][0]});
         [$_[1][0], $_[2][1]];
        }
	],
	[#Rule 37
		 'list', 3,
sub
#line 2177 "ppParser.yp"
{
         # update statistics, if necessary (shifters are not passed as standalone paragraphs, so ...)
         $statistics{$_[2][0][0][1]}++;

         # add shift informations to related list parts: the predecessor
         # gets informations about a following shift, the successor about
         # a predecessing shift
          @{$_[1][0][-1]}[STREAM_DIR_DATA+3, STREAM_DIR_DATA+4]
         =@{$_[3][0][ 0]}[STREAM_DIR_DATA+1, STREAM_DIR_DATA+2]
         =@{$_[2][0][ 0]}[STREAM_DIR_TYPE, STREAM_DIR_DATA];

         # update token list and reply it
         push(@{$_[1][0]}, @{$_[2][0]}, @{$_[3][0]});
         [$_[1][0], $_[3][1]];
        }
	],
	[#Rule 38
		 'list_part', 1,
sub
#line 2196 "ppParser.yp"
{
              # the first point may start by a certain number, check this
              my $start=(defined $_[1][0][0][STREAM_DIR_DATA] and $_[1][0][0][STREAM_DIR_DATA]>1) ? $_[1][0][0][STREAM_DIR_DATA] : 1;

              # embed the points into list directives
              my %hints=(nr=>++$directiveCounter);
              [
               [
                # opener directive
                [\%hints, DIRECTIVE_OLIST, DIRECTIVE_START, $start, (0) x 4],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [\%hints, DIRECTIVE_OLIST, DIRECTIVE_COMPLETE, $start, (0) x 4]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 39
		 'list_part', 1,
sub
#line 2215 "ppParser.yp"
{
              # reset ordered list flag
              $flags{olist}=0;

              # embed the points into list directives
              my %hints=(nr=>++$directiveCounter);
              [
               [
                # opener directive
                [\%hints, DIRECTIVE_ULIST, DIRECTIVE_START, 0, (0) x 4],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [\%hints, DIRECTIVE_ULIST, DIRECTIVE_COMPLETE, 0, (0) x 4]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 40
		 'list_part', 1,
sub
#line 2234 "ppParser.yp"
{
              # reset ordered list flag
              $flags{olist}=0;

              # embed the points into list directives
              my %hints=(nr=>++$directiveCounter);
              [
               [
                # opener directive
                [\%hints, DIRECTIVE_DLIST, DIRECTIVE_START, 0, (0) x 4],
                # the list of enclosed literals
                @{$_[1][0]},
                # final directive
                [\%hints, DIRECTIVE_DLIST, DIRECTIVE_COMPLETE, 0, (0) x 4]
               ],
               $_[1][1]
              ];
             }
	],
	[#Rule 41
		 'olist', 1, undef
	],
	[#Rule 42
		 'olist', 2,
sub
#line 2257 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 43
		 'ulist', 1, undef
	],
	[#Rule 44
		 'ulist', 2,
sub
#line 2267 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 45
		 'dlist', 1, undef
	],
	[#Rule 46
		 'dlist', 2,
sub
#line 2277 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, @{$_[2][0]});
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 47
		 '@5-1', 0,
sub
#line 2286 "ppParser.yp"
{
           # switch to opoint mode
           _stateManager(STATE_OPOINT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Ordered list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
	],
	[#Rule 48
		 'opoint', 3,
sub
#line 2294 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_OPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Ordered list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated number wildcard and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text)
           $_[3][0][0][STREAM_DIR_TYPE]=$_[3][0][-1][STREAM_DIR_TYPE]=&DIRECTIVE_OPOINT;

           # update list level hints as necessary
           $olistLevels[0]=(($flags{olist} or $_[1][0]) and @olistLevels) ? $olistLevels[0]+1 : 1;

           # add a level hint, if necessary
           if ($_[1][0] and not $flags{olist} and $olistLevels[0]>1)
	        {
	         push(@{$_[3][0][0]}, $olistLevels[0]);
             push(@{$_[3][0][-1]}, $olistLevels[0]);
	        }

           # update ordered list flag
           $flags{olist}=1;

	       # update checksums, if possible
           $flags{checksummed}=0 unless $flags{virtualParagraphStart};
	       _updateChecksums($_[3][0], 'Opoint_cache_hit');

	       # supply result
           $_[3];
          }
	],
	[#Rule 49
		 'opoint', 1,
sub
#line 2328 "ppParser.yp"
{
           # update list level hints as necessary
           $olistLevels[0]=($flags{olist} and @olistLevels) ? $olistLevels[0]+1 : 1;

           # update continued list points
           $_[1][0][0][STREAM_DIR_DATA]=$olistLevels[0] if @{$_[1][0][0]}>3;

           # update ordered list flag
           $flags{olist}=1;

           # supply updated stream snippet
           $_[1];
          }
	],
	[#Rule 50
		 'opoint_opener', 1,
sub
#line 2346 "ppParser.yp"
{[0, $_[1][1]];}
	],
	[#Rule 51
		 'opoint_opener', 2,
sub
#line 2348 "ppParser.yp"
{[1, $_[1][1]];}
	],
	[#Rule 52
		 '@6-1', 0,
sub
#line 2353 "ppParser.yp"
{
           # switch to upoint mode
           _stateManager(STATE_UPOINT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Unordered list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
	],
	[#Rule 53
		 'upoint', 3,
sub
#line 2361 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_UPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Unordered list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated bullet and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # remove trailing whitespaces from point text (it represents the final newline character)
           splice(@{$_[3][0]}, -2, 1) while not ref($_[3][0][-2]) and $_[3][0][-2]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text)
           $_[3][0][0][STREAM_DIR_TYPE]=$_[3][0][-1][STREAM_DIR_TYPE]=&DIRECTIVE_UPOINT;

    	   # update checksums, if possible
           $flags{checksummed}=0 unless $flags{virtualParagraphStart};
	       _updateChecksums($_[3][0], 'Upoint_cache_hit');

	       # supply result
           $_[3];
          }
	],
	[#Rule 54
		 'upoint', 1, undef
	],
	[#Rule 55
		 '@7-1', 0,
sub
#line 2390 "ppParser.yp"
{
          }
	],
	[#Rule 56
		 'dpoint', 3,
sub
#line 2393 "ppParser.yp"
{
           # update statistics (list points are not passed as standalone paragraphs, so ...)
           $statistics{&DIRECTIVE_DPOINT}++;

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[3][1]: Definition list point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

           # remove leading whitespaces from point text (it separated point introduction and literal text part)
           splice(@{$_[3][0]}, 1, 1) while not ref($_[3][0][1]) and $_[3][0][1]=~/^\s*$/;

           # reply data (they are already well prepared except that they are marked as text, and that the definition item stream needs to be added)
           my ($hints1, $hints2, $hints3)=({nr=>++$directiveCounter}, {nr=>++$directiveCounter}, {nr=>++$directiveCounter});
           $_[3][0][0]=[$hints1, DIRECTIVE_DPOINT, DIRECTIVE_START];
           $_[3][0][-1]=[$hints1, DIRECTIVE_DPOINT, DIRECTIVE_COMPLETE];

           # insert the definition item stream and an envelope for the explanation part
           splice(@{$_[3][0]}, 1, 0,
                  [$hints2, DIRECTIVE_DPOINT_ITEM, DIRECTIVE_START],
                  @{$_[1][0]},
                  [$hints2, DIRECTIVE_DPOINT_ITEM, DIRECTIVE_COMPLETE],
                  [$hints3, DIRECTIVE_DPOINT_TEXT, DIRECTIVE_START],
                 );
           splice(@{$_[3][0]}, -1, 0, [$hints3, DIRECTIVE_DPOINT_TEXT, DIRECTIVE_COMPLETE]);

     	   # update checksums, if possible
           $flags{checksummed}=0 unless $flags{virtualParagraphStart};
	       _updateChecksums($_[3][0], 'Dpoint_cache_hit');

           # supply the result
           $_[3];
          }
	],
	[#Rule 57
		 'dpoint', 1, undef
	],
	[#Rule 58
		 '@8-1', 0,
sub
#line 2430 "ppParser.yp"
{
                 # switch to dlist item mode
                 _stateManager(STATE_DPOINT_ITEM);

                 # trace, if necessary
                 warn "[Trace] $sourceFile, line $_[1][1]: Definition list point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                }
	],
	[#Rule 59
		 'dlist_opener', 4,
sub
#line 2438 "ppParser.yp"
{
                 # switch to dlist body mode
                 _stateManager(STATE_DPOINT);

                 # simply pass the elements
                 [$_[3][0], $_[4][1]];
                }
	],
	[#Rule 60
		 'compound_block', 1, undef
	],
	[#Rule 61
		 'compound_block', 2,
sub
#line 2451 "ppParser.yp"
{
                   # this is tricky - to combine both blocks, we have to remove the already
                   # embedded stop/start directives and to supply the ...
                   [
                    [
                     # ... original collection WITHOUT the final directive ...
                     @{$_[1][0]}[0..$#{$_[1][0]}-1],
                     # insert two additional newline characters (restoring the original empty line)
                     "\n\n",
                     # ... combined with the new block, except of its INTRO directive
                     @{$_[2][0]}[1..$#{$_[2][0]}],
                    ],
                    $_[2][1]
                   ];
                  }
	],
	[#Rule 62
		 'compound_block', 3,
sub
#line 2467 "ppParser.yp"
{
                   # update statistics (for the first part which is completed by the intermediate flag paragraph)
                   $statistics{&DIRECTIVE_BLOCK}++;

                   # this is simply a list of both blocks
                   [
                    [
                     # original collection
                     @{$_[1][0]},
                     # ... followed by the new block
                     @{$_[3][0]},
                    ],
                    $_[3][1]
                   ];
                  }
	],
	[#Rule 63
		 '@9-1', 0,
sub
#line 2486 "ppParser.yp"
{
                  # switch to control mode
                  _stateManager(STATE_CONTROL);

                  # trace, if necessary
                  warn "[Trace] $sourceFile, line $_[1][1]: New block flag starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                 }
	],
	[#Rule 64
		 'block_flagnew', 3,
sub
#line 2494 "ppParser.yp"
{
                  # back to default mode
                  _stateManager(STATE_DEFAULT);

                  # trace, if necessary
                  warn "[Trace] $sourceFile, line $_[1][1]: New block flag completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                  # reply data (these are dummies because block connectors are not made part of the output stream)
                  $_[3];
                 }
	],
	[#Rule 65
		 '@10-1', 0,
sub
#line 2508 "ppParser.yp"
{
          # switch to block mode
          _stateManager(STATE_BLOCK);

          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[1][1]: Block starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
         }
	],
	[#Rule 66
		 'block', 3,
sub
#line 2516 "ppParser.yp"
{
          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[3][1]: Block completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

          # reply data (they are almost perfect except that they are marked as text,
          # and that the initial spaces have to be inserted, and that a trailing newline
          # has to be removed)
          $_[3][0][0][STREAM_DIR_TYPE]=$_[3][0][-1][STREAM_DIR_TYPE]=DIRECTIVE_BLOCK;
          splice(@{$_[3][0]}, 1, 0, $_[1][0]);
          # remove the final newline made from the last carriage return, if any
          splice(@{$_[3][0]}, -2, 1) if @{$_[3][0]}>2 and defined $_[3][0][-2] and $_[3][0][-2] eq "\n";

    	  # update checksums, if possible
          $flags{checksummed}=0 unless $flags{virtualParagraphStart};
	      _updateChecksums($_[3][0], 'Block_cache_hit');

	      # supply result
          $_[3];
         }
	],
	[#Rule 67
		 'block', 1, undef
	],
	[#Rule 68
		 'optionally_dotted_text', 1, undef
	],
	[#Rule 69
		 'optionally_dotted_text', 1, undef
	],
	[#Rule 70
		 '@11-1', 0,
sub
#line 2545 "ppParser.yp"
{
         # enter text mode - unless we are in a block (or point (which already set this mode itself))
         unless (   $parserState==STATE_BLOCK
                 or $parserState==STATE_UPOINT
                 or $parserState==STATE_OPOINT
                 or $parserState==STATE_DPOINT
                 or $parserState==STATE_DPOINT_ITEM
                 or $parserState==STATE_DEFINITION
                 or $parserState==STATE_TEXT
                )
          {
           # switch to new mode
           _stateManager(STATE_TEXT);

           # trace, if necessary
           warn "[Trace] $sourceFile, line $_[1][1]: Text starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
          }
        }
	],
	[#Rule 71
		 'text', 4,
sub
#line 2565 "ppParser.yp"
{
         # trace, if necessary
         warn "[Trace] $sourceFile, line $_[4][1]: Text completed.\n" unless    not $flags{trace} & TRACE_PARAGRAPHS
                                                                             or $parserState==STATE_BLOCK
                                                                             or $parserState==STATE_UPOINT
                                                                             or $parserState==STATE_OPOINT
                                                                             or $parserState==STATE_DPOINT
                                                                             or $parserState==STATE_DPOINT_ITEM;

         # back to default mode
         _stateManager(STATE_DEFAULT);

         # remove the final EOL literal, if any
         pop(@{$_[3][0]}) if defined $_[3][0][-1] and $_[3][0][-1] eq 'EOL';

         # remove the final whitespace string made from the last carriage return, if any
         pop(@{$_[3][0]}) if defined $_[3][0][-1] and $_[3][0][-1] eq ' ';

         # reply data, if any
         if ((@{$_[1][0]} and $_[1][0][0]) or @{$_[3][0]})
          {
           my %hints=(nr=>++$directiveCounter);
           [
            [
             # opener directive
             [\%hints, DIRECTIVE_TEXT, DIRECTIVE_START],
             # the list of enclosed literals
             @{$_[1][0]}, @{$_[3][0]},
             # final directive
             [\%hints, DIRECTIVE_TEXT, DIRECTIVE_COMPLETE],
            ],
            $_[4][1],
           ];
          }
         else
          {
           # reply nothing real
           [[()], $_[4][1]];
          }
        }
	],
	[#Rule 72
		 '@12-1', 0,
sub
#line 2609 "ppParser.yp"
{
                # switch to new mode (to stop special handling of dots)
                _stateManager(STATE_TEXT);
               }
	],
	[#Rule 73
		 'dotted_text', 3,
sub
#line 2614 "ppParser.yp"
{
                # supply the text
                $_[3];
               }
	],
	[#Rule 74
		 '@13-1', 0,
sub
#line 2622 "ppParser.yp"
{
             # switch to verbatim mode
             _stateManager(STATE_VERBATIM);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Verbatim block starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # check close hint: should be different from "1"
             _semerr($_[0], "A heredoc close hint should be different from \"1\".") if $_[1][0] eq '1';

             # store close hint
             $specials{heredoc}=$_[1][0];
            }
	],
	[#Rule 75
		 'verbatim', 4,
sub
#line 2637 "ppParser.yp"
{
             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[4][1]: Verbatim block completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # back to default mode
             _stateManager(STATE_DEFAULT);

             # delete the initial newline (which follows the opener but is no part of the block)
             shift(@{$_[3][0]});

             # reply data
             my %hints=(nr=>++$directiveCounter);
             [
              [
               # opener directive
               [\%hints, DIRECTIVE_VERBATIM, DIRECTIVE_START],
               # the list of enclosed literals
               @{$_[3][0]},
               # final directive
               [\%hints, DIRECTIVE_VERBATIM, DIRECTIVE_COMPLETE]
              ],
              $_[4][1]
             ];
            }
	],
	[#Rule 76
		 '@14-2', 0,
sub
#line 2665 "ppParser.yp"
{
                        # switch to text mode to allow *all* characters starting a variable value!
                        _stateManager(STATE_TEXT);

                        # trace, if necessary
                        warn "[Trace] $sourceFile, line $_[1][1]: Variable assignment starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                       }
	],
	[#Rule 77
		 'variable_assignment', 4,
sub
#line 2673 "ppParser.yp"
{
                        # remove text directives and the final space (made from the final EOL)
                        shift(@{$_[4][0]});
                        pop(@{$_[4][0]});

                        # make the text contents a string and store it
                        $variables{$_[1][0]}=join('', @{$_[4][0]});

                        # the variable might have been reset
                        delete($variables{$_[1][0]}) if $variables{$_[1][0]}=~/^\s*$/;

                        # update variable checksum
                        $varChecksum=sha1_base64(nfreeze(\%variables));

                        # propagate the setting to the stream, if necessary
                        if ($flags{var2stream})
                         {
                          push(@{$resultStreamRef->[STREAM_TOKENS]}, [{}, DIRECTIVE_VARSET, DIRECTIVE_START, {var=>$_[1][0], value=>$variables{$_[1][0]}}]);

                          # update tag finish memory by the way
                          _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));
                         }

                        # make the new variable setting available to embedded Perl code, if necessary
                        if ($safeObject)
                         {
                          no strict 'refs';
                          ${join('::', ref($safeObject) ? $safeObject->root : 'main', $_[1][0])}=$variables{$_[1][0]};
                         }

                        # trace, if necessary
                        warn "[Trace] $sourceFile, line $_[4][1]: Variable assignment: \$$_[1][0]=$variables{$_[1][0]}.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                        # flag this paragraph as internal
                        ['', $_[4][1]];
                       }
	],
	[#Rule 78
		 '@15-2', 0,
sub
#line 2713 "ppParser.yp"
{
            # switch to comment mode
            _stateManager(STATE_COMMENT);

            # trace, if necessary
            warn "[Trace] $sourceFile, line $_[1][1]: Comment starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
           }
	],
	[#Rule 79
		 'comment', 5,
sub
#line 2721 "ppParser.yp"
{
            # back to default mode
            _stateManager(STATE_DEFAULT);

            # trace, if necessary
            warn "[Trace] $sourceFile, line $_[5][1]: Comment completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

            # reply data, if necessary
            my %hints=(nr=>++$directiveCounter);
            $flags{skipcomments} ? [[()], $_[5][1]]
                                 : [
                                    [
                                     # opener directive
                                     [\%hints, DIRECTIVE_COMMENT, DIRECTIVE_START],
                                     # the list of enclosed literals
                                     @{$_[4][0]},
                                     # final directive
                                     [\%hints, DIRECTIVE_COMMENT, DIRECTIVE_COMPLETE]
                                    ],
                                    $_[5][1]
                                   ];
           }
	],
	[#Rule 80
		 '@16-1', 0,
sub
#line 2747 "ppParser.yp"
{
                       # no mode switch necessary

                       # trace, if necessary
                       warn "[Trace] $sourceFile, line $_[1][1]: Stream entry point starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                      }
	],
	[#Rule 81
		 'dstream_entrypoint', 4,
sub
#line 2754 "ppParser.yp"
{
                       # no mode switch necessary

                       # trace, if necessary
                       warn "[Trace] $sourceFile, line $_[5][1]: Stream entry point completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                       # deactivate caching
                       $flags{checksummed}=0;

                       # reply data as wished
                       my $streamTitle=join('', @{$_[3][0]});
                       unless (
                                  $flags{docstreaming}==DSTREAM_IGNORE
                               or (
                                       $flags{docstreams2skip}
                                   and exists $flags{docstreams2skip}{$streamTitle}
                                  )
                              )
                         {
                          # store stream title (both globally and locally)
                          $resultStreamRef->[STREAM_DOCSTREAMS]{$streamTitle}=$flags{chapterDocstreams}{$streamTitle}=undef;

                          # special handling requested?
                          if ($flags{docstreaming}==DSTREAM_HEADLINES)
                            {
                             # make this docstream entry point a headline
                             # one level below the last real headline level
                             my %hints=(nr=>++$directiveCounter, shortcut=>'');
                             [
                              [
                               # opener directive (including headline level)
                               [\%hints, DIRECTIVE_HEADLINE, DIRECTIVE_START, $flags{headlineLevel}+1],
                               # the stream title becomes the "headline"
                               $streamTitle,
                               # final directive (including headline level again)
                               [\%hints, DIRECTIVE_HEADLINE, DIRECTIVE_COMPLETE, $flags{headlineLevel}+1]
                              ],
                              $_[5][1]
                             ];
                            }
                          # default handling
                          else
                            {
                             my %hints=(nr=>++$directiveCounter);
                             [
                              [
                               # directives
                               [\%hints, DIRECTIVE_DSTREAM_ENTRYPOINT, DIRECTIVE_START, $streamTitle],
                              ],
                              $_[5][1]
                             ];
                            }
                         }
                       else
                         {
                          # configure parser to ignore eveything till the next stream entry point or headline
                          # ... unless this is the *main* stream
                          $flags{skipInput}=2 unless $streamTitle eq 'main';

                          # we have to supply something, but it should be nothing (note that this is a *paragraph*, so reply a *string*)
                          ['', $_[5][1]];
                         }
                      }
	],
	[#Rule 82
		 '@17-1', 0,
sub
#line 2821 "ppParser.yp"
{
                # temporarily activate number detection
                push(@specialStack, $specials{number});
                $specials{number}=1;
               }
	],
	[#Rule 83
		 '@18-3', 0,
sub
#line 2827 "ppParser.yp"
{
                # restore previous number detection mode
                $specials{number}=pop(@specialStack);

                # switch to control mode
                _stateManager(STATE_CONTROL);

                # trace, if necessary
                warn "[Trace] $sourceFile, line $_[3][1]: List shift ", $_[1][0]==LIST_SHIFT_RIGHT ? 'right' : 'left', " starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
               }
	],
	[#Rule 84
		 'list_shift', 5,
sub
#line 2838 "ppParser.yp"
{
                # back to default mode
                _stateManager(STATE_DEFAULT);

                # trace, if necessary
                warn "[Trace] $sourceFile, line $_[5][1]: List shift ", $_[1][0]==LIST_SHIFT_RIGHT ? 'right' : 'left', " completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                # update related data
                if ($_[1][0]==LIST_SHIFT_RIGHT)
                 {unshift(@olistLevels, 0) for (1..(defined $_[3][0] ? $_[3][0] : 1));}
                else
                 {shift(@olistLevels) for (1..(defined $_[3][0] ? $_[3][0] : 1));}

                # reset ordered list flag
                $flags{olist}=0;

                # reply data
                [
                 [
                  # opener directive (no explicit closing)
                  [{}, $_[1][0]==LIST_SHIFT_RIGHT ? DIRECTIVE_LIST_RSHIFT : DIRECTIVE_LIST_LSHIFT, DIRECTIVE_START, defined $_[3][0] ? $_[3][0] : 1],
                 ],
                 $_[5][1]
                ];
               }
	],
	[#Rule 85
		 'list_shifter', 1,
sub
#line 2867 "ppParser.yp"
{
                 # reply a flag
                 [LIST_SHIFT_RIGHT, $_[1][1]];
                }
	],
	[#Rule 86
		 'list_shifter', 1,
sub
#line 2872 "ppParser.yp"
{
                 # reply a flag
                 [LIST_SHIFT_LEFT, $_[1][1]];
                }
	],
	[#Rule 87
		 'optional_literals', 0,
sub
#line 2880 "ppParser.yp"
{
                      # start a new, empty list and reply it
                      [[], $lineNrs{$inHandle}];
                     }
	],
	[#Rule 88
		 'optional_literals', 1, undef
	],
	[#Rule 89
		 'literals', 1, undef
	],
	[#Rule 90
		 'literals', 2,
sub
#line 2890 "ppParser.yp"
{
             # update token list and reply it
             push(@{$_[1][0]}, @{$_[2][0]});
             [$_[1][0], $_[2][1]];
            }
	],
	[#Rule 91
		 'optional_literals_and_empty_lines', 0,
sub
#line 2899 "ppParser.yp"
{
                                      # start a new, empty list and reply it
                                      [[], $lineNrs{$inHandle}];
                                     }
	],
	[#Rule 92
		 'optional_literals_and_empty_lines', 1, undef
	],
	[#Rule 93
		 'literals_and_empty_lines', 1, undef
	],
	[#Rule 94
		 'literals_and_empty_lines', 2,
sub
#line 2909 "ppParser.yp"
{
                             # update token list and reply it
                             push(@{$_[1][0]}, @{$_[2][0]});
                             [$_[1][0], $_[2][1]];
                            }
	],
	[#Rule 95
		 'literal_or_empty_line', 1, undef
	],
	[#Rule 96
		 'literal_or_empty_line', 1,
sub
#line 2919 "ppParser.yp"
{
                          # start a new token list and reply it
                          [[$_[1][0]], $_[1][1]];
                         }
	],
	[#Rule 97
		 'literal', 1, undef
	],
	[#Rule 98
		 'literal', 1,
sub
#line 2928 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 99
		 'optional_basics', 0,
sub
#line 2936 "ppParser.yp"
{
                   # start a new, empty list and reply it
                   [[], $lineNrs{$inHandle}];
                  }
	],
	[#Rule 100
		 'optional_basics', 1, undef
	],
	[#Rule 101
		 'basics', 1, undef
	],
	[#Rule 102
		 'basics', 2,
sub
#line 2946 "ppParser.yp"
{
           # update token list and reply it
           push(@{$_[1][0]}, @{$_[2][0]});
           [$_[1][0], $_[2][1]];
          }
	],
	[#Rule 103
		 'basic', 1, undef
	],
	[#Rule 104
		 'basic', 1, undef
	],
	[#Rule 105
		 'basic', 1, undef
	],
	[#Rule 106
		 'elements', 1, undef
	],
	[#Rule 107
		 'elements', 2,
sub
#line 2964 "ppParser.yp"
{
             # update token list and reply it
             push(@{$_[1][0]}, @{$_[2][0]});
             [$_[1][0], $_[2][1]];
            }
	],
	[#Rule 108
		 'element', 1,
sub
#line 2974 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 109
		 'element', 1,
sub
#line 2979 "ppParser.yp"
{
            # start a new token list and reply it
            [[$_[1][0]], $_[1][1]];
           }
	],
	[#Rule 110
		 'element', 1,
sub
#line 2984 "ppParser.yp"
{
            # flag that this paragraph uses variables (a cache hit will only be useful if variable settings will be unchanged)
            $flags{checksummed}[4]=1 unless exists $flags{checksummed} and not $flags{checksummed};

            # start a new token list and reply it
            [[exists $variables{$_[1][0]} ? $variables{$_[1][0]} : join('', '$', $_[1][0])], $_[1][1]];
           }
	],
	[#Rule 111
		 'element', 1,
sub
#line 2992 "ppParser.yp"
{
            # flag that this paragraph uses variables (a cache hit will only be useful if variable settings will be unchanged)
            $flags{checksummed}[4]=1 unless exists $flags{checksummed} and not $flags{checksummed};

            # start a new token list and reply it
            [[exists $variables{$_[1][0]} ? $variables{$_[1][0]} : join('', '$', "{$_[1][0]}")], $_[1][1]];
           }
	],
	[#Rule 112
		 'element', 1,
sub
#line 3000 "ppParser.yp"
{
            # start a new token list and reply it
            # (the passed stream is already a reference)
            [$_[1][0], $_[1][1]];
           }
	],
	[#Rule 113
		 'element', 1, undef
	],
	[#Rule 114
		 'element', 1, undef
	],
	[#Rule 115
		 'element', 1, undef
	],
	[#Rule 116
		 'optional_number', 0,
sub
#line 3013 "ppParser.yp"
{[undef, $lineNrs{$inHandle}];}
	],
	[#Rule 117
		 'optional_number', 1, undef
	],
	[#Rule 118
		 'words', 1,
sub
#line 3020 "ppParser.yp"
{
          # start a new token list and reply it
          [[$_[1][0]], $_[1][1]];
         }
	],
	[#Rule 119
		 'words', 2,
sub
#line 3025 "ppParser.yp"
{
          # update token list and reply it
          push(@{$_[1][0]}, $_[2][0]);
          [$_[1][0], $_[2][1]];
         }
	],
	[#Rule 120
		 'words_or_spaces', 1,
sub
#line 3034 "ppParser.yp"
{
                    # start a new token list and reply it
                    [[$_[1][0]], $_[1][1]];
                   }
	],
	[#Rule 121
		 'words_or_spaces', 2,
sub
#line 3039 "ppParser.yp"
{
                    # update token list and reply it
                    push(@{$_[1][0]}, $_[2][0]);
                    [$_[1][0], $_[2][1]];
                   }
	],
	[#Rule 122
		 'word_or_space', 1, undef
	],
	[#Rule 123
		 'word_or_space', 1, undef
	],
	[#Rule 124
		 '@19-1', 0,
sub
#line 3054 "ppParser.yp"
{
        # trace, if necessary
        warn "[Trace] $sourceFile, line $_[1][1]: Tag $_[1][0] starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

        # temporarily activate special "<" *as necessary*
        my $possible=   (exists $macros{$_[1][0]} and $macros{$_[1][0]}->[2])   # macro: evaluate body flag;
                     || $tagsRef->{$_[1][0]}{__flags__}{__body__};              # tag with body;
        push(@specialStack, $specials{'<'}), $specials{'<'}=1 if $possible;     # enable tag body, if necessary
        push(@specialStack, $possible);                                         # flags what is on stack;

        # temporarily activate specials "{" and "}" *as necessary*
        push(@specialStack, @specials{('{', '}')}), @specials{('{', '}')}=(1) x 2
         if    (exists $macros{$_[1][0]} and %{$macros{$_[1][0]}->[0]})         # macro: evaluate declared options;
            || $tagsRef->{$_[1][0]}{__flags__}{__options__};                    # tag with options;

	    # deactivate boost
	    $flags{noboost}=1;
       }
	],
	[#Rule 125
		 '@20-3', 0,
sub
#line 3073 "ppParser.yp"
{
	    # reactivate boost
	    $flags{noboost}=0;

        # restore special states of "{" and "}", if necessary
        @specials{('{', '}')}=splice(@specialStack, -2, 2)
         if    (exists $macros{$_[1][0]} and %{$macros{$_[1][0]}->[0]})         # macro: evaluate declared options;
            || $tagsRef->{$_[1][0]}{__flags__}{__options__};                    # tag with options;

        # check options in general if declared mandatory
        if (
                not @{$_[3][0]}
            and exists $tagsRef->{$_[1][0]}
            and exists $tagsRef->{$_[1][0]}{options}
            and $tagsRef->{$_[1][0]}{options}==&TAGS_MANDATORY
           )
         {
          # display error message
          warn "\n\n[Fatal] $sourceFile, line $_[3][1]: Missing mandatory options of tag $_[1][0]\n";

          # this is an syntactical error, stop parsing
          $_[0]->YYAbort;
         }
       }
	],
	[#Rule 126
		 'tag', 5,
sub
#line 3098 "ppParser.yp"
{
        # scopy
        my $ignore;

        # trace, if necessary
        warn "[Trace] $sourceFile, line $_[5][1]: Tag $_[1][0] completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

        # build parameter hash, if necessary
        my %pars;
        if (@{$_[3][0]})
          {
           # the list already consists of key/value pairs
           %pars=@{$_[3][0]}
          }

        # Tag condition set?
        if (exists $pars{_cnd_})
         {
          # ok, if the condition was true or could not be evaluated, return just the body
          # (so that the tag or macro is ignored)
          unless (_evalTagCondition($pars{_cnd_}, $sourceFile, $_[5][1]))
           {return([[@{$_[5][0]} ? @{$_[5][0]} : ()], $_[5][1]]);}
          else
           {
            # strip off this special option before the tag or macro is furtherly processed
            delete $pars{_cnd_};
           }
         }

        # tags require special handling
        unless (exists $macros{$_[1][0]})
         {
          # check tag body in general if declared mandatory
          if (
                 not @{$_[5][0]}
             and exists $tagsRef->{$_[1][0]}
             and exists $tagsRef->{$_[1][0]}{body}
             and $tagsRef->{$_[1][0]}{body}==&TAGS_MANDATORY
             )
           {
            # display error message
            warn "[Fatal] $sourceFile, line $_[5][1]: Missing mandatory body of tag $_[1][0]\n";

            # this is an syntactical error, stop parsing
            $_[0]->YYAbort;
           }

          # invoke hook function, if necessary
          if (exists $tagsRef->{$_[1][0]} and exists $tagsRef->{$_[1][0]}{hook})
           {
            # make an option hash
            my $options={@{$_[3][0]}};

            # call hook function (use eval() to guard yourself)
            my $rc;
            eval {$rc=&{$tagsRef->{$_[1][0]}{hook}}($_[1][1], $options, dclone($_[5][0]), $anchors, join('-', @headlineIds), $flags{headlinenr})};

            # check result
            unless ($@)
             {
              {
               # semantic error?
               ++$_semerr, last if $rc==PARSING_ERROR;

               # syntactical error?
               $_[0]->YYAbort, last if $rc==PARSING_FAILED;

               # tag to ignore, or even everything covered?
               $ignore=$rc, last if $rc==PARSING_IGNORE or $rc==PARSING_ERASE;

               # update options (might be modified, and checking for a difference
               # might take more time then just copying the replied values)
               @{$_[3][0]}=%$options;

               # all right?
               if ($rc==PARSING_OK)
                {
                 # is this a tag that will invoke a finish hook?
                 if (exists $tagsRef->{$_[1][0]}{finish})
                  {
                   # update number of tags to finish in the currently built stream section, if necessary
                   $pendingTags->[1]++;

                   # Disable storage of a checksum. (A finish hook makes the paragraph depending
                   # on something potentially outside the paragraph - the paragraph becomes dynamic.)
                   $flags{checksummed}=0;
                  }

                 # well done
                 last;
                }

               # or even superb?
               $_[0]->YYAccept, last if $rc==PARSING_COMPLETED;

               # something is wrong here
               warn "[Warn] Tags $_[1][0] tag hook replied unexpected result $rc, ignored.\n";
              }
             }
            else
             {warn "[Warn] Error in tags $_[1][0] tag hook: $@\n"}

            # rebuild parameter hash, if necessary
            if (@{$_[3][0]})
             {
              # the list already consists of key/value pairs
              %pars=@{$_[3][0]}
             }
           }
         }

        # this might be a macro as well as a tag - so what?
        unless (exists $macros{$_[1][0]})
          {
           # update statistics
           $statistics{&DIRECTIVE_TAG}++;

           # reply tag data as necessary
           unless (defined $ignore)
            {
             # supply a complete tag
             my %hints=(nr=>++$directiveCounter);
             [
              [
               # opener directive
               [\%hints, DIRECTIVE_TAG, DIRECTIVE_START, $_[1][0], \%pars, scalar(@{$_[5][0]})],
               # the list of enclosed literals, if any
               @{$_[5][0]} ? @{$_[5][0]} : (),
               # final directive
               [\%hints, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, $_[1][0], \%pars, scalar(@{$_[5][0]})]
              ],
              $_[5][1]
             ];
            }
           elsif ($ignore==PARSING_IGNORE)
            {
             # supply the body, ignore the tag "envelope" ("hide" the tag)
             [
              [
               # the list of enclosed literals, if any
               @{$_[5][0]} ? @{$_[5][0]} : (),
              ],
              $_[5][1]
             ];
            }
           elsif ($ignore==PARSING_ERASE)
            {
             # reply nothing real
             [[()], $_[5][1]];
            }
           else
            {die "[BUG] Unhandled flag $ignore.";}
          }
        else
          {
     	   # flag that this paragraph uses macros (a cache hit will only be useful if macro definitions will have been unchanged)
	       $flags{checksummed}[3]=1 unless exists $flags{checksummed} and not $flags{checksummed};

           # this is a macro - resolve it!
           my $macro=$macros{$_[1][0]}->[1];

           # fill in parameters
           foreach my $par (keys %{$macros{$_[1][0]}->[0]})
             {
              my $value=  exists $pars{$par}                   ? $pars{$par}
                        : defined $macros{$_[1][0]}->[0]{$par} ? $macros{$_[1][0]}->[0]{$par}
                        : '';
              $macro=~s/__${par}__/$value/g;
             }

           # Bodyless macros need special care - the parser already got the subsequent token to
           # recognize that the macro was complete. Now, the macro replacement is reinserted into
           # the stream where it will be read by the next lexer operation which is enforced when
           # the parser needs a token again - and this will happen after processing the already
           # received token which stood behind the bodyless macro. Letting the parser process the
           # read token this way, this token would be streamed (in most cases) *before* the macro
           # replacement, while it was intented to come after it. So, if we detect this case, we
           # move this token *behind* the macro replacement. As for the parser, we replace
           # this token by something streamed to "nothing", currently a special string declared
           # as "Word" token.
           my $delayedToken;
           unless (@{$_[5][0]})
             {
              # insert the current token behind the imaginary body
              $delayedToken=new PerlPoint::Parser::DelayedToken($_[0]->YYCurtok, $_[0]->YYCurval);

              # set new dummy values to let the parser work on
              # (something without effect and valid everywhere a tag is)
              $_[0]->YYCurtok('Word');
              $_[0]->YYCurval([DUMMY_TOKEN, $_[0]->YYCurval->[1]]);
             }

           # finally, pass the constructed text back to the input stream (by stack)
           _stackInput($_[0], (map {$_ eq '__body__' ? dclone($_[5][0]) : split(/(\n)/, $_)} split(/(__body__)/, $macro)), $delayedToken ? $delayedToken : ());

           # reset the "end of input reached" flag if necessary
           $readCompletely=0 if $readCompletely;

           # reply nothing real
           [[()], $_[5][1]];
          }
       }
	],
	[#Rule 127
		 'optional_tagpars', 0,
sub
#line 3304 "ppParser.yp"
{[[], $lineNrs{$inHandle}];}
	],
	[#Rule 128
		 'optional_tagpars', 1, undef
	],
	[#Rule 129
		 'used_tagpars', 3,
sub
#line 3310 "ppParser.yp"
{
                 # supply the parameters
                 [$_[2][0], $_[3][1]];
                }
	],
	[#Rule 130
		 'tagpars', 1, undef
	],
	[#Rule 131
		 'tagpars', 3,
sub
#line 3319 "ppParser.yp"
{
            # update parameter list
            push(@{$_[1][0]}, @{$_[3][0]});

            # supply updated parameter list
            [$_[1][0], $_[3][1]];
           }
	],
	[#Rule 132
		 '@21-1', 0,
sub
#line 3330 "ppParser.yp"
{
           # backslashes should pass in tag options
           push(@specialStack, $lexerFlags{backsl});
           $lexerFlags{backsl}=LEXER_TOKEN;

           # temporarily make "=" and quotes the only specials,
           # but take care to reset the remaining settings defined
           push(@specialStack, [(%specials)], $specials{'='});
           @specials{keys %specials}=(0) x scalar(keys %specials);
           @specials{('=', '"')}=(1, 1);
          }
	],
	[#Rule 133
		 '@22-3', 0,
sub
#line 3342 "ppParser.yp"
{
           # restore special "=" setting
           $specials{'='}=pop(@specialStack);
          }
	],
	[#Rule 134
		 'tagpar', 5,
sub
#line 3347 "ppParser.yp"
{
           # restore special settings
           %specials=@{pop(@specialStack)};

           # restore backslash flag
           $lexerFlags{backsl}=pop(@specialStack);

           # supply flag and value
           [[$_[1][0], $_[5][0]], $_[5][1]];
          }
	],
	[#Rule 135
		 'tagvalue', 1, undef
	],
	[#Rule 136
		 'tagvalue', 3,
sub
#line 3361 "ppParser.yp"
{
             # build a string and supply it
             [join('', @{$_[2][0]}), $_[3][1]];
            }
	],
	[#Rule 137
		 'optional_tagbody', 0,
sub
#line 3369 "ppParser.yp"
{
                     # if we are here, "<" *possibly* was marked to be a special - now it becomes what is was before
                     # (take care the stack is filled correctly!)
                     my $possible=pop(@specialStack);                # was the body enabled?
                     $specials{'<'}=pop(@specialStack) if $possible; # if so, restore the stack

                     # supply an empty result
                     [[], $lineNrs{$inHandle}];
                    }
	],
	[#Rule 138
		 '@23-1', 0,
sub
#line 3379 "ppParser.yp"
{
                     # if we are here, "<" was marked to be a special - now it becomes what is was before
                     # (take care the stack is filled correctly!)
                     my $possible=pop(@specialStack);                # can be ignored - surely the body was enabled!
                     $specials{'<'}=pop(@specialStack);              # restore the stack

                     # temporarily activate special ">"
                     push(@specialStack, @specials{('>')});
                     @specials{('>')}=1;
                    }
	],
	[#Rule 139
		 'optional_tagbody', 4,
sub
#line 3390 "ppParser.yp"
{
                     # reset ">" setting
                     @specials{('>')}=pop(@specialStack);

                     # reply the literals
                     [$_[3][0], $_[4][1]];
                    }
	],
	[#Rule 140
		 '@24-1', 0,
sub
#line 3401 "ppParser.yp"
{
          # trace, if necessary
          warn "[Trace] $sourceFile, line $_[1][1]: Table starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

          # check nesting
          _semerr($_[0], "$sourceFile, line $_[3][1]: Nested tables are not supported by this parser version.")
            if @tableSeparatorStack and not $flags{nestedTables};

          # temporarily activate specials "{" and "}"
          push(@specialStack, @specials{('{', '}')});
          @specials{('{', '}')}=(1, 1);

          # empty lines have to be ignored in tables
          push(@specialStack, $lexerFlags{el});
          $lexerFlags{el}=LEXER_IGNORE;

          # deactivate boost
          $flags{noboost}=1;
         }
	],
	[#Rule 141
		 '@25-3', 0,
sub
#line 3421 "ppParser.yp"
{
          # reactivate boost
          $flags{noboost}=0;

          # restore previous handling of empty lines
          $lexerFlags{el}=pop(@specialStack);

          # restore special state of "{" and "}"
          @specials{('{', '}')}=splice(@specialStack, -2, 2);

          # read parameters and adapt them, if necessary
          my %tagpars=@{$_[3][0]};

          if (exists $tagpars{rowseparator})
            {
             $tagpars{rowseparator}=quotemeta($tagpars{rowseparator});
             $tagpars{rowseparator}="\n" if $tagpars{rowseparator} eq '\\\\n';
            }

	      # mark table start
          $tableColumns=0-(
			   exists $tagpars{gracecr} ? $tagpars{gracecr}
                                                    : (not exists $tagpars{rowseparator} or $tagpars{rowseparator} eq "\n") ? 1
                                                    : 0
			  );

          # store specified column separator (or default)
          unshift(@tableSeparatorStack, [
					 exists $tagpars{separator}    ? quotemeta($tagpars{separator}) : '\|',
					 exists $tagpars{rowseparator} ? $tagpars{rowseparator} : "\n",
					]);
         }
	],
	[#Rule 142
		 'table', 6,
sub
#line 3454 "ppParser.yp"
{
          # build parameter hash, if necessary
          my %pars;
          if (@{$_[3][0]})
            {
             # the list already consists of key/value pairs
             %pars=@{$_[3][0]}
            }

          # Tag condition set?
          if (exists $pars{_cnd_})
           {
            # ok, if the condition was true or could not be evaluated,
            # stop processing of this tag (there is no body, so return an empty stream)
            unless (_evalTagCondition($pars{_cnd_}, $sourceFile, $_[6][1]))
             {return([[()], $_[6][1]]);}
            else
             {
              # strip off this special option before the tag or macro is furtherly processed
              delete $pars{_cnd_};
             }
           }

          # add row separator information unless it was defined by the user itself
          $pars{rowseparator}='\n' unless exists $pars{rowseparator};
          $pars{rowseparator}='\\\\n' if $pars{rowseparator} eq '\\n';

          # store nesting level information
          $pars{__nestingLevel__}=@tableSeparatorStack;

          # If we are here and found anything in the table, it is
          # possible that a final row was closed and a new one opened
          # (e.g. at the end of the last table line, if rows are separated
          # by "\n"). Because the table is completed now, these tags can
          # be removed to get the common case of an opened but not yet
          # completed table cell.
          splice(@{$_[5][0]}, -4, 4) if     @{$_[5][0]}
                                        and ref($_[5][0][-1]) eq 'ARRAY'
                                        and @{$_[5][0][-1]}==4
                                        and $_[5][0][-1][STREAM_DIR_TYPE]  eq DIRECTIVE_TAG
                                        and $_[5][0][-1][STREAM_DIR_STATE] eq DIRECTIVE_START
                                        and $_[5][0][-1][STREAM_DIR_DATA]  eq 'TABLE_COL';

          # normalize table rows (no need of auto format)
          ($pars{__titleColumns__}, $pars{__maxColumns__})=_normalizeTableRows($_[5][0], 0);

          # warn user in case of potential row width conflicts
          warn qq([Warn] $sourceFile, line $_[1][1]: The maximum cell number per row ($pars{__maxColumns__}) was not detected in the first row (which has $pars{__titleColumns__} columns).\n) if $pars{__titleColumns__}<$pars{__maxColumns__} and not ($flags{display} & DISPLAY_NOWARN);

          # reset column separator memory, mark table completed
          shift(@tableSeparatorStack);
          $tableColumns=0;

          # reply data in a "tag envelope" (for backends)
          my ($hints1, $hints2, $hints3)=({nr=>++$directiveCounter}, {nr=>++$directiveCounter}, {nr=>++$directiveCounter});
          [
           [
            # opener directives
            [$hints1, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE', \%pars],
            [$hints2, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
            [$hints3, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
            # the list of enclosed literals reduced by the final two, if any
            @{$_[5][0]} ? @{$_[5][0]} : (),
            # final directive
            [$hints3, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL'],
            [$hints2, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW'],
            [$hints1, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE', \%pars]
           ],
           $_[6][1]
          ];
         }
	],
	[#Rule 143
		 'table_separator', 1,
sub
#line 3529 "ppParser.yp"
{
                    # update counter of completed table columns
                    $tableColumns++;

                    # supply a simple seperator tag
                    my %hints=(nr=>++$directiveCounter);
                    [
                     [
                      [\%hints, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL'],
                      $_[1][0] eq 'c' ? ()
                                      : (
                                         [{}, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_ROW'],
                                         [{}, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
                                        ),
                      [\%hints, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
                     ],
                     $_[1][1]
                    ];
                   }
	],
	[#Rule 144
		 '@26-1', 0,
sub
#line 3552 "ppParser.yp"
{
                    # switch to condition mode
                    _stateManager(STATE_TABLE);

                    # trace, if necessary
                    warn "[Trace] $sourceFile, line $_[1][1]: Table paragraph starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                   }
	],
	[#Rule 145
		 '@27-4', 0,
sub
#line 3560 "ppParser.yp"
{
                    # store specified column separator
                    unshift(@tableSeparatorStack, [quotemeta(join('', @{$_[3][0]})), "\n"]);
                   }
	],
	[#Rule 146
		 'table_paragraph', 7,
sub
#line 3565 "ppParser.yp"
{
                    # back to default mode
                    _stateManager(STATE_DEFAULT);

                    # trace, if necessary
                    warn "[Trace] $sourceFile, line $_[7][1]: Table paragraph completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                    # reset column separator memory, mark table completed
                    shift(@tableSeparatorStack);
                    $tableColumns=0;

                    # build parameter hash (contains level information, which is always 1,
                    # and various retranslation hints)
                    my %pars=(
                              __nestingLevel__ => 1,
                              __paragraph__    => 1,
                              separator        => join('', @{$_[3][0]}),
                             );

                    # If we are here and found anything in the table, a final row was
                    # closed and a new one opened at the end of the last table line.
                    # Because the table is completed now, the final opener tags can
                    # be removed. This is done *here* and by pop() for acceleration.
                    if (@{$_[6][0]}>4)
                      {
                       # delete final opener directives made by the final carriage return
                       splice(@{$_[6][0]}, -2, 2);

                       # normalize table rows and autoformat headline fields
                       ($pars{__titleColumns__}, $pars{__maxColumns__})=_normalizeTableRows($_[6][0], 1);

                       # warn user in case of potential row width conflicts
                       warn qq([Warn] $sourceFile, line $_[1][1]: The maximum cell number per row ($pars{__maxColumns__}) was not detected in the first row (which has $pars{__titleColumns__} columns).\n) if $pars{__titleColumns__}<$pars{__maxColumns__} and not ($flags{display} & DISPLAY_NOWARN);

                       # reply data in a "tag envelope" (for backends)
                       my %hints=(nr=>++$directiveCounter);
                       [
                        [
                         # opener directives (note that first row and column are already opened by the initial carriage return stream)
                         [\%hints, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE', \%pars],
                         [{}, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_ROW'],
                         [{}, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_HL'],
                         # the list of enclosed literals reduced by the final two, if any
                         @{$_[6][0]} ? @{$_[6][0]} : (),
                         # final directive
                         [\%hints, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE', \%pars]
                        ],
                        $_[7][1]
                       ];
                      }
                    else
                      {
                       # empty table - reply nothing real
                       [[()], $_[7][1]];
                      }
                   }
	],
	[#Rule 147
		 '@28-1', 0,
sub
#line 3625 "ppParser.yp"
{
             # switch to embedding mode saving the former state (including *all* special settings)
             push(@stateStack, $parserState);
             push(@specialStack, [%specials]);
             _stateManager(STATE_EMBEDDING);

             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Embedding starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

             # Disable storage of a checksum. (Dynamic parts may change or have changed.
             # Static parts are static of course, but the filter settings may vary.)
             $flags{checksummed}=0;

             # temporarily activate specials "{" and "}"
             push(@specialStack, @specials{('{', '}')});
             @specials{('{', '}')}=(1, 1);

             # deactivate boost
             $flags{noboost}=1;
            }
	],
	[#Rule 148
		 '@29-3', 0,
sub
#line 3646 "ppParser.yp"
{
             # reactivate boost
             $flags{noboost}=0;

             # restore special state of "{" and "}"
             @specials{('{', '}')}=splice(@specialStack, -2, 2);
            }
	],
	[#Rule 149
		 'embedded', 6,
sub
#line 3654 "ppParser.yp"
{
             # restore former parser state (including *all* special settings)
             _stateManager(pop(@stateStack));
             %specials=@{pop(@specialStack)};

             # build parameter hash, if necessary
             my %pars;
             if (@{$_[3][0]})
               {
                # the list already consists of key/value pairs
                %pars=@{$_[3][0]}
               }

             # set default language, if necessary
             $pars{lang}='pp' unless exists $pars{lang};

             # Tag condition set?
             if (exists $pars{_cnd_})
              {
               # ok, if the condition was true or could not be evaluated,
               # stop processing of this tag (there is no body, so return an empty stream)
               unless (_evalTagCondition($pars{_cnd_}, $sourceFile, $_[6][1]))
                {return([[()], $_[6][1]]);}
               else
                {
                 # strip off this special option before the tag or macro is furtherly processed
                 delete $pars{_cnd_};
                }
              }

             # did the user exclude files of the language the embedded source is written in?
             my $langExcluded=not (
                                      not $flags{filter}                        # no general language filter is defined, so all languages are allowed, or
                                   or lc($pars{lang}) eq 'pp'                   # this is a PerlPoint file, or
                                   or (
                                           exists $pars{lang}                   # there is a general language filter,
                                       and $pars{lang}=~/^$flags{filter}$/i     # and it allows to include files of this language
                                      )
                                  );

             # set import filter as necessary
             my $filterSet=_setImportFilter($_[0], \%pars);

             # Input filter to call?
             if (
                     not $langExcluded       # files in the language of the embedded one are not excluded in general
                 and exists $pars{ifilter}   # and there is an import filter
                )
               {
                # Can we invoke the filter code?
                unless ($safeObject)
                  {
                   # What a pity - but probably the unfiltered source is not what the backend
                   # expects, so we need to ignore the embedded code completely for now. As
                   # usually, this is done without warning.
                   return([[()], $_[6][1]]);
                  }
                else
                  {
                   # OK, we can try to invoke the filter.

                   # inform user
                   warn qq([Warn] $sourceFile, line $_[1][1]: Running input filter.\n) if $flags{trace} & TRACE_ACTIVE;

                   # update active contents base data, if necessary
                   if ($flags{activeBaseData})
                     {
                      no strict 'refs';
                      ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                     }

                   # We provide the text in a special variable @main::_ifilterText,
                   # and the target type in a special variable $main::_ifilterType,
                   # as well as the filename in a special var. $main::_ifilterFile.
                   {
                    no strict 'refs';
                    @{join('::', ref($safeObject) ? $safeObject->root : 'main', '_ifilterText')}=@{$_[5][0]};
                    ${join('::', ref($safeObject) ? $safeObject->root : 'main', '_ifilterType')}=$pars{lang};
                    ${join('::', ref($safeObject) ? $safeObject->root : 'main', '_ifilterFile')}=$sourceFile;
                   }

                   # run the filter and catch what it supplies
                   $_[5][0]=[ref($safeObject) ? $safeObject->reval($pars{ifilter}) : eval(join(' ', '{package main; no strict;', $pars{ifilter}, '}'))];

                   # check result
                   if ($@)
                     {
                      # inform user, if necessary
                      _semerr($_[0], qq($sourceFile, line $_[1][1]: input filter failed: $@.));

                      # ignore this part
                      return([[()], $_[6][1]]);
                     }
                  }
               }

             # check if we have to stream this code
             if (not defined($filterSet) or $langExcluded)
               {
                # filter error occured, or the caller wants to skip the embedded code:
                # we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             elsif (lc($pars{lang}) eq 'pp')
               {
                # embedded PerlPoint - pass it back to the parser (by stack)
                _stackInput($_[0], split(/(\n)/, join('',  @{$_[5][0]})));

                # reset the "end of input reached" flag if necessary
                $readCompletely=0 if $readCompletely;

                # we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             elsif (lc($pars{lang}) eq 'perl')
               {
                # This is embedded Perl code, anything passed really?
                # And does the caller want to evaluate the code?
                if (@{$_[5][0]} and $safeObject)
                  {
                   # update active contents base data, if necessary
                   if ($flags{activeBaseData})
                     {
                      no strict 'refs';
                      ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                     }

                   # make the code a string and evaluate it
                   my $perl=join('',  @{$_[5][0]});
                   warn "[Trace] $sourceFile, line $_[6][1]: Evaluating this code:\n\n$perl\n\n\n" if $flags{trace} & TRACE_ACTIVE;

                   # ignore empty code
                   if ($perl=~/\S/)
                     {
                      # well, there is something, evaluate it
                      my $result=ref($safeObject) ? $safeObject->reval($perl) : eval(join(' ', '{package main; no strict;', $perl, '}'));

                      # check result
                      if ($@)
                        {_semerr($_[0], "$sourceFile, line $_[6][1]: embedded Perl code could not be evaluated: $@.");}
                      else
                        {
                         # success - make the result part of the input stream, if any
                         _stackInput($_[0], split(/(\n)/, $result)) if defined $result;
                        }

                      # reset the "end of input reached" flag if necessary
                      $readCompletely=0 if $readCompletely;
                     }
                  }

                # we have to supply something, but it should be nothing
                [[()], $_[6][1]];
               }
             else
               {
                # reply data in a "tag envelope" (for backends)
                my %hints=(nr=>++$directiveCounter);
                [
                 [
                  # opener directive
                  [\%hints, DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED', \%pars],
                  # the list of enclosed literals, if any
                  @{$_[5][0]} ? @{$_[5][0]} : (),
                  # final directive
                  [\%hints, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED', \%pars]
                 ],
                 $_[6][1]
                ];
               }
            }
	],
	[#Rule 150
		 '@30-1', 0,
sub
#line 3829 "ppParser.yp"
{
             # trace, if necessary
             warn "[Trace] $sourceFile, line $_[1][1]: Inclusion starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;

     	     # Disable storage of a checksum. (Files may change or have changed. Later on,
             # we could try to keep a files modification date unless it is a nested PerlPoint
             # source or a dynamic Perl part. For now, it seems to be sufficient that each file
             # is cached itself.)
	         $flags{checksummed}=0;

             # temporarily activate specials "{" and "}"
             push(@specialStack, @specials{('{', '}')});
             @specials{('{', '}')}=(1, 1);

             # deactivate boost
             $flags{noboost}=1;
            }
	],
	[#Rule 151
		 'included', 3,
sub
#line 3847 "ppParser.yp"
{
             # scopies
             my ($errors, $originalPath);

             # reactivate boost
             $flags{noboost}=0;

             # restore special state of "{" and "}"
             @specials{('{', '}')}=splice(@specialStack, -2, 2);

             # check parameters: type and filename should be set at least
             my %tagpars=@{$_[3][0]};
             $errors++, _semerr($_[0], "$sourceFile, line $_[3][1]: You forgot to specify the name of your included file.") unless exists $tagpars{file};

             # set default type, if necessary
             $tagpars{type}='pp' unless exists $tagpars{type};

             # Tag condition set?
             if (exists $tagpars{_cnd_})
              {
               # ok, if the condition was true or could not be evaluated,
               # stop processing of this tag (there is no body, so return an empty stream)
               unless (_evalTagCondition($tagpars{_cnd_}, $sourceFile, $_[3][1]))
                {return([[()], $_[3][1]]);}
               else
                {
                 # strip off this special option before the tag or macro is furtherly processed
                 delete $tagpars{_cnd_};
                }
              }

             # search specified directories for the file if necessary
             unless (-e $tagpars{file})
               {
                # pathes are stored in an already prepared array @libraryPath
                foreach my $path (@libraryPath)
                  {
                   my $newname="$path/$tagpars{file}";
                   warn "[Trace] $sourceFile, line $_[3][1]: Trying include file name $newname for $tagpars{file}.\n" if $flags{trace} & TRACE_SEMANTIC;
                   $tagpars{file}=$newname, last if -e $newname;
                  }
               }

             # expand filename to avoid trouble by various names for the same file
                $tagpars{file}=catfile(abs_path(dirname($originalPath=$tagpars{file})), basename($tagpars{file}))
             or $errors++, semmerr("$sourceFile, line $_[3][1]: File name $tagpars{file} cannot be resolved.\n");

             # smart inclusion?
             my $smart=1 if     $tagpars{type}=~/^pp$/
                            and exists $tagpars{smart} and $tagpars{smart}
                            and exists $openedSourcefiles{$tagpars{file}};

             # avoid circular source inclusion
             $errors++, _semerr($_[0], "$sourceFile, line $_[3][1]: Source file $originalPath was already opened before (full path: $tagpars{file}).") if     $tagpars{type}=~/^pp$/
                                                                                                                                                                         and not $smart
                                                                                                                                                                         and grep($_ eq $tagpars{file}, @nestedSourcefiles);


             # PerlPoint headline offsets have to be positive numbers or certain strings
             $errors++, _semerr($_[0], "$sourceFile, line $_[3][1]: Invalid headline level offset $tagpars{headlinebase}, positive number or keywords BASE_LEVEL/CURRENT_LEVEL expected.") if $tagpars{type}=~/^pp$/i and exists $tagpars{headlinebase} and $tagpars{headlinebase}!~/^\d+$/ and $tagpars{headlinebase}!~/^(base|current)_level$/i;
             $tagpars{headlinebase}=$flags{headlineLevel} if exists $tagpars{headlinebase} and $tagpars{headlinebase}=~/^current_level$/i;
             $tagpars{headlinebase}=$flags{headlineLevel}-1 if exists $tagpars{headlinebase} and $tagpars{headlinebase}=~/^base_level$/i;

             # all right?
             unless (defined $smart or defined $errors)
               {
                # check the filename
                if (-r $tagpars{file})
                  {
                   # store the files name and directory for later reference
                   # (we could refer do that later, but using intermediate buffers
                   # allows to keep the original values when switching the file in
                   # background which happens with input filters)
                   my $orgname=$tagpars{file};

                   # did the user exclude files of the language the embedded source is written in?
                   my $typeExcluded=not (
                                            not $flags{filter}                           # no general language filter is defined, so all languages are allowed, or
                                         or lc($tagpars{type}) eq 'pp'                   # this is a PerlPoint file, or
                                         or (
                                                 exists $tagpars{type}                   # there is a general language filter,
                                             and $tagpars{type}=~/^$flags{filter}$/i     # and it allows to include files of this language
                                            )
                                        );

                   # try to set a set default import filter, if necessary
                   if (exists $tagpars{import} and $tagpars{import} and $tagpars{import}!~/\D/)
                    {
                     # import format not set explicitly, scan file name for extension
                     $tagpars{file}=~/\.(\w+)$/;
                     $tagpars{import}=$1;

                     # success?
                     delete $tagpars{import}, _semerr($_[0], qq($sourceFile, line $_[3][1]: could not determine import filter via file extension.)) unless $1;
                    }

                   # arrange import as necessary
                   my $filterSet=_setImportFilter($_[0], \%tagpars);

                   # Import filter to call?
                   if (not $typeExcluded and exists $tagpars{ifilter})
                     {
                      # Can we invoke the filter code?
                      unless ($safeObject)
                        {
                         # What a pity - but probably the unfiltered source is not what the backend
                         # expects, so we need to ignore the embedded code completely for now. As
                         # usually, this is done without warning.
                         return([[()], $_[3][1]]);
                        }
                      else
                        {
                         # OK, we can try to invoke the filter.

                         # inform user
                         warn qq([Warn] $sourceFile, line $_[1][1]: Running input filter.\n) if $flags{trace} & TRACE_ACTIVE;

                         # update active contents base data, if necessary
                         if ($flags{activeBaseData})
                         {
                          no strict 'refs';
                          ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                         }

                         # open original file
                         open(my $orgHandle, $tagpars{file});
                         binmode($orgHandle);

                         # We provide the text in a special variable @main::_ifilterText,
                         # and the target type in a special variable $main::_ifilterType,
                         # as well as the filename in a special var. $main::_ifilterFile.
                         {
                          no strict 'refs';
                          @{join('::', ref($safeObject) ? $safeObject->root : 'main', '_ifilterText')}=<$orgHandle>;
                          ${join('::', ref($safeObject) ? $safeObject->root : 'main', '_ifilterType')}=$tagpars{type};
                          ${join('::', ref($safeObject) ? $safeObject->root : 'main', '_ifilterFile')}=$tagpars{file};
                         }

                         # close original file
                         close($orgHandle);

                         # run the filter in the files directory and catch what it supplies
                         my $startDir=cwd();
                         chdir(dirname($orgname));

                         my @ifiltered=ref($safeObject) ? $safeObject->reval($tagpars{ifilter}) : eval(join(' ', '{package main; no strict;', $tagpars{ifilter}, '}'));
                         chdir($startDir);

                         # check result
                         if ($@)
                           {
                            # inform user, if necessary
                            _semerr($_[0], qq($sourceFile, line $_[1][1]: input filter failed: $@.));

                            # ignore this part
                            return([[()], $_[3][1]]);
                           }

                         # ok, now "replace" the original file by a temporary one
                         my ($tmpHandle, $tmpFilename)=tempfile(UNLINK => ($flags{trace} & TRACE_TMPFILES ? 0 : 1));
                         $tagpars{file}=$tmpFilename;

                         print $tmpHandle @ifiltered;
                         close($tmpHandle);
                        }
                     }

                   # check for errors
                   if (not defined $filterSet)
                     {
                      # we have to supply something - but it should be nothing
                      [[()], $_[3][1]];
                     }
                   # check specified file type
                   elsif ($tagpars{type}=~/^pp$/i)
                     {
                      # update nesting stack
                      push(@nestedSourcefiles, $orgname);

                      # update source file nesting level hint
                      _predeclareVariables({_SOURCE_LEVEL=>scalar(@nestedSourcefiles)});

                      # build a hash of variables to "localize"
                      my ($localizedVars, $localizeAll)=({}, 0);
                      if (exists $tagpars{localize})
                        {
                         # special setting?
                         if ($tagpars{localize}=~/^\s*__ALL__\s*$/)
                           {
                            # store a copy of all existing variables
                            $localizedVars=dclone(\%variables);
                            $localizeAll=1;
                           }
                         else
                           {
                            # store values of all variables to localize (passed by a comma separated list)
                            $localizedVars={map {$_=>$variables{$_}} split(/\s*,\s*/, $tagpars{localize})};
                           }

                         # the source level variable needs to be corrected
                         $localizedVars->{_SOURCE_LEVEL}-- if exists $localizedVars->{_SOURCE_LEVEL};
                        }

                      # we include a PerlPoint document, switch input handle
                      # (we intermediately have to close the original handle because of perl5.6.0 bugs)
                      unshift(
                              @inHandles, [
                                           tell($inHandle),
                                           $_[0]->{USER}->{INPUT},
                                           basename($sourceFile),
                                           $lineNrs{$inHandle},
                                           @flags{qw(headlineLevelOffset headlineLevel)},
                                           cwd(),
                                           $localizedVars, $localizeAll,
                                          ]
                             );
                      close($inHandle);
                      open($inHandle, $tagpars{file});
                      binmode($inHandle);
                      $_[0]->{USER}->{INPUT}='';
                      $sourceFile=$tagpars{file};
                      $lineNrs{$inHandle}=0;

                      # change directory with file
                      chdir(dirname($orgname));

                      # open a new input stack
                      unshift(@inputStack, []);

                      # headline level offset declared?
                      $flags{headlineLevelOffset}=exists $tagpars{headlinebase} ? $tagpars{headlinebase} : 0;

                      # store the filename in the list of opened sources, to avoid circular reopening
                      # (it would be more perfect to store the complete path, is there a module for this?)
                      $openedSourcefiles{$tagpars{file}}=1;

                      # we have to supply something, but it should be nothing
                      [[()], $_[3][1]];
                     }
                   elsif ($flags{filter} and $tagpars{type}!~/^(($flags{filter})|(?:parsed)?example)$/i)
                     {
                      # this file does not need to be included, nevertheless
                      # we have to supply something - but it should be nothing
                      [[()], $_[3][1]];
                     }
                   elsif ($tagpars{type}=~/^perl$/i)
                     {
                      # Does the caller want to evaluate code?
                      if ($safeObject)
                        {
                         # update active contents base data, if necessary
                         if ($flags{activeBaseData})
                           {
                            no strict 'refs';
                            ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
                           }

                         # evaluate the source code (for an unknown reason, we have to precede the constant by "&" here to work)
                         warn "[Info] Evaluating included Perl code.\n" unless $flags{display} & &DISPLAY_NOINFO;
                         my $result=ref($safeObject) ? $safeObject->rdo($tagpars{file})
                                                     : eval
                                                        {
                                                         # enter user code namespace
                                                         package main;
                                                         # disable "strict" checks
                                                         no strict;
                                                         # excute user code
                                                         my $result=do $tagpars{file};
                                                         # check result ($! does not need to be checked, we checked file readability ourselves before)
                                                         die $@ if $@;
                                                         # reply provided result
                                                         $result;
                                                        };

                         # check result
                         if ($@)
                           {_semerr($_[0], "$sourceFile, line $_[3][1]: included Perl code could not be evaluated: $@.");}
                         else
                           {
                            # success - make the result part of the input stream (by stack)
                            _stackInput($_[0], split(/(\n)/, $result)) if defined $result;

                            # reset the "end of input reached" flag if necessary
                            $readCompletely=0 if $readCompletely;
                           }
                        }

                      # we have to supply something, but it should be nothing
                      [[()], $_[3][1]];
                     }
                   else
                     {
                      # we include anything else: provide the contents as it is,
                      # declared as an "embedded" part
#                      open(my $included, $tagpars{file});
                      my $included=new IO::File;
                      open($included, $tagpars{file});
                      my @included=<$included>;
                      close($included);

                      # in case the file was declared a (parsed) example, embed its contents as a (verbatim) block,
                      # otherwise, include it as really embedded part (to be processed by a backend)
                      if ($tagpars{type}=~/^(parsed)?example$/i)
                        {
                         # set paragraph type
                         my $ptypeDirective=defined($1) ? DIRECTIVE_BLOCK : DIRECTIVE_VERBATIM;

                         # indent lines, if requested
                         if (exists $tagpars{indent})
                           {
                            # check parameter
                            unless ($tagpars{indent}=~/^\d+$/)
                              {$errors++, _semerr($_[0], "$sourceFile, line $_[3][1]: Invalid indentation value of \"$tagpars{indent}\", please set up a number.");}
                            else
                              {
                               # all right, indent
                               my $indentation=' ' x $tagpars{indent};
                               @included=map {"$indentation$_"} @included;
                              }
                           }

                         my %hints=(nr=>++$directiveCounter);
                         [
                          [
                           # opener directive
                           [\%hints, $ptypeDirective, DIRECTIVE_START],
                           # the list of enclosed literals
                           @included,
                           # final directive
                           [\%hints, $ptypeDirective, DIRECTIVE_COMPLETE]
                          ],
                          $_[3][1]
                         ];
                        }
                      else
                        {
                         my %hints=(nr=>++$directiveCounter);
                         [
                          [
                           # opener directive
                           [\%hints, DIRECTIVE_TAG, DIRECTIVE_START, 'EMBED', {lang=>$tagpars{type}}],
                           # the list of enclosed "literals", if any
                           @included,
                           # final directive
                           [\%hints, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'EMBED', {lang=>$tagpars{type}}]
                          ],
                          $_[3][1]
                         ];
                        }
                     }
                  }
                else
                  {
                   # file missing, simply inform user
                   $errors++, _semerr($_[0], "$sourceFile, line $_[3][1]: File $tagpars{file} does not exist or cannot be read (current directory: ", cwd(), ").");

                   # we have to supply something, but it should be nothing
                   [[()], $_[3][1]];
                  }
               }
             else
               {
                # we have to supply something, but it should be nothing
                [[()], $_[3][1]];
               }
            }
	],
	[#Rule 152
		 '@31-1', 0,
sub
#line 4218 "ppParser.yp"
{
                     # switch to definition mode
                     _stateManager(STATE_DEFINITION);

                     # trace, if necessary
                     warn "[Trace] $sourceFile, line $_[1][1]: Macro definition starts.\n" if $flags{trace} & TRACE_PARAGRAPHS;
                    }
	],
	[#Rule 153
		 '@32-3', 0,
sub
#line 4226 "ppParser.yp"
{
                     # deactivate boost
                     $flags{noboost}=1;
                    }
	],
	[#Rule 154
		 '@33-5', 0,
sub
#line 4231 "ppParser.yp"
{
                     # reactivate boost
                     $flags{noboost}=0;
                    }
	],
	[#Rule 155
		 '@34-7', 0,
sub
#line 4236 "ppParser.yp"
{
                     # disable all specials to get the body as a plain text
                     @specials{keys %specials}=(0) x scalar(keys %specials);
                    }
	],
	[#Rule 156
		 'alias_definition', 9,
sub
#line 4241 "ppParser.yp"
{
                     # "text" already switched back to default mode (and disabled specials [{}:])

                     # trace, if necessary
                     warn "[Trace] $sourceFile, line $_[7][1]: Macro definition completed.\n" if $flags{trace} & TRACE_PARAGRAPHS;

                     # check spelling (only accept capitals and underscores in alias names, just like in tags)
                     if ($_[3][0]=~/[a-z]/)
                       {
                        warn "[Warn] $sourceFile, line $_[3][1]: Macro \"\\$_[3][0]\" is stored as ", uc("\\$_[3][0]"), ".\n" unless $flags{display} & DISPLAY_NOWARN;
                        $_[3][0]=uc($_[3][0]);
                       }

                     # build macro text
                     shift(@{$_[9][0]}); pop(@{$_[9][0]});
                     my $macro=join('', @{$_[9][0]});

                     # anything specified?
                     if ($macro=~/^\s*$/)
                       {
                        # nothing defined, should this line cancel a previous definition?
                        if (exists $macros{$_[3][0]})
                          {
                           # cancel macro
                           delete $macros{$_[3][0]};

                           # trace, if necessary
                           warn "[Trace] $sourceFile, line $_[7][1]: Macro \"$_[3][0]\" is cancelled.\n" if $flags{trace} & TRACE_SEMANTIC;

                           # update macro checksum
                           $macroChecksum=sha1_base64(nfreeze(\%macros));
                          }
                        else
                          {
                           # trace, if necessary
                           warn "[Trace] $sourceFile, line $_[7][1]: Empty macro \"$_[3][0]\" is ignored.\n" if $flags{trace} & TRACE_SEMANTIC;
                          }
                       }
                     else
                       {
                        # ok, this is a new definition - get all used parameters
                        my %pars;
                        @pars{($macro=~/__([^_\\]+)__/g)}=();

                        # store default values of options, if necessary
                        if (@{$_[5][0]})
                          {
                           # the list already consists of key/value pairs
                           my %defaults=@{$_[5][0]};
                           exists $pars{$_} and $pars{$_}=$defaults{$_} for keys %defaults;
                          }

                        # tag body wildcard is no parameter
                        my $bodyFlag=exists $pars{body} ? 1 : 0;
                        delete $pars{body};

                        # make guarded underscores just underscores
                        $macro=~s/\\_//g;

                        # store name, parameters (and their defaults, if any),
                        # macro text and body flag
                        $macros{$_[3][0]}=[\%pars, $macro, $bodyFlag];

                        # update macro checksum
                        $macroChecksum=sha1_base64(nfreeze(\%macros));
                       }

                     # we have to supply something, but it should be nothing
                     # (this is a paragraph, so reply a plain string)
                     ['', $_[11][1]];
                    }
	]
],
                                  @_);
    bless($self,$class);
}

#line 4316 "ppParser.yp"



# ------------------------------------------
# Internal function: input stack management.
# ------------------------------------------
sub _stackInput
 {
  # get parameters
  my ($parser, @lines)=@_;

  # declare variable
  my (@waiting);

  # the current input line becomes the last line to read in this set
  # (this way, we arrange it that additional text is exactly placed where its generator tag or macro stood,
  # without Ils confusion)
  push(@lines, (defined $parser->{USER}->{INPUT} and $parser->{USER}->{INPUT}) ? $parser->{USER}->{INPUT} : ());

  # combine line parts to lines completed by a trailing newline
  # (additionally, take into account that there might be mixed references which have to be stored unchanged)
  {
   my $lineBuffer='';
   foreach my $line (@lines)
     {
      if (ref($line))
        {
         # push collected string and current reference
         push(@waiting, length($lineBuffer) ? $lineBuffer : (), $line);

         # reset line buffer
         $lineBuffer='';

         # next turn
         next;
        }

      # compose a string ...
      $lineBuffer.=$line;

      # ... until a newline was found
      push(@waiting, $lineBuffer), $lineBuffer='' if $line eq "\n";
     }
   push(@waiting, $lineBuffer) if length($lineBuffer);
  }

  # get next line to read
  my $newInputLine=shift(@waiting);

  # update (innermost) input stack
  unshift(@{$inputStack[0]}, @waiting);

  # update line memory (flag that this was an expanded line by adding a third parameter)
  unshift(@inLine, [length($newInputLine)+length('exp.: '), "exp.: $newInputLine", 1]);

  # make the new top line the current input
  $parser->{USER}->{INPUT}=$newInputLine;
 }



# a pattern lookup table for certain specials, used by the lexer (should be scoped to it
# but indentation of a long function takes time ...)
my %specials2patterns;
@specials2patterns{'colon', 'number', '-'}=(':', '0-9', '\-');


# -----------------------------
# Internal function: the lexer.
# -----------------------------
sub _lexer
 {
  # get parameters
  my ($parser)=@_;

  # scan for unlexed EOL�s which should be ignored
  while (
	     $parser->{USER}->{INPUT}
	 and $parser->{USER}->{INPUT}=~/^\n/
	 and (
	         $lexerFlags{eol}==LEXER_IGNORE
	      or (
		      @tableSeparatorStack
		  and $tableSeparatorStack[0][1] eq "\n"
		  and $tableColumns<0
		 )
	     )
	)
    {
     # trace, if necessary
     warn "[Trace] Lexer: Ignored EOL in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;

     # remove the ignored newline
     $parser->{USER}->{INPUT}=~s/^\n//;

     # update column counter, if necessary
     $tableColumns++ if @tableSeparatorStack and $tableSeparatorStack[0][1] eq "\n" and $tableColumns<0;
    }

  # get next symbol
  unless ($parser->{USER}->{INPUT})
    {
     # update line memory (removed handled lines, both original and expanded ones)
     # (use a do block to perform the operation once in any case, see perlsyn)
     do {shift(@inLine)} until not @inLine or @{$inLine[0]}==2;

      {
       # will the next line be get from the input stack instead of from a real file?
       my $lineFromStack=scalar(@{$inputStack[0]});

       # reset stack line buffer, if necessary
       undef @previousStackLines unless $lineFromStack;

       # get next input line
       unless (
                  (@{$inputStack[0]} and ($parser->{USER}->{INPUT}=shift(@{$inputStack[0]}) or 1))
               or (defined($inHandle) and $parser->{USER}->{INPUT}=<$inHandle>)
              )
         {
          # was this a nested source?
          unless (@inHandles)
            {
             # This was the base document: should we insert a final additional token?
             # (In case we recognize the end of a document source when there is still a
             # paragraph filter pending, supply as many "empty lines" as necessary to let
             # the parser recognize the filtered paragraph is completed. Possibly a loop
             # detection should be added to avoid endless ping-pong.)
             $readCompletely=1,
             (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Final Empty_line in line $lineNrs{$inHandle}.\n")),
             return('Empty_line', ['', $lineNrs{$inHandle}]) unless $readCompletely and not $flags{virtualParagraphStart};

             # well done
             return('', [undef, -1]);
            }
          else
            {
             # we finished a nested source: close it and restore
             # things to continue reading of enclosing file
             my ($helper1, $helper2, $helper3, $localizedVars, $localizedAll);
             (
              $helper1,
              $parser->{USER}->{INPUT},
              $sourceFile,
              $helper2,
              @flags{qw(headlineLevelOffset headlineLevel)},
              $helper3,
              $localizedVars, $localizedAll,
             )=@{shift(@inHandles)};
             $lineNrs{$inHandle}=$helper2-1; # -1 to compensate the subsequent increment

             # back to envelopes directory
             chdir($helper3);

             # reopen envelope file
             close($inHandle);
             $inHandle=new IO::File;
             open($inHandle, $sourceFile);
             binmode($inHandle);
             seek($inHandle, $helper1, 0);

             # switch back to envelopes input stack
             shift(@inputStack);

             # update nesting stack
             pop(@nestedSourcefiles);

	     # update source file nesting level hint
	     _predeclareVariables({_SOURCE_LEVEL=>scalar(@nestedSourcefiles)});

             # restore variables as necessary
             if ($localizedAll)
               {
                # Do we have to take care of the stream?
                if ($flags{var2stream})
                  {
                   # stream variable reset
                   push(@{$resultStreamRef->[STREAM_TOKENS]}, [{}, DIRECTIVE_VARRESET, DIRECTIVE_START]);

                   # update tag finish memory
                   _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));

                   # restore former variables completely, overwriting current settings
                   # (and propagating them into the stream again)
                   undef %variables;
                   _predeclareVariables({$_=>$localizedVars->{$_}}, 1) foreach sort keys %$localizedVars;
                  }
                else
                  {
                   # ok, the stream does not take notice of this operation, so it can be performed quicker
                   %variables=%$localizedVars;
                  }
               }
             elsif (!$localizedAll and %$localizedVars)
               {
                # handle each localized variable
                foreach my $var (keys %$localizedVars)
                  {
                   # restore old value in parser and stream context, if necessary
                   _predeclareVariables({$var=>$localizedVars->{$var}}, 1)
                     if $localizedVars->{$var} ne $variables{$var};
                  }
               }
            }
         }

       # update stack line buffers, if necessary
       if ($lineFromStack)
         {
          # "rotate" buffers (necessary because there are various return points following,
          # so there will be not exactly one final point where we could save the current
          # line value in a scalar buffer)
          $previousStackLines[0]=$previousStackLines[1];
          $previousStackLines[1]=$parser->{USER}->{INPUT};
         }

       # reference found on stack?
       if ($lineFromStack and ref($parser->{USER}->{INPUT}))
         {
          # get the reference
          my @refLexed=_refLexed($parser);

          # unless the item was a newline, we can use it directly
          # (but the context for newline evaluation might have changed between the
          # point of delaying and now)
          return @refLexed unless $refLexed[0] eq 'Empty_line';

          # ok, this has to be parsed *again* (because the paragraph/special characters
          # context *now* might be different from that that was present when we stacked
          # the item)
          ($parser->{USER}->{INPUT}, $lineNrs{$inHandle})=@{$refLexed[1]};
         }

       # update line counter, if necessary
       $lineNrs{$inHandle}++ unless $lineFromStack;

       # ignore this line if wished (take conditions and docstreams into account)
       $parser->{USER}->{INPUT}='', redo if $flags{skipInput}==1 and $parser->{USER}->{INPUT}!~/^\?/;
       $parser->{USER}->{INPUT}='', redo if $flags{skipInput}==2 and $parser->{USER}->{INPUT}!~/^[~=]/;

       # if we are here, we can leave the skip mode (both condition and docstream one)
       $flags{skipInput}=0;

       # we read a new line (or something from stack)
       unshift(@inLine, [length($parser->{USER}->{INPUT})+length('org.: '), "org.: $parser->{USER}->{INPUT}"]);

       unless ($lineFromStack)
         {
          # add a line update hint
          if ($flags{linehints})
            {
             push(@{$resultStreamRef->[STREAM_TOKENS]}, [{}, DIRECTIVE_NEW_LINE, DIRECTIVE_START, {file=>$sourceFile, line=>$lineNrs{$inHandle}}]);

             # update tag finish memory by the way
             _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));
            }

          # remove TRAILING whitespaces, but keep newlines (if any)
          {
           my $newline=($parser->{USER}->{INPUT}=~/\n$/m);
           $parser->{USER}->{INPUT}=~s/\s*$//;
           $parser->{USER}->{INPUT}=join('', $parser->{USER}->{INPUT}, "\n") if $newline;
          }
	 }

       # scan for empty lines as necessary
       if ($parser->{USER}->{INPUT}=~/^$/)
         {
          # update the checksum flags
          $flags{checksum}=1 if $flags{cache} & CACHE_ON;

          # trace, if necessary
          warn "[Trace] Lexer: Empty_line in line $lineNrs{$inHandle}", $lexerFlags{el}==LEXER_IGNORE ? ' is ignored' : '', ".\n" if $flags{trace} & TRACE_LEXER;

          # update input line
          $parser->{USER}->{INPUT}='';

          # sometimes empty lines have no special meaning
          shift(@inLine), redo if $lexerFlags{el}==LEXER_IGNORE;

          # but sometimes they are very special
          return('Empty_line', ["\n", $lineNrs{$inHandle}]);
         }
       else
         {
          # disable caching for embedded code containing empty lines
          $flags{checksummed}=0 if $specials{embedded};

          # this may be the first line of a new paragraph to be checksummed
          if (
                  ($flags{cache} & CACHE_ON)
              and $flags{checksum}
              and not $lineFromStack
              and (not $specials{heredoc} or $specials{heredoc} eq '1')
              and not @tableSeparatorStack
              and not $specials{embedded}
             )
            {
             # handle $/ locally
             local($/);

             # update statistics
             $statistics{cache}[0]++;

             # well, switch to paragraph mode (depending on the paragraph type)!
             if ($parser->{USER}->{INPUT}=~/^<<(\w+)/)
               {$/="\n$1";}
             elsif ($parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i)
               {$/="\n\\END_TABLE";}
             else
               {$/='';}

             # store current position
             my $lexerPosition=tell($inHandle);

             # read *current* paragraph completely (take care - we may have read it completely yet!)
             seek($inHandle, $lexerPosition-length($parser->{USER}->{INPUT}), 0) unless $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;
             my $paragraph=<$inHandle>;
             $paragraph=join('', $parser->{USER}->{INPUT}, $paragraph) if $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;

             # count the lines in the paragraph read
             my $plines=0;
             $plines++ while $paragraph=~/(\n)/g;
             $plines-- unless $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;

             # remove trailing whitespaces (to avoid checksumming them)
             $paragraph=~s/\n+$//;

             # anything interesting found?
             if (defined $paragraph)
               {
                # build checksum (of paragraph *and* headline level offset)
                my $checksum=sha1_base64(join('+', exists $flags{headlineLevelOffset} ? $flags{headlineLevelOffset} : 0, $paragraph));

                # warn "---> Searching checksum for this paragraph:\n-----\n$paragraph\n- by $checksum --\n";
                # check paragraph to be known
                if (
                        exists $checksums->{$sourceFile}
                    and exists $checksums->{$sourceFile}{$checksum}
                    and (
                            not defined $checksums->{$sourceFile}{$checksum}[3]
                         or $checksums->{$sourceFile}{$checksum}[3] eq $macroChecksum
                        )
                    and (
                            not defined $checksums->{$sourceFile}{$checksum}[4]
                         or $checksums->{$sourceFile}{$checksum}[4] eq $varChecksum
                        )
                   )
                  {
                   # Do *not* reset the checksum flag for new checksums - we already read the
                   # empty lines, and a new paragraph may follow! *But* deactivate the current
                   # checksum to avoid multiple storage - we already stored it, right?
                   $flags{checksummed}=0;

                   # reset input buffer - it is all handled (take care to remove a final newline
                   # if the paragraph was closed by a string - this would normally be read in a
                   # per line processing, but it remained in the file in paragraph mode)
                   $/="\n";
                   scalar(<$inHandle>) if $parser->{USER}->{INPUT}=~/^<<(\w+)/ or $parser->{USER}->{INPUT}=~/^(?<!\\)\\TABLE/i;
                   $parser->{USER}->{INPUT}='';

                   # warn "===========> PARAGRAPH CACHE HIT!! ($lineNrs{$inHandle}/$sourceFile/$checksum) <=================\n$paragraph-----\n";
                   # use Data::Dumper; warn Dumper($checksums->{$sourceFile}{$checksum});

                   # update statistics
                   $statistics{cache}[1]++;

                   # update line counter
                   # warn "----> Old line: $lineNrs{$inHandle}\n";
                   $lineNrs{$inHandle}+=$plines;
                   # warn "----> New line: $lineNrs{$inHandle}\n";

                   # update anchors
                   $anchors->add($_, $checksums->{$sourceFile}{$checksum}[5]{$_}, $flags{headlinenr})
                     foreach keys %{$checksums->{$sourceFile}{$checksum}[5]};

                   # The next steps depend - follow the provided hint. We may have to reinvoke
                   # the parser to restore a state.
# perl 5.6 #       unless (exists $checksums->{$sourceFile}{$checksum}[2])
                   unless (defined $checksums->{$sourceFile}{$checksum}[2])
                     {
                      # direct case - add the already known part directly to the stream
                      push(@{$resultStreamRef->[STREAM_TOKENS]}, @{$checksums->{$sourceFile}{$checksum}[0]});

                      # update tag finish memory
                      _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));

                      # Well done this paragraph - go on!
                      shift(@inLine);
                      redo;
                     }
                   else
                     {
                      # more complex case - reinvoke the parser to update its states
                      return($checksums->{$sourceFile}{$checksum}[2], [dclone($checksums->{$sourceFile}{$checksum}[0]), $lineNrs{$inHandle}]);
                     }
                  }

                # flag that we are going to build an associated stream
                $flags{checksummed}=[$checksum, scalar(@{$resultStreamRef->[STREAM_TOKENS]}), $plines];
                # warn "---> Started checksumming for\n-----\n$paragraph\n---(", $plines+1, " line(s))\n";

                # restart anchor logging
                $anchors->checkpoint(1);
               }

             # reset file pointer
             seek($inHandle, $lexerPosition, 0);
            }

          # update the checksum flag: we are *within* a paragraph, do not checksum
          # until we reach the next empty line
          $flags{checksum}=0;
         }

       # detect things at the beginning of a *real* line at the beginning of a paragraph
       # (which nevertheless might have been stacked)
       if (   not $lineFromStack
           or (    defined $previousStackLines[0]
               and not ref($previousStackLines[0])
               and $previousStackLines[0]=~/\n$/
              )
          )
         {
          my @rc=_lineStartResearch($parser);
          return(@rc) if shift(@rc);
         }
      }
    }

  # trace, if necessary
  warn '[Trace] Lexing ', ref($parser->{USER}->{INPUT}) ? 'a prepared part' : qq("$parser->{USER}->{INPUT}"), ".\n" if $flags{trace} & TRACE_LEXER;

  # Reference found? (Usually placed by _stackInput().)
  return _refLexed($parser) if ref($parser->{USER}->{INPUT});

  # if the paragraph was just filtered, there might be certain operations to perform
  # (as usual at the beginning of a new paragraph)
  if ($parserState==STATE_PFILTERED)
    {
     my @rc=_lineStartResearch($parser);
     return(@rc) if shift(@rc);
    }

  # scan for heredoc close hints
  if ($specials{heredoc} and $specials{heredoc} ne '1' and $parser->{USER}->{INPUT}=~/^($specials{heredoc})$/)
    {
     # trace, if necessary
     warn "[Trace] Lexer: Heredoc close hint $1 in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;

     # update input line
     $parser->{USER}->{INPUT}='';

     # reset heredoc setting
     $specials{heredoc}=1;

     # reply token
     return('Heredoc_close', [$1, $lineNrs{$inHandle}]);
    }

  # can we take the rest of the line at *once*?
  if (($parserState==STATE_COMMENT or $parserState==STATE_VERBATIM) and $parser->{USER}->{INPUT} ne "\n")
    {
     # grab line and chomp if necessary
     my $line=$parser->{USER}->{INPUT};
     chomp($line) unless $parserState==STATE_VERBATIM;

     # update input line (restore trailing newline if it will be used to detect paragraph completion)
     $parser->{USER}->{INPUT}=$parserState==STATE_VERBATIM ? '' : "\n";

     # trace, if necessary
     warn qq([Trace] Lexer: word "$line" in line $lineNrs{$inHandle}.\n) if $flags{trace} & TRACE_LEXER;

     # supply result
     return('Word', [$line, $lineNrs{$inHandle}]);
    }

  # reply a token
  for ($parser->{USER}->{INPUT})
    {
     # declare scopies
     my ($found, $sfound);

     # check for table separators, if necessary (these are the most common strings)
     if (@tableSeparatorStack)
       {
        # check for a column separator
        s/^$tableSeparatorStack[0][0]//,
        (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: table column separator in line $lineNrs{$inHandle}.\n")),
        return('Table_separator', ['c', $lineNrs{$inHandle}]) if /^($tableSeparatorStack[0][0])/;

        # check for row separator
        s/^$tableSeparatorStack[0][1]//,
        (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: table row separator in line $lineNrs{$inHandle}.\n")),
        return('Table_separator', ['r', $lineNrs{$inHandle}]) if /^($tableSeparatorStack[0][1])/;
       }

     # reply next token: EOL?
     if (/^(\n)/)
       {
        if ($lexerFlags{eol}==LEXER_TOKEN)
          {
           $found=$1;
           warn("[Trace] Lexer: EOL in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('EOL', [$found, $lineNrs{$inHandle}]);
          }
        elsif ($lexerFlags{eol}==LEXER_EMPTYLINE)
          {
           # flag "empty line" as wished
           warn("[Trace] Lexer: EOL -> Empty_line in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('Empty_line', ['', $lineNrs{$inHandle}]);
          }
        elsif ($lexerFlags{eol}==LEXER_SPACE)
          {
           # flag "space" as wished and reply a simple whitespace
           warn("[Trace] Lexer: EOL -> Space in line $lineNrs{$inHandle}.\n") if $flags{trace} & TRACE_LEXER;
           s/^$1//;
           return('Space', [' ', $lineNrs{$inHandle}]);
          }
        else
          {die "[BUG] Unhandled EOL directive $lexerFlags{eol}.";}
       }

     # reply next token: scan for Ils if necessary
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Ils in line $lineNrs{$inHandle}.\n")),
     return('Ils', [$found, $lineNrs{$inHandle}]) if $parserState==STATE_PFILTERED and /^$lexerPatterns{space}/;

     # reply next token: scan for spaces
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Space in line $lineNrs{$inHandle}.\n")),
     return('Space', [$found, $lineNrs{$inHandle}]) if /^$lexerPatterns{space}/;

     # reply next token: scan for paragraph filter delimiters ("||" and "|")
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn(qq([Trace] Lexer: Paragraph filter delimiter "$found" in line $lineNrs{$inHandle}.\n))),
     return($found, [$found, $lineNrs{$inHandle}]) if /^$lexerPatterns{pfilterDelimiter}/ and $specials{pfilter};

     # reply next token: scan for here doc openers
     $found=$1, s/^<<$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Heredoc opener $found in line $lineNrs{$inHandle}.\n")),
     return('Heredoc_open', [$found, $lineNrs{$inHandle}]) if /^<<(\w+)/ and $specials{heredoc} eq '1';

     # reply next token: scan for SPECIAL tagnames: \TABLE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Table starts in line $lineNrs{$inHandle}.\n")),
     return('Table', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^$lexerPatterns{table}/;

     # reply next token: scan for SPECIAL tagnames: \END_TABLE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Table completed in line $lineNrs{$inHandle}.\n")),
     return('Tabled', [$found, $lineNrs{$inHandle}])  if $specials{tag} and /^$lexerPatterns{endTable}/;

     # reply next token: scan for SPECIAL tagnames: \EMBED
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Embedding starts in line $lineNrs{$inHandle}.\n")),
     return('Embed', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^$lexerPatterns{embed}/;

     # reply next token: scan for SPECIAL tagnames: \END_EMBED
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Embedding completed in line $lineNrs{$inHandle}.\n")),
     return('Embedded', [$found, $lineNrs{$inHandle}]) if $specials{embedded} and /^$lexerPatterns{endEmbed}/;

     # reply next token: scan for SPECIAL tagnames: \INCLUDE
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Including starts in line $lineNrs{$inHandle}.\n")),
     return('Include', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^$lexerPatterns{include}/;

     # reply next token: scan for tagnames
     $found=$1, s/^\\$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Tag opener $found in line $lineNrs{$inHandle}.\n")),
     return('Tag_name', [$found, $lineNrs{$inHandle}]) if $specials{tag} and /^$lexerPatterns{tag}/ and (exists $tagsRef->{$1} or exists $macros{$1});

     # reply next token: scan for special characters
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Special $found in line $lineNrs{$inHandle}.\n")),
     return($found, [$found, $lineNrs{$inHandle}]) if /^$patternNlbBackslash(\S)/ and exists $specials{$1} and $specials{$1};

     # reply next token: scan for definition list items
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Colon in line $lineNrs{$inHandle}.\n")),
     return('Colon', [$found, $lineNrs{$inHandle}]) if $specials{colon} and /^$lexerPatterns{colon}/;

     # reply next token: search for named variables (which need to be defined except at the
     # beginning of a new assignment paragraph)
     $found=$1, s/^\$$1//,
     (($flags{trace} & TRACE_LEXER) and warn(qq([Trace] Lexer: Named variable "$found" in line $lineNrs{$inHandle}.\n))),
     return('Named_variable', [$found, $lineNrs{$inHandle}])
       if     /^$lexerPatterns{namedVar}(=?)/
          and (
                  ($parserState==STATE_DEFAULT and defined($2))
               or exists $variables{$1}
              );

     # reply next token: search for symbolic variables (these cannot be used in assignments,
     # so handling is easier)
     $found=$2, s/^\$$1//,
     (($flags{trace} & TRACE_LEXER) and warn(qq([Trace] Lexer: Symbolic variable "$found" in line $lineNrs{$inHandle}.\n))),
     return('Symbolic_variable', [$found, $lineNrs{$inHandle}])
       if /^$lexerPatterns{symVar}/ and exists $variables{$2};

     # flag that this paragraph *might* use macros someday, if there is still something being no tag and no
     # macro, but looking like a tag or a macro (somebody could *later* declare it a real macro, so the cache
     # needs to check macro definitions)
     $flags{checksummed}[3]=1
       if     $specials{tag} and /^$lexerPatterns{tag}/
          and not (exists $flags{checksummed} and not $flags{checksummed});

     # likewise, flag that this paragraph *might* use variables someday, if there is still something being no variable,
     # but looking like a variable (somebody could *later* declare it a real var, so the cache
     # needs to check variable definitions)
     $flags{checksummed}[4]=1
       if     /($lexerPatterns{namedVarKernel})|($lexerPatterns{symVarKernel})/
          and not (exists $flags{checksummed} and not $flags{checksummed});

     # remove guarding \\, if necessary
     s/^\\// unless    $specials{heredoc}
                    or (defined $lexerFlags{backsl} and $lexerFlags{backsl}==LEXER_TOKEN)
                    or $parserState==STATE_EMBEDDING
                    or $parserState==STATE_PFILTER
                    or $parserState==STATE_CONDITION
                    or $parserState==STATE_DEFINITION;

     # reply next token: scan for numbers, if necessary
     $found=$1, s/^$1//,
     (($flags{trace} & TRACE_LEXER) and warn("[Trace] Lexer: Number $found in line $lineNrs{$inHandle}.\n")),
     return('Number', [$found, $lineNrs{$inHandle}]) if $specials{number} and /^(\d+)/;

     unless ($flags{noboost})
       {
        # build set of characters to be special
        my $special=join('', '([', (map {exists $specials2patterns{$_} ? $specials2patterns{$_} : $_} grep(($specials{$_} and (length==1 or exists $specials2patterns{$_})), keys %specials)), '\n\\\\', '])');
        $special=qr($special|(\|{1,2})) if $specials{pfilter};
        $special=qr($special|($tableSeparatorStack[0][0])|($tableSeparatorStack[0][1])) if @tableSeparatorStack;
        $special=qr($special|(($lexerPatterns{namedVar})|($lexerPatterns{symVar})));

        # reply next token: scan for word or single character (declared as "Word" as well)
        #warn("~~~~~~~~~> $special\n");
        #warn("---------> $_");
        $found=$1, s/^\Q$1//,
        #warn("=====> $found\n\n"),
        (($flags{trace} & TRACE_LEXER) and warn(qq([Trace] Lexer: (Boosted) word "$found" in line $lineNrs{$inHandle}.\n))),
        return('Word', [$found, $lineNrs{$inHandle}])
          if $_!~/^$special/ and /^(.+?)($special|($))/;
       }

     # reply next token: scan for word or single character (declared as "Word" as well)
     $found=$1, s/^\Q$1//,
     (($flags{trace} & TRACE_LEXER) and warn(qq([Trace] Lexer: Word "$found" in line $lineNrs{$inHandle}.\n))),
     return('Word', [$found, $lineNrs{$inHandle}]) if /^($patternWUmlauts)/ or /^(\S)/;

     # everything should be handled - this code should never be executed!
     die qq([BUG] $sourceFile, line $lineNrs{$inHandle}: No symbol found in "$_"!\n);
    }
 }


# evaluate a tag condition (can possibly be generalized: this is just a piece of code)
sub _evalTagCondition
 {
  # get parameters
  my ($code, $file, $line)=@_;
  confess "[BUG] Missing code parameter.\n" unless defined $code;
  confess "[BUG] Missing file parameter.\n" unless defined $file;
  confess "[BUG] Missing line parameter.\n" unless defined $line;

  # declare variables
  my ($rc);

  #  Does the caller want to evaluate the code?
  if ($safeObject)
    {
     # update active contents base data, if necessary
     if ($flags{activeBaseData})
       {
        no strict 'refs';
        ${join('::', ref($safeObject) ? $safeObject->root : 'main', 'PerlPoint')}=dclone($flags{activeBaseData});
       }

     # make the code a string and evaluate it
     warn "[Trace] $sourceFile, line $line: Evaluating this code:\n\n$code\n\n\n" if $flags{trace} & TRACE_ACTIVE;

     # invoke perl to compute the result
     $rc=ref($safeObject) ? $safeObject->reval($code) : eval(join(' ', '{package main; no strict;', $code, '}'));

     # check result
     _semerr($_[0], "$file, line $line: tag condition could not be evaluated: $@.") if $@;
    }

  # supply result
  $rc;
 }

# reference lexed: reply appropriate token
sub _refLexed
  {
   # get parameters
   my ($parser)=@_;

   # we got an already prepared stream part or a delayed token
   if (ref($parser->{USER}->{INPUT}) eq 'PerlPoint::Parser::DelayedToken')
     {
      my $delayedToken=$parser->{USER}->{INPUT};
      $parser->{USER}->{INPUT}='';
      return($delayedToken->token, $delayedToken->value);
     }
   else
     {
      my $streamedPart=$parser->{USER}->{INPUT};
      $parser->{USER}->{INPUT}='';
      return('StreamedPart', [$streamedPart, $lineNrs{$inHandle}]);
     }
  }


sub _lineStartResearch
 {
  # get parameters
  my ($parser)=@_;

  # scan for indented lines, if necessary
  if ($parser->{USER}->{INPUT}=~/^(\s+)/)
    {
     if ($lexerFlags{ils}==LEXER_TOKEN)
       {
        # trace, if necessary
        warn "[Trace] Lexer: Ils in line $lineNrs{$inHandle}.\n" if $flags{trace} & TRACE_LEXER;

        # update input buffer and reply the token (contents is necessary as well)
        my $ils=$1;
        $parser->{USER}->{INPUT}=~s/^$1//;
        return(1, 'Ils', [$ils, $lineNrs{$inHandle}]);
       }
     elsif ($lexerFlags{ils}==LEXER_IGNORE)
       {
        warn "[Trace] Lexer: Ils in line $lineNrs{$inHandle} is ignored.\n" if $flags{trace} & TRACE_LEXER;
        $parser->{USER}->{INPUT}=~s/^(\s+)//;
       }
    }

  # scan for a need of a virtual token opening a new paragraph
  # (to avoid parser state trouble caused by filters when the parser needs a lookahead
  # to detect the next paragraph)
  # warn "------> state $parserState (", STATE_DEFAULT, "), flag $flags{virtualParagraphStart}, $lexerFlagsOfPreviousState{cbell}\n";
  if ($parserState==STATE_DEFAULT and $flags{virtualParagraphStart} and $lexerFlagsOfPreviousState{cbell} ne LEXER_IGNORE)
    {
     warn "[Trace] Inserted virtual token to enable clean parser lookahead after pfilter invokation.\n" if $flags{trace} & TRACE_LEXER;
     return(1, 'Word', ['', $lineNrs{$inHandle}])
       if    $lexerFlagsOfPreviousState{cbell} eq 'Ils'
          or $parser->{USER}->{INPUT}!~/^$lexerFlagsOfPreviousState{cbell}/;
    }

  # scan for a new paragraph opened by a tag, if necessary
  if (($parserState==STATE_DEFAULT or $parserState==STATE_PFILTERED) and $parser->{USER}->{INPUT}=~/^\\/)
    {
     # remain in default state, but switch to its tag mode
     _stateManager(STATE_DEFAULT_TAGMODE);
    }

  # flag that there is no token to return
  0;
 }

# ----------------------------------------------------------------------------------------------
# Internal function: error message display.
# ----------------------------------------------------------------------------------------------
sub _Error
 {
  # get parameters
  my ($parser)=@_;

  # declare base indention
  my $baseIndentation=' ' x length('[Error] ');

  # use $_[0]->YYCurtok to display the recognized *token* if necessary
  # - for users convenience, it is suppressed in the message
  warn "\n\n[Error] $sourceFile, ",
       ${$parser->YYCurval}[1] > 0 ? "line ${$parser->YYCurval}[1]" : 'all sources read',
       (exists $statistics{cache} and $statistics{cache}[1]) ? ' (or below because of cache hits)'
                                                             : (),
       ': found ',
       defined ${$parser->YYCurval}[0] ? qq("${$parser->YYCurval}[0]") : 'nothing',
       ", expected:\n$baseIndentation",
       ' ' x length('or '),
       join("\n${baseIndentation}or ",
            map {
                 exists $tokenDescriptions{$_} ? defined $tokenDescriptions{$_} ? $tokenDescriptions{$_}
                                                                                : ()
                                               : $_
                } sort grep($_!~/cache_hit$/, $parser->YYExpect)
           ),
        ".\n\n";

  # visualize error position
  warn(
       (map {my $l=$_->[1]; chomp($l); "$baseIndentation$l\n"} reverse @inLine==1 ? @inLine : @inLine[0, -1]), "",
       $baseIndentation, ' ' x ($inLine[0][0]-length($parser->{USER}->{INPUT})-1), "^\n",
       $baseIndentation, '_' x ($inLine[0][0]-length($parser->{USER}->{INPUT})-1), '|', "\n\n\n"
      ) if @inLine;
 }

# ----------------------------------------------------------------------------------------------
# Internal function: state manager.
# ----------------------------------------------------------------------------------------------
sub _stateManager
 {
  # get parameter
  my ($newState)=@_;

  # check parameter
  confess "[BUG] Invalid new state $newState passed.\n" unless    $newState==STATE_DEFAULT
                                                               or $newState==STATE_DEFAULT_TAGMODE
                                                               or $newState==STATE_TEXT
                                                               or $newState==STATE_UPOINT
                                                               or $newState==STATE_OPOINT
                                                               or $newState==STATE_DPOINT
                                                               or $newState==STATE_DPOINT_ITEM
                                                               or $newState==STATE_BLOCK
                                                               or $newState==STATE_VERBATIM
                                                               or $newState==STATE_EMBEDDING
                                                               or $newState==STATE_PFILTER
                                                               or $newState==STATE_PFILTERED
                                                               or $newState==STATE_CONDITION
                                                               or $newState==STATE_HEADLINE_LEVEL
                                                               or $newState==STATE_HEADLINE
                                                               or $newState==STATE_TABLE
                                                               or $newState==STATE_DEFINITION
                                                               or $newState==STATE_CONTROL
                                                               or $newState==STATE_COMMENT;

  # store the new state
  $parserState=$newState;

  # enter new state: default
  $newState==STATE_DEFAULT and do
    {
     # buffer last states lexer flags (take care of a clean init)
     %lexerFlagsOfPreviousState=%lexerFlags ? %lexerFlags : (cbell => LEXER_IGNORE);

     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1);

     # trace, if necessary
     warn "[Trace] Entered default state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: paragraph filter installation
  $newState==STATE_PFILTER and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1);

     # trace, if necessary
     warn "[Trace] Entered pfilter installation state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: paragraph filter (similar to default except for the name)
  $newState==STATE_PFILTERED and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1);

     # trace, if necessary
     warn "[Trace] Entered postfilter default state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };


  # enter new state: default in tag mode (same as default, but a paragraph starting with a tag delays switching to other
  # modes, so we have to explicitly disable the paragraph opener specials)
  $newState==STATE_DEFAULT_TAGMODE and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_TOKEN, LEXER_EMPTYLINE, LEXER_IGNORE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered default state in tag mode.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: headline body
  ($newState==STATE_HEADLINE or $newState==STATE_HEADLINE_LEVEL) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, $newState==STATE_HEADLINE ? 0 : 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered headline ", $newState==STATE_HEADLINE ? 'body' : 'level', " state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: comment
  $newState==STATE_COMMENT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_IGNORE, LEXER_EMPTYLINE, LEXER_IGNORE, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered comment state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_TEXT and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered text state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_TABLE and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered table paragraph state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: text
  $newState==STATE_DEFINITION and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered macro definition state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point - defined item
  ($newState==STATE_DPOINT_ITEM) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered definition item state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: list point
  ($newState==STATE_UPOINT or $newState==STATE_OPOINT or $newState==STATE_DPOINT) and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_IGNORE, LEXER_SPACE, LEXER_TOKEN, qr([*#:]));

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered point state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: block
  $newState==STATE_BLOCK and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN, 'Ils');

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered block state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: verbatim block
  $newState==STATE_VERBATIM and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered verbatim state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: embedding
  $newState==STATE_EMBEDDING and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_SPACE, LEXER_TOKEN, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered embedding state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: condition (very similar to embedding, naturally)
  $newState==STATE_CONDITION and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_SPACE, LEXER_SPACE, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered condition state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # enter new state: unordered list point
  $newState==STATE_CONTROL and do
    {
     # prepare lexer
     @lexerFlags{qw(ils eol el cbell)}=(LEXER_IGNORE, LEXER_IGNORE, LEXER_TOKEN, LEXER_IGNORE);

     # activate special characters as necessary
     @specials{('.', '/', '*', '#', '=', '<', '>', '{', '}' , '-', '?', '@', '+', '~', 'heredoc', 'colon', 'tag', 'embedded', 'number', 'pfilter')}=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

     # trace, if necessary
     warn "[Trace] Entered control state.\n" if $flags{trace} & TRACE_SEMANTIC;

     # well done
     return;
    };

  # check yourself
  confess "[BUG] Unhandled state $newState.\n";
 }


=pod

=head2 run()

This function starts the parser to process a number of specified files.

B<Parameters:>
All parameters except of the I<object> parameter are named (pass them by hash).

=over 4

=item activeBaseData

This optional parameter allows to pass common data to all active contents
(conditions, embedded and included Perl) by a I<hash reference>. By convention,
a translator at least passes the target language and user settings by

  activeBaseData => {
                     targetLanguage => "lang",
                     userSettings   => \%userSettings,
                    },

User settings are intended to allow the specification of per call settings by a
user, e.g. to include special parts. By using this convention, users can easily
specify such a part the following way

  ? flagSet('setting')

  Special part.

  ? 1

It is up to a translator author to declare translator specific settings (and to
document them). The passed values can be as complex as necessary as long as they
can be duplicated by C<Storable::dclone()>.

Whenever active contents is invoked, the passed hash reference is copied
(duplicated by C<Storable::dclone()>) into the Safe objects namespace
(see I<safe>) as a global variable $PerlPoint. This way, modifications by
invoked code do not effect subsequently called code snippets, base data are
always fresh.

=item activeDataInit

Reserved to pass hook functions to be called preparing every active contents
invokation. I<The hook is still unimplemented.>

=item cache

This optional parameter controls source file paragraph caching.

By default, a source file is parsed completely everytime you pass it to the
parser. This is no problem with tiny sources but can delay your work if you
are dealing with large sources which have to be translated periodically into
presentations while they are written. Typically most of the paragraphs remain
unchanged from version to version, but nevertheless everything is usually
reparsed which means a waste of time. Well, to improve this a paragraph
cache can be activated by setting this option to B<CACHE_ON>.

The parser caches each I<initial source file> individually. That means
if three files are passed to the parser with activated caching, three cache
files will be written. They are placed in the source file directory, named
.<source file>.ppcache. Please note that the paragraphs of I<included> sources
are cached in the cache file of the I<main> document because they may have to
be evaluated differently depending on inclusion context.

What acceleration can be expected? Well, this I<strongly>
depends on your source structure. Efficiency will grow with longer paragraphs,
reused paragraphs and paragraph number. It will be reduced by heavy usage
of active contents and embedding because every paragraph that refers
to parts defined externally is not strongly determined by itself and therefore
it cannot be cached. Here is a list of all reasons which cause a paragraph to
be excluded from caching:

=over 4

=item Embedded parts

Obviously dynamic parts may change from one version to another, but even static
parts could have to be interpreted differently because a user can set up new
I<filter>s.

=item Included files

An \INCLUDE tag immediately disables caching for the paragraph it resides in
because the loaded file may change its contents. This is not really a
restriction because the included paragraphs themselves I<are> cached if possible.

=item Filtered paragraphs

A paragraph filter can transform a source paragraph in whatever the author of
a Perl function might think is useful, potentially depending on highly dynamical
data. So it cannot be determined by the parser what the final translation of a
certain source paragraph will be.

=item Document stream entry points

Depending on the parsers configuration, these points can be transformed into
headlines or remain unchanged, so there is no fixed up mapping between a
source paragraph and its streamed expression.

=back

Even with these restrictions about 70% of a real life document of more than
150 paragraphs could be cached. This saved more than 60% of parsing time in
subsequent translator calls.

New cache entries are always I<added> which means that old entries are never
replaced and a cache file tends to grow. If you ever wish to clean up a
cache file completely pass B<CACHE_CLEANUP> to this option.

To deactivate caching explicitly pass B<CACHE_OFF>.
I<An existing cache will not be destroyed.>

Settings can be combined by I<addition>.

  # clean up the cache, then refill it
  cache => CACHE_CLEANUP+CACHE_ON,

  # clean up the cache and deactivate it
  cache => CACHE_CLEANUP+CACHE_OFF,

The B<CACHE_OFF> value is overwritten by any other setting.

It is suggested to make this setting available to translator users to let
them decide if a cache should be used.

I<Please note> that there is a problem with line numbers if paragraphs are
restored from cache because of the behaviour of perls paragraph mode. In this
mode, the <> operator reads in any number of newlines between paragraphs but
supplies only one of them. That is why I do not get the real number of lines
in a paragraph and therefore cannot store them. To work around this, two
strategies can be used. First, do not use more than exactly one newline
between paragraphs. (This strategy is not for real life users, of course,
but in this case restored numbers would be correct.) Second, remember that
source line numbers are only interesting in error messages. If the parser
detects an error, it therefore says: error "there or later" when a cache hit
already occured. If the real number is wished the parser could be reinvoked
then with deactivated cache and will report it.

I<Another known paragraph mode problem> occurs if you parse on a UNIX
system but your document (or parts of it) were written in DOS format. The
paragraph mode reads such a document I<completely>. Please replace the line
ending character sequences system appropriate. (If you are using C<dos2unix>
under Solaris please invoke it with option C<-ascii> to do this.)

More, Perls paragraph mode and PerlPoint treat whitespace lines differently.
Because of the way it works, paragraph mode does not recognize them as "empty"
while PerlPoint I<does> for reasons of usability (invisible characters should
not make a difference). This means that lines containing only whitespaces
separate PerlPoint paragraphs but not "Perl" paragraphs, making the cache
working wrong especially in examples. If paragraphs unintentionally disappear
in the resulting presentation, please check the "empty lines" before them.

Consistent cache data depend on the versions of the parser, of constant
declarations and of the module B<Storable> which is used internally. If the
parser detects a significant change in one of these versions, existing
caches are automatically rebuilt.

I<Final cache note:> cache files are not locked while they are used.
If you need this feature please let me know.

=item criticalSemanticErrors

If set to a true value, semantic errors will cause the parser to terminate
immediately. This defaults to false: errors are accumulated and finally
reported.

=item display

This parameter is optional. It controls the display of runtime messages
like informations or warnings. By default, all messages are displayed. You
can suppress these informations partially or completely by passing one or
more of the "DISPLAY_..." variables declared in B<PerlPoint::Constants>.
Constants should be combined by addition.

=item docstreams2skip

by default, all document streams are made part of the result, but by this
parameter one can I<exclude> certain streams (all remaining ones will be
streamed as usual).

The list should be supplied by an array reference.

It is suggested to take the values of this parameter from a user option,
which by convention should be named C<-skipstream>.

=item docstreaming

specifies the way the parser handles stream entry points. The value passed
might be either C<DSTREAM_DEFAULT>, C<DSTREAM_IGNORE> or C<DSTREAM_HEADLINES>.

C<DSTREAM_HEADLINES> instructs the parser to transform the entry points
into I<headlines>, one level below the current real headline level. This
is an easy to implement and convenient way of docstream handling seems to
make sense in most target formats.

C<DSTREAM_IGNORE> hides all streams except of the main stream. The effect
is similar to a call with I<docstreams2skip> set for all document streams
in a source.

C<DSTREAM_DEFAULT> treats the entry points as entry points and streams
them as such. This is the default if the parameter is omitted.

Please note that filters applied by I<docstream2skip> work regardless of
the I<docstreaming> configuration which only affects the way the parser
passes docstream data to a backend.

It is recommended to take the value of this parameter from a user option,
which by convention should be named C<-docstreaming>. (A converter can
define various more modes than provided by the parser and implement them
itself, of course. See C<pp2sdf> for a reference implementation.)


=item files

a reference to an array of files to be scanned.

Files are treated as PerlPoint sources except when their name has the
prefix C<IMPORT:>, as in C<IMPORT:podsource.pod>. With this prefix, the
parser tries to automatically tranform the source into PerlPoint,
using a standard import filter for the format indicated by the file
extension (C<pod> in our example). The filter must be installed as
C<PerlPoint::Import::E<lt>uppercased format nameE<gt>>, e.g.
C<PerlPoint::Import::POD>.

=item filter

a regular expression describing the target language. This setting, if used,
prevents all embedded or included source code of other languages than the set
one from inclusion into the generated stream. This accelerates both parsing
and backend handling. The pattern is evaluated case insensitively.

 Example: pass "html|perl" to allow HTML and Perl.

To illustrate this, imagine a translator to PostScript. If it reads a Perl
Point file which includes native HTML, this translator cannot handle such code.
The backend would have to skip the HTML statements. With a "PostScript" filter,
the HTML code will not appear in the stream.

This enables PerlPoint texts prepared for various target languages. If an
author really needs plain target language code to be embedded into PerlPoint,
he could provide versions for various languages. Translators using a filter
will then receive exactly the code of their target language, if provided.

Please note that you cannot filter out PerlPoint code or example files.

By default, no filter is set.


=item headlineLinks

this optional flag causes the parser to register all headline
titles as anchors automatically. (Headlines are stored without
possibly included tags which are stripped off.)

Registering anchors does \I<not> mean there are anchors included
to the stream, it just means that they are known to exist at
parsing time because they are added to an internal C<PerlPoint::Anchor>
object which is passed to all tag hooks and can be evaluated there.
See \C<PerlPoint::Tags> and C<PerlPoint::Anchors> for details.

It is recommended to make use of this feature if your converter
automatically makes headlines an anchor named like the headline
(this feature was introduced by Lorenz Domkes C<pp2html> initially).
(Nevertheless, usefulness may depend on dealing with the parsers
anchor collection in tag hooks. See the documentations of used
tag modules for details.)

If your converter does not support automatic headline anchors
the mentioned way, it is recommended to omit this option because
it could confuse tag hooks that evaluate the parsers anchor collection.


=item libpath

An optional reference to an array of library pathes to be searched for
files specified by \INCLUDE tags. This array is intended to be filled
by directories specified via an converter option. By convention, this
option is named C<includelib> and should be enabled multiple times
(C<converter -includelib path1 -includelib path2 document.pp>).

Please note that library pathes can be set via environment variable
C<PERLPOINTLIB> as well, but directories specified via C<libpath> are
searched I<first>.


=item linehints

If set to a true value, the parser will embed line hints into the stream
whenever a new source line begins.

A line hint directive is provided as

  [
   DIRECTIVE_NEW_LINE, DIRECTIVE_START,
   {file=>filename, line=>number}
  ]

and is suggested to be handled by a backend callback.

Please note that currently source line numbers are not guaranteed to be
correct if stream parts are restored from I<cache> (see there for details).

The default value is 0.

=item nestedTables

This is an optional flag which is by default set to 0, indicating if the parser
shall accept nested tables or not. Table nesting can produce very nice results
if it is supported by the target language. HTML, for example, allows to nest
tables, but other languages I<do not>. So, using this feature can really improve
the results if a user is focussed on supporting certain target formats only. If I want
to produce nothing but HTML, why should I take care of target formats not able
to handle table nesting? On the other hand, I<if> a document shall be translated
into several formats, it might cause trouble to nest tables therein.

Because of this, it is suggested to let converter users decide if they want to
enable table nesting or not. If the target format does not support nesting, I
recommend to disable nesting completely.


=item object

the parser object made by I<new()>;

=item safe

an object of the B<Safe> class which comes with perl. It is used to evaluate
embedded Perl code in a safe environment. By letting the caller of I<run()>
provide this object, a translator author can make the level of safety fully
configurable by users. Usually, the following should work

  use Safe;
  ...
  $parser->run(safe=>new Safe, ...);

Safe is a really good module but unfortunately limited in loading modules
transparently. So if a user wants to use modules in his embedded code, he
might fail to get it working in a Safe compartment. If safety does not matter,
he can decide to execute it without Safe, with full Perl access. To switch
on this mode, pass a true scalar value (but no reference) instead of a Safe
object.

To make all PerlPoint converters behave similarly, it is recommended to provide
two related options C<-activeContents> and C<-safeOpcode>. C<-activeContents>
should flag that active contents shall be evaluated, while C<-safeOpcode>
controls the level of security. A special level C<ALL> should mean that all
code can b executed without any restriction, while any other settings should be
treated as an opcode to configure the Safe object. So, the recommended rules
are: pass 0 unless C<-activeContents> is set. Pass 1 if the converter was
called with C<-activeContents> I<and> C<-safeOpcode ALL>. Pass a Safe object
and configure it according to the users C<-safeOpcode> settings if
C<-activeContents> is used but without C<-safeOpcode ALL>. See C<pp2sdf>
for an implementation example.

Active Perl contents is I<suppressed> if this setting is omitted or if anything
else than a B<Safe> object is passed. (There are currently three types of active
contents: embedded or included Perl and condition paragraphs.)


=item predeclaredVars

Variables are usually set by assignment paragraphs. However, it may be useful
for a converter to predeclare a set of them to provide certain settings to the
users. Predeclared variables, as any other PerlPoint variables, can be used
both in pure PerlPoint and in active contents. To help users distinguish them
from user defined vars, their names will be I<capitalized>.

Just pass a hash of variable name / value pairs:

  $parser->run(
               ...
               predeclaredVars => {
                                   CONVERTER_NAME    => 'pp2xy',
                                   CONVERTER_VERSION => $VERSION,
                                   ...
                                  },
              );

Non capitalized variable names will be capitalized without further notice.

Please note that variables currently can only be scalars. Different data types
will not be accepted by the parser.

Predeclared variables should be mentioned in the converters documentation.

The parser itself makes use of this feature by declaring C<_PARSER_VERSION>
(the version of this module used to parse the source) and _STARTDIR (the full
path of the startup directory, as reported by C<Cwd::cdw()>).

C<predeclaredVars> needs C<var2stream> to take effect.


=item skipcomments

By default comments are streamed and can be converted into comments of the target language.
But often they are of limited use in generated files: especially if they are intended to
help the author of a document, not the reader of the source of generated results. So with
this option one can suppress comments from being streamed.

It is suggested to get this setting via user option,
which by convention should be named C<-skipcomments>.

=item stream

A reference to an array where the generated output stream should be stored in.

Application programmers may want to tie this array if the target ASCII
texts are expected to be large (long ASCII texts can result in large stream
data which may occupy a lot of memory). Because of the fact that the parser
stores stream data I<by paragraph>, memory consumption can be reduced
significantly by tying the stream array.

It is recommended to pass an empty array. Stored data will not be overwritten,
the parser I<appends> its data instead (by C<push()>).

=item trace

This parameter is optional. It is intended to activate trace code while the method
runs. You may pass any of the "TRACE_..." constants declared in B<PerlPoint::Constants>,
combined by addition as in the following example:

  # show the traces of both
  # lexical and syntactical analysis
  trace => TRACE_LEXER+TRACE_PARSER,

If you omit this parameter or pass TRACE_NOTHING, no traces will be displayed.

=item var2stream

If set to a true value, the parser will propagate variable settings into the stream
by adding additional C<DIRECTIVE_VARSET> directives.

A variable propagation has the form

  [
   DIRECTIVE_VARSET, DIRECTIVE_START,
   {var=>varname, value=>value}
  ]

and is suggested to be handled by a backend callback.

The default value is 0.

=item vispro

activates "process visualization" which simply means that a user will see
progress messages while the parser processes documents. The I<numerical>
value of this setting determines how often the progress message shall be
updated, by a I<chapter interval>:

  # inform every five chapters
  vispro => 5,

Process visualization is automatically suppressed unless STDERR is
connected to a terminal, if this option is omitted, I<display> was set
to C<DISPLAY_NOINFO> or parser I<trace>s are activated.

=back

B<Return value:>
A "true" value in case of success, "false" otherwise. A call is performed
successfully if there was neither a syntactical nor a semantic error in the
parsed files.

B<Example:>

  $parser->run(
               stream => \@streamData,
               files  => \@ARGV,
               filter => 'HTML',
               cache  => CACHE_ON,
               trace  => TRACE_PARAGRAPHS,
              );

=cut
sub run
 {
  # get parameters
  my ($me, @pars)=@_;

  # build parameter hash
  confess "[BUG] The number of parameters should be even.\n" if @pars%2;
  my %pars=@pars;

  # and check parameters
  confess "[BUG] Missing object parameter.\n" unless $me;
  confess "[BUG] Object parameter is no ", __PACKAGE__, " object.\n" unless ref $me and ref $me eq __PACKAGE__;
  confess "[BUG] Missing stream array reference parameter.\n" unless $pars{stream};
  confess "[BUG] Stream array reference parameter is no array reference.\n" unless ref $pars{stream} and ref $pars{stream} eq 'ARRAY';
  confess "[BUG] Missing file list reference parameter.\n" unless $pars{files};
  confess "[BUG] File list reference parameter is no array reference.\n" unless ref $pars{files} and ref $pars{files} eq 'ARRAY';
  confess "[BUG] You should pass at least one file to parse.\n" unless @{$pars{files}};
  confess "[BUG] Active base data reference is no hash reference.\n" if exists $pars{activeBaseData} and ref $pars{activeBaseData} ne 'HASH';
  confess "[BUG] Active data initializer is no code reference.\n" if exists $pars{activeDataInit} and ref $pars{activeDataInit} ne 'CODE';
  confess "[BUG] Document stream skip list is no array reference.\n" if exists $pars{docstreams2skip} and ref $pars{docstreams2skip} ne 'ARRAY';
  if (exists $pars{filter})
    {
     eval "'lang'=~/$pars{filter}/";
     confess qq([BUG] Invalid filter expression "$pars{filter}": $@.\n) if $@;
    }

  # variables
  my ($rc, %docHints)=(1);

  # init internal data
  (
   $resultStreamRef,          #  1
   $safeObject,               #  2
   $flags{trace},             #  3
   $flags{display},           #  4
   $flags{filter},            #  5
   $flags{linehints},         #  6
   $flags{var2stream},        #  7
   $flags{cache},             #  8
   $flags{cached},            #  9
   $flags{vis},               # 10
   $flags{activeBaseData},    # 11
   $flags{activeDataInit},    # 12
   $flags{nestedTables},      # 13
   $flags{headlineLinks},     # 14
   $flags{skipcomments},      # 15
   $flags{docstreams2skip},   # 16
   $flags{docstreaming},      # 17
   $flags{criticalSemantics}, # 18
   $macroChecksum,            # 19
   $varChecksum,              # 20
   $anchors,                  # 21
  )=(
     $pars{stream},                                                                         #  1
     (                                                                                      #  2
          exists $pars{safe}
      and defined $pars{safe}
     ) ? ref($pars{safe}) eq 'Safe' ? $pars{safe}
                                    : 1
       : 0,
     exists $pars{trace} ? $pars{trace} : TRACE_NOTHING,                                    #  3
     exists $pars{display} ? $pars{display} : DISPLAY_ALL,                                  #  4
     exists $pars{filter} ? $pars{filter} : '',                                             #  5
     (exists $pars{linehints} and $pars{linehints}),                                        #  6
     (exists $pars{var2stream} and $pars{var2stream}),                                      #  7
     exists $pars{cache} ? $pars{cache} : CACHE_OFF,                                        #  8
     0,                                                                                     #  9
     exists $pars{vispro} ? $pars{vispro} : 0,                                              # 10
     exists $pars{activeBaseData} ? $pars{activeBaseData} : 0,                              # 11
     exists $pars{activeDataInit} ? $pars{activeDataInit} : 0,                              # 12
     exists $pars{nestedTables} ? $pars{nestedTables} : 0,                                  # 13
     exists $pars{headlineLinks} ? $pars{headlineLinks} : 0,                                # 14
     (exists $pars{skipcomments} and $pars{skipcomments}),                                  # 15
     exists $pars{docstreams2skip} ? {map {($_ => undef)} @{$pars{docstreams2skip}}} : 0,   # 16
     exists $pars{docstreaming} ? $pars{docstreaming} : DSTREAM_DEFAULT,                    # 17
     exists $pars{criticalSemanticErrors} ? $pars{criticalSemanticErrors} : 0,              # 18
     0,                                                                                     # 19
     0,                                                                                     # 20
     PerlPoint::Anchors->new,                                                               # 21
    );

  # prepare stream data structure and appropriate handlers
  unless (@$resultStreamRef and $resultStreamRef->[STREAM_IDENT] eq '__PerlPoint_stream__')
    {
     # empty stream
     @$resultStreamRef=();
     # initiate
     @{$resultStreamRef}[
                         STREAM_IDENT,
                         STREAM_TOKENS,
                         STREAM_HEADLINES,
                        ]=(
                           '__PerlPoint_stream__',     # stream identifier;
                           [],                         # base stream;
                           [],                         # headline stream;
                          );
    }

  # declare helper subroutines to be used in active contents
  if ($safeObject)
    {
     my $code=<<'EOC';

  unless (defined *main::flagSet{CODE})
   {
    # check if at least one of a set of flags is set
    # - define functions anonymously to avoid redefinition in case the condition is not matched
    *main::flagSet=sub
                    {
                     # declare and init variable
                     my $rc=0;

                     # check flags
                     foreach (@_)
                       {$rc=1, last if exists $PerlPoint->{userSettings}{$_};}

                     # supply result
                     $rc;
                    };

    # provide the value of a PerlPoint variable
    # - define function anonymously to avoid redefinition in case the condition is not matched
    *main::varValue=sub {${join('::', 'main', $_[0])};};
   }

# complete compartment code
EOC

     ref($safeObject) ? $safeObject->reval($code) : eval("{package main; no strict; $code}");
     die "[BUG] Bug in function definition, please inform developer: $@" if $@;
    }

  # predeclare variables
  _predeclareVariables({_PARSER_VERSION=>$PerlPoint::Parser::VERSION, _STARTDIR=>cwd()});

  # store initial variables, if necessary
  if (exists $pars{predeclaredVars})
    {
     # check data format
     confess "[BUG] Please pass predeclared variables by a hash reference .\n" unless ref($pars{predeclaredVars}) eq 'HASH';

     # declare
     _predeclareVariables($pars{predeclaredVars});
    }

  # update visualization flag
  $flags{vis}=0 unless     $flags{vis}
                       and not $flags{display} & &DISPLAY_NOINFO
                       and not $flags{trace}>TRACE_NOTHING
                       and -t STDERR;

  # init more
  @flags{qw(skipInput headlineLevelOffset headlineLevel olist virtualParagraphStart)}=(0) x 5;
  delete $flags{ifilters};
  $statistics{cache}[1]=0 if $flags{cache} & CACHE_ON;

  # init even more
  %paragraphTypeStrings=(
                         DIRECTIVE_HEADLINE()    => 'headline',
                         DIRECTIVE_TEXT()        => 'text',
                         DIRECTIVE_UPOINT()      => 'unordered list point',
                         DIRECTIVE_ULIST()       => 'list',
                         DIRECTIVE_OPOINT()      => 'ordered list point',
                         DIRECTIVE_OLIST()       => 'list',
                         DIRECTIVE_DPOINT()      => 'definition list point',
                         DIRECTIVE_DLIST()       => 'list',
                         DIRECTIVE_BLOCK()       => 'block',
                         DIRECTIVE_VERBATIM()    => 'verbatim block',
                         DIRECTIVE_TAG()         => 'tag',
                         DIRECTIVE_LIST_RSHIFT() => 'right list shifter',
                         DIRECTIVE_LIST_LSHIFT() => 'left list shifter',
                         DIRECTIVE_COMMENT()     => 'comment',
                        );
  # check tag declarations
  unless (ref($PerlPoint::Tags::tagdefs) eq 'HASH')
    {
     # warn user
     warn "[Warn] No tags are declared. No tags will be detected.\n" unless $flags{display} & DISPLAY_NOWARN;

     # init shortcut pointer
     $tagsRef={};
    }
  else
    {
     # ok, there are tags, make a shortcut
     $tagsRef=$PerlPoint::Tags::tagdefs;
    }

  # build an array of include pathes - specified via environment variable PERLPOINTLIB
  # and parameter "libpath"
  confess "[BUG] Please pass library pathes by an array reference .\n" if exists $pars{libpath} and not ref($pars{libpath}) eq 'ARRAY';
  push(@libraryPath,
       exists $pars{libpath}     ? @{$pars{libpath}} : (),
       exists $ENV{PERLPOINTLIB} ? split(/\s*;\s*/, $ENV{PERLPOINTLIB}) : (),
      );

  # welcome user
  unless ($flags{display} & DISPLAY_NOINFO)
   {
    print STDERR "[Info] The PerlPoint parser ";
    {
     no strict 'refs';
     print STDERR ${join('::', __PACKAGE__, 'VERSION')};
    }
    warn " starts.\n";
    warn "       Active contents is ", $safeObject ? ref($safeObject) ? 'safely evaluated' : 'risky evaluated' : 'ignored', ".\n";

    # report cache mode
    warn "       Paragraph cache is ", ($flags{cache} & CACHE_ON) ? '' : 'de', "activated.\n";
   }

  # save current directory
  my $startupDirectory=cwd();

  # scan all input files
  foreach my $file (@{$pars{files}})
    {
     # scopies
     my $specifiedFile=$file;

     # scan for an import directive
     if ($file=~/^IMPORT:(.+)/)
      {
       # replace the original file by a temporary one ...
       my ($tmpHandle, $tmpFilename)=tempfile(UNLINK => ($flags{trace} & TRACE_TMPFILES ? 0 : 1));
       $file=$tmpFilename;

       # which imports the real file
       my $realfile=abs_path($specifiedFile=$1);
       print $tmpHandle qq(\n\n\\INCLUDE{import=1 file="$realfile"}\n\n);
       close($tmpHandle);

       # due to the extra level chances are we have to to accept a first paragraph that is not a headline
       $flags{complainedAbout1stHeadline}='IMPORT' unless exists $flags{complainedAbout1stHeadline} and $flags{complainedAbout1stHeadline} eq '1';
      }

     # inform user
     warn "[Info] Processing $specifiedFile ...\n" unless $flags{display} & DISPLAY_NOINFO;

     # init input stack
     @inputStack=([]);

     # init nesting stack
     @nestedSourcefiles=($file);

     # update source file nesting level hint
     _predeclareVariables({_SOURCE_LEVEL=>scalar(@nestedSourcefiles)});

     # update file hint
     $sourceFile=$file;

     # open file and make the new handle the parsers input
     open($inHandle, $file) or confess("[Fatal] Could not open input file $file.\n");
     binmode($inHandle);

     # store the filename in the list of opened sources, to avoid circular reopening
     # (it would be more perfect to store the complete path, is there a module for this?)
     $openedSourcefiles{$file}=1;

     # change into the source directory
     chdir(dirname($file));

     # (cleanup and) read old checksums as necessary
     my $cachefile=sprintf(".%s.ppcache", basename($file));
     if (($flags{cache} & CACHE_CLEANUP) and -e $cachefile)
       {
        warn "       Resetting paragraph cache for $specifiedFile.\n" unless $flags{display} & DISPLAY_NOINFO;
        unlink($cachefile);
       }
     if (($flags{cache} & CACHE_ON) and -e $cachefile)
       {
        $checksums=retrieve($cachefile) ;
        #use Data::Dumper; warn Dumper($checksums);

        # clean up old format caches
        unless (
                    exists $checksums->{sha1_base64('version')}
                and $checksums->{sha1_base64('version')}>=0.38

                and exists $checksums->{sha1_base64('constants')}
                and $checksums->{sha1_base64('constants')}==$PerlPoint::Constants::VERSION

                and exists $checksums->{sha1_base64('Storable')}
                and $checksums->{sha1_base64('Storable')}==$Storable::VERSION
               )
          {
           warn "       Paragraph cache for $specifiedFile is rebuilt because of an old format.\n" unless $flags{display} & DISPLAY_NOINFO;
           unlink($cachefile);
           $checksums={};
          }
       }

     # store cache builder version and constant declarations version
     if ($flags{cache} & CACHE_ON)
       {
        $checksums->{sha1_base64('version')}=$PerlPoint::Parser::VERSION;
        $checksums->{sha1_base64('constants')}=$PerlPoint::Constants::VERSION;
        $checksums->{sha1_base64('Storable')}=$Storable::VERSION;
       }

     # store a document start directive (done here to save memory)
     push(@{$resultStreamRef->[STREAM_TOKENS]}, [\%docHints, DIRECTIVE_DOCUMENT, DIRECTIVE_START, basename($file)]);

     # update tag finish memory by the way
     _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));

     # enter first (and most common) lexer state
     _stateManager(STATE_DEFAULT);

     # flag that the next paragraph can be checksummed, if so
     $flags{checksum}=1 if $flags{cache} & CACHE_ON;

     # set a timestamp, if helpful
     $flags{started}=time unless $flags{display} & DISPLAY_NOINFO;

     # parse input
     $rc=($rc and $me->YYParse(yylex=>\&_lexer, yyerror=>\&_Error, yydebug => ($flags{trace} & TRACE_PARSER) ? 0x1F : 0x00));

     # stop time, if necessary
     warn "\n       $specifiedFile was parsed in ", time-$flags{started}, " seconds.\n" unless $flags{display} & DISPLAY_NOINFO;

     # store a document completion directive (done here to save memory)
     push(@{$resultStreamRef->[STREAM_TOKENS]}, [\%docHints, DIRECTIVE_DOCUMENT, DIRECTIVE_COMPLETE, basename($file)]);

     # reset the input handle and flags
     $readCompletely=0;

     # store checksums, if necessary
     store($checksums, $cachefile) if     ($flags{cache} & CACHE_ON)
                                      and $flags{cached}
                                      and defined $checksums and %$checksums;

     # close the input file
     close($inHandle);
     $inHandle=new IO::File;

     # back to startup directory
     chdir($startupDirectory);
    }


  # make a simple helper backend object
  my $helperBackend=new PerlPoint::Backend(
                                           name    => 'parsers helper backend',
                                           display => DISPLAY_NOINFO+DISPLAY_NOWARN,

                                           trace   => TRACE_NOTHING,
                                          );

  # get toc
  $helperBackend->bind($resultStreamRef);
  my $toc=$helperBackend->toc;

  # store headlines as anchors, if necessary
  if (@$toc and $flags{headlineLinks})
    {
     # scopies
     my ($headlineNr, @headlinePath)=(0);

     foreach (@$toc)
       {
        # update headline counter
        $headlineNr++;

        # get data
        my ($level, $title)=@$_;

        # skip empty headlines
        next unless $title;

        # update headline path and numbers
        $headlinePath[$level]=$title;

        # store both plain and composite headlines in the anchor object
        $anchors->add($title, $title, $headlineNr);
        $anchors->add(join('|', map {defined($_) ? $_ : ''} @headlinePath[$_..$level]), $title, $headlineNr) for (1..$level-1);
       }
    }

  # add complete headline titles to streamed headline tokens,
  # move abbreviation, docstream and variable hints into data section
  if (@$toc)
   {
    # scopy
    my (@headlinePath, @shortcutPath, @levelPath, @pagenumPath);

    for (my $index=0; $index<=$#{$toc}; ++$index)
     {
      # build a more readable shortcut
      my $ref=$resultStreamRef->[STREAM_TOKENS][$resultStreamRef->[STREAM_HEADLINES][$index]];

      # get toc data
      my ($level, $title)=@{$toc->[$index]};

      # adapt arrays to get rid of previous data - important in case someone skips several levels
      # (jumping from level 5 to 100 etc.)
      $#headlinePath=$#shortcutPath=$#levelPath=$#pagenumPath=$level;

      # update headline pathes and numbers
      $headlinePath[$level]=$title;
      $shortcutPath[$level]=$ref->[0]{shortcut} ? $ref->[0]{shortcut} : $title;
      $levelPath[$level]++;
      $pagenumPath[$level]=$index+1;  # real page number, no index

      my $docstreams=delete($ref->[0]{docstreams});
      my $variables=delete($ref->[0]{vars});
      push (
            @$ref,
            $toc->[$index][1],
            delete($ref->[0]{shortcut}),
            $flags{docstreaming}==DSTREAM_DEFAULT ? [sort keys %$docstreams] : {},

            # store headline path data in the streamed token
            [
             dclone([@headlinePath[1..$level]]),
             dclone([@shortcutPath[1..$level]]),
             dclone([@levelPath[1..$level]]),
             dclone([@pagenumPath[1..$level]]),
             $variables,
            ],
           );
     }
   }

  # finish tags, if necessary
  if (@$pendingTags==3)
   {
    # get number of tokens
    my $lastIndex=$#{$resultStreamRef->[STREAM_TOKENS]};

    # handle all marked sections
    foreach my $section (@{$pendingTags->[2]})
      {
       # scan the stream till all pending tags were handled,
       # begin as near as possible
       for (my $position=$section->[0]; $position<=$lastIndex; $position++)
        {
         # get token
         my $token=$resultStreamRef->[STREAM_TOKENS][$position];

         # skip everything except tag beginners of tags with finish hooks
         next unless     ref($token)
                     and $token->[STREAM_DIR_TYPE]==DIRECTIVE_TAG
                     and $token->[STREAM_DIR_STATE]==DIRECTIVE_START
                     and exists $tagsRef->{$token->[STREAM_DIR_DATA]}{finish};

         # make an option hash
         my $options=dclone($token->[STREAM_DIR_DATA+1]);

         # call hook function (use eval() to guard yourself)
         my $rc;
         eval {$rc=&{$tagsRef->{$token->[STREAM_DIR_DATA]}{finish}}($options, $anchors, join('-', @headlineIds))};

         # check result
         unless ($@)
          {
           {
            # Error? (Treat syntactic errors as semantic ones at this point to give PARSING_FAILED a meaning.)
            ++$_semerr, last if $rc==PARSING_ERROR or $rc==PARSING_FAILED;

            # update options (might be modified, and checking for a difference
            # might take more time then just copying the replied values)
            $token->[STREAM_DIR_DATA+1]=$options;

            # all right? (several values just mean "ok" at this point)
            last if $rc==PARSING_OK or $rc==PARSING_COMPLETED;

            # backend hints to store?
            $token->[STREAM_DIR_HINTS]{ignore}=1, last if $rc==PARSING_IGNORE;
            $token->[STREAM_DIR_HINTS]{hide}=1,   last if $rc==PARSING_ERASE;

            # something is wrong here
            warn "[Warn] Tags ", $token->[STREAM_DIR_DATA], " tag finish hook replied unexpected result $rc, ignored.\n";
           }
          }
         else
          {warn "[Warn] Error in tags ", $token->[STREAM_DIR_DATA], " finish hook (ignored): $@\n"}

         # update counter and leave loop if all pending tags in this section were handled
         last unless --$section->[1];
        }
      }
   }

  # clean up
  undef $pendingTags;


  # success?
  if ($rc and not $_semerr)
    {
     # display a summary
     warn <<EOM unless $flags{display} & DISPLAY_NOINFO;

[Info] Input ok.

       Statistics:
       -----------
       ${\(_statisticsHelper(DIRECTIVE_HEADLINE))},
       ${\(_statisticsHelper(DIRECTIVE_TEXT))},
       ${\(_statisticsHelper(DIRECTIVE_UPOINT))},
       ${\(_statisticsHelper(DIRECTIVE_OPOINT))},
       ${\(_statisticsHelper(DIRECTIVE_DPOINT))},
       ${\(_statisticsHelper(DIRECTIVE_BLOCK))},
       ${\(_statisticsHelper(DIRECTIVE_VERBATIM))},
       ${\(_statisticsHelper(DIRECTIVE_TAG))}
       ${\(_statisticsHelper(DIRECTIVE_LIST_RSHIFT))},
       ${\(_statisticsHelper(DIRECTIVE_LIST_LSHIFT))},
       and ${\(_statisticsHelper(DIRECTIVE_COMMENT))} were detected.

EOM

     # add cache informations, if necessary
     warn  ' ' x length('[Info] '), int(100*$statistics{cache}[1]/$statistics{cache}[0]+0.5), "% of all checked paragraphs were restored from cache.\n\n" if $flags{cache} & CACHE_ON and not $flags{display} & DISPLAY_NOINFO;
    }
  else
    {
     # display a summary
     warn "[Info] Input contains $_semerr semantic error", $_semerr>1?'s':'', ".\n" if $_semerr;
    }

  # inform user
  warn "[Info] Parsing completed.\n\n" unless $flags{display} & DISPLAY_NOINFO;

  # reply success state
  $rc and not $_semerr;
 }


# report a semantic error, terminate process if necessary
sub _semerr
 {
  my $parser=shift;
  warn "[Error ", ++$_semerr, "] ", @_, "\n";
  $parser->YYAbort if $flags{criticalSemantics};
 }

# ------------------------------------------------------
# A tiny helper function intended for internal use only.
# ------------------------------------------------------
sub _statisticsHelper
 {
  # get and check parameters
  my ($type)=@_;
  confess "[BUG] Missing type parameter.\n" unless defined $type;

  # declare variables
  my ($nr)=(exists $statistics{$type} and $statistics{$type}) ? $statistics{$type} : 0;

  # reply resulting string
  join('', "$nr ", $paragraphTypeStrings{$type}, $nr==1 ? '' : 's');
 }

sub _updateChecksums
 {
  # get and check parameters
  my ($streamPart, $parserReinvokationHint)=@_;
  confess "[BUG] Missing stream part parameter.\n" unless defined $streamPart;
  confess "[BUG] Stream part parameter is no reference.\n" unless ref($streamPart);

  # certain paragraph types are not cached intentionally
  return if    not ($flags{cache} & CACHE_ON)
            or exists {
                       DIRECTIVE_COMMENT() => 1,
                      }->{$streamPart->[0][STREAM_DIR_TYPE]};

  if (exists $flags{checksummed} and $flags{checksummed})
    {
     $checksums->{$sourceFile}{$flags{checksummed}[0]}=[
                                                        dclone($streamPart),
                                                        $flags{checksummed}[2],
                                                        $parserReinvokationHint ? $parserReinvokationHint : (),
                                                        defined $flags{checksummed}[3] ? $macroChecksum : (),
                                                        defined $flags{checksummed}[4] ? $varChecksum : (),
                                                        $anchors->reportNew,
                                                       ];
     # use Data::Dumper;
     # warn Dumper($streamPart);
     $flags{checksummed}=undef;

     # note that something new was cached
     $flags{cached}=1;
    }
 }


# --------------------------------------------------------
# Extend all table rows to the number of columns found
# in the first table line ("table headline"). On request,
# automatically format the first table line as "headline".
# --------------------------------------------------------
sub _normalizeTableRows
 {
  # get and check parameters
  my ($stream, $autoHeadline)=@_;
  confess "[BUG] Missing stream part reference parameter.\n" unless defined $stream;
  confess "[BUG] Stream part reference parameter is no array reference.\n" unless ref($stream) eq 'ARRAY';
  confess "[BUG] Missing headline mode parameter.\n" unless defined $autoHeadline;

  # declare variables
  my ($refColumns, $maxColumns, $columns, $nested, @flags, @improvedStream)=(0, 0, 0.5, 0, 1);

  # remove whitespaces at the beginning and end of the stream, if necessary
  shift(@$stream) if $stream->[0]=~/^\s*$/; $stream->[0]=~s/^\s+//;
  pop(@$stream) if $stream->[-1]=~/^\s*$/; $stream->[-1]=~s/\s+$//;

  # process the received stream
  foreach (@$stream)
    {
     # search for *embedded* tables - which are already normalized!
     $nested+=($_->[STREAM_DIR_STATE]==DIRECTIVE_START ? 1 : -1)
       if ref($_) eq 'ARRAY' and $_->[STREAM_DIR_TYPE]==DIRECTIVE_TAG and $_->[STREAM_DIR_DATA] eq 'TABLE';

     # Inside an embedded table? Just pass the stream unchanged then.
     push(@improvedStream, $_), next if $nested;

     # check state, set flags
     $flags[1]=(ref($_) eq 'ARRAY' and $_->[STREAM_DIR_TYPE]==DIRECTIVE_TAG);
     $flags[2]=($flags[1] and $_->[STREAM_DIR_DATA] eq 'TABLE_COL');
     $flags[3]=($flags[1] and $_->[STREAM_DIR_STATE]==DIRECTIVE_COMPLETE and $_->[STREAM_DIR_DATA] eq 'TABLE_ROW');
     $flags[4]=1 if $flags[2] and $_->[STREAM_DIR_STATE]==DIRECTIVE_START;
     $flags[4]=0 if $flags[2] and $_->[STREAM_DIR_STATE]==DIRECTIVE_COMPLETE;

     # update counter of current row columns
     $columns+=0.5 if $flags[2];

     # end of column reached?
     if ($flags[2] and not $flags[4])
       {
        # remove all trailing whitespaces in the last recent data entry,
        # remove data which becomes empty this way
        $improvedStream[-1]=~s/\s+$//;
        pop(@improvedStream) unless length($improvedStream[-1]);
       }

     # first data after opening a new column?
     if ($flags[4] and not $flags[2])
       {
        # reset flag
        $flags[4]=0;

        # remove all leading whitespaces, skip data which becomes empty this way
        s/^\s+//;
        next unless length($_);
       }

     # table headline row?
     if ($flags[0])
       {
        # ok: mark columns as headline parts if necessary, take other elements unchanged
        push(@improvedStream, ($flags[2] and $autoHeadline) ? [@{$_}[STREAM_DIR_HINTS .. STREAM_DIR_STATE], 'TABLE_HL'] : $_);
        # at the end of this first row, marks that it is reached, store the number
        # of its columns as a reference for the complete table, and reset the column counter
        # (which will be used slightly differently in the following lines)
        $flags[0]=0, $refColumns=$maxColumns=$columns, $columns=0 if $flags[3];
       }
     else
       {
        # this is a content row (take care to preserve the order of operations here)

        # end of table row reached?
        if ($flags[3])
          {
           # yes: insert additional columns, if necessary
           push(
                @improvedStream,
                [{}, DIRECTIVE_TAG, DIRECTIVE_START, 'TABLE_COL'],
                [{}, DIRECTIVE_TAG, DIRECTIVE_COMPLETE, 'TABLE_COL'],
               ) for 1 .. ($refColumns-$columns);

           # reset column counter
           $columns=0;
          }

        # update maximum number of columns, if necessary
        $maxColumns=$columns if $columns>$maxColumns;

        # in any case, copy this stream part
        push(@improvedStream, $_);
       }
    }

  # replace original stream by the improved variant
  @$stream=@improvedStream;

  # supply the number of columns in the table row *and* the maximum number of columns
  ($refColumns, $maxColumns);
 }


# predeclare variables
sub _predeclareVariables
 {
  # get and check parameters
  my ($declarations, $preserveNames)=@_;
  confess "[BUG] Missing declaration parameter.\n" unless defined $declarations;
  confess "[BUG] Declaration parameter is no hash reference.\n" unless ref($declarations) eq 'HASH';

  # transform variable names, if necessary
  {
   my $c=0;
   %$declarations=map {$c++; $c%2 ? uc : $_} %$declarations unless $preserveNames;
  }

  # handle every setting (keys are sorted for test puposes only, to make the stream reproducable)
  foreach my $var (sort {$a cmp $b} keys %$declarations)
    {
     # check data format
     confess "[BUG] Predeclared variable $var is no scalar.\n" if ref($declarations->{$var});

     # store the variable - with an uppercased name
     $variables{$var}=$declarations->{$var};

     # propagate the setting to the stream, if necessary
     push(@{$resultStreamRef->[STREAM_TOKENS]}, [{}, DIRECTIVE_VARSET, DIRECTIVE_START, {var=>$var, value=>$declarations->{$var}}]) if $flags{var2stream};

     # make the new variable setting available to embedded Perl code, if necessary
     if ($safeObject)
       {
        no strict 'refs';
        ${join('::', ref($safeObject) ? $safeObject->root : 'main', $var)}=$declarations->{$var};
       }
    }

   # update tag finish memory by the way
   _updateTagFinishMem(scalar(@{$resultStreamRef->[STREAM_TOKENS]}));
 }


# update tag finish memory
sub _updateTagFinishMem
 {
  # get and check parameters
  my ($lastKnownStreamIndex)=@_;
  confess "[BUG] Missing last known stream index parameter.\n" unless defined $lastKnownStreamIndex;

  # update tag finish memory, if necessary
  if ($pendingTags->[1])
    {
     # store current collection
     push(@{$pendingTags->[2]}, [@{$pendingTags}[0, 1]]);

     # reset tag counter
     $pendingTags->[1]=0;
    }

  # in any case, update the "last known index" memory
  $pendingTags->[0]=$lastKnownStreamIndex;
 }



# set import filter, if necessary (by setting an import function - a user function is *not* overwritten!)
sub _setImportFilter
 {
  # get and check parameters
  my ($parser, $optionHash)=@_;
  confess "[BUG] Missing parser parameter.\n" unless $parser;
  confess "[BUG] Missing option hash parameter.\n" unless defined $optionHash;
  confess "[BUG] Option hash parameter is no hash reference.\n" unless ref($optionHash) eq 'HASH';

  # anything to do?
  if (
          not exists $optionHash->{ifilter}                                # there is no functional import filter set yet
      and exists $optionHash->{import}                                     # but there is a type specific import filter set yet
      and not (                                                            # and there is not ...
                   exists $flags{ifilters}{lc($optionHash->{import})}      # ... a general import filter known yet
               and not defined $flags{ifilters}{lc($optionHash->{import})} # ... which flags that there is no such filter
              )
      )
   {
    # parser options allow to use input filters of other languages, if this is the case we find that the
    # value of the general import filter is a special string which holds the name of that language
    my $filterLang=lc(
                      (
                           exists $flags{ifilters}{lc($optionHash->{import})}
                       and $flags{ifilters}{lc($optionHash->{import})}=~/^MAP:\s*(\w+)$/
                      ) ? $flags{ifilters}{lc($1)} : $optionHash->{import}
                     );

    # first time we need this import filter?
    unless (exists $flags{ifilters}{$filterLang})
     {
      # so, there is a chance to find such a filter via general modules, search for such a module
      eval
       {
        # no strict subs
        no strict;

        # build module name
        my $moduleName=join('::', 'PerlPoint::Import', uc($filterLang));

        # try to load the module
        my $evalCode="require $moduleName;";
        ref($safeObject) ? $safeObject->reval($evalCode) : eval $evalCode;
        die $@ if $@;

        # check for the import function specified by the API, store the code reference to the function
        # found or the undefined value otherwise, which will avoid repeated searches (store it both
        # for the filter language and the file language, which might differ due to filter mapping)
        $evalCode="exists \$${moduleName}::{importFilter}";
        $flags{ifilters}{lc($optionHash->{import})}=$flags{ifilters}{$filterLang}=join('::', $moduleName, 'importFilter()') if ref($safeObject) ? $safeObject->reval($evalCode) : eval $evalCode;
       };

      # check success
      $parser->_semerr("Could not load $optionHash->{import} import filter module: $@."), return undef if $@;
     }

    # now, set a functional filter, if possible
    $optionHash->{ifilter}=$flags{ifilters}{$filterLang}
      if exists $flags{ifilters}{$filterLang} and defined $flags{ifilters}{$filterLang};
   }

  # flag success
  1;
 }

# perform paragraph filter calls
sub _pfilterCall
 {
  # get and check parameters
  my ($parser, $filters, $pstream, $lineNr)=@_;
  confess "[BUG] Missing parser parameter.\n" unless $parser;
  confess "[BUG] Missing filter list.\n" unless $filters;
  confess "[BUG] Filter list is no array reference.\n" unless ref($filters) eq 'ARRAY';
  confess "[BUG] Missing paragraph stream.\n" unless $pstream;
  confess "[BUG] Paragraph stream is no array reference.\n" unless ref($pstream) eq 'ARRAY';
  confess "[BUG] Missing line number.\n" unless $lineNr;


  # declare and init variables
  my ($streamRef, %tableCounters);
  $retranslationBuffer='';

  # build retranslator, if necessary
  unless ($retranslator)
    {
     # scopy
     my ($verbatimFlag)=(0);

     # the retranslator is a backend object
     $retranslator=new PerlPoint::Backend(
                                          name    => 'retranslator',
                                          display => DISPLAY_NOINFO+DISPLAY_NOWARN,
                                          trace   => TRACE_NOTHING,
                                         );

     # various callbacks perform the retranslation
     $retranslator->register(DIRECTIVE_SIMPLE, sub
                                                {
                                                 # get parameters
                                                 my ($opcode, $mode, @contents)=@_;

                                                 # add contents to the source text collection,
                                                 # double backslashes (if they are here, they were guarded originally),
                                                 # and restore ">" characters as if they were guarded
                                                 (my $text=join('', @contents));
                                                 $text=~s/([\\>])/\\$1/g unless $verbatimFlag;
                                                 $retranslationBuffer.=$text;
                                                }
                            );

     $retranslator->register(DIRECTIVE_HEADLINE, sub
                                                  {
                                                   # get parameters
                                                   my ($opcode, $mode, $level)=@_;

                                                   # add preceeding "=" characters
                                                   $retranslationBuffer.=('=' x $level) if $mode==DIRECTIVE_START;
                                                  }
                            );

     $retranslator->register(DIRECTIVE_VERBATIM, sub
                                                  {
                                                   # get parameters
                                                   my ($opcode, $mode)=@_;

                                                   # cover contents
                                                   $verbatimFlag=1, $retranslationBuffer.="<<EOE\n" if $mode==DIRECTIVE_START;
                                                   $verbatimFlag=0, $retranslationBuffer.="EOE\n"   if $mode==DIRECTIVE_COMPLETE;
                                                  }
                            );

     my $handleListPoint=sub
                          {
                           # get parameters
                           my ($opcode, $mode, @data)=@_;

                           # act mode dependend
                           if ($mode==DIRECTIVE_START)
                             {$retranslationBuffer.=$opcode==DIRECTIVE_UPOINT ? '* ' : $opcode==DIRECTIVE_OPOINT ? '# ' : ':';}
                           else
                             {$retranslationBuffer.="\n\n"}
                          };

     my $handleDListPointItem=sub
                               {
                                # get parameters
                                my ($opcode, $mode, @data)=@_;

                                # complete the item part if necessary
                                $retranslationBuffer.=': ' if $mode==DIRECTIVE_COMPLETE;
                               };

     my $handleListShift=sub
                          {
                           # get parameters
                           my ($opcode, $mode, $offset)=@_;

                           # anything to do?
                           $retranslationBuffer.=join('',
                                                      $opcode==DIRECTIVE_LIST_RSHIFT ? '>' : '<',
                                                      "$offset\n\n",
                                                     ) if $mode==DIRECTIVE_START;
                          };

     $retranslator->register($_, $handleListPoint) foreach (DIRECTIVE_UPOINT, DIRECTIVE_OPOINT, DIRECTIVE_DPOINT);
     $retranslator->register($_, $handleListShift) foreach (DIRECTIVE_LIST_LSHIFT, DIRECTIVE_LIST_RSHIFT);
     $retranslator->register(DIRECTIVE_DPOINT_ITEM, $handleDListPointItem);

     $retranslator->register(DIRECTIVE_TAG, sub
                                             {
                                              # get parameters
                                              my ($opcode, $mode, $tag, $settings, $bodyHint)=@_;

                                              # table tags need special care, is it one?
                                              unless ($tag=~/^TABLE/)
                                                {
                                                 # it can happen that perl complains about an undefined value here
                                                 # even if no such value is to be find in debugging
                                                 local($^W)=0;

                                                 # act mode dependend
                                                 $retranslationBuffer.=$mode==DIRECTIVE_START ? join('', "\\$tag", (defined $settings and %$settings and grep(!/^__/, keys %$settings)) ? join('', '{', join(' ', map {qq($_="$settings->{$_}")} grep(!/^__/, keys %$settings)), '}') : (), ((defined $bodyHint and $bodyHint) ? '<' : ())) : ((defined $bodyHint and $bodyHint) ? '>' : ());
                                                }
                                              else
                                                {
                                                 # TABLE declared by paragraph?
                                                 if ($tag eq 'TABLE' and exists $settings->{__paragraph__})
                                                   {
                                                    # translate TABLE into paragraph start or completion
                                                    $retranslationBuffer.=$mode==DIRECTIVE_START ? join('', '@', $settings->{separator}, "\n") : '';
                                                    # init counters, store separators
                                                    @tableCounters{qw(row col rowsep colsep)}=(0, 0, "\n", " $settings->{separator} ");
                                                   }
                                                 # TABLE declared by tags?
                                                 elsif ($tag eq 'TABLE')
                                                   {
                                                    # translate TABLE into TABLE and END_TABLE
                                                    $retranslationBuffer.=$mode==DIRECTIVE_START ? join('', '\TABLE{', join(' ', map {qq($_="$settings->{$_}")} grep(!/^__/, keys %$settings)), '}', $settings->{rowseparator} eq '\\\n' ? "\n" : '') : join('', $settings->{rowseparator} eq '\\\n' ? "\n" : '', '\END_TABLE');
                                                    # init counters, store separators
                                                    @tableCounters{qw(row col rowsep colsep)}=(0, 0, $settings->{rowseparator} eq '\\\n' ? "\n" : $settings->{rowseparator}, $settings->{separator} eq '\\\n' ? "\n" : " $settings->{separator} ");
                                                   }
                                                 # TABLE_ROW?
                                                 elsif ($tag eq 'TABLE_ROW')
                                                   {
                                                    # we only need to act at startup
                                                    if ($mode==DIRECTIVE_START)
                                                      {
                                                       # write a row separator if there was a row before
                                                       $retranslationBuffer.=$tableCounters{rowsep} if $tableCounters{row};
                                                       # update row counter, reset column counter
                                                       $tableCounters{row}++;
                                                       $tableCounters{col}=0;
                                                      }
                                                   }
                                                 # TABLE_HL or TABLE_COL?
                                                 elsif ($tag=~/TABLE_(HL|COL)/)
                                                   {
                                                    # we only need to act at startup
                                                    if ($mode==DIRECTIVE_START)
                                                      {
                                                       # write a column separator if there was a column before
                                                       $retranslationBuffer.=$tableCounters{colsep} if $tableCounters{col};
                                                       # update row counter
                                                       $tableCounters{col}++;
                                                      }
                                                   }
                                                }
                                             }
                            );
    }

  # embed paragraph stream into a structure looking like a complete stream
  @{$streamRef}[
                STREAM_IDENT,
                STREAM_TOKENS,
                STREAM_HEADLINES,
               ]=(
                  '__PerlPoint_stream__',     # stream identifier;
                  $pstream,                   # base stream: paragraph stream;
                  [],                         # headline stream (dummy);
                 );

  # retranslate paragraph
  $retranslator->run($streamRef);

  # init paragraph text
  # $retranslationBuffer=join('', @{$pstream}[1..($#{$pstream}-1)]);

  # warn "BUFFER: $retranslationBuffer\n";

  foreach my $perl (@$filters)
    {
     # we provide the paragraph text simply - for a general solution, we need to use an object
     # of a handy subclass of PerlPoint::Backend (still to be written)
     {
      no strict 'refs';
      ${join('::', ref($safeObject) ? $safeObject->root : 'main', '_pfilterText')}=$retranslationBuffer;
      ${join('::', ref($safeObject) ? $safeObject->root : 'main', '_pfilterType')}=$paragraphTypeStrings{$pstream->[0][1]};
     }

     # inform user
     warn qq([Trace] $sourceFile, line $lineNr: Running paragraph filter "$perl".\n) if $flags{trace} & TRACE_ACTIVE;

     # call the filter
     $retranslationBuffer=ref($safeObject) ? $safeObject->reval($perl) : eval(join(' ', '{package main; no strict;', $perl, '}'));

     # check result
     if ($@)
       {
        # inform user, if necessary
        _semerr($parser, qq($sourceFile, line $lineNr: paragraph filter "$perl" could not be evaluated: $@.));

        # stop processing, flag error
        return undef;
       }
    }

   # success: reply result (embed it into empty lines to avoid paragraph mismatch)
   defined $retranslationBuffer ? [("\n") x 2, split(/(\n)/, $retranslationBuffer), ("\n") x 2] : '';
  }

=pod

=head2 anchors()

A class method that supplied all anchors collected by the parser.

Example:

   my $anchors=PerlPoint::Parser::anchors;

=cut
sub anchors
 {$anchors;}

1;


# declare a helper package used for token "delay" after bodyless macros
# (implemented the oo way to determine the data)
package PerlPoint::Parser::DelayedToken;

# even this tiny package needs modules!
use Carp;

# make an object holding the token name and its value
sub new
 {
  # get parameter
  my ($class, $token, $value)=@_;

  # check parameters
  confess "[BUG] Missing class name.\n" unless $class;
  confess "[BUG] Missing token parameter.\n" unless $token;
  confess "[BUG] Missing token value parameter.\n" unless defined $value;

  # build and reply object
  bless([$token, $value], $class);
 }

# reply token
sub token {$_[0]->[0];}

# reply value
sub value {$_[0]->[1];}

1;


# = POD TRAILER SECTION =================================================================

=pod

=head1 EXAMPLE

The following code shows a minimal but complete parser.

  # pragmata
  use strict;

  # load modules
  use PerlPoint::Parser;

  # declare variables
  my (@streamData);

  # build parser
  my ($parser)=new PerlPoint::Parser;
  # and call it
  $parser->run(
               stream  => \@streamData,
               files   => \@ARGV,
              );

=head1 NOTES

=head2 Converter namespace

It is suggested to B<avoid> operating in namespace B<main::>. In order to emulate
the behaviour of the B<Safe> module by C<eval()> in case a user wishes to get
full Perl access for active contents, active contents needs to be executed in
this namespace. Safe does not allow to change this, so the documented default
for "saved" and "not saved" active contents I<needs> to be C<main::>. This means
that both the parser and active contents will pollute C<main::>. Prevent from being
effected by choosing a different converter namespace. The B<PerlPoint::Converter::>
 hyrarchy is reserved for this purpose. The recommended namespace is
C<PerlPoint::Converter::<converter name>>, e.g. C<PerlPoint::Converter::pp2sdf>.

=head2 Format

The PerlPoint format was initially designed by I<Tom Christiansen>,
who wrote an HTML slide generator for it, too.

I<Lorenz Domke> added a number of additional, useful and interesting
features to the original implementation. At a certain point, we
decided to redesign the tool to make it a base for slide generation
not only into HTML but into various document description languages.

The PerlPoint format implemented by this parser version is slightly
different from the original design. Presentations written for Perl
Point 1.0 will I<not> pass the parser but can simply be converted
into the new format. We designed the new format as a team of
I<Lorenz Domke>, I<Stephen Riehm> and me.

=head2 Storable updates

From version 0.24 on the Storable module is a prerequisite of the
parser package because Storable is used to store and retrieve cache
data in files. If you update your Storable installation it I<might>
happen that its internal format changes and therefore stored cache
data becomes unreadable. To avoid this, the parser automatically
rebuilds existing caches in case of Storable updates.

=head1 FILES

If I<cache>s are used, the parser writes cache files where the initial
sources are stored. They are named .<source file>.ppcache.

=head1 SEE ALSO

=over 4

=item PerlPoint::Backend

A frame class to write backends basing on the I<STREAM OUTPUT>.

=item PerlPoint::Constants

Constants used by parser functions and in the I<STREAM FORMAT>.

=item PerlPoint::Tags

Tag declaration base class.

=item pp2sdf

A reference implementation of a PerlPoint converter, distributed with the parser package.

=item pp2html

The inital PerlPoint tool designed and provided by Tom Christiansen. A new translator
by I<Lorenz Domke> using B<PerlPoint::Package>.

=back


=head1 SUPPORT

A PerlPoint mailing list is set up to discuss usage, ideas,
bugs, suggestions and translator development. To subscribe,
please send an empty message to perlpoint-subscribe@perl.org.

If you prefer, you can contact me via perl@jochen-stenzel.de
as well.


=head1 AUTHOR

Copyright (c) Jochen Stenzel (perl@jochen-stenzel.de), 1999-2001.
All rights reserved.

This module is free software, you can redistribute it and/or modify it
under the terms of the Artistic License distributed with Perl version
5.003 or (at your option) any later version. Please refer to the
Artistic License that came with your Perl distribution for more
details.

The Artistic License should have been included in your distribution of
Perl. It resides in the file named "Artistic" at the top-level of the
Perl source tree (where Perl was downloaded/unpacked - ask your
system administrator if you dont know where this is).  Alternatively,
the current version of the Artistic License distributed with Perl can
be viewed on-line on the World-Wide Web (WWW) from the following URL:
http://www.perl.com/perl/misc/Artistic.html.

B<PerlPoint::Parser> is built using B<Parse::Yapp> a way that users
have I<not> to explicitly install B<Parse::Yapp> themselves. According
to the copyright note of B<Parse::Yapp> I have to mention the following:

"The Parse::Yapp module and its related modules and shell
scripts are copyright (c) 1998-1999 Francois Desarmenien,
France. All rights reserved.

You may use and distribute them under the terms of either
the GNU General Public License or the Artistic License, as
specified in the Perl README file."


=head1 DISCLAIMER

This software is distributed in the hope that it will be useful, but
is provided "AS IS" WITHOUT WARRANTY OF ANY KIND, either expressed or
implied, INCLUDING, without limitation, the implied warranties of
MERCHANTABILITY and FITNESS FOR A PARTICULAR PURPOSE.

The ENTIRE RISK as to the quality and performance of the software
IS WITH YOU (the holder of the software).  Should the software prove
defective, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
CORRECTION.

IN NO EVENT WILL ANY COPYRIGHT HOLDER OR ANY OTHER PARTY WHO MAY CREATE,
MODIFY, OR DISTRIBUTE THE SOFTWARE BE LIABLE OR RESPONSIBLE TO YOU OR TO
ANY OTHER ENTITY FOR ANY KIND OF DAMAGES (no matter how awful - not even
if they arise from known or unknown flaws in the software).

Please refer to the Artistic License that came with your Perl
distribution for more details.

=cut

1;
