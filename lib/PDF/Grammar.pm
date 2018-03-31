use v6;

grammar PDF::Grammar:ver<0.1.5> {
    # abstract base grammar for PDF Elements, see instances:
    # PDF::Grammar::Content  - Text and Graphics Content
    # PDF::Grammar::FDF      - Describes FDF (Form Data) files
    # PDF::Grammar::PDF      - Overall PDF Document Structure
    # PDF::Grammar::Function - Postscript calculator functions
    #
    enum AST-Types is export(:AST-Types) < array body bool
	dict encoded end entries decoded fdf gen-num header hex-string
	ind-ref ind-obj int obj-count obj-first-num offset literal
	name null pdf real start startxref stream trailer type version cond>;

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    token comment {'%' \N* \n?}
    # [PDF 1.7] Table 3.1: White-space characters
    token ws-char {<[ \x20 \x0A \x0 \t \f \n ]> | <.comment>}
    token ws      {<!ww><.ws-char>*}

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token int { < + - >? \d+ }
    # reals must have a decimal point and some digits before or after it.
    token real { < + - >? [\d+\.\d* | \.\d+] }

    rule number { <real> | <int> }

    token octal-code {<[0..7]> ** 1..3}
    token literal-delimiter {<[ ( ) \\ \n \r ]>}

    # literal string components
    proto token literal {*}
    token literal:sym<regular>          {<-literal-delimiter>+}
    token literal:sym<eol>              {\n}
    token literal:sym<substring>        {<literal-string>}
    # literal string escape sequences
    token literal:sym<esc-octal>        {\\ <octal-code>}
    token literal:sym<esc-delim>        {\\ $<delim>=<[ ( ) \\ ]>}
    token literal:sym<esc-backspace>    {\\ b}
    token literal:sym<esc-formfeed>     {\\ f}
    token literal:sym<esc-newline>      {\\ n}
    token literal:sym<esc-cr>           {\\ r}
    token literal:sym<esc-tab>          {\\ t}
    token literal:sym<esc-continuation> {\\ \n?}

    token literal-string { '(' <literal>* ')' }

    # hex strings
    token hex-string {'<' [ <xdigit> | <.ws-char> ]* '>'}

    token string {<string=.hex-string>|<string=.literal-string>}

    # [PDF 1.7] 7.2.2 Character Set
    token char-delimiter {<[ ( ) < > \[ \] { } / % \# ]>}

    proto token name-bytes {*}
    token name-bytes:sym<number-symbol> {'##'}
    token name-bytes:sym<escaped>       {'#'<xdigit>**2 }
    token name-bytes:sym<regular>       {<[\! .. \~] -char-delimiter>+}

    rule name { '/'<name-bytes>* }

    # [PDF 1.7] 7.3.2  Boolean objects + Null object
    # ---------------
    rule array  {'[' <object>* ']'}
    rule dict   {'<<' [ <name> <object> ]* '>>'}

    # Define a core set of objects.
    proto rule object {*}
    rule object:sym<number>  { <number> }
    rule object:sym<true>    { <sym> }
    rule object:sym<false>   { <sym> }
    rule object:sym<string>  { <string> }
    rule object:sym<name>    { <name> }
    rule object:sym<array>   { <array> }
    rule object:sym<dict>    { <dict> }
    rule object:sym<null>    { <sym> }

}

