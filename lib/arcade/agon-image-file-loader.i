;; Agon Image Format loader(from FILE)
;; ========================
;; (c) 2024 Aleksandr Sharikhin
;;
;; Use for good of all beings

;; Extracts image from ram to VDP buffer
;; BC - buffer number
;; HL - pointer to filename
agon_image_load_from_file:
;; Store buffer ID to vars
    ld a, c
    ld (@buff), a
    ld (@buff1), a
    ld (@bmid), a
    ld (@decompress_buff), a
    ld (@source_buff), a
    ld a, b
    ld (@buff + 1), a
    ld (@buff1 + 1), a
    ld (@bmid + 1), a
    ld (@decompress_buff + 1), a
    ld (@source_buff + 1), a

    ld c, 01 ; MOS_FA_READ
    ld a, __mos_fopen
    rst.lil $08
    or a
    jp z, @fopen_err

    ld (@fp + 1), a

;; check header
    call @fgetc
    cp 'I'
    jp nz, @format_err

    call @fgetc
    cp 'M'
    jp nz, @format_err

;; Copy raw data lenght to command
    call @fgetc
    ld (@len), a
    ld (@notpacked+1), a

    call @fgetc
    ld (@len + 1), a
    ld (@notpacked+2), a

;; Send command that will await bytes of RGB2222 image
    ld hl, @cmd1
    ld bc, @cmd1_end - @cmd1
    rst.lil $18
    
;; Storing pixel size of image(Width/height)
    ld de, @iw
    call @fgetc
    ld (de), a
    inc de
    call @fgetc
    ld (de), a
    inc de
    call @fgetc
    ld (de), a
    inc de
    call @fgetc
    ld (de), a

;; Is our image RLE encoded?
    call @fgetc
    and a
    jp z, @notpacked
    ;; Packed
    
    cp 2
    jp z, @turbo_packed

;; Packed words count
    call @fgetc
    ld c, a
    call @fgetc
    ld b, a

@unpack_loop:
    push bc
;; How many copies of byte
    call @fgetc
    ld b, a
    call @fgetc
;; Sending them to VDP
@send_loop:
    rst.lil $10
    djnz @send_loop
    pop bc

    dec bc
    ld a, b
    or c 
    jr nz, @unpack_loop
    jr @uploaded


;; If data wasn't RLE encoded
@notpacked:
    ld bc, 0
@notpacked_loop:
    call @fgetc
    rst.lil $10
    dec bc

    ld a, b
    or c
    jr nz, @notpacked_loop

@uploaded:
    ld hl, @cmd2
    ld bc, @cmd2_end - @cmd2
    rst.lil $18

    ld a, (@fp + 1)
    ld c, a
    ld a, __mos_fclose
    rst.lil $08

    xor a
    ret
@turbo_packed:
    ld bc, (@notpacked + 1)
@turbo_upload_loop:
    call @fgetc
    rst.lil $10
    dec bc 
    ld a, b 
    or c
    jr nz, @turbo_upload_loop

    ld hl, @unpack_cmd
    ld bc, @unpack_end - @unpack_cmd
    rst.lil $18
    jr @uploaded


@fopen_err:
    ld a, 1
    or a
    ret
@format_err:
    ld a, (@fp + 1)
    ld c, a
    ld a, __mos_fclose
    rst.lil $08

    ld a, 2
    or a 
    ret

@fgetc:
    push bc
@fp:
    ld c, 0
    ld a, __mos_fgetc
    rst.lil $08
    pop bc
    ret

@cmd1:
    ;; Clean buffer
    db 23, 0, $A0
@buff:
    dw 0
    db 2
    ;; Load to buffer
    db 23, 0, $A0
@buff1:
    dw 0
    db 0
@len:
    dw 0
@cmd1_end:

@cmd2:
    ;; Select image by buffer
    db 23, 27, $20
@bmid:
    dw 0
    ;; Make image from buffer
    db 23, 27, $21
@iw:
    dw 0
@ih:
    dw 0
    db 1
@cmd2_end:

@unpack_cmd:
    db 23, 0, $A0
@decompress_buff:
    dw 0
    db 65
@source_buff:
    dw 0
@unpack_end: