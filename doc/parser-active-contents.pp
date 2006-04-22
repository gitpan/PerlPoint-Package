
// declare an empty variable to separate bodyless tags from text
$empty=

=Active Contents

Document parts can be generated \I<dynamically>. This is done by evaluating a \I<condition>,
\I<embedded> or \I<included> \B<Perl> code \I<at translation time>. Paragraph and input filters
are more types of Active Content.

@|
active part       | description | example
condition         | A paragraph type to control inclusion of all subsequent source parts before the next condition. | \C<\B<?> \$PerlPoint-\>{targetLanguage} eq "HTML">
\I<tag> condition | A special tag option available for all tags which accept options which flags whether the tag should take effect or not.  If Active Contents is \REF{name=Security type=linked}<disabled>, the condition defaults to "false". | \C<\\IMAGE{\B<_cnd_="$illustrate"> src="piegraph.gif"}>
embedded Perl     | Perl code embedded into \C<\\EMBED> and \C<\\END_EMBED> tags, marked as Perl by tag option \C<lang> set to \C<"perl">. The code is expected to return a string which will be interpreted as \B<PerlPoint>. | \C<This document was generated by perl \B<\\EMBED{lang=perl}$]\\END_EMBED>.>
included Perl     | Perl code read from a file via an \C<\\INCLUDE> tag, marked as Perl by tag option \C<type> set to \C<"perl">. File contents is evaluated like embedded Perl. | \C<\B<\\INCLUDE{type=perl file="included.pl"}>>
input filters     | A special option to \C<\\EMBED> and \C<\\INCLUDE> tags which allows to preprocess embedded code or included files before they are furtherly processed. The filter code may be passed directly or refer to functions defined in \I<embedded Perl> (see above) previously processed. This is a generic way to import sources written in other languages. | \C<\\INCLUDE{type=pp file="perlpod.pod" \B<ifilter="pod2pp()">}>
paragraph filters | Calls to functions declared in \I<embedded Perl> (see above) used to modify a complete paragraph and return it for reparsing. Filters are applied by preceeding the target paragraph with the filter call enclosed in \C<\|\|> pairs. | Automatically enumerate lines in a code block: the code can be copied unmodified from a real sourcecode file, but readers of the produced document will see line numbers.\BR\BR\C<\B<\|\|enumerate\|\|>  $result=5+2;>\BR\BR${empty}Filter calls are pure Perl, so they can take options, for example to start enumeration with a certain number:\BR\BR\C<\B<\|\|enumerate(\I<10>)\|\|>  $result=5+2;>\BR\BR${empty}Another typical application is automatic syntax highlightning of example code: this can relieve document authors a lot and makes it easy to switch between several colorization schemes.\BR\BR\C<\B<\|\|highlight\|\|>  $result=5+2;>\BR\BR${empty} Filter calls can be \I<cascaded>, so it's easy to automatically enumerate \I<and> colorize a block:\BR\BR\C<\B<\|\|enumerate\|highlight\|\|>  $result=5+2;>

  As an introduction example of the active contents feature,
  here is a report about this document: it was generated
  at \EMBED{lang=perl}my @t=(localtime)[3, 4, 5]; sprintf("%d.%d.%d", $t[0], $t[1]+1, $t[2]+1900); \END_EMBED.


==What it is for

Well, honestly spoken, I'm looking forward to the usage people will make of this feature.
But I can already imagine things like

* document parts included depending on the target language (an article could
  possibly provide more informations than presentation sheets), the time of
  presentation generation (informations may be confidental until a certain
  point; or imagine exercises - solutions may be presented in a second step)
  or depending on the system state;

* automatic documentation of system parts (directories, partitions, or share
  a generic PerlPoint source which will produce a presentation automatically
  adapted to the target system);

* integration of sources provided in a format different to PerlPoint, automatically
  translated and integrated;

* including statistics and images made on the fly on base of whatever data
  Perl can access;

* grabbing presentation data from the web or a server;

* let Perl generate a presentation of complex data instead of having to write
  the PerlPoint yourself;

* using C, Assembler, Python or other languages (or libraries) to generate
  parts of your document on the fly via \B<Inline>;

* and more ...

As for conditions, they can be used to generate various different documents from
one and the same source, depending on decisions based on evaluated Perl code.


==An example

The following files were found in the source directory of this documentation part when this presentation was built:

\EMBED{lang=perl}

# read /tmp
opendir(D, '.');
my @snapshot=map {my $size=(stat($_))[7]; [$_, defined $size ? $size : 0]} sort readdir(D);
closedir(D);

# supply the listing as a table
join(
     # row separator
     "\n",

     # initial lines (to make sure the table paragraph is recognized)
     ('') x 2,

     # table opener
     '@|',

     # headline
     "filename | file size",

     # data, sorted
     map {join(' | ', @$_)} @snapshot,

     # closing empty line
     '',
    );

\END_EMBED


==Security

Security is kept by running active contents in a safe environment via a \B<Safe>
object if requested. This way every translator can implement its own grade of security,
allowing only such operations which seem to be uncritical to the author.

Nevertheless, the necessary security grade may vary. Imagine a downloaded presentation source
and a self written document. But even with own presentations it seems to be good
advice to never translate a presentation with root permissions.

There are a few limitations in using \B<Safe>, especially if code wants to use modules.
If security is not an issue, it's possible to bypass \B<Safe> completely. That's why
embedded code can perform whatever operation Perl provides, but without any security
restrictions. It's up to you to make your choice.

If active contents is disabled at all, all related PerlPoint elements (conditions,
embedded and included code) are ignored.

Please refer to the specific translators documentation. Implementations can vary
from generally disabled active contents to user configurable security settings.


==Sharing data between active parts

All active contents shares the same \B<Safe> object which means that it is executed \I<in
the same Perl namespace> (which usually happens to appear as \C<main::>, please see the
translators documentation for details). As a consequece, several parts can interact with
each other by variables and functions.

Note that the active parts are evaluated in the order they appear in the PerlPoint source.

<<EOE

   \EMBED{lang=perl}

   sub fileCount
     {
      # get number of files
      opendir(D, '.');
      my @fileNr=readdir(D);
      my $fileNr=@fileNr;
      closedir(D);

      # supply result
      $fileNr;
     }

   # scan directory
   $filesFound=fileCount;

   '';

   \END_EMBED

EOE

The following condition evaluates the number of files found by the previously
executed code, using a variable set there:

  // conditional hints
  ? \B<$filesFound>>10000000000

... and includes more informations if appropriate:

  =Using directories

  The number of files in your directory let us add additional suggestions:

  ...

  // back to main document
  ? 1

Now we can use the previously declared function again:

  There are \\EMBED{lang=perl}\B<fileCount>\\END_EMBED files
  in the current directory.


==Using document variables

PerlPoint variables are \I<no> active contents. Even when active contents is
disabled completely, variables will still work. Nevertheless, their \I<values>
are \I<copied> into the namespace of active contents.

That means you can read every PerlPoint variable in active parts.

<<EOE

  $var=10

  The variables value on PerlPoint side is $var. On Perl side,
  it is \EMBED{lang=perl}$main::var\END_EMBED as well.

EOE

Note that the variables are only \I<copied>. They may be modified on Perl side
but without effect to PerlPoint.

<<EOE

  $var=10

  The variables value on PerlPoint side is $var. On Perl side,
  it is \EMBED{lang=perl}$main::var*=100\END_EMBED now. But this does not
  affect PerlPoint which still sees a value of $var.

EOE

Further more, whenever a variable is set on PerlPoint side, the Perl side
value is updated which overwrites all modifications eventually made.

You may have noticed that the variables were accessed by their fully qualified names
in the examples above. This was done because PerlPoint variables are evaluated \I<first>
- before the code is passed to perl. By using the fully qualified name which is unknown
to PerlPoint this replacement is suppressed. Alternatively, \C<\\$var> may be written.


==Accessing base data

Base data like the target language is provided by a global pseudo hash reference
variable \C<\B<\$main::PerlPoint>> (which belongs to the usual namespace \C<main::>
of the \B<Safe> object, if used).
Please see specific translator documentations for a list of passed data. By
convention, this hash provides the target language and user settings at least:

  // include the following to HTML documents only
  ? $PerlPoint->{targetLanguage} eq 'HTML'

  // include the following depending on command
  ? $PerlPoint->{userSettings}{special}

There is also a less rough function interface to access these data:

  // include the following depending on command
  ? flagSet('special')

Active contents can modify the provided data but changes will \I<expire> when a code
snippet is executed completely.

<<EOE

  // active contents modifying base data
  \EMBED{lang=perl}
     $PerlPoint->{targetLanguage}='modified';
  \END_EMBED

  // base data is automatically restored now,
  // so the condition checks the original value
  ? $PerlPoint->{targetLanguage} eq 'HTML'

EOE


==Known problems

Dealing with the \B<Safe> module is not as easy as it seems at first sight.

* Specifying permitted operations can be a longer task. Please have
  a look at the manpages of \C<Safe> and \C<Opcode>.

* Sorting by a subroutine seems to fail - \C<$a> and \C<$b> are always undefined.

* Using modules is a challenge, especially with compiled parts. If security
  is not that important (e.g. if you can trust the document author or your
  working environment is carefully set up) it is possible to bypass \B<Safe>
  completely. See the security section for details.

Maybe I only need advice because I just started to use \C<Safe>. If you know
how to manage these tasks, please let me know.

