#!/bin/bash

set -e;
set -u;

declare table;

{ IFS= read -r -d $'\x11' table || :; } <<'END_STD_INPUT'
|	00	^@	C-Space	|
|	01	^A	C-a	|
|	02	^B	C-b	|
|	03	^C	C-c	|
|	04	^D	C-d	|
|	05	^E	C-e	|
|	06	^F	C-f	|
|	07	^G	C-g	|
|	08	^H	C-h	|
|	09	^I	C-i	|
|	0a	^J	C-j	|
|	0b	^K	C-k	|
|	0c	^L	C-l	|
|	0d	^M	C-m	|
|	0e	^N	C-n	|
|	0f	^O	C-o	|
|	10	^P	C-p	|
|	11	^Q	C-q	|
|	12	^R	C-r	|
|	13	^S	C-s	|
|	14	^T	C-t	|
|	15	^U	C-u	|
|	16	^V	C-v	|
|	17	^W	C-w	|
|	18	^X	C-x	|
|	19	^Y	C-y	|
|	1a	^Z	C-z	|
|	1b	^[	C-[	|
|	1c	^\	C-\	|
|	1d	^]	C-]	|
|	1e	^^	C-^	|
|	1f	^_	C-_	|
|	20	 	 	|
|	21	!	!	|
|	22	"	"	|
|	23	#	#	|
|	24	$	$	|
|	25	%	%	|
|	26	&	&	|
|	27	'	'	|
|	28	(	(	|
|	29	)	)	|
|	2a	*	*	|
|	2b	+	+	|
|	2c	,	,	|
|	2d	-	-	|
|	2e	.	.	|
|	2f	/	/	|
|	30	0	0	|
|	31	1	1	|
|	32	2	2	|
|	33	3	3	|
|	34	4	4	|
|	35	5	5	|
|	36	6	6	|
|	37	7	7	|
|	38	8	8	|
|	39	9	9	|
|	3a	:	:	|
|	3b	\\;	\;	|
|	3c	<	<	|
|	3d	=	=	|
|	3e	>	>	|
|	3f	?	?	|
|	40	@	@	|
|	41	A	A	|
|	42	B	B	|
|	43	C	C	|
|	44	D	D	|
|	45	E	E	|
|	46	F	F	|
|	47	G	G	|
|	48	H	H	|
|	49	I	I	|
|	4a	J	J	|
|	4b	K	K	|
|	4c	L	L	|
|	4d	M	M	|
|	4e	N	N	|
|	4f	O	O	|
|	50	P	P	|
|	51	Q	Q	|
|	52	R	R	|
|	53	S	S	|
|	54	T	T	|
|	55	U	U	|
|	56	V	V	|
|	57	W	W	|
|	58	X	X	|
|	59	Y	Y	|
|	5a	Z	Z	|
|	5b	[	[	|
|	5c	\	\	|
|	5d	]	]	|
|	5e	^	^	|
|	5f	_	_	|
|	60	`	`	|
|	61	a	a	|
|	62	b	b	|
|	63	c	c	|
|	64	d	d	|
|	65	e	e	|
|	66	f	f	|
|	67	g	g	|
|	68	h	h	|
|	69	i	i	|
|	6a	j	j	|
|	6b	k	k	|
|	6c	l	l	|
|	6d	m	m	|
|	6e	n	n	|
|	6f	o	o	|
|	70	p	p	|
|	71	q	q	|
|	72	r	r	|
|	73	s	s	|
|	74	t	t	|
|	75	u	u	|
|	76	v	v	|
|	77	w	w	|
|	78	x	x	|
|	79	y	y	|
|	7a	z	z	|
|	7b	{	{	|
|	7c	|	|	|
|	7d	}	}	|
|	7e	~	~	|
|	7f	Bspace	BSpace	|
|
END_STD_INPUT

function rebind_all_ascii () {
        declare counter;
        declare head;
        declare tail=$table;
        declare tuple hexdigits sendliteral bindliteral;
        for (( counter = 0 ; counter < 128 ; counter ++ )); do
                head=${tail%%$'\n'|*};
                tail=${tail#|*|$'\n'};

                tuple=$head;
                tuple=${tuple#??};
                tuple=${tuple%?};
                {
                        IFS= read -r -d $'\t' hexdigits;
                        IFS= read -r -d $'\t' sendliteral;
                        IFS= read -r -d $'\t' bindliteral;
                } <<< "$tuple";

                tmux bind-key -n "$bindliteral" send-keys "$sendliteral" '\;' run-shell "tmux set-option status-right '$hexdigits' >/dev/null 2>&1 &";
        done;
};

function rebind_send_prefix () {
        declare tmpstr quicklookup re target lookup result
        tmpstr=$(printf %s $(tmux list-keys | grep -m 1 send-prefix || :))
        quicklookup=' a01 b02 c03 d04 e05 f06 g07 h08 i09 j0a k0b l0c m0d n0e o0f p10 q11 r12 s13 t14 u15 v16 w17 x18 y19 z1a'
        if [[ $tmpstr = '' ]]; then
                echo 'Notice: Currently no send-prefix key binding is found.'
        else
                tmpstr=${tmpstr%send-prefix}
                tmpstr=${tmpstr#bind-keyC-}
                re='^[a-z]$'
                if [[ $tmpstr =~ $re ]]; then
                        target=$tmpstr
                        lookup=${quicklookup##* $target}
                        result=${lookup:0:2}
                        tmux bind-key C-$target send-keys ^$target '\;' run-shell "tmux set-option status-right '$result' >/dev/null 2>&1 &";
                else
                        echo 'Notice: If some key is bound to `send-prefix`, you may want to rebind it...'
                fi
        fi
};

rebind_all_ascii;
rebind_send_prefix;

# vi: se et sta ts=8 sw=8 sts=2 :
