h'3F00100804023F000F0101010101010F'
 dc h'00010204081020000F0808080808080F'
 dc h'0000040A11000000000000000000007F'
 dc h'0303020000000000 00003E2121212600' ;'`a'
 dc h'01011D2121211F0000003E0101013E00'
 dc h'20202E2121213E0000003E1109013E00'
 dc h'0E01010F0101010000001E212126201F'
 dc h'01011D21212121000400040404040400' ;'hi'
 dc h'04000404040404030101110907091100'
 dc h'040404040404040000001B2525252500'
 dc h'00001F212121210000001E2121211E00'
 dc h'00001F2121211D0100003E2121212E20'
 dc h'00001C020202020000003E011E201F00' ;'rs'
 dc h'01010F0101010E000000212121211E00'
 dc h'00001111110A04000000252525253A00'
 dc h'0000110A040A11000000192122140807'
 dc h'00003F100C023F000000000000000001'

Colors	anop
 dc i'$F00,$F10,$F20,$F30,$F40,$F50,$F60,$F70,$F80,$F90,$FA0,$FB0,$FC0,$FD0,$FE0'
 dc i'$FF0,$EF0,$DF0,$CF0,$BF0,$AF0,$9F0,$8F0,$7F0,$6F0,$5F0,$4F0,$3F0,$2F0,$1F0'
 dc i'$0F0,$0F1,$0F2,$0F3,$0F4,$0F5,$0F6,$0F7,$0F8,$0F9,$0FA,$0FB,$0FC,$0FD,$0FE'
 dc i'$0FF,$0EF,$0DF,$0CF,$0BF,$0AF,$09F,$08F,$07F,$06F,$05F,$04F,$03F,$02F,$01F'
 dc i'$00F,$10F,$20F,$30F,$40F,$50F,$60F,$70F,$80F,$90F,$A0F,$B0F,$C0F,$D0F,$E0F'
 dc i'$F0F,$F0E,$F0D,$F0C,$F0B,$F0A,$F09,$F08,$F07,$F06,$F05,$F04,$F03,$F02,$F01'
ColorsLen	equ	*-Colors

*
*
Setup	anop
*
* Handle the Setup and all. Entry: Accum=T2Message
*
*
	cmp	#MakeT2
	beq	doMake
	cmp	#HitT2
	jeq	doHit
*	cmp	#KillT2
*	jeq	doKill
	cmp	#SaveT2
	jeq	doSave
	cmp	#LoadSetupT2
	jeq	doLoadSetup
*	cmp	#UnloadSetupT2
*	jeq	doUnloadSetup
	brl	Done

*=================================================
*
*	Create	all	the	buttons	in	the	window
*
doMake	anop

	lda	T2data1+2
	sta	WindPtr+2
	lda	T2data1
	sta	WindPtr
	lda	T2data2
	sta	RezFileID
	WordResult
	_MMStartUp
	PullWord	MyID

	LongResult
	PushLong	WindPtr
	PushWord	#9	;resource 2 resource
	PushLong	#1	;resource item ID=1
	_NewControl2
	plx
	plx		;chuck result out

* Make sure we're dealing with the T2pref file.

	WordResult
	_GetCurResourceFile
	PushWord	RezFileID
	_SetCurResourceFile

	jsr	load_setup

noShapes1	anop
MoveOn	_SetCurResourceFile

	PushWord	#%011	;ptr to gs/os output string
	PushLong	#TheText
	PushWord	#0	;upper word of length
	PushWord	MsgLen	;length of block
	PushWord	#0	;ptr to TEFormat...
	PushLong	#0	;nil ptr

	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	_TESetText

	lda	#4
	sta	T2Result
	brl	Bye

*=================================================



temp	ds	4

rDClockPrefs	str	'LedMsg: Text'

* Format: Upper byte=clock type (ignored for now)
*                   0=DClock; 1= AClock; 2=Random on Entry
*         Lower byte=Refreshes between movement...

*=================================================
doLoadSetup	anop

	jsr	load_setup
	brl	Bye

load_setup	anop

*	Load	the	fps/maxzoom/delay	resource.

	LongResult
	Pushword	#rC1OutputString ;type
	PushLong	#rDClockPrefs
	_RMLoadNamedResource
	bcc	PrefsThere
	plx
	plx		;setup not saved yet...

	ldx	ErrText	;length word
	inx
	inx		;length of whole thing
CopyErr2	lda	ErrText,x
	sta	MsgLen,x
	dex                   ;could be odd length
	bpl	CopyErr2
	bra	NoPrefs

PrefsThere	anop
	makePdp
	ldy	#504
GetText	lda	[3],y
	sta	TheText,y
	dey
	dey
	bpl	GetText
	killLdp
	mov	#500,TheText	;buffer size
	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	MakePdp
	ldy	#$10
	lda	[3],y
            and	#%1111111110111111
	sta	[3],y	;mark saved
	killLdp

	PushWord	#3	;purge levek
	PushWord	#rC1OutputString	;rtype for release

	LongResult
	PushWord	#rC1OutputString
	PushLong	#rDClockPrefs
	PushLong	#Temp	;don't care about filenum, but toolbox does
	_RMFindNamedResource	;get it
	_ReleaseResource	;and throw it out. We have a copy now :)

NoPrefs	rts

*=================================================
doSave	anop

	WordResult
	_GetCurResourceFile
	PushWord	RezFileID
	_SetCurResourceFile

	LongResult
	PushWord	#%011	;ptr to gs/os output string
	PushLong	#TheText
	PushLong	#500	;length of buffer size
	PushWord	#0	;ptr to TEFormat...
	PushLong	#0	;nil ptr

	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	lda	3,s	;duplicate handle
	pha
	lda	3,s
	pha
	_TECompactRecord

	_TEGetText
	pla
	pla		;throw away result

            LongResult
            PushWord	#rC1OutputString
	PushLong	#rDClockPrefs
	_RMLoadNamedResource
	jcc	HavePrefs
	plx
	plx

	LongResult
	PushLong	#506	;length of block in bytes
	WordResult
	_GetCurResourceApp
	PushWord	#attrNoCross+attrNoSpec
	phd
	phd
	_NewHandle
	lda	1,s
	sta	temp
	lda	1+2,s
	sta	temp+2
	mov	#500,TheText	;buffer size

	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	_TECompactRecord

	makePdp
	ldy	#504
SaveText	lda	TheText,y
	sta	[3],y
	dey
	dey
	bpl	SaveText
	killLdp

	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	MakePdp
	ldy	#$10
	lda	[3],y
            and	#%1111111110111111
	sta	[3],y	;mark saved
	killLdp

	PushLong	temp		;handle
	PushWord	#attrNoSpec+attrNoCross	;attr
	PushWord	#rC1OutputString	;rtype
	LongResult
	PushWord	#$FFFF
	PushWord	#rC1OutputString
	_UniqueResourceID
	lda	1,s
	sta	temp
	lda	1+2,s
	sta	temp+2
	_AddResource

	PushWord	#rC1OutputString	;rType
	PushLong	temp		;rID
	PushLong	#rDClockPrefs	;ptr to name str
	_RMSetResourceName
	brl	created1

HavePrefs	anop
	makePdp

	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	_TECompactRecord

	mov	#500,TheText	;buffer size
	ldy	#504
SaveText2	lda	TheText,y
	sta	[3],y
	dey
	dey
	bpl	SaveText2
	killLdp
	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	MakePdp
	ldy	#$10
	lda	[3],y
            and	#%1111111110111111
	sta	[3],y	;mark saved
	killLdp

	PushWord	#TRUE	;changeflag:	true
	PushWord	#rC1OutputString	;rtype

	LongResult
	PushWord	#rC1OutputString
	PushLong	#rDClockPrefs
	PushLong	#Temp	;don't care about filenum, but toolbox does
	_RMFindNamedResource	;get it
	_MarkResourceChange

created1	anop
            PushWord	RezFileID
	_UpdateResourceFile
	_SetCurResourceFile
	brl	Bye

*=================================================
*	Hit
*
*	handle	item	hits

doHit	anop

	stz	T2Result+2
	stz	T2Result	;assume nothing hit
	lda	T2data2+2	;ctlID hi word must be zero
	bne	nothingHit
	lda	T2data2	;get ctlID
	cmp	#1
	beq	enable	;branch if was 1 (TE Control)
nothingHit	brl	Bye

enable	anop
	LongResult
	PushLong	WindPtr
	PushLong	#1	;TE Control ID
	_GetCtlHandleFromID
	MakePdp
	ldy	#$10
	lda	[3],y
	pld
	plx
	plx		;keep a-reg intact
	and	#$40	;dirty bit: has it changed?
	beq	NothingHit
	lda	#TRUE
	sta	T2Result
	bra	nothingHit


MyID	ds	2
WindPtr	ds	4
RezFileID	ds	2



	end
                                                       �L � � =	random
*	else,	=	shape	+	2	(so	shape	1	would	=	3)

ImpulseShapes	ds	2

temp	ds	4

rImpulseFlag	str	'Impulse:	Flags'
rImpulseShapes	str	'Impulse:	Shapes'
*=================================================
doLoadSetup	=	*

	jsr	load_setup
	brl	Bye

load_setup	=	*

*	Load	the	fps/maxzoom/delay	resource.

	~RMLoadNamedResource	#rT2ModuleWord;#rImpulseFlag
	bcc	:flagThere
	plx
	plx	;setup	not	saved	yet...
	lda	#$0200	;	20	second	delay,	no	fps,	no	large	shapes
	sta	ImpulseFlag
	bra	:noFlag

:flagThere
	jsr	make#include "types.rez"
#include "t2common.rez"

// --- Flags resource

resource rT2ModuleFlags (moduleFlags) {
	fFadeOut+fFadeIn+fGrafPort320+fSetup,	// module flags word
	$01,						// enabled flag (unimplemented)
	$0110,					// minimum T2 version required
	NIL,						// reserved
	"L.E.D. Message"				// module name
};

// --- About text resource

resource rTextForLETextBox2 (moduleMessage) {
	TBLeftJust
	TBBackColor TBColorF
	TBForeColor TBColor1
	"L.E.D. Message"
	TBForeColor TBColor0
	" scrolls a message of your choice across the screen.\n"
	TBForeColor TBColor4
	"Written by Nathan Mates, dedicated to Ah-Ram Kim."
};

// --- Version resource

resource rVersion (moduleVersion) {
       {1,0,0,final,2},             // Version
       verUS,                         // US Version
       "T2 L.E.D. Message Module",     // program's name
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
		$"0F040000044400044400F0"
		$"0F040000040000040040F0"
		$"0F040000044000040040F0"
		$"0F040000040000040040F0"
		$"0F044404044404044404F0"
		$"0F000000000000000000F0"
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

resource rControlList (0x00000001) {{
 0x00000001,  /* control resource id */
 0x00000002,  /* control resource id */
 3,  		// Icon //
 4,		// Descriptor string //
};
};

resource rControlTemplate (0x00000001) {
 0x00000001,  /* control id */ 
{0x0040,0x000C,0x007C,0x0154},  /* control rectangle */
    editTextControl{{  /* control type */
 0x0000,  /* flags */
 0x7400,  /* more flags */
 0,        /* ref con */
 0x42800000,      /* TE text flags */
 {0xFFFF,0xFFFF,0xFFFF,0xFFFF}, /* indent rect, standard */
 0xFFFFFFFF,       /* TE vert scroll */
 0,       /* te vert movement */                
 0,      /* MUST BE NUL version 1.0 */
 0,        /* MUST BE NUL version 1.0 */
 0,       /* style ref */
 0,        /* text descriptor */
 0,       /* text ref */ 
 0,       /* text length */
 0,        /* maximum characters */
 0,      /* MUST BE NUL version 1.0 */
 0,        /* MUST BE NUL version 1.0 */
 0,        /* MUST BE NUL version 1.0 */
 0,      /* color table */
 0x0000,        /* drawing mode */
 0        /* filter proc */
}};
};


resource rControlTemplate (0x00000002) {
 0x00000002,  /* control id */ 
{0x0032,0x000A,0x003F,0x0085},  /* control rectangle */
    statTextControl{{  /* control type */
 0x0000,  /* flags */
 0x1002,  /* more flags */
 0,        /* ref con */
 0x00000003,   /* text reference */
 0x0010,   /* text length */
 0x0008 /* text justification  not currently implemented (sys 5.0.2) */
}};
};


resource rTextForLETextBox2 (0x00000003){
 "Text to display:"
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
		{ 32,142, 42,350},		// rect
		statTextControl {{
			$0000,			// flag
			$1002,			// moreFlags
			$00000000,			// refCon
			1			//txtref...
		}};
};

resource rTextForL