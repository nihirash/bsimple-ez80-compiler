_vsync:
  ld a, 23
  rst.lil $10
  xor a
  rst.lil $10
  ld a, $c3
  rst.lil $10
  ret

_agi_load:
  push ix
  ld ix, 0
  add ix, sp

  ld bc, (ix + 6)
  ld hl, (ix + 9)
  call agon_image_load_from_file
  
  or a
  sbc hl, hl 
  ld l, a
  
  ld sp, ix
  pop ix
  ret

_bitmap_draw:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  
  ld a, l
  ld (@img_number), a
  ld a, h
  ld (@img_number + 1), a


  ld hl, (ix + 9)
  ld a, l
  ld (@x), a
  ld a, h
  ld (@x + 1), a

  ld hl, (ix + 12)
  ld a, l
  ld (@y), a
  ld a, h
  ld (@y + 1), a

  ld hl, @select_cmd
  ld bc, @end - @select_cmd
  rst.lil $18

  ld sp, ix
  pop ix
  ret
@select_cmd:
  db 23, 27, 32
@img_number:
  dw  0
@draw_bitmap:
  db 23, 27, 3
@x:
  dw 0
@y:
  dw 0
@end:

