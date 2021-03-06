#include <asm.h>

# issue read command
#
#	r3	ptr
#	r4	len	
#	r5	off
#	r6	cb

dDVDReadAbs:

	stwu    %sp, -0x10(%sp)
	mflr    %r0
	stw     %r0, 8(%sp)

#send cmd to DM

	li		%r0,	0
	lis		%r8,	0xC000
	addi	%r8,	%r8,	0x2F00
#IPC area
	dcbi	%r0,	%r8

	srwi	%r8,	%r5,	5
	mtctr	%r8
	mr		%r8,	%r4
invalidloop:
	dcbi	%r0,	%r8
	addi	%r8,	%r8,	0x20
	bdnz	invalidloop

	lis     %r8,	0xC000
	
	lis     %r0,	0xA900
	stw     %r0,	0x2F08(%r8)
	
	srwi    %r0,	%r5,	2
	stw     %r0,	0x2F0C(%r8)
	stw     %r3,	0x2F14(%r8)

	stw     %r4,	0x2F10(%r8)
	stw     %r4,	0x2F18(%r8)
	
	li      %r0,	3
	stw     %r0,	0x2F1C(%r8)

ready_loop:
	lwz		%r0,	0x2F1C(%r7)
	cmpwi	%r0,	3
	beq		ready_loop

wait_loop:
	lwz		%r0,	0x2F30(%r7)
	andi.	%r0,	%r0,	0x14
	cmpwi	%r0,	0
	beq		wait_loop

	cmpwi	%r12,	0
	beq		skip_cb
	mtctr	%r12
	mr		%r3,	%r5
	bctrl

skip_cb:

	li      %r3,	1

	lwz     %r0, 8(%sp)
	mtlr    %r0
	addi    %sp, %sp, 0x10
	blr
