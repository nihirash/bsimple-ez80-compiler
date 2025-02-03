
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

