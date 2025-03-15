;; Sleep frames
;; 1/60 of second in most video modes
_sleepf:
    push ix
    ld ix, 0
    add ix, sp

    ld hl, (ix + 6)
    ld de, 0
    sbc hl, de
    jr z, @exit
@loop:
    ex de, hl

    ld hl, (_frame_counter_ptr)
    ld a, (hl)
@wait:
    cp (hl)
    jr z, @wait

    ex de, hl
    ld de, 1
    or a 
    sbc hl, de
    jr nz, @loop
@exit:
    ld sp, ix
    pop ix
    ret
