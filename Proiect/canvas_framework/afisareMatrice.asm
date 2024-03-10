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

window_title DB "X/0",0
area_width EQU 500
area_height EQU 500
area DD 0

counter DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 50
symbol_height EQU 50
include digits.inc
include letters.inc

gameTable db	10, 10, 10,
				10, 10, 10,
				10, 10, 10
				
tableSize EQU 3
n EQU 9

format db "%d ", 0
endl db 13, 10, 0

.code
start:
	
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
	cmp EAX, n
	JB bucla1
	
	push 0
	call exit
end start
