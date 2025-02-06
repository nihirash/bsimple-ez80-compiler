
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
_fopen_mode:
	push ix
	ld ix, 0
	add ix, sp
	push de
	ld hl, __file001
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file002
	ld hl, __fa_r
	jp _fopen_mode_end
_file002:
	push de
	ld hl, __file003
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file004
	ld hl, __fa_w
	jp _fopen_mode_end
_file004:
	push de
	ld hl, __file005
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file006
	ld hl, __fa_a
	jp _fopen_mode_end
_file006:
	push de
	ld hl, __file007
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file008
	ld hl, __fa_wx
	jp _fopen_mode_end
_file008:
	push de
	ld hl, __file009
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file00a
	ld hl, __fa_wp
	jp _fopen_mode_end
_file00a:
	push de
	ld hl, __file00b
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file00c
	ld hl, __fa_rp
	jp _fopen_mode_end
_file00c:
	push de
	ld hl, __file00d
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file00e
	ld hl, __fa_ap
	jp _fopen_mode_end
_file00e:
	push de
	ld hl, __file00f
	push hl
	ld hl, (ix+6)
	push hl
	call _strcmp
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, 0
	or a
	sbc hl, de
	jp z, _file010
	ld hl, __fa_wxp
	jp _fopen_mode_end
_file010:
	ld hl, -1
	jp _fopen_mode_end
_fopen_mode_end:
	ld sp, ix
	pop ix
	ret

_fopen:
	push ix
	ld ix, 0
	add ix, sp
	push de
	ld hl, (ix+9)
	push hl
	call _fopen_mode
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld (ix+9), hl
	ld hl, (ix+9)
	ld de, 4294967295
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file011
	ld hl,0
_file011:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file012
	ld hl, 0
	jp _fopen_end
_file012:
	push de
	ld hl, (ix+9)
	push hl
	ld hl, (ix+6)
	push hl
	call _mos_fopen
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	jp _fopen_end
_fopen_end:
	ld sp, ix
	pop ix
	ret

_fprintf:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -6
	add hl, sp
	ld sp, hl

	lea hl, ix+9
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	ld (ix+-3), hl
	lea hl, ix+12
	ld (ix+-6), hl
_file013:
	ld hl, (ix+-3)
	ld de, 0
	or a
	sbc hl, de
	jp z, _file014
	ld hl, (ix+-3)
	ld de, 37
	or a
	sbc hl, de
	ld hl, -1
	jr nz, _file015
	ld hl,0
_file015:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file016
	ld hl, (ix+-3)
	push hl
	ld hl, (ix+6)
	push hl
	call _fputc
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_file016:
	ld hl, (ix+-3)
	ld de, 37
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file017
	ld hl,0
_file017:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file018
	ld hl, (ix+9)
	ld de, 1
	add hl, de
	ld (ix+9), hl
	lea hl, ix+9
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	ld (ix+-3), hl
	ld hl, (ix+-3)
	ld de, 115
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file019
	ld hl,0
_file019:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file01a
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	ld hl, (ix+6)
	push hl
	call _fputs
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_file01a:
	ld hl, (ix+-3)
	ld de, 99
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file01b
	ld hl,0
_file01b:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file01c
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	push hl
	ld hl, (ix+6)
	push hl
	call _fputc
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_file01c:
	ld hl, (ix+-3)
	ld de, 100
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file01d
	ld hl,0
_file01d:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file01e
	ld hl, 10
	push hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	ld hl, (ix+6)
	push hl
	call _fprintn
	ex de,hl
	ld hl, 9
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_file01e:
	ld hl, (ix+-3)
	ld de, 111
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file01f
	ld hl,0
_file01f:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file020
	ld hl, 8
	push hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	ld hl, (ix+6)
	push hl
	call _fprintn
	ex de,hl
	ld hl, 9
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_file020:
	ld hl, (ix+-3)
	ld de, 98
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file021
	ld hl,0
_file021:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file022
	ld hl, 2
	push hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	ld hl, (ix+6)
	push hl
	call _fprintn
	ex de,hl
	ld hl, 9
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_file022:
	ld hl, (ix+-3)
	ld de, 120
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file023
	ld hl,0
_file023:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file024
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	ld hl, (ix+6)
	push hl
	call _fprintx
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_file024:
	ld hl, (ix+-3)
	ld de, 37
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file025
	ld hl,0
_file025:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file026
	ld hl, 37
	push hl
	ld hl, (ix+6)
	push hl
	call _fputc
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_file026:
_file018:
	ld hl, (ix+9)
	ld de, 1
	add hl, de
	ld (ix+9), hl
	lea hl, ix+9
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	ld (ix+-3), hl
	jp _file013
_file014:
_fprintf_end:
	ld sp, ix
	pop ix
	ret

_fprintn:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -3
	add hl, sp
	ld sp, hl

	ld hl, (ix+9)
	ld de, 16
	or a
	sbc hl, de
	ld hl, -1
	jr z, _file027
	ld hl,0
_file027:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file028
	push de
	ld hl, (ix+9)
	push hl
	ld hl, (ix+6)
	push hl
	call _fprintx
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	jp _fprintn_end
_file028:
	ld hl, (ix+9)
	ld de, 0
	call __cmp
	ld hl, 0
	jp p, _file029
	ld hl, -1
_file029:
	ld de, 0
	or a
	sbc hl, de
	jp z, _file02a
	push de
	ld hl, (ix+9)
	push hl
	call _neg
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld (ix+9), hl
	ld hl, 45
	push hl
	ld hl, (ix+6)
	push hl
	call _fputc
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_file02a:
	ld hl, (ix+9)
	ld de, (ix+12)
	call __div
	ld (ix+-3), hl
	ld hl, (ix+-3)
	ld de, 0
	or a
	sbc hl, de
	jp z, _file02b
	ld hl, (ix+12)
	push hl
	ld hl, (ix+-3)
	push hl
	ld hl, (ix+6)
	push hl
	call _fprintn
	ex de,hl
	ld hl, 9
	add hl, sp
	ld sp, hl
	ex de,hl
_file02b:
	ld hl, (ix+9)
	ld de, (ix+12)
	call __mod
	ld de, 48
	add hl, de
	push hl
	ld hl, (ix+6)
	push hl
	call _fputc
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_fprintn_end:
	ld sp, ix
	pop ix
	ret

_fprintx:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -6
	add hl, sp
	ld sp, hl

	ld hl, __file02c
	ld (ix+-6), hl
	push de
	ld hl, 16
	push hl
	ld hl, (ix+9)
	push hl
	call _udiv
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld (ix+-3), hl
	ld hl, (ix+-3)
	ld de, 0
	or a
	sbc hl, de
	jp z, _file02d
	ld hl, (ix+-3)
	push hl
	ld hl, (ix+6)
	push hl
	call _fprintx
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_file02d:
	ld hl, (ix+9)
	ld de, 15
	call __and
	ld de, (ix+-6)
	add hl, de
	ld (ix+-6), hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	ld hl, (ix+6)
	push hl
	call _fputc
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_fprintx_end:
	ld sp, ix
	pop ix
	ret
__file001:	db "r", 0
__file003:	db "w", 0
__file005:	db "a", 0
__file007:	db "wx", 0
__file009:	db "w+", 0
__file00b:	db "r+", 0
__file00d:	db "a+", 0
__file00f:	db "w+x", 0
__file02c:	db "0123456789ABCDEF", 0
