	include "../../lib/startup.i"

_test:
	push ix
	ld ix,0
	add ix,sp
	ld hl,__main001
	push hl
	call _printf
	ex de,hl
	ld hl,3
	add hl,sp
	ld sp,hl
	ex de,hl
_test_end:
	ld sp,ix
	pop ix
	ret

_main:
	push ix
	ld ix,0
	add ix,sp
	push hl
	call _test
	ex de,hl
	ld hl,3
	add hl,sp
	ld sp,hl
	ex de,hl
_main_end:
	ld sp,ix
	pop ix
	ret
__main001:	db "Hello, world!\r\n", 0
