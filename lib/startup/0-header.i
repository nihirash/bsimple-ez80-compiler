;; Startup file
  ASSUME ADL=1
  org $40000
  jp _start

__mos_sysvars:      EQU $008

___argc:
  dl 0
___argv:
  dl 0

  align 64
  db "MOS"
  db 0
  db 1

_start:
  push ix
  push iy
  di
  ld (___sp_save), sp
  ei
  
  ld ix, ___argv
  call ___parse_args
  ld a,c
  ld (___argc), a

  ld hl, ___argv
  push hl
  ld hl, (___argc)
  push hl
  call __init_vars
  call _main

_exit:
  di
  ld sp, (___sp_save)
  ei
  pop iy
  pop ix

  ld hl, 0
  ret
___sp_save:
  dl 0

___parse_args:
    call @skip_spaces
    ld bc,0
    ld b, 16
@parse1:
    push bc
    push hl
    call @get_token
    ld a,c
    pop de
    pop bc
    and a
    ret z
    ld (ix+0),de
    push hl
    pop de
    call @skip_spaces
    xor a
    ld (de),a
    inc ix
    inc ix
    inc ix
    inc c
    ld a, c
    cp b
    jr c,@parse1
    ret
@get_token:
    ld c,0
@loop:
    ld a,(hl)
    or a
    ret z

    cp 13
    ret z

    cp 32
    ret z

    inc hl
    inc c
    
    jr @loop
@skip_spaces:
    ld a,(hl)
    cp 32
    ret nz
    inc hl
    jr @skip_spaces


__init_vars:
  push ix
  ld a, __mos_sysvars
  rst.lil $08
  ld (_frame_counter_ptr), ix
  pop ix
  ret

_frame_counter_ptr:
    dl 0
