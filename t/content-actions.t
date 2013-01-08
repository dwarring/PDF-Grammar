#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;
use PDF::Grammar::Content::Actions;

my $sample_content1 = '/RGB CS';

my $sample_content2 = '100 125 m 9 0 0 9 476.48 750 Tm';

my $sample_content3 = 'BT 100 350 Td [(Using this Guide)-13.5( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .)-257.1( xiii)]TJ ET';

my $sample_content4 = '/foo <</MP /yup>> BDC 50 50 m BT 200 200 Td ET EMC'; 

my $sample_content5 = q:to/END4/;
/GS1 gs
BT
  /TT6 1 Tf
  9 0 0 9 476.48 750 Tm
  0 g
  0 Tc
  0 Tw
  (Some random test opcodes)Tj
  1.6111 -1.2222 TD
  (version 10.0)Tj
  -42.5533 -77.3778 TD
  (Doc. Revision 1.0)Tj
  45.04 0 TD
  (Page i)Tj
ET
.25 .085 0 .25 K
2 J 0 j .51 w 3.86 M [] 0 d
1 i 
q 1 0 0 1 540 54 cm 0 0 m
-432 0 l
S
Q
/EmbeddedDocument /MC3 BDC
  q
  66.184 0 0 29 474.55 705.39 cm
  /Im3 Do
  Q
EMC
BT
  /TT2 1 Tf
  22 0 0 22 108 676.53 Tm
  -.01 Tc
  (Contents)Tj
  12 0 0 12 108 641.2 Tm
  0 Tc
  [(Using this Guide)-13.5( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .)-257.1( xiii)]TJ
  /TT8 1 Tf
  .0909 Tw
  [( ...almost there)]TJ
  -37.9318 -1.2727 TD
  0 Tw
ET
END4

my $sample_content6 = q:to/END5/;    # example from [PDF 1.7] Section 7.8
0.0 G					% Set stroking colour to black
1.0 1.0 0.0 rg				% Set nonstroking colour to yellow
25 175 175 -150 re			% Construct rectangular path
f					% Fill path
/Cs12 cs				% Set pattern colour space
0.77 0.20 0.00 /P1 scn			% Set nonstroking colour and pattern
99.92 49.92 m				% Start new path
99.92 77.52 77.52 99.92 49.92 99.92 c	% Construct lower-left circle
22.32 99.92 -0.08 77.52 -0.08 49.92 c
-0.08 22.32 22.32 -0.08 49.92 -0.08 c
77.52 -0.08 99.92 22.32 99.92 49.92 c
B					% Fill and stroke path
0.2 0.8 0.4 /P1 scn			% Change nonstroking colour
224.96 49.92 m				% Start new path
224.96 77.52 202.56 99.92 174.96 99.92 c% Construct lower-right circle
147.36 99.92 124.96 77.52 124.96 49.92 c
124.96 22.32 147.36 -0.08 174.96 -0.08 c
202.56 -0.08 224.96 22.32 224.96 49.92 c
B					% Fill and stroke path
0.3 0.7 1.0 /P1 scn			% Change nonstroking colour
87.56 201.70 m				% Start new path
63.66 187.90 55.46 157.30 69.26 133.4 c	% Construct upper circle
83.06 109.50 113.66 101.30 137.56 115.10 c
161.46 128.90 169.66 159.50 155.86 183.40 c
142.06 207.30 111.46 215.50 87.56 201.70 c
B					% Fill and Stroke path
0.5 0.2 1.0 /P1 scn			% Change nonstroking colour
50 50 m					% Start new path
175 50 l				% Construct triangular path
112.5 158.253 l
b					% Close, fill, and stroke path
END5

my $dud_content = '10 10 Td 42 dud';

my $actions = PDF::Grammar::Content::Actions.new;

for ($sample_content1, $sample_content2, $sample_content3, $sample_content4,
    $dud_content, $sample_content5, $sample_content6) {
    my $p = PDF::Grammar::Content.parse($_, :actions($actions));
    ok($p, "parsed pdf content")
       or diag ("unable to parse: $_");
    diag "$_ ==>";
    diag {result => $p.ast}.perl;
}

done;
