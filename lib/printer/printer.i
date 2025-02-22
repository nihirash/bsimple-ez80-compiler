_enable_printer:
  ld a, 2
  rst.lil $10
  ret 

_disable_printer:
  ld a, 3
  rst.lil $10
  ret

_printerc:
  push ix
  ld ix, 0
  add ix, sp

  ld a, 1
  rst.lil $10

  ld a, (ix + 6)
  rst.lil $10

  ld sp, ix
  pop ix
  ret
  ret