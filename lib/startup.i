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
;; Common runtime

__and:
  push de
  push hl
  ld hl, 2
  add hl, sp
  ld a, (hl)
  inc hl
  inc hl
  inc hl
  and (hl)
  dec hl
  dec hl
  dec hl
  ld (hl), a
  pop hl
  pop de
  ld a, h
  and d
  ld h, a

  ld a, l
  and e
  ld l, a

  ret

__or:
  push de
  push hl
  ld hl, 2
  add hl, sp
  ld a, (hl)
  inc hl
  inc hl
  inc hl
  or (hl)
  dec hl
  dec hl
  dec hl
  ld (hl), a
  pop hl
  pop de
  ld a, h
  or d
  ld h, a

  ld a, l
  or e
  ld l, a
  ret

__xor:
  push de
  push hl
  ld hl, 2
  add hl, sp
  ld a, (hl)
  inc hl
  inc hl
  inc hl
  xor (hl)
  dec hl
  dec hl
  dec hl
  ld (hl), a
  pop hl
  pop de
  ld a, h
  xor d
  ld h, a
  
  ld a, l
  xor e
  ld l, a
  ret

__mul:
  push	ix
  ld	ix,0
  add	ix,sp

  push	de		
  push	de		
  push	hl		
  push	hl		

  push	de		
  push	af

  ld	a,(ix-7)
  xor	a,(ix-4)
  jp	p, @ssign

  xor	a,(ix-4)
  jp	m, @op2neg

  ex	de,hl
  ld	hl,0
  or	a,a
  sbc	hl,bc
  ld	(ix-6),hl
  push	hl
  pop	bc
  ex	de,hl
  jp	@ustart
@op2neg:
  ld	de,0
  ex	de,hl
  or	a,a
  sbc	hl,de
  ld	(ix-9),hl
  jp	@ustart
@ssign:
  xor	a,(ix-4)
  jp	p, @ustart
  ex	de,hl		
  ld	hl,0
  or	a,a
  sbc	hl,bc
  ld	(ix-6),hl	
  push bc
  pop hl
  ex	de,hl
  jp	@op2neg
@ustart:
  ld	hl,0
  ld	l,(ix-8)
  ld	h,(ix-6)
  mlt	hl
  ld	de,0
  ld	d,(ix-9)
  ld	e,(ix-5)
  mlt	de
  add	hl,de

  ld	de,0
  push	de	
  ld	(ix-19),h
  ld	(ix-20),l
  pop	hl
  ld	e,(ix-9)
  ld	d,(ix-6)
  mlt	de
  add	hl,de
  or	a,a	
  ld	d,(ix-7)
  ld	e,(ix-6)
  mlt	de
  ld	c,(ix-8)
  ld	b,(ix-5)
  mlt	bc
  ex	de,hl
  adc	hl,bc
  ex	de,hl
  or	a,a
  ld	b,(ix-9)
  ld	c,(ix-4)
  mlt	bc
  ex	de,hl
  adc	hl,bc

  ld	bc,0
  push	bc
  ld	(ix-19),l
  pop	hl

  or	a,a
  adc	hl,de

  ld	a,(ix-1)
  xor	a,(ix-10)
  jp	p, @popregs
  ld	de,0
  ex	de,hl
  or	a,a
  sbc	hl,de
@popregs:
  pop	af
  pop	de		
  pop	de		
  pop	de		
  pop	de		
  pop	de		
  pop ix
  ret

__mod:
  push de
  pop bc
  ex	de, hl
  ld	a, 24
  or	a, a
  sbc	hl, hl
@div1:
  ex	de, hl
  add	hl, hl
  ex	de, hl
  adc	hl, hl
  sbc	hl, bc
  inc	e
  jr	nc, @div2
  add	hl, bc
  dec	e
@div2:
  dec	a
  jr	nz, @div1
  ret

_udiv:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld de, (ix + 9)
  call __mod
  ex de, hl

  ld sp, ix
  pop ix
  ret

__div:
  push	de
  pop     bc
  push	hl
  ex	de,hl
  or	a,a
  sbc	hl,hl
  sbc	hl,de
  jp	m,@L0
  ex	de,hl
@L0:
  or	a,a
  sbc	hl,hl
  sbc	hl,bc
  jp	m,@L1
  push bc
  pop hl
@L1:
  ex	de,hl
  call	__idivu

  ex	de,hl
  ld	hl,2
  add	hl,sp
  ld	a,(hl)
  inc	hl
  ld	sp,hl
  inc	hl
  inc	hl
  xor	a,(hl)
  jp	p,@L2
  sbc	hl,hl
  sbc	hl,de
  ex	de,hl
@L2:
  ex	de,hl
  ret 

__idivu:
  push	af
  push	de
  ex de,hl
  ld	a,24		
  or	a,a
  sbc	hl,hl
@loop1:
  ex	de,hl		
  add	hl,hl
  ex	de,hl
  adc	hl,hl	
  sbc	hl,bc
  jr	nc,@over

  add	hl,bc	
  jr	@under
@over:
  inc	e
@under:
  dec	a
  jr	nz,@loop1
  ex	de,hl
  pop	de
  pop	af
  ret

__cmp:
  or a,a 
  sbc hl,de

  push af
  pop bc
  bit 2, c
  jr z, @done
  ld a, c
  xor a, $80
  ld c, a
@done:
  push bc
  pop af
  ret

_rand:
  ld hl, (@state)
  add hl, bc
  add hl, de
  add hl, sp

  rrca
  xor h
  xor l
  xor e
  xor b
  rrca

  ld e, a
  ld a, r
  xor e

  xor h
  ld h, a

  rr l
  rrca 
  xor c
  xor e
  ld l, a
  ld (@state), hl
  ret
@state:
  dl $F7A2E3

_trace:
  rst.lil $38
  ret

_putc:
  push ix
  ld ix, 0
  add ix, sp

  ld a, (ix + 6)
  rst.lil $10

  ld sp, ix
  pop ix
  ret

_puts:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld bc, 0
  xor a
  rst.lil $18

  ld sp, ix
  pop ix
  ret

_getc:
  push ix
  ld ix, 0
  add ix, sp

  xor a       ;; mos_getkey = 0
  rst.lil $08

  or a 
  sbc hl, hl

  ld l, a
  
  ld sp, ix
  pop ix
  ret
_neg:
	push ix
	ld ix, 0
	add ix, sp
	ld hl, 0
	ld de, (ix+6)
	or a
	sbc hl,de
	jp _neg_end
_neg_end:
	ld sp, ix
	pop ix
	ret

_abs:
	push ix
	ld ix, 0
	add ix, sp
	ld hl, (ix+6)
	ld de, 0
	call __cmp
	ld hl, 0
	jp p, _math001
	ld hl, -1
_math001:
	ld de, 0
	or a
	sbc hl, de
	jp z, _math002
	push de
	ld hl, (ix+6)
	push hl
	call _neg
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	jp _abs_end
_math002:
	ld hl, (ix+6)
	jp _abs_end
_abs_end:
	ld sp, ix
	pop ix
	ret

_swap:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -3
	add hl, sp
	ld sp, hl

	lea hl, ix+6
	ld hl, (hl)
	ld hl, (hl)
	ld (ix+-3), hl
	lea hl, ix+9
	ld hl, (hl)
	ld hl, (hl)
	ld (ix+6), hl
	ld hl, (ix+-3)
	ld (ix+9), hl
_swap_end:
	ld sp, ix
	pop ix
	ret

_rand_range:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -3
	add hl, sp
	ld sp, hl

	ld hl, (ix+6)
	ld de, (ix+9)
	ex de, hl
	call __cmp
	ld hl, 0
	jp p, _math003
	ld hl, -1
_math003:
	ld de, 0
	or a
	sbc hl, de
	jp z, _math004
	lea hl, ix+9
	push hl
	lea hl, ix+6
	push hl
	call _swap
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_math004:
	ld hl, (ix+9)
	ld de, (ix+6)
	or a
	sbc hl,de
	ld (ix+-3), hl
	push de
	push hl
	call _rand
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld de, (ix+-3)
	call __mod
	ld de, (ix+6)
	add hl, de
	jp _rand_range_end
_rand_range_end:
	ld sp, ix
	pop ix
	ret

_printf:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -6
	add hl, sp
	ld sp, hl

	lea hl, ix+6
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	ld (ix+-3), hl
	lea hl, ix+9
	ld (ix+-6), hl
_printf001:
	ld hl, (ix+-3)
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf002
	ld hl, (ix+-3)
	ld de, 37
	or a
	sbc hl, de
	ld hl, -1
	jr nz, _printf003
	ld hl,0
_printf003:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf004
	ld hl, (ix+-3)
	push hl
	call _putc
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
_printf004:
	ld hl, (ix+-3)
	ld de, 37
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf005
	ld hl,0
_printf005:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf006
	ld hl, (ix+6)
	ld de, 1
	add hl, de
	ld (ix+6), hl
	lea hl, ix+6
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	ld (ix+-3), hl
	ld hl, (ix+-3)
	ld de, 115
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf007
	ld hl,0
_printf007:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf008
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	call _puts
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_printf008:
	ld hl, (ix+-3)
	ld de, 99
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf009
	ld hl,0
_printf009:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf00a
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	push hl
	call _putc
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_printf00a:
	ld hl, (ix+-3)
	ld de, 100
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf00b
	ld hl,0
_printf00b:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf00c
	ld hl, 10
	push hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	call _printn
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_printf00c:
	ld hl, (ix+-3)
	ld de, 111
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf00d
	ld hl,0
_printf00d:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf00e
	ld hl, 8
	push hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	call _printn
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_printf00e:
	ld hl, (ix+-3)
	ld de, 98
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf00f
	ld hl,0
_printf00f:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf010
	ld hl, 2
	push hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	call _printn
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_printf010:
	ld hl, (ix+-3)
	ld de, 120
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf011
	ld hl,0
_printf011:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf012
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	call _printx
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	ld hl, (ix+-6)
	ld de, 3
	add hl, de
	ld (ix+-6), hl
_printf012:
	ld hl, (ix+-3)
	ld de, 37
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf013
	ld hl,0
_printf013:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf014
	ld hl, 37
	push hl
	call _putc
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
_printf014:
_printf006:
	ld hl, (ix+6)
	ld de, 1
	add hl, de
	ld (ix+6), hl
	lea hl, ix+6
	ld hl, (hl)
	ld hl, (hl)
	ld de, 255
	call __and
	ld (ix+-3), hl
	jp _printf001
_printf002:
_printf_end:
	ld sp, ix
	pop ix
	ret

_printn:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -3
	add hl, sp
	ld sp, hl

	ld hl, (ix+6)
	ld de, 16
	or a
	sbc hl, de
	ld hl, -1
	jr z, _printf015
	ld hl,0
_printf015:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf016
	push de
	ld hl, (ix+6)
	push hl
	call _printx
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	jp _printn_end
_printf016:
	ld hl, (ix+6)
	ld de, 0
	call __cmp
	ld hl, 0
	jp p, _printf017
	ld hl, -1
_printf017:
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf018
	push de
	ld hl, (ix+6)
	push hl
	call _neg
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld (ix+6), hl
	ld hl, 45
	push hl
	call _putc
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
_printf018:
	ld hl, (ix+6)
	ld de, (ix+9)
	call __div
	ld (ix+-3), hl
	ld hl, (ix+-3)
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf019
	ld hl, (ix+9)
	push hl
	ld hl, (ix+-3)
	push hl
	call _printn
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
_printf019:
	ld hl, (ix+6)
	ld de, (ix+9)
	call __mod
	ld de, 48
	add hl, de
	push hl
	call _putc
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
_printn_end:
	ld sp, ix
	pop ix
	ret

_printx:
	push ix
	ld ix, 0
	add ix, sp

	ld hl, -6
	add hl, sp
	ld sp, hl

	ld hl, __printf01a
	ld (ix+-6), hl
	push de
	ld hl, 16
	push hl
	ld hl, (ix+6)
	push hl
	call _udiv
	ex de,hl
	ld hl, 6
	add hl, sp
	ld sp, hl
	ex de,hl
	pop de
	ld (ix+-3), hl
	ld hl, (ix+-3)
	ld de, 0
	or a
	sbc hl, de
	jp z, _printf01b
	ld hl, (ix+-3)
	push hl
	call _printx
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
_printf01b:
	ld hl, (ix+6)
	ld de, 15
	call __and
	ld de, (ix+-6)
	add hl, de
	ld (ix+-6), hl
	lea hl, ix+-6
	ld hl, (hl)
	ld hl, (hl)
	push hl
	call _putc
	ex de,hl
	ld hl, 3
	add hl, sp
	ld sp, hl
	ex de,hl
_printx_end:
	ld sp, ix
	pop ix
	ret
__printf01a:	db "0123456789ABCDEF", 0
