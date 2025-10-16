; Loads a BASIC file from memory - used to convert BAS to XEX.
; -----------------------------------------------------------
;
; (c) 2025 DMSC
; Code under MIT license, see LICENSE file.

        .export start

TRAMSZ  = $06
RTCLOK  = $12
SDMCTL  = $22F
HATABS  = $31A
ICCOM   = $342
ICBAL   = $344
ICBAH   = $345
BASICF  = $3F8

CIOV    = $E456
RAMTOP  = $6A
RAMSIZ  = $2E4

CARTCS  = $BFFA
CARTINI = $BFFE
PORTB   = $D301

COPEN   = 3
CCLOSE  = 12

        .code
start:
        ; First, tries to enable BASIC
        lda     #0
        sta     $20
        sta     SDMCTL
        sta     BASICF

        ; Wait for vertical blank to avoid glitches
        lda     RTCLOK+2
:       cmp     RTCLOK+2
        beq     :-

        lda     PORTB
        and     #$FD
        sta     PORTB

        ; Check new RAM size
        lda     #$C0
        tax

chkram: dex
        stx     $21
        eor     ($20),y
        sta     ($20),y
        eor     ($20),y ;  A = 0 (RAM)  A = C0 (ROM)
        bne     chkram

        inx
        stx     RAMSIZ
        stx     RAMTOP

        ; Ok, we now need to reopen E: with original handler
        jsr     CIORE

        ; Search E: handler - assumes that it exists, so
        ; no loop termination is needed.
        ldy     #<HATABS+1-3
        lda     #'E'
srch_e: iny
        iny
        iny
TAB0 = (HATABS&$FF00)
        cmp     TAB0-1,y
        bne     srch_e

        ; Save current handler and store our own
        lda     TAB0,y
        sta     restore_l+1
        sty     restore_l+3
        lda     #<handler_tab
        sta     TAB0,y
        iny
        lda     TAB0,Y
        sta     restore_h+1
        sty     restore_h+3
        lda     #>handler_tab
        sta     TAB0,y

        ; Init cart
        jsr     cart1
        lda     #1
        sta     TRAMSZ
        jmp     (CARTCS)

        ; And exit
cart1:  jmp     (CARTINI)

CIORE:  lda     #CCLOSE
        jsr     CIOE
        lda     #COPEN
        ldx     #<dev_e
        ldy     #>dev_e
CIOA:   stx     ICBAL
        sty     ICBAH
CIOE:   ldx     #0
        sta     ICCOM,x
        jmp     CIOV

.proc   E_GET
ptr:    lda     buffer
        inc     ptr+1
        bne     :+
        inc     ptr+2
:       inc     count
        bne     ret_ok
        inc     count+1
        bne     ret_ok
        ldy     #136
        rts
.endproc

.proc   E_OPEN
        lda     #<prog_start
        sta     E_GET::ptr+1
        lda     #>prog_start
        sta     E_GET::ptr+2
::ret_ok:
        ldy     #1
        rts
.endproc

E_PUT     = ret_ok
E_STATUS  = E_PUT
E_SPECIAL = E_PUT

.proc   E_CLOSE
        ; Restore old handler
        lda     #0
        sta     HATABS
        lda     #0
        sta     HATABS
        ldy     #1
        rts
.endproc
restore_l = E_CLOSE
restore_h = E_CLOSE + 5


handler_tab:
        .addr   E_OPEN-1
        .addr   E_CLOSE-1
        .addr   E_GET-1
        .addr   E_PUT-1
        .addr   E_STATUS-1
        .addr   E_SPECIAL-1

buffer:
        .byte   "?", 34, 125, 34, ":RUN", 34
dev_e:  .byte   "E", $9B
count:
        .word   $FFFF - (count - buffer + prog_size)

        .segment "BAS"
prog_start = *
;        .incbin "test.bas"
prog_size = (* - prog_start)

