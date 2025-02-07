

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

_strstarts:
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
  ld hl, 0
  jr @x
@done:
  ld hl, -1
@x:
  ld sp, ix
  pop ix
	ret

_strcpy:
  push ix
  ld ix, 0
  add ix, sp
  ld de, (ix + 6)
  ld hl, (ix + 9)
@loop:
  ld a, (hl)
  ldi
  and a
  jr z, @x
  jr @loop
@x:
  ld sp, ix
  pop ix
	ret


_strlen:
  ld hl, 3
  add hl, sp
  ld hl, (hl)
  ld bc, 0
  xor a
  cpir
  or a
  sbc hl, hl
  scf
  sbc hl, bc
  ret

_strcat:
  push ix
  ld ix, 0
  add ix, sp
; Looking for string end
  xor a
  ld bc, 0
  ld hl, (ix + 6)
  cpir
; we're just after 0x00 byte
  dec hl
  ld de, (ix + 9)
  ex de, hl
@cp_lp:
  ld a, (hl)
  ldi
  and a
  jr z, @x
  jr @cp_lp
@x:
  ld sp, ix
  pop ix
  ret

_strchr:
  ld hl, 3
  add hl, sp
  ld hl, (hl)
  ld bc, 0
  xor a
  cpir
  or a
  sbc hl, hl
  scf
  sbc hl, bc
  push hl
  pop bc
  
  ld hl, 6
  add hl, sp
  ld a, (hl)
  dec hl
  dec hl
  dec hl
  ld hl, (hl)
  cpir
  dec hl
  ret z

  or a
  sbc hl, hl
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

_strstr:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -9
	add hl, sp
	ld sp, hl

	push de
	ld hl, (ix+9)
	push hl
	call _strlen
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld (ix+-9), hl
	ld hl, (ix+6)
	ld (ix+-6), hl
	ld hl, (ix+-6)
	push hl
	ld hl, (ix+6)
	push hl
	call _strlen
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	ex de, hl
	pop hl
	add hl, de
	ld de, (ix+-9)
	or a
	sbc hl,de
	ld (ix+-3), hl
_strings001:
	ld hl, (ix+-6)
	ld de, (ix+-3)
	call __cmp
	ld hl, 0
	jp p, _strings002
	ld hl, -1
_strings002:
	ld de, 0
	or a
	sbc hl, de
	jp z, _strings003
	push de
	ld hl, (ix+9)
	push hl
	ld hl, (ix+-6)
	push hl
	call _strstarts
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _strings004
	ld hl, (ix+-6)
	jp _strstr_end
_strings004:
	ld hl, (ix+-6)
	ld de, 1
	add hl, de
	ld (ix+-6), hl
	jp _strings001
_strings003:
	ld hl, 0
	jp _strstr_end
_strstr_end:
	ld sp, ix
	pop ix
	ret
