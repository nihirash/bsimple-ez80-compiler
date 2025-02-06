
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

_str2cmp:
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