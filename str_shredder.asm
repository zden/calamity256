;      |           |        |
;      |  .  .  .  |  .   . |
;      s  h  r  e  d  d  e  r
;
;    designed for 286 12.5 MHz
;    run in DosBox 3000 cycles
;
;       calamity 256 vol.2
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
     pop es
; --- snd
mov     al, 90h
mem4:
out     43h, al
in      al, 61h
mem1:
or      al, 3
out     61h, al

	xor cx, cx
frame_loop:
;---------
	mov ax,cx
	shl ax, 1
	call _sin
	push ax
	call _rnd
	pop ax
	shr ax,1

	call sound

	push ax
	and al,127
	mov es:[si],al
	inc si
	pop ax

	push si
	mov si, cx
	push ax
	mov ax, cx
	shr ax,8
	mov dx, 320
	mul dx
	add si, ax
	pop ax
	add si, ax
	push ax
	xor al, 255

	and al,127
more:
	mov es:[si],al
	mov es:[si+320],al
nocol:
	pop ax
	pop si


	xchg al, bl

	mov dx, 03c8h
	out dx, al
	inc dx

	mov al, bh
	out dx, al
	mov al, bl
	out dx, al
	mov al, [si]
	out dx, al

lala:
	inc cx
	jnz noset
	call _rnd
	mov word ptr[mem1], bx
	call _rnd
	mov word ptr [mem2], bx
	mov di,bx
	dec byte ptr [mem3]
	xor byte ptr [mem3], 17
	mov byte ptr [mem4], bl
noset:

	; ESC check
	in al, 60h
	dec al


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

	mov dl, cl

	cmp cx, word ptr [mem1]
	jb snd_set2
	cmp cx, word ptr [mem2]
	ja snd_set3

	mov dh, byte ptr [mem3]
	and dl, dh

	mov byte ptr es:[di], al;
	mov byte ptr es:[di+32768], ah;
	dec di
	jnz ok2
	mov di, 64000-1
ok2:
	cmp bl, 64
	jb snd1
	shr ax,1

	jmp snd1
snd_set2:
	mov dl, ch
	mov dh, byte ptr [mem1]
	and dl, dh
	jmp snd1
snd_set3:
	mov dh, byte ptr [mem4]
	xor dh, ch
	and dl, dh
snd1:
	shr bx,1
	dec dl
	jnz snd1
	add ax,bx

	out 42h,al
ret

mem3	db 17
mark db 'Z'
	end start