D126521FD5179A11FFFF'
FW3D20 anop
 dc h'1F0FE70DAE11B416371EF826752EF035A939A1391A37D430512990201319D812FFFF'
FW3D21 anop
 dc h'1C0FA40C2C0F3314B81B7924372DB334AC39E43A9C395533D02B0F23511AD512FFFF'
FW3D22 anop
 dc h'1A0FA20CEB0DB2113819FA21F92B7533AE39263CDD3A1637902FCE26CF1C5315FFFF'
FW3D23 anop
 dc h'170F5F0B680B310FB7167B1F7B293732B139693D603D973911324D294D1F9116FFFF'
FW3D24 anop
 dc h'54105D0B260AAF0C3614FB1CFC26F93074386B3DA23E193CD2350D2DCC210F19FFFF'
FW3D25 anop
 dc h'92115A0BE3086D0B75103B197D247B2E36376E3DE53F9B3E53388D2F8B254D1AFFFF'
	                          
	end
�v�hpD�`< flW��W�PB����=h F��p / Hn��`P+�Q RP+�Uv�� ��`P+*W��RP+*J�h��p��JFg��s��X r`�MEo \f(UVWr`L>� ^�r � � �}V`LX�y ��`�Mv�W��P   ��,�v��B�,%W��/ T P"h TN�v��B�,
W��P�W��W��P��h��U.��J��U� r`pVW��/L�� rhO�,%/N�j�,��,&W U hqcpVW L�� nhO�U� n�,&/N�jm`|�xVP�PJ�g�W��P
g��� ��\�. pO�M g\Ei fLE �f<ג[Y[�XX"hhN��g�'|�M�'|�tartX+2	;fraction part

	lda	#$EEEE	;color in all bits
	ldx	StartX
	ldy	StartY
	jsr	Plot
	mov	#1,YSpeed
	lda	YSpeed+2
	ora	#$4000	;set at least one high-speed-bit
	sta	YSpeed+2

AnimateShot	Long	I,m
	lda	#0
	ldx	StartX
	ldy	StartY
	jsr	Plot
	lda	StartX+2
	clc
	adc	XDSpeed+2
	sta	StartX+2
	lda	StartX
	adc	XDSpeed
	sta	StartX
	lda	YSpeed+2
	sec
	sbc	#1050	;on average, turn around most of the way up
	sta	YSpeed+2
	bcs	YHiWordOk	;didn't wrap
	dec	YSpeed	;-1 if it wrapped
	lda	YSpeed
	inc	a
	bmi	WaitAround
YHiWordOk	lda	StartY+2
	sec
	sbc	YSpeed+2
	sta	StartY+2
	lda	StartY
	sbc	YSpeed
	sta	StartY
	bmi	OffScreen
YShotOk2	anop
	lda	#$EEEE
	ldx	StartX
	ldy	StartY
	cpy	#200-40
	bge	WaitArnd2
NoWaitArnd2	jsr	Plot

	lda	StartX
	sec
	sbc	TargetX
	beq	WaitAround	;reached target
	dec	a
	beq	WaitAround	;reached target -- +/-1 tolerance
	inc	a
	inc	a
	beq	WaitAround	;reached target
	jsr	WaitNextVBL
	brl	AnimateShot

OffScreen	jsr	WaitNextVBL	;check if time to quit
	brl	DoAnother
WaitArnd2	lda	YSpeed
	bmi	WaitAround
	lda	#$EEEE
	bra	NoWaitArnd2
                               
WaitAround	anop
	lda	#0	;first, get center of shot off the screen
	ldx	StartX
	ldy	StartY
	jsr	Plot
	lda	StartY
	cmp	#200-38	;below minimum safe height?
	bge	OffScreen

	lda	StartX
	sec
	sbc	#36
	lsr	a
	pha		;save on stack

	lda	StartY
	sec
	sbc	#27
	xba		;#256
	lsr	a	;*128
	pha
	lsr	a	;*64
	lsr	a	;*32
	clc
	adc	1,s	;*160
	adc	3,s	;x/2
	adc	#$2000
	plx
	plx		;throw away temp values
	sta	PixAddr1+1
	sta	PixAddr2+1
	sta	PlotIt+1
	mov	#$10,ColorH
	mov	#$01,ColorL

	WordResult
	_Random
	pla
	and	#$F
	asl	a
	tax
	lda	FWs,x
	sta	16
	
	ldy	#0
DoParams	sty	ParamOffset
DoParams2	lda	Running
	bne	DoRunStuff
	brl	ParamFromBlk
DoRunStuff	anop

	ldx	#36
	Short	M
Shift1Up	lda	Block1+2,x	;shift up by 1 byte
	sta	Block1+3,x
	lda	Block2+2,x
	sta	Block2+3,x
	dex
	bpl	Shift1Up

	ldx	Erase	;offset to value to erase
	lda	Block1+2,x
	ora	Block1+2
	ora	Block2+2,x
	ora	Block2+2	;check all to-plot values
	bne	StillPlot
	Long	M
	stz	Running
	brl	ParamFromBlk	;branch if done running
StillPlot	Long	M
	phx
	lda	Block1+2,x
	beq	Erase2
	stz	Block1+2,x
	and	#$FF
	stz	ColorL
	stz	ColorH	;black
	jsr	PlotValue	;value to plot
Erase2	plx
	lda	Block2+2,x
	beq	Draw1
	and	#$FF
	stz	Block2+2,x
	stz	ColorL    
	stz	ColorH	;black
	jsr	PlotValue
Draw1	Short	M
	lda	Block1
	cmp	Block1+1	;at the end of block1?
	blt	DoDraw1
	stz	Block1+2	;didn't plot anything
	bra	Draw2
DoDraw1	inc	Block1	;next value to plot
	sta	Block1+2     ;save it as plotted
	Long	M
	and	#$FF	;mask to 1-byte
	pha
	tax
	lda	Colors-16,x
	#include "types.rez"
#include "t2common.rez"

// --- Flags resource

resource rT2ModuleFlags (moduleFlags) {
	fFadeOut+fFadeIn+fGrafPort320, // module flags word
	$01,						// enabled flag (unimplemented)
	$0110,					// minimum T2 version required
	NIL,						// reserved
	"Mini Fireworks"				// module name
};

// --- About text resource

resource rTextForLETextBox2 (moduleMessage) {
	TBLeftJust
	TBBackColor TBColorF
	TBForeColor TBColor1
	"Mini Fireworks"
	TBForeColor TBColor0
	" shoots off fireworks that explode in random patterns.\n"
	TBForeColor TBColor4
	"Written by Nathan Mates, dedicated to Ah-Ram Kim."
};

// --- Version resource

resource rVersion (moduleVersion) {
       {1,0,0,final,2},             // Version
       verUS,                         // US Version
       "T2 Mini Fireworks Module",     // program's name
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
		$"0F000000000E00000000F0"
		$"0F000000000000000000F0"
		$"0F00000E000000E00000F0"
		$"0F00000000EEE0000000F0"
		$"0F0000000EE0EE000000F0"
		$"0F0000E00E000E00E000F0"
		$"0F0000000EE0EE000000F0"
		$"0F00000000EEE0000000F0"
		$"0F00000E0000000E0000F0"
		$"0F000000000E00000000F0"
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
 N�jP�//& �N�//N���hT*$`P+gfNdT,gRQ-.g(-/gR~(d(X&�'m`1� ```P0g�M[��Z[PzJ�mg��~MPjm)&3��hT*�  ���er   �B    "@�cK`YMX(hM/. /. /. /. /. / T P"hN��[N^NuNVK`� /. /. /.q`/. /%&�['�\�pO..��M/N�,�J X�� ̖��肀 ��amnu��x/ N�:r���m� �YqXJ�� �/. P%"z[�X�� 
ggzU�r$f/p"/ N��X�"&@ fr Jg&Krt	M
	lda	>$01c019
	bmi	WaitNxtVBL2
	Long	I,m
	rts

PlotValue	tay		;store thru jsr
	jsr	WaitNextVBL
	tya
	asl	a
	tax
	lda	FWDTrans-32,X ;-32 because 16 is first one
	sta	18	;address of points to plot
	ldy	#0
PlotPix	lda	(18),y
	bmi	DonePlots	;- means end of list
	lsr	a	;divide by 2 for actual offset
	bcc	LeftPic
	tax
	Short	M
PixAddr1	lda	>$E12000,x
	and	#$F0
	ora	ColorL
	bra	PlotIt
LeftPic	tax
	Short	M
PixAddr2	lda	>$E12000,x
	and	#$F
	ora	ColorH
PlotIt	sta	>$E12000,x
	Long	M
	iny
	iny
	bra	PlotPix
DonePlots	rts

Plot	pha
	tya		;y-pos
	xba
	lsr	a	;y*128
	pha
	lsr	a
	lsr	a	;y*32
	clc
	adc	1,s	;y*160
	ply		;clean up stack
	pha		;store on stack-- line base
	txa
	lsr	a	;divide x by 2 (2 pix/byte)
	bcs	OddPix
	adc	1,s	;carry guaranteed clear
	cmp	#$8000
	bge	PlotError
OnScreenX	ply
	tax		;byte address of pixel
	pla		;Color
	and	#$00F0	;left pixel
	sta	Color
	lda	>$E12000,x
	and	#$FF0F	;keep bits
	ora	Color
	sta	>$E12000,x
	rts
PlotError	ply	
	pla
	rts
OddPix	clc
	adc	1,s
	cmp	#$8000
	bge	PlotError	;don't plot if unset exit
Set AuxType $4004
Set KeepType $BC
Set A */system/cdevs/twilight
Echo Assembling {1}
if {1} == "Boxes"
  asml +w -x boxes.asm
  delete {a}/Modern.Art
  copy Modern.Art {a}
else if {1} == "ClockS"
  asml +w -x Clocks.Asm
  delete {a}/Clocks
  copy Clocks {a}
else if {1} == "LedMsg"
  asml +w -x LedMsg.Asm
  delete {a}/led.msg
  copy Led.Msg {a}
else if {1} == "Comedy"
  asml +w -x Comedian.Asm
  delete {a}/Comedian
  copy Comedian {a}
else if {1} == "Fire"
  asml +w -x Fireworks.Asm
  copy -f Fireworks MiniFireworks
  delete {A}/MiniFireworks
  copy MiniFireworks {A}
else if {1} == "MSlides"
  asml +w -x MSlides.asm
  delete {a}/mslides
  copy MSlides {a}
else if {1} == "Persp"
  asml +w -x Perspective.Asm
  copy -f persp.temp Perspective
  delete {A}/Perspective
  copy Perspective {A}
else if {1} == "Plasma"
  asml +w -x Plasma.Asm
  delete {A}/Plasma
  copy Plasma {A}
else if {1} == "SNF"          
  asml +w -x SNF.asm
  copy -f SNF SharksAndFish
  delete {a}/SharksAndFish
  copy SharksAndFish {A}
else if {1} == "Tunnel"
  asml +w -x TunnelGame.asm
  delete {a}/TunnelGame
  copy TunnelGame {A}
else           
  Echo Known programs:
  Echo "  Aclock - AClock.Asm"
  Echo "  Boxes - Boxes.Asm"
  Echo "  Comedy - Comedian.Asm"
  Echo "  DClock - DClock.Asm"
  Echo "  Fire - Fireworks.Asm"
  Echo "  LedMsg - LedMsg.Asm"
  Echo "  MSlides - MSlides.Asm"
  Echo "  Persp - Perspective.Asm"
  Echo "  Plasma - Plasma.Asm"
  Echo "  SNF - SNF.Asm"
  Echo "  Tunnel - TunnelGame.Asm"
  end
H�/ L �P�/ P	�(@ k	ds	2
StartX	ds	4	;4 for 32-bit frac adds
StartY	ds	4	;ditto
TargetX	ds	2
TargetY	ds	2
XDSpeed	ds	4
YSpeed	ds	4
OldBorder	ds	2
ParamOffset	ds	2
ColorH	ds	2
ColorL	ds	2
Erase	ds	2
Running	ds	2
Block1	ds	50
Block2	ds	50

Blocks	dc	a'Block1,Block2'

EndFW	equ	245
SetColor	equ	246
WaitTick	equ	247
SetErase	equ	248
SetRunBlock	equ	249
RunNow	equ	250
Brighter	equ	$FFFF	;-1
Darker	equ	$FFFE	;-2

FWs	dc	a'FW1Code,FW2Code,FW3Code,FW4Code,FW5Code,FW6Code,FW7Code'
	dc	a'FW8Code,FW9Code,FW10Code,FW11Code,FW12Code,FW13Code'
	dc	a'FW14Code,FW15Code,FW16Code'

Colors	dc	H'EEEEEEEEEEDDDDDDCCCCCCBBBBBBAAAAAA9999999999999999' ;1-25
	DC	H'99999999999999999999FF' ;26-36
	dc	H'EEEEEEEEEEDDDDDDCCCCCCBBBBBBAAAAAA99999999999999FF' ;1-25
	dc	H'EEEEEEEEEEDDDDDDCCCCCCBBBBBBAAAAAA99999999999999FF' ;1-25

FWDTrans	dc	a'FW1D1,FW1D2,FW1D3,FW1D4,FW1D5,FW1D6,FW1D7,FW1D8,FW1D9'
	DC	A'FW1D10,FW1D11,FW1D12,FW1D13,FW1D14,FW1D15,FW1D16'
	DC	A'FW1D17,FW1D18,FW1D19,FW1D20,FW1D21,FW1D22,FW1D23'
	DC	A'FW1D24,FW1D25,FW1D26,FW1D27,FW1D28,FW1D29,FW1D30'
	DC	A'FW1D31,FW1D32,FW1D33,FW1D34,FW1D35,FW1D36'
	dc	a'FW2D1,FW2D2,FW2D3,FW2D4,FW2D5,FW2D6,FW2D7,FW2D8,FW2D9'
	DC	A'FW2D10,FW2D11,FW2D12,FW2D13,FW2D14,FW2D15,FW2D16'
	DC	A'FW2D17,FW2D18,FW2D19,FW2D20,FW2D21,FW2D22,FW2D23'
	DC	A'FW2D24,FW2D25'
	dc	a'FW3D1,FW3D2,FW3D3,FW3D4,FW3D5,FW3D6,FW3D7,FW3D8,FW3D9'
	DC	A'FW3D10,FW3D11,FW3D12,FW3D13,FW3D14,FW3D15,FW3D16'
	DC	A'FW3D17,FW3D18,FW3D19,FW3D20,FW3D21,FW3D22,FW3D23'
	DC	A'FW3D24,FW3D25'
FW1P1	EQU	1+15
FW1P2	EQU	2+15
FW1P3	EQU	3+15
FW1P4	EQU	4+15
FW1P5	EQU	5+15
FW1P6	EQU	6+15
FW1P7	EQU	7+15
FW1P8	EQU	8+15
FW1P9	EQU	9+15
FW1P10	EQU	10+15
FW1P11	EQU	11+15
FW1P12	EQU	12+15
FW1P13	EQU	13+15
FW1P14	EQU	14+15
FW1P15	EQU	15+15
FW1P16	EQU	16+15
FW1P17	EQU	17+15
FW1P18	EQU	18+15
FW1P19	EQU	19+15
FW1P20	EQU	20+15
FW1P21	EQU	21+15
FW1P22	EQU	22+15
FW1P23	EQU	23+15
FW1P24	EQU	24+15
FW1P25	EQU	25+15
FW1P26	EQU	26+15
FW1P27	EQU	27+15
FW1P28	EQU	28+15
FW1P29	EQU	29+15
FW1P30	EQU	30+15
FW1P31	EQU	31+15
FW1P32	EQU	32+15
FW1P33	EQU	33+15
FW1P34	EQU	34+15
FW1P35	EQU	35+15
FW1P36	Eunset exit
Set AuxType $4004
Set KeepType $BC
Set A */system/cdevs/twilight
Echo Assembling {1}
if {1} == "Clocks"
  compile Clocks.Rez Keep=Clocks
  delete {a}/Clocks
  copy Clocks {a}
else if {1} == "AClock"
  compile AClock.Rez Keep=AClock
  delete {a}/Aclock
  copy AClock {a}
else if {1} == "SNF"
  compile SNF.Rez Keep=SharksAndFish
  delete {a}/SharksAndFish
  copy SharksAndFish {a}
else if {1} == "Boxes"
  compile Boxes.Rez Keep=Modern.Art
  delete {a}/Modern.Art
  copy Modern.Art {a}
else if {1} == "Tunnel"
  compile TunnelGame.Rez Keep=TunnelGame
  delete {a}/TunnelGame
  copy TunnelGame {a}
else if {1} == "Persp"
  compile Perspective.Rez Keep=Perspective
  delete {a}/Perspective
  copy Perspective {a}
else if {1} == "Fire"
  compile Fireworks.Rez Keep=MiniFireworks
  delete {a}/MiniFireworks
  copy MiniFireworks {a}
else if {1} == "LedMsg"
  compile LedMsg.Rez Keep=Led.Msg
  delete {a}/Led.Msg
  copy Led.Msg {a}
else           
  Echo Known programs:
  Echo "  Aclock - AClock.Asm"
  Echo "  Boxes - Boxes.Asm"
  Echo "  Comedy - Comedian.Asm"
  Echo "  DClock - DClock.Asm"
  Echo "  Fire - Fireworks.Asm"
  Echo "  LedMsg - LedMsg.Asm"
  Echo "  MSlides - MSlides.Asm"
  Echo "  Persp - Perspective.Asm"
  Echo "  Plasma - Plasma.Asm"
  Echo "  SNF - SNF.Asm"
  Echo "  Tunnel - TunnelGame.Asm"
  end
       ���ͧ���                     9� 9� 9�                                                                                                                                                       p � � h RunNow'
	dc	i1'EndFW'          

FW6Code	anop
	dc	i1'SetErase,25'
	dc	i1'SetRunBlock,1,FW2P1,FW2P25'
	dc	i1'RunNow'
	dc	i1'EndFW'          
                                               
FW7Code	anop
	dc	i1'SetErase,25'
	dc	i1'SetRunBlock,1,FW3P1,FW3P25'
	dc	i1'RunNow'
	dc	i1'EndFW'          

FW8Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW2P1,FW2P15'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW2P16,FW2P25'
	dc	i1'SetRunBlock,2,FW3P1,FW3P10'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW3P11,FW3P25'
	dc	i1'RunNow'
	dc	i1'EndFW'                   

FW9Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW1P1,FW1P13'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW2P14,FW2P25'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW1P26,FW1P35'
	dc	i1'RunNow'
	dc	i1'EndFW'                   

FW10Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW1P1,FW1P13'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW2P14,FW2P25'
	dc	i1'RunNow'
	dc	i1'EndFW'                   

FW11Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW2P1,FW2P25'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW1P26,FW1P36'
	dc	i1'RunNow'
	dc	i1'EndFW'                   

FW12Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW1P1,FW1P13'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW3P14,FW3P25'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW1P26,FW1P35'
	dc	i1'RunNow'
	dc	i1'EndFW'                   

FW13Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW1P1,FW1P13'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW3P14,FW3P25'
	dc	i1'RunNow'
	dc	i1'EndFW'                   

FW14Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW3P1,FW3P25'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW1P26,FW1P36'
	dc	i1'RunNow'
	dc	i1'EndFW'                   

FW15Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW1P1,FW1P20'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW1P21,FW1P36'
	dc	i1'SetRunBlock,2,FW3P1,FW3P16'
	dc	i1'RunNow'
	dc	i1'EndFW'                    

FW16Code	anop
	dc	i1'SetErase,5'
	dc	i1'SetRunBlock,1,FW1P1,FW1P20'
	dc	i1'RunNow'
	dc	i1'SetRunBlock,1,FW1P21,FW1P25'
	dc	i1'SetRunBlock,2,FW3P1,FW3P5'
	dc	i1'RunNow'
	dc	i1'SetRunBlock
#include "types.rez"
#include "22:t2common.rez"

// --- Flags resource

resource rT2ModuleFlags (moduleFlags) {
	fSetup+fFadeOut+fFadeIn+fGrafPort320, // module flags word
	$01,						// enabled flag (unimplemented)
	$0110,					// minimum T2 version required
	NIL,						// reserved
	"Impulse 3D"					// module name
};

// --- About text resource

resource rTextForLETextBox2 (moduleMessage) {
	TBLeftJust
	TBBackColor TBColorE
	TBForeColor TBColor4
	"Impulse 3D"
	TBForeColor TBColor0
	" zooms, scales and rotates dazzling wireframe 3D objects in real time.\n"
	TBBackColor TBColorF
	TBForeColor TBColor1
	"Impulse requires low memory mode to be off to be able to "
	"animate objects."
};

// --- Version resource

resource rVersion (moduleVersion) {
       {1,0,0,final,2},             // Version
       verUS,                         // US Version
       "T2 Impulse 3D Module",     // program's name
       "By FTA & Jim Maricondo.\n"
       "Copyright 1992-93 Jim Maricondo."    // copyright notice
};

// --- About icon resource

resource rIcon (moduleIcon) {
		$8000,				// kind
		$0014,				// height
		$0016,				// width

		$"F00000000000000000000F"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0F000000000000000000F0"
		$"0F000B3000000E300000F0"
		$"0F0000B300000EE30000F0"
		$"0F00000B30000E3E3000F0"
		$"0F000BBBB3000E30E300F0"
		$"0F000000B3000E30E300F0"
		$"0F00000B30000E3E3000F0"
		$"0F0000B300000EE30000F0"
		$"0F000B3000000E300000F0"
		$"0F000000000000000000F0"
		$"0FFFFFFFFFFFFFFFFAFFF0"
		$"0000000000000000000000"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FF4AFFFFFFFFFFFFFF0F"
		$"F0CCCCCCCCCCCCCCCCCC0F"
		$"F0FFFFFFFFFFFFFFFAFF0F"
		$"F00000000000000000000F",

		$"0FFFFFFFFFFFFFFFFFFFF0"
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

// --- type $8004 defines
#define CTLTMP_00006FFD $00006FFD
#define CTLTMP_00006FFE $00006FFE
#define CTLTMP_00006FFF $00006FFF
#define CTLTMP_00007000 $00007000
#define CTLTMP_00007001 $00007001
#define CTLTMP_00007002 $00007002
#define CTLTMP_00007003 $00007003
#define CTLTMP_00010012 $00010012
// --- type $8006 defines
#define PSTR_0000000D $0000000D
#define PSTR_0000000E $0000000E
#define PSTR_0000000F $0000000F
#define PSTR_00000010 $00000010
#define PSTR_00000011 $00000011
#define PSTR_00000012 $00000012
#define PSTR_000000FC $000000FC
#define PSTR_00000107 $00000107
#define PSTR_00000108 $00000108
#define PSTR_00000109 $00000109
#define PSTR_0000010A $0000010A
#define PSTR_0000010B $0000010B
#define PSTR_0000010C $0000010C
#define PSTR_0000010D $0000010D
#define PSTR_0000010E $0000010E
#define PSTR_0000010F $0000010F
#define PSTR_00000110 $00000110
#define PSTR_00000111 $00000111
#define PSTR_00000112 $00000112
#define PSTR_00000113 $00000113
#define PSTR_00000114 $00000114
#define PSTR_00000115 $00000115
#define PSTR_00000116 $00000116
#define PSTR_00000117 $00000117
#define PSTR_00000118 $00000118
#define PSTR_00000119 $00000119
#define PSTR_0000011A $0000011A
// --- type $8009 defines
#define MENU_00000001 $00000001
#define MENU_00000002 $00000002
// --- type $800A defines
#define MENUITEM_00000001 $00000001
#define MENUITEM_00000107 $00000107
#define MENUITEM_00000108 $00000108
#define MENUITEM_00000109 $00000109
#define MENUITEM_0000010A $0000010A
#define MENUITEM_0000010B $0000010B
#define MENUITEM_0000010C $0000010C
#define MENUITEM_0000010D $0000010D
#define MENUITEM_0000010E $0000010E
#define MENUITEM_0000010F $0000010F
#define MENUITEM_00000110 $00000110
#define MENUITEM_00000111 $00000111
#define MENUITEM_00000112 $00000112
#define MENUITEM_00000113 $00000113
#define MENUITEM_00000114 $00000114
#define MENUITEM_00000115 $00000115
#define MENUITEM_00000116 $00000116
#define MENUITEM_00000117 $00000117
#define MENUITEM_00000118 $00000118
#define MENUITEM_00000119 $00000119
#define MENUITEM_0000011A $0000011A
#define MENUITEM_0000011B $0000011B
// --- type $800B defines
#define LETXTBOX_00000001 $00000001
#define LETXTBOX_00000002 $00000002
// --- type $800E defines
#define WPARAM1_00000FFF $00000FFF
// --- type $8010 defines
#define WCOLOR_00000001 $00000001

// --- Control List Definitions

resource rControlList (1) {
		{
		CTLTMP_00007002,			// control 1
		CTLTMP_00007001,			// control 2
		CTLTMP_00007000,			// control 3
		CTLTMP_00006FFF,			// control 4
		CTLTMP_00006FFE,			// control 5
		CTLTMP_00006FFD,			// control 6
		1,						// control 7
		2,						// control 8
		};
};

// --- Control Templates

resource rControlTemplate (CTLTMP_00006FFE) {
		1,			// ID
		{ 82, 14, 91,338},		// rect
		checkControl {{
			$0000,			// flag
			$3002,			// moreFlags
			$00000000,			// refCon
			PSTR_0000000D,	// titleRef
			$0001,			// initialValue
			0,			// colorTableRef
			{"D","d",$0100,$0100}	// key equivalents
		}};
};

resource rControlTemplate (CTLTMP_00006FFF) {
		2,			// ID
		{ 66, 12,  0,  0},		// rect
		popUpControl {{
			$0040,			// flag
			$1002+fDrawPopDownIcon,	// moreFlags
			$00000000,			// refCon
			$0000,			// titleWidth
			MENU_00000002,	// menuRef -- SHOW DELAY popup
			2,			// initialValue
			0				// colorTableRef
		}};
};

resource rControlTemplate (CTLTMP_00007000) {
		3,			// ID
		{ 51, 12,  0,  0},		// rect
		popUpControl {{
			$0040,			// flag
			$1002+fDrawPopDownIcon,	// moreFlags
			$00000000,			// refCon
			$0000,			// titleWidth
			MENU_00000001,	// menuRef -- WHICH SHAPE popup
			16,			// initialValue
			0				// colorTableRef
		}};
};

resource rControlTemplate (CTLTMP_00006FFD) {
		4,			// ID
		{108, 72,127,271},		// rect
		statTextControl {{
			$0000,			// flag
			$1002,			// moreFlags
			$00000000,			// refCon
			LETXTBOX_00000002		// textRef
		}};
};

resource rControlTemplate (CTLTMP_00007001) {
		5,			// ID
		{ 32,136, 42,255},		// rect
		statTextControl {{
			$0000,			// flag
			$1002,			// moreFlags
			$00000000,			// refCon
			LETXTBOX_00000001		// textRef
		}};
};

resource rControlTemplate (CTLTMP_00007002) {
		6,			// ID
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

resource rControlTemplate (1) {
       7,              // ID
       {105,42,106,296},           // rect
       rectangleControl {{
               $0002,               // flag (%10 = black pattern)
               fCtlProcNotPtr,      // moreFlags (required values)
               NIL            // refCon
       }};
};

resource rControlTemplate (2) {
		8,			// ID
//		{ 93, 14,102,296},		// rect
		{ 93, 14,102,338},		// rect
		checkControl {{
			$0000,			// flag
			$3002,			// moreFlags
			$00000000,			// refCon
			10,	// titleRef
			$0000,			// initialValue
			0,			// colorTableRef
			{"M","m",$0100,$0100}	// key equivalents
		}};
};

// --- rPString Templates

resource rPString (PSTR_0000000D) {
	"Display Frames Per Second (fps) Counter"
};

resource rPString (10) {
	"Maximum Zoom (Accelerator Recommended)"
};

// --- SHOW DELAY popup

resource rPString (PSTR_0000000F) {
	" Show Each Shape For: "
};

resource rPString (PSTR_0000000E) {		//1
	"10 Seconds"
};

resource rPString (PSTR_00000115, $C018