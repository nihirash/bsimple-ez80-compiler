;; MOS calls wrappers

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

  xor a
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
  ld a, 9
  rst.lil $08

  or a 
  sbc hl, hl

  ld l, a
  
  ld sp, ix
  pop ix
  ret
