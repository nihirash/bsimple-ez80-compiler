
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
