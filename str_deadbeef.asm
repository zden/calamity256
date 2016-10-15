;      |            |       |
;      |  .  .   .  |   . . |
;      d  e  a   d  b   e e f
;
;    designed for 286 12.5 MHz
;    run in DosBox 3000 cycles
;
;       calamity 256 vol.3
;            |      |
;        zden satori 2016

.model tiny
.code
.286
     org 100h
start:

     mov al, 13h
     int 10h
mem2:
	mov si, offset pal_data
	mov bx, 0004h
pal_l:
	mov cx, 64
pal:
	mov dx, 03c8h
	mov al, bh
	out dx, al
	inc dx

	mov al, cl
	and al, [si]
	out dx, al

	mov al, cl
	and al, [si+1]
	out dx, al

	mov al, cl
	and al, [si+2]
	out dx, al
	inc bh
	loop pal
	add si, 3
	dec bl
	jnz pal_l

	push 0a000h
	pop es
	push es
	pop ds

; --- snd
mov     al, 90h
mem4:
out     43h, al
in      al, 61h
mem1:
or      al, 3
out     61h, al

	xor cx,cx
	mov si, 256
	xor di,di
frame_loop:
;---------
	mov ax,cx
	call _sin
	add al, 26
	nop
	nop
	nop

	mov dl,[di-180]
data_sound:
	add al,dl
	out 42h,al

	mov [si],al
	inc di
	inc si

	inc cx
	jnz noset
	cmp bx, [si]
	jb p1
	call pix_do2

	mov word ptr cs:[data_sound-2],-170
	jmp p2
p1:
	push si

	mov dh, 16
pix_rows:
	mov bl, 16
pix_row_rep:
	mov dl, 8
	mov ah, [si]
pix_more:
	shl ah, 1
	jc pix_write
	add di, 16
	jmp pix_skip

pix_write:
	mov cx, 16
	rep stosb
pix_skip:
	dec dl
	jnz pix_more
	add di, 320-(16*8)
	dec bl
	jnz pix_row_rep

	inc si
	dec dh
	jnz pix_rows

	pop si
	mov word ptr cs:[data_sound-2],-180
p2:

noset:

	xor ax, ax
	; ESC check
	in al, 60h
	dec ax 


	jnz short frame_loop
	
	in al, 61h
	and al, 11111100b
	out 61h, al


	mov al, 3h
	int 10h

	ret

; sin by Baudsurfer - http://olivier.poudade.free.fr/arc/tinysine.zip
_sin: 
mov bx,ax       ; al=bl=x
imul bl         ; ax=x*x
mov al,ah       ; ax=x*x*256+x%256
imul bl         ; ax=x*(x*x*256+x%256)
mov al,ah       ; ax=(x*(x*x*256+x%256))*256+(x*(x*x*256+x%256))%256
shr bx,2        ; bx=x/4
add al,13       ; ax=13+(x*(x*x*256+x%256))*256+(x*(x*x*256+x%256))%256 
sub ax,bx       ; ax=-x/4+100+(x*(x*x*256+x%256))*256+(x*(x*x*256+x%256))%256
db 0d4h,64      ; ax=(-x/4+100+(x*(x*x*256+x%256))*256+(x*(x*x*256+x%256))%256)%64
ret
; -----------------------------------------
pix_do2:
	push si

	mov dh, 16
pix_rows2:
	mov bl, 16
pix_row_rep2:
	mov dl, 8
	mov al, [si]
pix_more2:
	shr al, 1
	jc pix_write2
	add di, 16
	jmp pix_skip2
pix_write2:
	mov cx, 16
	rep stosb
	inc si
pix_skip2:
	dec dl
	jnz pix_more2
	add di, 320-(16*8)
	dec bl
	jnz pix_row_rep2

	dec dh
	jnz pix_rows2

	pop si
	ret
; --------
pal_data:	db 255,0,0, 63,47,0, 63,0, 0deh, 0adh,0beh,0efh
db 'Z'
	end start