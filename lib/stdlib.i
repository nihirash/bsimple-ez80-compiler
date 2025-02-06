

__mos_getkey:       EQU	$000
__mos_load:         EQU $001
__mos_save:         EQU $002
__mos_sysvars:      EQU $008
__mos_editline:     EQU $009
__mos_getError:     EQU $00F
__mos_oscli:        EQU $010
__mos_getrtc:       EQU $012
__mos_setrtc:       EQU $013
__mos_setintvector: EQU $014
__mos_uopen:        EQU $015
__mos_uclose:       EQU $016
__mos_ugetc:        EQU $017
__mos_uputc:        EQU $018
__mos_setkbvector:  EQU $01D
__mos_getkbmap:     EQU $01E
__mos_i2c_open:     EQU $01F
__mos_i2c_close:    EQU $020
__mos_i2c_write:    EQU $021
__mos_i2c_read:     EQU $022


_readline:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld bc, (ix + 9)
  ld e, %101
  ld a, __mos_editline
  rst.lil $08

  or a 
  sbc hl, hl

  ld l, a
  
  ld sp, ix
  pop ix
  ret

_exec:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld a, __mos_oscli
  rst.lil $08

  or a 
  sbc hl, hl

  ld l, a
  
  ld sp, ix
  pop ix
  ret
;; Compare strings
_strcmp:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld de, (ix + 9)
@loop:
  ld	a, (de)
	or	a, a
	jr	z, @done
	cpi
	inc	de
	jr	z, @loop

	dec	hl
@done:
	sub	(hl)
  ld hl, -1
  jr z, @x

  ld hl, 0
@x:
  ld sp, ix
  pop ix
	ret


;; VDP routines
_cls:
  ld a, 12
  rst.lil $10
  ret

_gotoxy:
  push ix
  ld ix, 0
  add ix, sp

  ld a, 31
  rst.lil $10

  ld a, (ix + 6)
  rst.lil $10

  ld a, (ix + 9)
  rst.lil $10

  ld sp, ix
  pop ix
  ret

_vdp_mode:
  push ix
  ld ix, 0
  add ix, sp

  ld a, 22
  rst.lil $10

  ld a, (ix + 6)
  rst.lil $10

  ld sp, ix
  pop ix
  ret

_set_cursor_mode:
  push ix
  ld ix, 0
  add ix, sp

  ld a, 23
  rst.lil $10

  ld a, 1
  rst.lil $10

  ld a, (ix + 6)
  rst.lil $10

  ld sp, ix
  pop ix
  ret

_use_text_cursor:
  ld a, 4
  rst.lil $10
  ret

_use_graphics_cursor:
  ld a, 5
  rst.lil $10
  ret

_beep:
  ld a, 7
  rst.lil $10
  ret
