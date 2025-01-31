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

_printer_putc:
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

_printer_puts:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
@loop:
  ld a, (hl)
  and a
  jr z, @exit
  push hl
  ex af, af
  ld a, 1
  rst.lil $10
  ex af, af
  rst.lil $10
  pop hl
  inc hl
  jr @loop
@exit:
  ld sp, ix
  pop ix
  ret

_printer_enable:
  ld a, 2
  rst.lil $10
  ret

_printer_disable:
  ld a, 3
  rst.lil $10
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