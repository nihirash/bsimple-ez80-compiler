;; MOS calls wrappers
__fa_r:   EQU $01
__fa_rp:  EQU $03
__fa_w:   EQU $0a
__fa_wp:  EQU $0b
__fa_a:   EQU $32
__fa_ap:  EQU $33
__fa_wx:  EQU $06
__fa_wxp: EQU $07

__mos_getkey:       EQU	$000
__mos_load:         EQU $001
__mos_save:         EQU $002
__mos_cd:           EQU $003
__mos_dir:          EQU $004
__mos_del:          EQU $005
__mos_ren:          EQU $006
__mos_mkdir:        EQU $007
__mos_sysvars:      EQU $008
__mos_editline:     EQU $009
__mos_fopen:        EQU $00A
__mos_fclose:       EQU $00B
__mos_fgetc:        EQU $00C
__mos_fputc:        EQU $00D
__mos_feof:         EQU $00E
__mos_getError:     EQU $00F
__mos_oscli:        EQU $010
__mos_copy:         EQU $011
__mos_getrtc:       EQU $012
__mos_setrtc:       EQU $013
__mos_setintvector: EQU $014
__mos_uopen:        EQU $015
__mos_uclose:       EQU $016
__mos_ugetc:        EQU $017
__mos_uputc:        EQU $018
__mos_getfil:       EQU $019
__mos_fread:        EQU $01A
__mos_fwrite:       EQU $01B
__mos_flseek:       EQU $01C
__mos_setkbvector:  EQU $01D
__mos_getkbmap:     EQU $01E
__mos_i2c_open:     EQU $01F
__mos_i2c_close:    EQU $020
__mos_i2c_write:    EQU $021
__mos_i2c_read:     EQU $022


_putc:
  push ix
  ld ix, 0
  add ix, sp

  ld a, (ix + 6)
  rst.lil $10

  ld sp, ix
  pop ix
  ret

_puts:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld bc, 0
  xor a
  rst.lil $18

  ld sp, ix
  pop ix
  ret

_getc:
  push ix
  ld ix, 0
  add ix, sp

  xor a       ;; mos_getkey = 0
  rst.lil $08

  or a 
  sbc hl, hl

  ld l, a
  
  ld sp, ix
  pop ix
  ret

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

_mos_fopen:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld c, (ix + 9)
  ld a, __mos_fopen
  rst.lil $08

  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret

_fclose:
_mos_fclose:
  push ix
  ld ix, 0
  add ix, sp
  
  ld c, (ix + 6)
  ld a, __mos_fclose
  rst.lil $08

  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret

_fputc:
  push ix
  ld ix, 0
  add ix, sp

  ld c, (ix + 6)
  ld b, (ix + 9)
  ld a, __mos_fputc
  rst.lil $08

  ld sp, ix
  pop ix
  ret

_fputs:
  push ix
  ld ix, 0
  add ix, sp

  ld c, (ix + 6)
  ld hl, (ix + 9)
@loop:
  ld a, (hl)
  and a
  jr z, @exit

  ld b, a
  ld a, __mos_fputc
  rst.lil $08
  
  inc hl
  jr @loop

@exit:
  ld sp, ix
  pop ix
  ret

_fgetc:
  push ix
  ld ix, 0
  add ix, sp

  ld c, (ix + 6)
  ld a, __mos_fgetc
  rst.lil $08

  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret

_feof:
  push ix
  ld ix, 0
  add ix, sp

  ld c, (ix + 6)
  ld a, __mos_feof
  rst.lil $08

  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret

_delete:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld a, __mos_del
  rst.lil $08

  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret