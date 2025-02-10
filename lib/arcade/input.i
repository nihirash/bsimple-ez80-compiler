

__PC_DR:    EQU $9E
__PD_DR:    EQU $A2

__joystick_state:
    db 0

__kbmap_addr:
    dl 0

_joystick_enabled:
    dl 0

;; Based on Christian Pinder's code from ChuckieEgg
_joystick_read:
    ld b, 0
    in0 a, (__PD_DR)
    cpl
    add a, a 
    rl b
    add a, a
    add a, a
    rl b

    in0 a, (__PC_DR)
    cpl
    rra
    rra
    rl b
    rra 
    rra
    rl b
    rra 
    rra
    rl b
    rra
    rra
    rl b
    ld a, b
    ld (__joystick_state), a
    ret

_kbd_init:
    push ix
    ld a, __mos_getkbmap
    rst.lil $08
    ld (__kbmap_addr), ix
    pop ix
    ret
