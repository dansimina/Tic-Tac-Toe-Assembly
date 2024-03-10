.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 600
area_height EQU 500
area DD 0

character_diagonal EQU 60
character_height EQU 70
character_width EQU 50

counter DD 0 ; numara evenimentele de tip timer
clickParity DB 1

gameTable DB	10, 10, 10,
				10, 10, 10,
				10, 10, 10
				
tableSize EQU 3

; pozitia in matrice
ai DB 0
aj DB 0
; pozitia pe ecran
px DD 0
py DD 0
; counter click-uri
cnt DB 0
;numarul casutelor
nBoxes EQU 9

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

colorX EQU 1 ; culoare X
colorO EQU 1 ; culoare 0
colorLines EQU 1 ; culoare linii
colorW EQU 1 ; culoare linie victorie

; de sters
format db "%d ", 0
endl db 13, 10, 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

horizontal_line macro x, y, len, color 
local lineLoop

	mov eax, y; eax = y
	mov ebx, area_width
	mul ebx ; eax = y * area width
	add eax, x; eax = y * area width + x
	shl eax, 2
	add eax, area	
	
	mov ecx, len
	
	lineLoop:
	
		mov dword ptr [eax], color
		mov dword ptr [eax - 4], color
		mov dword ptr [eax + 4], color
		mov dword ptr [eax + area_width * 4], color
		mov dword ptr [eax - area_width * 4], color
		add eax, 4
		
	loop lineLoop

endm

vertical_line macro x, y, len, color 
local lineLoop

	mov eax, y; eax = y
	mov ebx, area_width
	mul ebx ; eax = y * area width
	add eax, x; eax = y * area width + x
	shl eax, 2
	add eax, area	
	
	mov ecx, len
	
	lineLoop:
	
		mov dword ptr [eax], color
		mov dword ptr [eax - 4], color
		mov dword ptr [eax + 4], color
		mov dword ptr [eax + area_width * 4], color
		mov dword ptr [eax - area_width * 4], color
		add eax, area_width * 4 
		
	loop lineLoop

endm

first_diagonal macro x, y, len, color 
local firstLoop, salt

	mov eax, y; eax = y
	mov ebx, area_width
	mul ebx ; eax = y * area width
	add eax, x; eax = y * area width + x
	shl eax, 2
	add eax, area	
	mov ecx, len
	
	mov edx, 0
	
	firstLoop:
	
		mov dword ptr [eax], color
		mov dword ptr [eax - 4], color
		mov dword ptr [eax + 4], color
		mov dword ptr [eax + 8], color
		mov dword ptr [eax + area_width * 4], color
		mov dword ptr [eax - area_width * 4], color
		
		add eax, area_width * 4
		add eax, 4
		
		cmp edx, 3
		jne salt

		add eax, 4
		mov edx, 0
			
		salt:
		
		inc edx
		
	loop firstLoop
	
endm

x_design macro x, y, color 
local firstLoop, secondLoop

	mov eax, y; eax = y
	mov ebx, area_width
	mul ebx ; eax = y * area width
	add eax, x; eax = y * area width + x
	shl eax, 2
	add eax, area	
	mov ecx, character_diagonal
	
	firstLoop:
	
		mov dword ptr [eax], color
		mov dword ptr [eax - 4], color
		mov dword ptr [eax + 4], color
		mov dword ptr [eax + area_width * 4], color
		mov dword ptr [eax - area_width * 4], color
		
		add eax, area_width * 4
		add eax, 4
		
	loop firstLoop
	
	mov eax, y; eax = y
	mov ebx, area_width
	mul ebx ; eax = y * area width
	add eax, x; eax = y * area width + x
	add eax, character_diagonal
	shl eax, 2
	add eax, area	
	
	mov ecx, character_diagonal
	
	secondLoop:
	
		mov dword ptr [eax], color
		mov dword ptr [eax - 4], color
		mov dword ptr [eax + 4], color
		mov dword ptr [eax + area_width * 4], color
		mov dword ptr [eax - area_width * 4], color
		
		add eax, area_width * 4
		sub eax, 4
		
	loop secondLoop

endm

o_design macro x, y, color 
local firstLoop, secondLoop

	mov eax, y; eax = y
	mov ebx, area_width
	mul ebx ; eax = y * area width
	add eax, x; eax = y * area width + x
	shl eax, 2
	add eax, area	
	mov ecx, character_height
	
	sub eax, 12
	
	firstLoop:
	
		mov dword ptr [eax], color
		mov dword ptr [eax - 4], color
		mov dword ptr [eax + 4], color
		mov dword ptr [eax + area_width * 4], color
		mov dword ptr [eax - area_width * 4], color
		
		mov dword ptr [eax + character_width * 4 + 20], color
		mov dword ptr [eax + character_width * 4 - 4 + 20], color
		mov dword ptr [eax + character_width * 4 + 4 + 20], color
		mov dword ptr [eax + character_width * 4 + area_width * 4 + 20], color
		mov dword ptr [eax + character_width * 4- area_width * 4 + 20], color
		
		add eax, area_width * 4
		
	loop firstLoop
	
	mov eax, y; eax = y
	mov ebx, area_width
	mul ebx ; eax = y * area width
	add eax, x; eax = y * area width + x
	shl eax, 2
	add eax, area	
	
	sub eax, 16 * area_width
	
	mov ecx, character_width
	
	secondLoop:
	
		mov dword ptr [eax], color
		mov dword ptr [eax - 4], color
		mov dword ptr [eax + 4], color
		mov dword ptr [eax + area_width * 4], color
		mov dword ptr [eax - area_width * 4], color
		
		mov dword ptr [eax + character_height * area_width * 4 + 24 * area_width], color
		mov dword ptr [eax + character_height * area_width * 4 - 4 + 24 * area_width], color
		mov dword ptr [eax + character_height * area_width * 4 + 4 + 24 * area_width], color
		mov dword ptr [eax + character_height * area_width * 4 + area_width * 4 + 24 * area_width], color
		mov dword ptr [eax + character_height * area_width * 4 - area_width * 4 + 24 * area_width], color
		
		add eax, 4
		
	loop secondLoop

endm

selectPlayer macro x, y
local skip_1, skip_2

	cmp clickParity, 1
	jne skip_1
		x_design x, y, 1
		mov clickParity, 0
		jmp skip_2
	skip_1:
		o_design x, y, 1
		mov clickParity, 1
	skip_2:
endm

position macro x, y
local finalX, finalY, saltX1, saltX2, saltY1, saltY2, saltCmpBox

;;determin linia pe care ma aflu
	mov edx, 0
	mov eax, 0
	mov eax, area_height
	mov ebx, 3
	div ebx
	sub eax, 5
	
	cmp eax, y
	
	jl saltY1
		
	mov ai, 0
	sub eax, character_height
	sub eax, 20
	mov py, eax
	
	jmp finalY
		
	saltY1:
	
	mov edx, 0
	mov eax, 0
	mov eax, area_height
	mov ebx, 2
	mul ebx
	mov ebx, 3
	div ebx
	sub eax, 5
	
	cmp eax, y
	jl saltY2
		
	mov ai, 3
	sub eax, character_height
	sub eax, 50
	mov py, eax
	
	jmp finalY
		
	saltY2:
	
	mov eax, 0
	mov eax, area_height
	sub eax, 90
	
	mov ai, 6
	sub eax, character_height
	add eax, 20
	mov py, eax
	
	finalY:
	
;;determin coloana pe care ma aflu

	mov edx, 0
	mov eax, 0
	mov eax, area_width
	mov ebx, 3
	div ebx
	sub eax, 5	; eax = area_width * 1 / 3 - 5
	
	cmp eax, x
	jl saltX1
		
	mov aj, 0
	sub eax, character_width
	sub eax, 70
	mov px, eax
	
	jmp finalX
		
	saltX1:
	
	mov edx, 0
	mov eax, 0
	mov eax, area_width
	mov ebx, 2
	mul ebx
	mov ebx, 3
	div ebx
	sub eax, 5	; eax = area_width * 2 / 3 - 5
	
	cmp eax, x
	jl saltX2
		
	mov aj, 1
	sub eax, character_width
	sub eax, 75
	mov px, eax
	
	jmp finalX
		
	saltX2:
	
	mov eax, 0
	mov eax, area_width
	sub eax, 70
	
	mov aj, 2
	sub eax, character_width
	sub eax, 15
	mov px, eax
	
	finalX:
	
	mov EAX, 0
	mov EBX, 0
	mov AL, ai
	mov BL, aj
	mov CL, clickParity

	; comparare daca casuta e libera
	
	cmp gameTable[EAX][EBX], 10
	jne saltCmpBox
	
	inc cnt
	mov gameTable[EAX][EBX], CL
	selectPlayer px, py
	
	saltCmpBox:

endm

winX macro

	make_text_macro 'C', area, area_width / 2 - 90, 5
	make_text_macro 'A', area, area_width / 2 - 80, 5
	make_text_macro 'S', area, area_width / 2 - 70, 5
	make_text_macro 'T', area, area_width / 2 - 60, 5
	make_text_macro 'I', area, area_width / 2 - 50, 5
	make_text_macro 'G', area, area_width / 2 - 40, 5
	make_text_macro 'A', area, area_width / 2 - 30, 5
	make_text_macro 'T', area, area_width / 2 - 20, 5
	make_text_macro 'O', area, area_width / 2 - 10, 5
	make_text_macro 'R', area, area_width / 2, 5
	make_text_macro 'U', area, area_width / 2 + 10, 5
	make_text_macro 'L', area, area_width / 2 + 20, 5
	make_text_macro ' ', area, area_width / 2 + 30, 5
	make_text_macro 'E', area, area_width / 2 + 40, 5
	make_text_macro 'S', area, area_width / 2 + 50, 5
	make_text_macro 'T', area, area_width / 2 + 60, 5
	make_text_macro 'E', area, area_width / 2 + 70, 5
	make_text_macro ' ', area, area_width / 2 + 80, 5
	make_text_macro 'X', area, area_width / 2 + 90, 5

endm

win0 macro

	make_text_macro 'C', area, area_width / 2 - 90, 5
	make_text_macro 'A', area, area_width / 2 - 80, 5
	make_text_macro 'S', area, area_width / 2 - 70, 5
	make_text_macro 'T', area, area_width / 2 - 60, 5
	make_text_macro 'I', area, area_width / 2 - 50, 5
	make_text_macro 'G', area, area_width / 2 - 40, 5
	make_text_macro 'A', area, area_width / 2 - 30, 5
	make_text_macro 'T', area, area_width / 2 - 20, 5
	make_text_macro 'O', area, area_width / 2 - 10, 5
	make_text_macro 'R', area, area_width / 2, 5
	make_text_macro 'U', area, area_width / 2 + 10, 5
	make_text_macro 'L', area, area_width / 2 + 20, 5
	make_text_macro ' ', area, area_width / 2 + 30, 5
	make_text_macro 'E', area, area_width / 2 + 40, 5
	make_text_macro 'S', area, area_width / 2 + 50, 5
	make_text_macro 'T', area, area_width / 2 + 60, 5
	make_text_macro 'E', area, area_width / 2 + 70, 5
	make_text_macro ' ', area, area_width / 2 + 80, 5
	make_text_macro '0', area, area_width / 2 + 90, 5
endm

verif macro
local final, salt_1, salt_2, salt_3, salt_4, salt_5, salt_6, salt_7, salt_8, salt_9, salt_10, salt_10, salt_11, salt_12, salt_13, salt_14, salt_15, salt_16

	; prima linie
	mov ecx, 0
	mov eax, 0
	mov ebx, 0
	add cl, gameTable[eax][ebx]
	inc ebx
	add cl, gameTable[eax][ebx]
	inc ebx
	add cl, gameTable[eax][ebx]
	
	cmp ecx, 0
	jne salt_1
	
	win0
	horizontal_line 20, area_height * 1 / 6 + 20, area_width - 40, colorW
	mov cnt, 10
	jmp final
	
	salt_1:
	cmp ecx, 3
	jne salt_2
	
	winX
	horizontal_line 20, area_height * 1 / 6 + 20, area_width - 40, colorW
	mov cnt, 10
	jmp final
	
	; a doua linie
	salt_2:
	
	mov ecx, 0
	mov eax, 3
	mov ebx, 0
	add cl, gameTable[eax][ebx]
	inc ebx
	add cl, gameTable[eax][ebx]
	inc ebx
	add cl, gameTable[eax][ebx]
	
	cmp ecx, 0
	jne salt_3
	
	win0
	horizontal_line 20, area_height * 3 / 6 - 10, area_width - 40, colorW
	mov cnt, 10
	jmp final
	
	salt_3:
	cmp ecx, 3
	jne salt_4
	
	winX
	horizontal_line 20, area_height * 3 / 6 - 10, area_width - 40, colorW
	mov cnt, 10
	jmp final
	
	; a treia linie
	salt_4:
	
	mov ecx, 0
	mov eax, 6
	mov ebx, 0
	add cl, gameTable[eax][ebx]
	inc ebx
	add cl, gameTable[eax][ebx]
	inc ebx
	add cl, gameTable[eax][ebx]
	
	cmp ecx, 0
	jne salt_5
	
	win0
	horizontal_line 20, area_height * 5 / 6 - 25, area_width - 40, colorW
	mov cnt, 10
	jmp final
	
	salt_5:
	cmp ecx, 3
	jne salt_6
	
	winX
	horizontal_line 20, area_height * 5 / 6 - 25, area_width - 40, colorW
	mov cnt, 10
	jmp final
	
	; prima coloana
	salt_6:
	
	mov ecx, 0
	mov eax, 0
	mov ebx, 0
	add cl, gameTable[eax][ebx]
	add eax, 3
	add cl, gameTable[eax][ebx]
	add eax, 3
	add cl, gameTable[eax][ebx]
	
	cmp ecx, 0
	jne salt_7
	
	win0
	vertical_line area_width * 1 / 6 + 5, 50, area_height - 90, colorW
	mov cnt, 10
	jmp final
	
	salt_7:
	cmp ecx, 3
	jne salt_8
	
	winX
	vertical_line area_width * 1 / 6 + 5, 50, area_height - 90, colorW
	mov cnt, 10
	jmp final
	
	; a doua coloana
	salt_8: 
	
	mov ecx, 0
	mov eax, 0
	mov ebx, 1
	add cl, gameTable[eax][ebx]
	add eax, 3
	add cl, gameTable[eax][ebx]
	add eax, 3
	add cl, gameTable[eax][ebx]
	
	cmp ecx, 0
	jne salt_9
	
	win0
	vertical_line area_width * 3 / 6, 50, area_height - 90, colorW
	mov cnt, 10
	jmp final
	
	salt_9:
	cmp ecx, 3
	jne salt_10
	
	winX
	vertical_line area_width * 3 / 6, 50, area_height - 90, colorW
	mov cnt, 10
	jmp final
	
	; a treia coloana
	salt_10: 
	
	mov ecx, 0
	mov eax, 0
	mov ebx, 2
	add cl, gameTable[eax][ebx]
	add eax, 3
	add cl, gameTable[eax][ebx]
	add eax, 3
	add cl, gameTable[eax][ebx]
	
	cmp ecx, 0
	jne salt_11
	
	win0
	vertical_line area_width * 5 / 6 - 5, 50, area_height - 90, colorW
	mov cnt, 10
	jmp final
	
	salt_11:
	cmp ecx, 3
	jne salt_12
	
	winX
	vertical_line area_width * 5 / 6 - 5, 50, area_height - 90, colorW
	mov cnt, 10
	jmp final
	
	; prima diagonala
	salt_12: 
	
	mov ecx, 0
	mov eax, 0
	mov ebx, 0
	add cl, gameTable[eax][ebx]
	inc ebx
	add eax, 3
	add cl, gameTable[eax][ebx]
	inc ebx
	add eax, 3
	add cl, gameTable[eax][ebx]
	
	cmp ecx, 0
	jne salt_13
	
	win0
	first_diagonal 40, 52, area_width * 2 / 3 - 10, colorW
	mov cnt, 10
	jmp final
	
	salt_13:
	cmp ecx, 3
	jne salt_14
	
	winX
	first_diagonal 40, 52, area_width * 2 / 3 - 10, colorW
	mov cnt, 10
	jmp final
	
	; a doua diagonala
	salt_14:
	
	; remiza
	
	final:

endm

; de sters

afisare macro
local bucla1, bucla2
mov EAX, 0
	mov EBX, 0
	
	bucla1:
		
		mov EBX, 0
		
		bucla2:
		
			mov ECX, 0
			mov CL, gameTable[EAX][EBX]
			
			push EAX
			push EBX
			
			push ECX
			push offset format
			call printf
			add ESP, 8
			
			pop EBX
			pop EAX
			
		inc EBX
		cmp	EBX, tableSize
		JB bucla2
		
		push EAX
		push EBX
		
		push offset endl
		call printf
		add ESP, 4
		
		pop EBX
		pop EAX
	
	add EAX, 3
	cmp EAX, nBoxes
	JB bucla1
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:

	cmp cnt, nBoxes
	jge salt
	position [ebp + arg2], [ebp + arg3]
	verif
	salt:
	afisare

	jmp afisare_litere
	
evt_timer:
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	
	cmp cnt, nBoxes
	jg final
	
	make_text_macro 'R', area, area_width / 2 - 70, 5
	make_text_macro 'A', area, area_width / 2 - 60, 5
	make_text_macro 'N', area, area_width / 2 - 50, 5
	make_text_macro 'D', area, area_width / 2 - 40, 5
	make_text_macro 'U', area, area_width / 2 - 30, 5
	make_text_macro 'L', area, area_width / 2 - 20, 5
	make_text_macro ' ', area, area_width / 2 - 10, 5
	make_text_macro 'L', area, area_width / 2, 5
	make_text_macro 'U', area, area_width / 2 + 10, 5
	make_text_macro 'I', area, area_width / 2 + 20, 5
	make_text_macro ' ', area, area_width / 2 + 30, 5
	
	cmp clickParity, 1
	jne skip_1
		make_text_macro 'X', area, area_width / 2 + 40, 5
		jmp skip_2
	skip_1:
		make_text_macro '0', area, area_width / 2 + 40, 5
	skip_2:
	
	final: 
	
	; desenez liniile 
	
	horizontal_line area_width / 2 - 75, 30, 130, colorLines
	
	horizontal_line 20, area_height * 1 / 3 - 5, area_width - 40, colorLines
	horizontal_line 20, area_height * 2 / 3 - 5, area_width - 40, colorLines
	
	vertical_line area_width * 1 / 3 - 5, 50, area_height - 90, colorLines
	vertical_line area_width * 2 / 3 - 5, 50, area_height - 90, colorLines

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	mov edx, 0
	mov eax, area_width
	mul area_height
	sub eax, 1 ; eax = area_width * area_height - 1
	
	mov ecx, eax
	
	bucla2:
		mov ebx, colorF
		mov area[ecx * 4], ebx
	loop bucla2
	
	;terminarea programului
	push 0
	call exit
end start
