;      |        |           |
;      |  .  .  |  .  .  .  |
;      a  b  e  y  a  n  c  e
;
;    designed for 286 12.5 MHz
;    run in DosBox 3000 cycles
;
;       calamity 256 vol.4
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
	push 0a000h
was:
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

	mov cx, 32
pal:
	mov al, cl
	mov dx, 03c8h
	out dx, al
	inc dx
	out dx, al
	ror al, 1
	out dx, al
	ror al, 1
	out dx, al
	loop pal

frame_loop:
;---------
	mov ax,cx
	shr ax,0
shift2:
	call _sin
	cmp cx, 65000
val1:
	jb jpp
	mov bx, [di+1025]
off1:
	shr al, 4
	shr bl, 4
	add al, bl
jpp:
	call sound
	mov [si],al

	inc si
	inc di

	add cx, 4
	jnz noset
; -----------------------------------------------------------------------
	call pix_do
	cmp byte ptr cs:[was-1], 3
	jnz cont
	mov si, 256
	xor di, di
cont:
; -----------------------------
	call _rnd
	jc noccc

	and al,5
	mov byte ptr cs:[shift-1],al
noccc:
	mov word ptr cs:[val1-2],bx

	cmp bl, 124
	ja aaaa
	call _rnd
	mov cx, bx
	shr cx, 4
shift:
cmp bl, 124
jb bbb
	rep movsw
jmp aaaa
bbb:
	rol byte ptr cs:[shift2-1],1
	shr cx,1
shup:
	xor byte ptr cs:[shup-1],1
	rep stosw
aaaa:
	inc byte ptr cs:[was-1]
	and byte ptr cs:[was-1],15
noset:

	xor ax, ax
	in al, 60h
	dec ax 

	jnz short frame_loop

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

_rnd:
; ------------------ random
	mov     al,16
r_loop: rol     bp,1
	jnc     r_skip
	xor     bp,0ah

r_skip: dec     al
	jne     r_loop
        mov     bx,bp
	ret
; -----------------------------
sound:
	mov dl,[di-1023]

	add al,dl
	out 42h,al
ret
; -----------------------------
pix_do:
	shr al,1
	push si
	push di
	mov di,[si]

	mov dh, 32
pix_rows:
	mov bl, 8
pix_row_rep:
	mov dl, 8
	mov ah, [si]
pix_more:
	shl ah, 1
	jc pix_write
	xor al,255
pix_write:
	mov cl, 8
	rep stosb
pix_skip:
	dec dl
	jnz pix_more
	adc di, 320-(8*8)
	dec bl
	jnz pix_row_rep
	dec al

	inc si
	dec dh
	jnz pix_rows

	pop di
	pop si
	ret

	end start