2'
TickEndY2	anop               
 dc i'-4,-3,-2,0,2,3,4,3,2,0,-2,-3'


	end
�er   ,    �qNV  /. LN^NuNV_H�&n (n U-@��/N����fwingf<(��(z�R/ T P"h�N�z_hTg�H�/ Z_PZ'm�[L���%��\&n (n /<----(�J P�g8QX� (�fextX�f"Q3(�* ///-�L�hTkXBQ ( $�ansrgP� ���� �g:k� �/N� �/-�L�p �8 O� gP	*�f=�opstPm~k �Azv�BHn� Hn��/N��Q��odoc>g � Kg�g��g`,<<�`(E�`"�.�B`E�`�.�z�Eƻ6U�ost important-- fast mvn if available
	sta	MvnLoc2+1	;most important-- fast mvn if available

	lda	DClockPrefs
	and	#$FF
	sta	ClockType
	cmp	#3
	blt	DoDefType
	
GetClockType WordResult
	_Random
	pla
	and	ClockType	;mask to 0-3...
DoDefType	dec	a
	bmi	GotoASClock
	dec	a
	bmi	GotoAClock
	beq	DoDClock	;0 now means was 2=DClock
	bra	GetClockType	;3= still random
	
GotoAClock	brl	DoAClock
GotoASClock	brl	DoASClock
ClockType	ds	2

DoDClock	mov	#$F00,>$e19e02
	stz	OnColor	;now in current bank

	PushWord #1	;color #
	_SetSolidPenPat
	PushWord #0
	_SetSolidBackPat

NewLoc	LongResult
	WordResult
	_Random		;random #
	PushWord	#160	;divide by
	_UDivide
	pla
	pla		;modulo
	lsr	a
	asl	a	;make it on an even byte boundary
	sta	Left	;left edge of stuff to draw
	clc
	adc	#40
	sta	WipeRect+6	;for erasing hours
GetNewY	LongResult	;for Division
	WordResult
	_Random
	PushWord	#171	;to divide by
	_UDivide
	pla		;quotient
	pla		;modulo result (0-170)
	sta	Top
	clc
	adc	#29
	sta	WipeRect+4
	jsr	GetTimed
	jsr	Buf2Digs
	lda	Top
	clc
	adc	#6
	sta	Circle
	clc
	adc	#4
	sta	Circle+4
	lda	Left
	clc
	adc	#46
	sta	Circle+2
	clc
	adc	#5
	sta	Circle+6
	PushLlcl #Circle
	_PaintOval
	lda	Circle
	clc
	adc	#13
	sta	Circle
	clc
	adc	#4
	sta	Circle+4
	PushLlcl #Circle
	_PaintOval
	stz	LastDigits
	stz	LastDigits+2
	stz	LastDigits+4	;clean up after last time...

	jsr	DrawAll

LessThan	mov	#1,WasAbove

WaitAround	lda	[T2Data1]	;check done ptr in long mode just in case
	bne	Done

	lda	>$E0C02E	;vertical counter, upper 8 bits of it
	and	#$00FF
	rol	a
	cmp	WaitFor
	blt	LessThan

	lda	WasAbove	;check position on screen
	beq	WaitAround	;check if we've already displayed it...
	stz	WasAbove	;flag below
	dec	CountTwo
	bpl	WaitAround
	lda	DClockPrefs
	xba
	and	#$FF
	sta	CountTwo

	jsr	MoveIt
	jsr	GetTimed

*	short	M	
*Wait1d	lda	>$e1C019	;wait for start of next refresh
*	bpl	Wait1d	;so no-blink screen clear
*Wait2d	lda	>$E1C019
*	bmi	Wait2d
*	Long	M	;force at least 1 full wait

	lda	Buffer+$F
	cmp	Digits+4	;seconds changed yet?
	beq	WaitAround
	ldx	OnColor
	lda	Colors,x	;next color
	sta	>$e19e02
	inx
	inx
	cpx	#ColorsLen
	blt	OkColor
	ldx	#0
OkColor	stx	OnColor
DontJump	jsr	Buf2Digs
	jsr	DrawAll
	bra	WaitAround

done	anop
	stz	<16
	stz	<18	;return w/no error
Bye	anop
	pld
	plx
	ply		;return address & bank
	pla
	pla		;T2data2
	pla
	pla		;T2data1
	pla		;Message
	phy
	phx
	plb
	rtl

GetTimed	PushLlcl #Buffer
	_ReadAsciiTime
	ldx	#18
ToLowAscii	lda	Buffer,x
	and	#$7F7F
	sta	Buffer,x
	dex
	dex
	bpl	ToLowAscii
	rts

Buf2Digs	lda	Buffer+9
	cmp	Digits	;hours changed?
	beq	Min2Digs
	sta	Digits	;update in memory
	stz	LastDigits	;and screen update list
            lda	Top
	clc
	adc	#29
	sta	WipeRect+4
	lda	Left
	clc
	adc	#40
	sta	WipeRect+6
	          
	PushLlcl	#WipeRect
	_EraseRect
Min2Digs	lda	Buffer+$C
	sta	Digits+2
	lda	Buffer+$F
	sta	Digits+4
AnRts	long	I,m
	rts

DrawSeconds lda	Left
	clc
	adc	#140
	sta	CharSX
	lda	Digits+5	;fall into DrawDigit
	ldx	#5	;correct place

DrawDigit	and	#$FF	;clear a's hob
	Short	M
	cmp	#$20	;space
	beq	AnRts	;quit if a space
	sec
	sbc	#$30	;mask#include "types.rez"
#include "t2common.rez"

// --- Flags resource

resource rT2ModuleFlags (moduleFlags) {
	fFadeOut+fFadeIn+fGrafPort320+fSetup,	// module flags word
	$01,					// enabled flag (unimplemented)
	$0110,					// minimum T2 version required
	NIL,					// reserved
	"Clocks"				// module name
};

// --- About text resource

resource rTextForLETextBox2 (moduleMessage) {
	TBLeftJust
	TBBackColor TBColorF
	TBForeColor TBColor1
	"Clocks"
	TBForeColor TBColor0
	" bounces 2 types of clocks around the screen.\n"
	TBForeColor TBColor4
	"Written by Nathan Mates, dedicated to Ah-Ram Kim."
};

// --- Version resource

resource rVersion (moduleVersion) {
       {1,0,0,final,2},             // Version
       verUS,                         // US Version
       "T2 Clocks Module",     // program's name
       "By Nathan Mates.\n"
       "Special Thanks to Jim Maricondo."    // copyright notice
};

// --- About icon resource

resource rIcon (moduleIcon) {
		$8000,				// kind
		$0014,				// height
		$0016,				// width
		$"0000000000000000000000"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0F000000000000000000F0"
		$"0F000000000000000000F0"
		$"0F000000000000000000F0"
		$"0F000404000444044400F0"
		$"0F000404040004040000F0"
		$"0F000444000444044400F0"
		$"0F000004040400000400F0"
		$"0F000004000444044400F0"
		$"0F000000000000000000F0"
		$"0F000000000000000000F0"
		$"0FFFFFFFFFFFFFFFFAFFF0"
		$"0000000000000000000000"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FF4AFFFFFFFFFFFFFF0F"
		$"F0CCCCCCCCCCCCCCCCCC0F"
		$"F0FFFFFFFFFFFFFFFAFF0F"
		$"F00000000000000000000F",

		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0";
};        

resource rControlList(1) {
	{
        1,		//speed
        2,		//type
	3,		//icon
        4,		//title
        };
};

resource rControlTemplate (1) {
 0x00000001,  /* control id */ 
{0x0043,0x0018,0x0000,0x0000},  /* control rectangle */
      PopUpControl{{   /* control type */
 0x0004,  /* flags */
 0x1002+fDrawPopDownIcon,   /* more flags */
 0,        /* ref con */
 0, /* title width */
 0x0008A37E, /* menu reference */
 0x012E,  /* inital value */
 0x00000000    /* color table id */
}};
};

resource rControlTemplate (3) {
		3,			// ID
		{ 25, 84, 48,130},		// rect
		iconButtonControl {{
			$000C,			// flag
			$1020,			// moreFlags
			$00000000,			// refCon
			moduleIcon,		// iconRef
			0,			// titleRef
			0,			// colorTableRef
			$0000			// displayMode
		}};
};

resource rControlTemplate (4) {
		4,			// ID
		{ 32,142, 42,250},		// rect
		statTextControl {{
			$0000,			// flag
			$1002,			// moreFlags
			$00000000,			// refCon
			1			//txtref...
		}};
};


resource rMenu (0x0008A37E) {
0x001E,  /* id of menu */
 RefIsResource*MenuTitleRefShift+RefIsResource*ItemRefShift+fAllowCache,
 0x0008A37E,  /* id of title string */
 {
 0x0000000A,    /* item reference */
 0x0000000B,    /* item reference */
 0x0000000C,    /* item reference */
 0x0000000D,    /* item reference */
 0x0000000E,    /* item reference */
 0x0000000F,    /* item reference */
};};
resource rPString (0x0008A37E) { 
"Speed: "};
resource rMenuItem (0x0000000A) {
 0x012C, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x0000000A,    /* title reference */
};
resource rPString (0x0000000A) { 
"Maxxed"};
resource rMenuItem (0x0000000B) {
 0x012D, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x0000000B,    /* title reference */
};
resource rPString (0x0000000B) { 
"Fast"};
resource rMenuItem (0x0000000C) {
 0x012E, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x0000000C,    /* title reference */
};
resource rPString (0x0000000C) { 
"Normal"};
resource rMenuItem (0x0000000D) {
 0x012F, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x0000000D,    /* title reference */
};
resource rPString (0x0000000D) { 
"Slower"};
resource rMenuItem (0x0000000E) {
 0x0130, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x0000000E,    /* title reference */
};
resource rPString (0x0000000E) { 
"Slower Still"};
resource rMenuItem (0x0000000F) {
 0x0131, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x0000000F,    /* title reference */
};
resource rPString (0x0000000F) { 
"Creeping"};

resource rControlTemplate (2) {
 0x00000002,  /* control id */ 
{0x0053,0x001F,0x0000,0x0000},  /* control rectangle */
      PopUpControl{{   /* control type */
 0x0004,  /* flags */
 0x1002+fDrawPopDownIcon,   /* more flags */
 0,        /* ref con */
 0, /* title width */
 0x0008A37F, /* menu reference */
 0x0134,  /* inital value */
 0x00000000    /* color table id */
}};

};
resource rMenu (0x0008A37F) {
0x0020,  /* id of menu */
 RefIsResource*MenuTitleRefShift+RefIsResource*ItemRefShift+fAllowCache,
 0x0008A37F,  /* id of title string */
 {
 0x00000010,    /* item reference */
 0x00000011,    /* item reference */
 0x00000012,    /* item reference */
 0x00000013,    /* item reference */
};};
resource rPString (0x0008A37F) { 
"Type: "};

resource rMenuItem (0x00000010) {
 0x0132, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x00000010,    /* title reference */
};
resource rPString (0x00000010) { 
"Small Analog"};

resource rMenuItem (0x00000011) {
 0x0133, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x00000011,    /* title reference */
};
resource rPString (0x00000011) { 
"Analog"};

resource rMenuItem (0x00000012) {
 0x0134, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x00000012,    /* title reference */
};
resource rPString (0x00000012) { 
"Digital"};

resource rMenuItem (0x00000013) {
 0x0135, /* item id number */
 "","",       /* hot key*/
 0,       /* check character */
 RefIsResource*ItemTitleRefShift+fXOR,
 0x00000013,    /* title reference */
};
resource rPString (0x00000013) { 
"Random"};



resource rTextForLETextBox2 (1) {
	"Clocks Options"
};
/6/#!#/3"f'4/6"*#4h  I ~*~t+~qf,�43%#f)4(j22#0#f'6650
'44?f
#(?)(4�-7
M
/5'f#5-2)6f'('!#4fw~w+~uf,�32+/2.0 43-f
3")*6.f3"f/**f2-~5)5�  ̨�er   �4     ocK\j(n �oM���X P"hN� T&h 6RQ$%s�_N^NuNVr\#B/ T P"h �N� T(� %g� �B===========================
Data Field Control Template
===========================
           ________________
      $00 |                |	
          |-    pCount    -| - Word - Parameter count for template: 7 or 8
          |________________|
      $02 |                |
          |-              -|
          |                |
          |--     ID     --| - Long - Application-assigned control ID
          |                |
          |-              -|
          |________________|
      $06 |                |
          |-              -|
          |                |
          |--            --|
          |                |
          |-              -|
          |__    rect    __| - Rect - Boundary rectangle for control
          |                |
          |-              -|
          |                |
          |--            --|
          |                |
          |-              -|
          |________________|
      $0E |                |
          |-              -|
          |                |
          |--  procRef   --| - Long - Resource ID of control definition
          |                |             procedure
          |-              -|
          |________________|
      $12 |                |
          |-     flag     -| - Word - Hilight and control flags for control
          |________________|
      $14 |                |
          |-   moreFlags  -| - Word - Additional control flags
          |________________|
      $16 |                |
          |-              -|
          |                |
          |--   refCon   --| - Long - Application-defined value
          |                |
          |-              -|
          |________________|
      $1A |                |
          |-              -|
          |                |
          |-- dataListRef--| - Long - Reference to dataList structure
          |                |
          |-              -|
          |________________|
      $1E |                |
          |- fieldValues  -| - Words - Array of 8 words specifying the default
          |__            __|	           display strings for each field. These
          |                |	           are tags that correspond to tags within
          |-              -|            the associated string list. Set a field
          |__            __|            to zero to display the first string.
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |________________|


----------------------      
dataList sub-structure
----------------------
           ________________
          |                |
          |-              -|
          |                |
          |--  fieldLoc  --| - Point - Location of this field relative to
          |                |	             control's boundary
          |-              -|
          |________________|
          |                |
          |-              -|
          |                |
          |-- stringRef  --| - Long - Reference to tagged string structure
          |                |             associated with this field
          |-              -|
          |________________|
             .     	    .
             .          .
             .     	    .
          	
          (Repeats for each data field - terminated by the word $FFFF)


	
=========================
Data Field Control Record
=========================
           ________________
      $00 |                |
          |-              -|
          |                |
          |--  cltNext   --| - Long - Handle to next control; NIL for last
          |                |           control
          |-              -|
          |________________|
      $04 |                |
          |-              -|
          |                |
          |--  ctlOwner  --| - Long - Pointer to window to which control
          |                |	          belongs
          |-              -|
          |________________|
      $08 |                |
          |-              -|
          |                |
          |--            --|
          |                |
          |-              -|
          |__  ctlRect   __| - Rect - Boundary rectangle for control
          |                |
          |-              -|
          |                |
          |--            --|
          |                |
          |-              -|
          |________________|
      $10 |     ctlFlag    |
          |________________| - Byte - Control visibility and other attributes
      $11 |    cltHilite   |
          |________________| - Byte - Hilighting
      $12 |                |
          |-   ctlValue   -| - Word - Reserved
          |________________|
      $14 |                |
          |-              -|
          |                |
          |--  ctlProc   --| - Long - Resource ID of control definition
          |                |             procedure
          |-              -|
          |________________|
      $18 |                |
          |-              -|
          |                |
          |-- ctlAction  --| - Long - Pointer to custom procedure; NIL if none
          |                |
          |-              -|
          |________________|
      $1C |                |
          |-              -|
          |                |
          |--  ctlData   --| - Long - Low-word is the number of entry fields in
          |                |           this control; High-word is hilighted field
          |-              -|
          |________________|
      $20 |                |
          |-              -|
          |                |
          |-- ctlRefCon  --| - Long - Application-defined value
          |                |
          |-              -|
          |________________|
      $24 |                |
          |-              -|
          |                |
          |--  ctlColor  --| - Long - Not used; must be set to 0
          |                |
          |-              -|
          |________________|
      $28 |                |
          |-              -|
          | ctlDataListRef |
          |--            --| - Long - Reference to dataList structure
          |                |
          |-              -|
          |________________|
      $2C |                |
          | ctlFieldWidths | - Bytes - Array of 8 bytes specifying the widths
          |-              -|	           of each field. These are calculated from
          |                |	           the longest string in each field.
          |-              -|
          |                |
          |-              -|
          |                |
          |-              -|
          |                |
          |-              -|
          |                |
          |-              -|
          |                |
          |-              -|
          |                |
          |________________|
      $34 |                |
          |-              -|
          |                |
          |-- ctlReserved--| - Long - Reserved
          |                |
          |-              -|
          |________________|
      $38 |                |
          |-              -|
          |                |
          |--   ctlID    --| - Long - Application-assigned ID
          |                |
          |-              -|
          |________________|
      $3C |                |
          |- ctlMoreFlags -| - Word - Additional control flags
          |________________|
      $3E |                |
          |-  ctlVersion  -| - Word - Set to 0
          |________________|
      $40 |                |
          |- ctlFieldVals -| - Words - Array of 8 words specifying the current
          |__            __|	           display strings for each field. These
          |                |	           are tags that correspond to tags within
          |-              -|            the associated string list.
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |__            __|
          |                |
          |-              -|
          |________________|
~jP%Rm0�g�`LTgs��'r\j#,o<&jR-.`Q/�R$%g-1f�s��'_\�pO#R`LFׂ_mgY_�X$ �)g*� �� �J( Gm  �C�� ���'h � T� �x"<K� ��7A ^( �H���~*o3V�@ H�+ � /����+7�+K۹8�*�36 �7��87�^702�-@��gg. n�� PJ( Gm"(,)� 9 �7�	T�+7g5 | XsĔ'K\#BJh��`L�dg`
`L�H gs�_'[\jpO#�K�7h F�0:;5u�(MH�x9 � )��8,35,33,30,28,25'
 dc i1'22,20,17,15,13,10,8,6,5,3,2,1,1,0,0,0,1,1,2,3,5,6,8,10,13,15,17,20,22'

MinSecDY2	anop
 dc i1'0,0,1,1,2,3,4,6,7,9,11,13,15,17,20,22,24,27,29,31,33,35,37,38,40,41,42,43,43,44,44'
 dc i1'44,43,43,42,41,40,38,37,35,33,31,29,27,24,22,20,17,15,13,11,9,7,6,4,3,2,1,1,0'

HoursDX2	anop
 dc i1'23,24,24,25,25,26,27,27,28,28,29,29,30,30,31,32,32,33,33,33,34,34,35,35,36,36,36,37,37,37,38,38,38,39,39,39,39,39,39,40,40,40,40,40,40,40,40,40,40,40,40,40,39,39,39,39,39,39,38,38,38'
 dc i1'37,37,37,36,36,36,35,35,34,34,33,33,33,32,32,31,30,30,29,29,28,28,27,27,26,25,25,24,24,23,22,22,21,21,20,19,19,18,18,17,17,16,16,15,15,14,13,13,13,12,12,11,11,10,10,10,9,9,9,8'
 dc i1'8,8,7,7,7,7,7,7,6,6,6,6,6,6,6,6,6,6,6,6,6,7,7,7,7,7,7,8,8,8,9,9,9,10,10,10,11,11,12,12,13,13,13,14,15,15,16,16,17,17,18,18,19,19,20,21,21,22,22'

HoursDY2	anop
 dc i1'5,5,5,5,5,5,5,6,6,6,6,6,6,7,7,7,7,8,8,8,9,9,9,10,10,10,11,11,12,12,13,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,27'
 dc i1'28,28,29,29,30,30,30,31,31,31,32,32,32,33,33,33,33,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,35,35,34,34,34,34,34,34,33,33,33,33,32,32,32,31,31,31,30,30,30,29,29,28,28,27'
 dc i1'27,27,26,26,25,25,24,24,23,23,22,22,21,21,20,19,19,18,18,17,17,16,16,15,15,14,14,13,13,13,12,12,11,11,10,10,10,9,9,9,8,8,8,7,7,7,7,6,6,6,6,6,6,5,5,5,5,5,5'

TickStartX2	anop
 dc i'0,10,18,21,18,11,0,-10,-18,-21,-18,-10'
TickStartY2	anop
 dc i'-18,-16,-9,0,9,16,18,16,9,0,-9,-16'
TickEndX2	anop
 dc i'0,2,4,4,4,2,0,-2,-4,-4,-4,-
#include "types.rez"
#include "22:t2common.rez"

// --- type $8003 defines