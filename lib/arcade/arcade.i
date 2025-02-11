
;; arcade_init(video_mode);
_arcade_init:
  push ix
  ld ix, 0
  add ix, sp
  
  ld a, (ix + 6)
  ld (@mode), a

  call _kbd_init
  ld hl, @cmd
  ld bc, @end - @cmd
  rst.lil $18
  
  push ix
  ld a, __mos_sysvars
  rst.lil $08
  ld (_frame_counter_ptr), ix
  pop ix

  ld sp, ix
  pop ix
  ret
@cmd:
  db 22
@mode:
  db 8
  db 23, 27, 17
  db 23, 0, $c0, 0
  db 23, 1, 0
  db 5
  db 23, 0, $a0, $ff, $ff, 2, 0
@end:


_waitframe:
  ld hl, (_frame_counter_ptr)
  ld a, (hl)
@wait:
  cp (hl)
  jr z, @wait
  call _joystick_read
  ret

_flip:
  ld hl, @cmd
  ld bc ,3
  rst.lil $18
  call _joystick_read
  ret
@cmd:
  db 23, 0, $c3


_frame_counter_ptr:
  dl 0
