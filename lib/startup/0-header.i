;; Startup file
  ASSUME ADL=1
  org $40000
  jp _start

  align 64
  db "MOS"
  db 0
  db 1

_start:
  push ix
  push iy

  call _main

  pop iy
  pop ix

  ld hl, 0
  ret
