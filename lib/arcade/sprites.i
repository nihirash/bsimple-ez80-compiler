
_sprite_select:
  push ix
  ld ix, 0
  add ix, sp

  ld a, (ix + 6)
  ld (@sprite), a
  
  ld hl, @cmd
  ld bc, 4
  xor a
  rst.lil $18
    
  ld sp, ix
  pop ix
  ret
@cmd:
    db 23, 27, 4
@sprite:
    db 0

_sprite_clear:
  ld a, 23
  rst.lil $10
  ld a, 27
  rst.lil $10
  ld a, 5
  rst.lil $10
  ret

_sprite_add_bitmap:
  push ix
  ld ix, 0
  add ix, sp  
  
  ld hl, (ix + 6)
  ld (@bmp), hl

  ld hl, @cmd
  ld bc, 5
  rst.lil $18
  
  ld sp, ix
  pop ix
  ret
@cmd:
    db 23, 27, $26
@bmp:
    dl 0

_sprites_activate:
  push ix
  ld ix, 0
  add ix, sp  
  
  ld a, (ix + 6)
  ld (@cnt), a

  ld hl, @cmd
  ld bc, 4
  rst.lil $18
  
  ld sp, ix
  pop ix
  ret
@cmd:
    db 23, 27, 7
@cnt:
    db 0

_sprite_next_frame:
  ld a, 23
  rst.lil $10
  ld a, 27
  rst.lil $10
  ld a, 8
  rst.lil $10
  ret

_sprite_prev_frame:
  ld a, 23
  rst.lil $10
  ld a, 27
  rst.lil $10
  ld a, 9
  rst.lil $10
  ret

_sprite_frame_select:
  push ix
  ld ix, 0
  add ix, sp  
  
  ld a, (ix + 6)
  ld (@cnt), a

  ld hl, @cmd
  ld bc, 4
  rst.lil $18
  
  ld sp, ix
  pop ix
  ret
@cmd:
    db 23, 27, 10
@cnt:
    db 0

_sprite_show:
  ld a, 23
  rst.lil $10

  ld a, 27
  rst.lil $10

  ld a, 11
  rst.lil $10
  ret

_sprite_hide:
  ld a, 23
  rst.lil $10
  ld a, 27
  rst.lil $10
  ld a, 12
  rst.lil $10
  ret

_sprite_position:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld a, l
  ld (@x), a
  ld a, h
  ld (@x + 1), a

  ld hl, (ix + 9)
  ld a, l
  ld (@y), a
  ld a, h
  ld (@y + 1), a

  ld hl, @cmd
  ld bc, @end - @cmd
  rst.lil $18

  ld sp, ix
  pop ix
  ret
@cmd:
  db 23, 27, 13
@x:
  dw 0
@y:
  dw 0
@end:

_sprite_move:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld a, l
  ld (@x), a
  ld a, h
  ld (@x + 1), a

  ld hl, (ix + 9)
  ld a, l
  ld (@y), a
  ld a, h
  ld (@y + 1), a

  ld hl, @cmd
  ld bc, @end - @cmd
  rst.lil $18

  ld sp, ix
  pop ix
  ret
@cmd:
  db 23, 27, 14
@x:
  dw 0
@y:
  dw 0
@end:

_sprites_update:
  ld a, 23
  rst.lil $10
  ld a, 27
  rst.lil $10
  ld a, 15
  rst.lil $10
  ret

_sprites_bmp_reset:
  ld a, 23
  rst.lil $10
  ld a, 27
  rst.lil $10
  ld a, 16
  rst.lil $10
  ret

_sprites_reset:
  ld a, 23
  rst.lil $10
  ld a, 27
  rst.lil $10
  ld a, 17
  rst.lil $10
  ret

