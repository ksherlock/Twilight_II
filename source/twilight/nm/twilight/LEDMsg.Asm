unset exit
Echo Generating macros for {1}
if {1} == "Boxes"
  macgen boxes.asm Boxes.Macs Boxes.Macs 18/m16=
else if {1} == "Clocks"
  macgen Clocks.Asm Clocks.Macs Clocks.Macs 18/m16=
else if {1} == "LedMsg"
  macgen LedMsg.Asm LedMsg.Macs LedMsg.Macs 18/m16=
else if {1} == "Comedy"
  macgen Comedian.Asm Comedian.Macs Comedian.Macs 18/m16=
else if {1} == "Fire"
  macgen Fireworks.Asm Fireworks.Macs Fireworks.Macs 18/m16=
else if {1} == "MSlides"
  asml +w -x MSlides.asm
  delete {a}/mslides
  copy MSlides {a}
else if {1} == "Persp"
  macgen Perspective.Asm Persp.Macs Persp.Macs 18/m16=
else if {1} == "SNF"
  macgen SNF.Asm SNF.Macs SNF.Macs 18/m16=
else if {1} == "Tunnel"
  macgen TunnelGame.asm Tunnel.Macs Tunnel.Macs 18/m16=
else           
  Echo Known programs:
  Echo "  Boxes - Boxes.Asm"
  Echo "  Comedy - Comedian.Asm"
  Echo "  Clocks - Clocks.Asm"
  Echo "  Fire - Fireworks.Asm"
  Echo "  LedMsg - LedMsg.Asm"
  Echo "  MSlides - MSlides.Asm"
  Echo "  Persp - Perspective.Asm"
  Echo "  SNF - SNF.Asm"
  Echo "  Tunnel - TunnelGame.Asm"
  end
 ����    �    O�  T           ���l���                      R� R�                        �Finder�   p��pdos    @    �   M Z     ��  � ��s����                      jB +        jn                �
FloorTiles    PS16pdos ����    W    ;�  F           ��>l�ݍX                      y                            �
FourInARow    PS16pdos ����    �    z   ~           �`��\�                      �Y 	                                  ���p � � next refresh
	bpl	Wait1d	;so no-blink screen clear
Wait2d	lda	>$E1C019
	bmi	Wait2d
	Long	M	;force at least 1 full wait
	plp
	bcc	MainLoop	;branch if still in message
	brl	NewMessage
LessThan	mov	#1,WasAbove
	bra	MainLoop

done	anop
	stz	<16
	stz	<18	;return w/ no error
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

WaitFor	ds	2
WasAbove	ds	2

ScrollMsg	anop
*
* Handles the scrolling of the message
*
*
	ldx	LineStart
	PushWord MvnLoc+1
	plb
	plb		;pull bank byte twice (word pushed!)
	php
	sei
	lda	#64	;lines to move
	sta	<16
MoveLines	anop
	phx
	txy
	dey		;target is one byte over from start
	lda	#$a0-3	;# bytes to move
MvnLoc	dc	h'54e1e1'	;Mvn e1e1
	plx
	stz	|$009B,x
	txa
	clc
	adc	#$a0
	tax
	dec	<16
	bne	MoveLines
	plp
	phk
	plb
	lda	posn
	eor	#1
	sta	Posn
	beq	NotOffYet	;draw every other time (every 4 bytes of scroll)

	lda	ScrollingOff ;scrolling message off the screen
	bmi	DoRun	;if not, go on
	dec	ScrollingOff
	bpl	NotOffYet
	sec		;flag all off screen
	rts
NotOffYet	clc
AnRts	rts
Posn	ds	2

DoRun	anop
NextCol	ldx	OnColor
	inx
	inx
	cpx	#ColorsLen
	blt	OkOffset
	ldx	#0
OkOffset	stx	OnColor
	lda	Colors,x
	sta	>$E19e02	;to next color
	inc	PartOfChar
	lda	PartOfChar
	cmp	#9
	blt	StillInChar	;in same character

	mov	#1,PartOfChar ;restart bit-shift ops
	inc	PlaceInMsg
	lda	PlaceInMsg
	cmp	MsgLen
	blt	StillInIt	;still within message, no wrap
	beq	StillInIt	;still within message, no wrap
	mov	#81,ScrollingOff ;41 chars to move off
	clc		;still in message
	rts
StillInIt	anop
	ldy	PlaceInMsg
	lda	TheText+3,y
	and	#$FF
	cmp	#127
	bge	BadChar	;ignore IIGS special chars (accents, etc)
	cmp	#32
	bge	GoodChar	;branch if in 32-127
BadChar	lda	#32	;replace illegal stuff by space
GoodChar	sec             
	sbc	#32	;first char defined is space
	asl	a
	asl	a
	asl	a	;each char bitmap is 8 bytes long
	adc	#CharSet
	sta	CharStart+1	;and save its place

StillInChar ldy	#0	;now, time to display a part of the char
	mov	TopY,Oval2Make ;top coord of first one

*-----------------------------------------------------------------------------*
* makePdp.  V1.00 - 12/08/91 by JRM.
*
* Dereference handle (make a pointer) on the stack.
*
* Inputs:
*
* |previous contents|
* |-----------------|
* |     handle      |  Long - Handle to dereference.
* |-----------------|
* |     rtsAddr     |  Word - Return address.
* |-----------------|
*
* Outputs:
*
* |                 |
* |previous contents|
* |-----------------|
* |     pointer     |  Long - Dereferenced handle.
* |-----------------|
* |     rtsAddr     |  Word - Return address.
* |-----------------|
*

makePdp        Start

TheHandle      equ   DP+2
DP             equ   1

               plx                      ; yank return address
               phd
               tsc
               tcd
               ldy   #2
               lda   [TheHandle],y
               tay
               lda   [TheHandle]
               sta   <TheHandle
               sty   <TheHandle+2
               phx                      ; push back return address
               rts

               End
*-----------------------------------------------------------------------------*
   ��   � S	TITLE.PAKRGS �    ��   � T!Finder.Dats �     ��   � T!FourInA.Row �     ��                                                                                                                                                                                                                                                                                 � � � � h J , t may already be set
	sta	$2000+1,x
	lda	$2000+320,x
	ora	#1
	sta	$2000+320,x
	lda	$2000+480,x
	ora	#1
	sta	$2000+480,x
	lda	$2000+640,x
	ora	#1
	sta	$2000+640,x
	lda	$2000+961,x
	ora	#1
	sta	$2000+961,x
	lda	#$10
	sta	$2000+3,x
	sta	$2000+324,x
	sta	$2000+484,x
	sta	$2000+644,x
	sta	$2000+963,x
	long	M
	phk
	plb
	pla		;keep stack ok
	rts

;................................................................

PlaceInMsg	ds	2
PartOfChar	ds	2
Oval2Make	ds	8
Count	dc	i'2'
TopY	ds	2
ScrollingOff dc	i'-1'
LineStart	ds	2

RowNum	ds	2
OnColor	ds	2

TheText	dosout	500	;504 byte buffer for text...
MsgLen	equ	TheText+2	;actual length of text

ErrText	dosin	'Twilight II is Awesome!   This LED Message module was programmed by Nathan Mates, with special thanks to Jim Maricondo (code), the FTA (more code), Beagle Bros (font), and is dedicated to Ah-Ram Kim...'

CharSet	anop
 dc h'00000000000000000404040400040400'
 dc h'1B1B12120000000000123F12123F1200'
 dc h'083E011E201F080027251708043A2939'
 dc h'0C1E021E01011E0C0303020000000000'
 dc h'0C02010101020C000304080808040300'
 dc h'150E1B0E150000000004041F04040000'
 dc h'00000000000303020000001F00000000'
 dc h'00000000000303000020100804020100'
 dc h'1E31292523211E000605040404040400' ;'0'
 dc h'1F20201E01003F003F10001C20201F00'
 dc h'080C0A003F0808003F001F2020201F00'
 dc h'1008041E21211E003F00100804020100'
 dc h'1E21211E21211E001E21211E08040200'
 dc h'00000303000303000000030300030302'
 dc h'000402010204000000001F001F000000'
 dc h'00010204020100000F10100C04000400'
 dc h'000F101615150E001F2020213F212100'
 dc h'1F20201F21211F003C02010101023C00' ;'@'
 dc h'0F10212121110F003F00003F01013F00'
 dc h'3F00003F010101003C02013901221C00'
 dc h'2121212F212121000700020202020700'
 dc h'1C000808080807002111090509112100'
 dc h'0101010101013F001F21252525252500'
 dc h'1F212121212121001E21212121211E00'
 dc h'1F20201F010101001E2121212121023C' ;'P'
 dc h'1F20201F212121003E01011E20201F00'
 dc h'3F000404040404002121212121213E00'
 dc h'21212112120C0C002525252525213A00'
 dc h'21120C0C0C1221001111110E00040400'
 dc ICON001      I"$FFFF"
             I"$009A"
             I"$000E"
             I"$0016"
		$"0000000000000000000000"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0F000000F0F4F0000000F0"
		$"0F000000000400000000F0"
		$"0F000030004000C00000F0"
		$"0F000000004000000000F0"
		$"0F0000F111F000F00000F0"
		$"0F000000000B00000000F0"
		$"0F0000300000B0C00000F0"
		$"0F00000000000B000000F0"
		$"0F000000F0F0F0000000F0"
		$"0F000000000000000000F0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0000000000000000000000"
		
		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"F00000000000000000000F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F00000000000000000000F"
		$"FFFFFFFFFFFFFFFFFFFFFF"
ICON002      I"$FFFF"
             I"$009A"
             I"$000E"
             I"$0016"
		$"0000000000000000000000"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0F77766000AA00066777F0"
		$"0F77766000AA00066777F0"
		$"0F77700DDD00DDD00777F0"
		$"0F2EEBB000CC000BBEE2F0"
		$"0F100BB88022088BB001F0"
		$"0F100BB88022088BB001F0"
		$"0F2EEBB000CC000BBEE2F0"
		$"0F77700DDD00DDD00777F0"
		$"0F77766000AA00066777F0"
		$"0F77766000AA00066777F0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0000000000000000000000"

		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"F00000000000000000000F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F00000000000000000000F"
		$"FFFFFFFFFFFFFFFFFFFFFF"

ICON003      I"$FFFF"
             I"$009A"
             I"$000E"
             I"$0016"
		$"0000000000000000000000"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0F000000000000000000F0"
		$"0F000000000000000000F0"
		$"0F000000000000000000F0"
		$"0F0F0F00F000F0F00F00F0"
		$"0F0F0F0F0F00F0F0F0F0F0"
		$"0F0FFF0FFF00FFF0FFF0F0"
		$"0F0F0F0F0F00F0F0F0F0F0"
		$"0F0F0F0F0F00F0F0F0F0F0"
		$"0F000000000000000000F0"
		$"0F000000000000000000F0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0000000000000000000000"

		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"F00000000000000000000F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F00000000000000000000F"
		$"FFFFFFFFFFFFFFFFFFFFFF"

ICON004      I"$FFFF"
             I"$009A"
             I"$000E"
             I"$0016"
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
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0000000000000000000000"

		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FF4AFFFFFFFFFFFFFF0F"
		$"F0CCCCCCCCCCCCCCCCCC0F"
		$"F0FFFFFFFFFFFFFFFAFF0F"
		$"F00000000000000000000F",

		$"FFFFFFFFFFFFFFFFFFFFFF"
		$"F00000000000000000000F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F0FFFFFFFFFFFFFFFFFF0F"
		$"F00000000000000000000F"
		$"FFFFFFFFFFFFFFFFFFFFFF"

		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0"
		$"0FFFFFFFFFFFFFFFFFFFF0";


ICON005      I"$FFFF"
             I"$009A"
             I"$000E"
             I"$0016"
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
             $"0FFFFFFFFFFFFFFFFFFFF0"
             $"0000000000000000000000"
             $"FFFFFFFFFFFFFFFFFFFFFF"
             $"F00000000000000000000F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F00000000000000000000F"
             $"FFFFFFFFFFFFFFFFFFFFFF"

ICON006      I"$FFFF"
             I"$009A"
             I"$000E"
             I"$0016"
             $"0000000000000000000000"
             $"0FFFFFFFFFFFFFFFFFFFF0"
             $"0F000000000000000000F0"
             $"0F000000000000000000F0"
             $"0F0F00000FFF000FFF00F0"
             $"0F0F00000F00000F00F0F0"
             $"0F0F00000FF0000F00F0F0"
             $"0F0F00000F00000F00F0F0"
             $"0F0FFF0F0FFF0F0FFF0FF0"
             $"0F000000000000000000F0"
             $"0F000000000000000000F0"
             $"0F000000000000000000F0"
             $"0FFFFFFFFFFFFFFFFFFFF0"
             $"0000000000000000000000"
             $"FFFFFFFFFFFFFFFFFFFFFF"
             $"F00000000000000000000F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F0FFFFFFFFFFFFFFFFFF0F"
             $"F00000000000000000000F"
             $"FFFFFFFFFFFFFFFFFFFFFF"

ICON007      I"$FFFF"
             I"$009A"
             I"$000E"
             I"$0016"
             $"0000000000000000000000"
             $"0FFFFFFFFFFFFFFFFFFFF0"
             $"0F000000000000000000F0"
             $"0F00C000000C0000000CF0"
             $"0F00C00C000CC000000CF0"
             $"0F00C00C000CC00C0CCCF0"
             $"0FCCC00C0CCC000C0CC0F0"
             $"0FCC0CCC0CC0000