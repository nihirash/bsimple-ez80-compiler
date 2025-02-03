
;; MOS calls wrappers
__fa_r:   EQU $01
__fa_rp:  EQU $03
__fa_w:   EQU $0a
__fa_wp:  EQU $0b
__fa_a:   EQU $32
__fa_ap:  EQU $33
__fa_wx:  EQU $06
__fa_wxp: EQU $07

__mos_cd:           EQU $003
__mos_dir:          EQU $004
__mos_del:          EQU $005
__mos_ren:          EQU $006
__mos_mkdir:        EQU $007
__mos_fopen:        EQU $00A
__mos_fclose:       EQU $00B
__mos_fgetc:        EQU $00C
__mos_fputc:        EQU $00D
__mos_feof:         EQU $00E
__mos_copy:         EQU $011
__mos_getfil:       EQU $019
__mos_fread:        EQU $01A
__mos_fwrite:       EQU $01B
__mos_flseek:       EQU $01C

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
  ld a, __mos_del
  jr __mos_hl_call

_cwd:
  ld a, __mos_cd
  jr __mos_hl_call

_mkdir:
  ld a, __mos_mkdir
__mos_hl_call:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)

  rst.lil $08

  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret

_frename:
  ld a, __mos_ren
  jr __mos_hlde_call
_fcopy:
  ld a, __mos_copy
__mos_hlde_call:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld de, (ix + 9)
  rst.lil $08

  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret

_fread:
  ld a, __mos_fread
  jr __fread_write
_fwrite:
  ld a, __mos_fwrite
__fread_write:
  push ix
  ld ix, 0
  add ix, sp
  ld c,  (ix + 6)
  ld hl, (ix + 9)
  ld de, (ix + 12)
  rst.lil $08
  ex de, hl

  ld sp, ix
  pop ix
  ret

_flseek_ext:
  push ix
  ld ix, 0
  add ix, sp
  ld de, (ix + 12)
  jr __flseek1
_flseek:
  push ix
  ld ix, 0
  add ix, sp

  ld e, 0

__flseek1:
  ld c,  (ix + 6)
  ld hl, (ix + 9)
  ld a, __mos_flseek
  rst.lil $08
  
  or a
  sbc hl, hl
  ld l, a

  ld sp, ix
  pop ix
  ret