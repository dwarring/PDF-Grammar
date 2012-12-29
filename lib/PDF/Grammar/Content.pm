use v6;

use PDF::Grammar;
use PDF::Grammar::Body::Xref;

grammar PDF::Grammar::Body is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing the basic block structure of a
    # PDF document.
    # - memory hungry/slow - don't try on documents > ~ 500K
    # - token/block-structure  level parsing only, no attempt to interpret
    #   overall structure, character escapes  or high level objects (e.g.
    #   Fonts, Pages)
    # - limited to non-existant stream parsing
    # - no attempt yet to capture content
    # - no error handling or diagnostics
    #
    rule TOP {<pdf>}
    rule pdf {^<header><eol>(<content>+)'%%EOF'<eol>?$}
    # xref section is optional - document could have a cross reference stream
    # quite likley if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule content {<body><xref>?<trailer>} 

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token header {'%PDF-1.'\d}
    token eol {"\r\n"  # ms/dos
               | "\n"  #'nix
               | "\r"} # mac-osx
    rule body {<object>+}

    rule xref {<PDF::Grammar::Body::Xref::xref>}

    # [PDF 1.7] 7.3.2  Boolean Objects
    # ---------------
    token bool { ['true' | 'false'] }

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token int { ('+' | '-')? \d+ }
    # reals must have at least one digit either before or after the decimal
    # point
    rule real { ('+' | '-')? ((\d+\.\d*) | (\d*\.\d+)) | <int> }

    token literal_char_escaped { '\n' | '\r' | '\t' | '\b' | '\f' | '\(' | '\)' | '//' | ('\\' <[0..7]> ** 1..3) }
    # literal_character - all but '(' ')' '\'
    token literal_char_regular { <-[\(\)\\]> }
    token literal_line_continuation {"\\"<eol>}
    rule literal_substring { '('(<literal_char_escaped>|<literal_char_regular>|<literal_substring>|<literal_line_continuation>)*')' }

    # nb
    # -- new-lines are acceptable within strings
    # -- nested parenthesis are acceptable - allow recursive substrings
    rule literal_string {<literal_substring>}
    # hex strings

    token hex_char {<xdigit>**1..2}
    token hex_string { \<<hex_char>(<hex_char>|<eol>)*\> }

    rule string {<hex_string>|<literal_string>}

    token name_char_number_symbol { '##' }
    # name escapes are strictly two hex characters
    token name_char_escaped { \#(<xdigit>**2) }
    # all printable but '#', '/', '[', ']',
##  not having any luck with the following regex; me? rakudo-star? (2012.11)
##   token name_char_printable { <[\!..\~] - [\[\#\]\//\(\)\<\>]> }
##  .. rather more ungainly...
    token name_char_printable { <[a..z A..Z 0..9 \! \" \$..\' \*..\. \: \; \= \? \@ _ \^ \' \{ \| \} \~]> }

    rule name { '/'(<name_char_printable>|<name_char_escaped>|<name_char_number_symbol>)* }

    rule array {\[ <object>* \]}

    rule dict {'<<' (<name> <object>)* '>>'}

    # stream parsing - efficiency matters here
    token stream_marker {stream<eol>}
    # Hmmm allow endstream .. anywhere?
    # Seems to be some chance of streams appearing where they're not
    # supposed to, e.g. nested in a subdictionary
    token endstream_marker {<eol>?endstream<ws_char>+}
    rule stream {<dict> <stream_marker>.*?<endstream_marker>}

    token null { 'null' }

    rule indirect_object {<int> <int> obj <object>* endobj}
    rule indirect_reference {<int> <int> R}

    rule object { <stream> | <indirect_reference> | <indirect_object> | <real> | <int> | <bool> | <string> | <name> | <array> | <dict> | <null> }

    rule trailer {
        trailer<eol>
        <dict>
        startxref<eol>\d+<eol>}

}
