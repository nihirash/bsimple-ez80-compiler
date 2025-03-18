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

_write:
  push ix
  ld ix, 0
  add ix, sp

  ld hl, (ix + 6)
  ld bc, (ix + 9)
  xor a
  rst.lil $18

  ld sp, ix
  pop ix
  ret

  