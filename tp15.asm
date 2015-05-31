;******************************************************************
; Ejercicio que transforma un nro en binario a su representacion en
; en ASCII mediante divisiones sucesivas y lo imprime en pantalla
; en base 16
;*******************************************************************

segment pila stack
   resb 1024
segment datos data

	num		    dw  1250
	diez		dw  16
	cociente	db  0
	resto		db  0
	cadena	    times 10	db  '0'
                db'$' ;para agregar el fin de string para imprimir por pantalla
    letra_a		dw	10
segment codigo code
..start:
	mov   	ax,datos	   ;ds <-- dir del segmento de datos
	mov   	ds,ax
	mov   	ax,pila		;ss <-- dir del segmento de pila
	mov   	ss,ax

	mov   	dx,0	    ;pongo en 0 dx para la dupla dx:ax
	mov   	ax,[num]  ;copio el nro en AX para divisiones sucesivas
	mov   	si,9	    ;'si' apunta al ultimo byte de la cadena

otraDiv:
	div   	word[diez]      ;dx:ax div 10 ==> dx <- resto & ax <- cociente
    cmp		dx,10
	jl		esNumero
	add   	dx,55		      ;convierto a Ascii el resto
	jmp		strNum
esNumero:
	add		dx,48
	jmp		strNum
strNum:
	mov   	[cadena+si],dl	;lo pongo en la posicion anterior
	sub   	si,1		      ;posiciono SI en el caracter anterior en la cadena
	
	cmp   	ax,[diez]	;IF    cociente < 10
	jl   	finDiv		;THEN  fin division
	
	mov   	dx,0		;pongo en 0 DX para la dupla DX:AX
	jmp   	otraDiv
finDiv:
	add   	ax,48
	mov   	[cadena+si],al
    ;imprime en pantalla el numero.
	lea   	dx,[cadena]
	mov   	ah,9
	int   	21h

	mov  ax,4c00h	;retorno al DOS
	int  21h
