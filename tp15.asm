;******************************************************************
; Ejercicio que transforma un nro en binario a su representacion en
; en ASCII mediante divisiones sucesivas y lo imprime en pantalla
; en base 16
;*******************************************************************

segment pila stack
   resb 1024
segment datos data
    msjDeci    	dw		'00002015'
	msjHexa		dw		'7DF'
    char     resb   1
    hexa        db      'H'
    deci        db      'D'
    msgIng      db      10,13,"H - Hexa to Decimal. D - Decimal to Hexa: ",10,13,'$'
    msgMues     db      10,13,"Ud ingreso: $"
    num         dw  0
    dieciseis   dw  16
    diez        dw  10
    cociente    db  0
    resto       db  0
    cadena      times 10 db '0'
                db '$'
;para agregar el fin de string para imprimir por pantalla

segment codigo code
..start:
    mov     ax,datos       ;ds <-- dir del segmento de datos
    mov     ds,ax
    mov     ax,pila     ;ss <-- dir del segmento de pila
    mov     ss,ax
    
    lea     dx,[msgIng] ;dx <-- offset de 'msgIng' dento del segmento de datos
    mov     ah,9            ;servicio 9 para int 21h -- Impmrimir msg en pantalla
    int     21h

    mov     ah,8h           ;servicio 8 para int 21h -- lee caracter de teclado y no lo muestra, lo deja en 'al'
    int     21h
; me fijo que letra es la ingresada ;
    mov     [char],al   ;guardo en char el ascii del caracter ingresado ya que el servicio
						;que se ejecuta a continuación altera 'al' copiando el ascii del signo $
    cmp     byte[char],'H'
    je      charToHexa
    cmp     byte[char],'D'
    je      charToDeci
    jmp     errorLetra

charToHexa:
    mov     di,0
otroHexa:
    cmp		di,9
	jg	    cnvNumHexa
	cmp     byte[msjHexa+di],'0'
	jb      error
	cmp     byte[msjHexa+di],'9'
	jbe     otroHexa
	cmp     byte[msjHexa+di],'A'
	jb      error
	cmp     byte[msjHexa+di],'F'
	jbe     otroHexa
sumDiHexa:
    add     di,10
	jmp		otroHexa

error:
    jmp     finPrograma

charToDeci:
	mov     di,0
otroDeci:
	cmp		di,9
	jg	    cnvNumDec
	cmp     byte[msjDeci+di],'0'
	jb      error
	cmp     byte[msjDeci+di],'9'
	ja      error
	add		di,1
    jmp		otroDeci

cnvNumHexa:
    mov		di,0

	
cnvNumDec:
; para poder pasar de caracter a binario tengo que tomar un caracter y restarle 48, luego
; tengo que multiplicar ese binario por la posicion que ocupa en la cadena.
	mov  di,0 ; pongo direccionamiento en 0.
otroCharDec:	
	cmp  di,9
	je   finCnvDec
	mov  si,9 
	sub  si,di
	mov  ax,byte[msjDeci+di] ;cargo caracter
	sub  ax,48 ; convierto a binario
    
otraMulDec:
	cmp  si,0
	je   finMulDec
	mul  10
	sub  si,1
	jmp  otraMulDec
finMulDec:
	add  di,1
	add  [numero],ax
	jmp  otroCharDec
finCnvDec:
	jmp	 binToHexa

; a partir de aqui se hacen las conversiones de binario a su correspondiente
; configuracion para imprimir en pantalla.	
 
binToDec:
    mov     dx,0       ;pongo en 0 dx para la dupla dx:ax
    mov     ax,[num]  ;copio el nro en AX para divisiones sucesivas
    mov     si,9       ;'si' apunta al ultimo byte de la cadena
otraDiv:
    div     word[diez]      ;dx:ax div 10 ==> dx <- resto & ax <- cociente
    add     dx,48             ;convierto a Ascii el resto
    mov     [cadena+si],dl  ;lo pongo en la posicion anterior
    sub     si,1              ;posiciono SI en el caracter anterior en la cadena
    cmp     ax,[diez]   ;IF    cociente < 10
    jl      finDiv      ;THEN  fin division
    mov     dx,0        ;pongo en 0 DX para la dupla DX:AX
    jmp     otraDiv
finDiv:
    add     ax,48
    jmp     impStr
    
binToHexa:  
    mov     dx,0        ;pongo en 0 dx para la dupla dx:ax
    mov     ax,[num]  ;copio el nro en AX para divisiones sucesivas
    mov     si,9        ;'si' apunta al ultimo byte de la cadena
otraDivHexa:
    div     word[dieciseis]      ;dx:ax div 10 ==> dx <- resto & ax <- cociente
    cmp     dx,10
    jl      esNumeroHexa
    add     dx,55             ;convierto a Ascii el resto
    jmp     strNumHexa
esNumeroHexa:
    add     dx,48
    jmp     strNumHexa
strNumHexa:
    mov     [cadena+si],dl  ;lo pongo en la posicion anterior
    sub     si,1              ;posiciono SI en el caracter anterior en la cadena
    cmp     ax,[dieciseis]  ;IF    cociente < 16
    jl      finDivHexa      ;THEN  fin division
    mov     dx,0        ;pongo en 0 DX para la dupla DX:AX
    jmp     otraDivHexa
	
finDivHexa:
    cmp     ax,10
    jl      esNumHexa
    add     ax,55
    jmp     impStr
esNumHexa:
    add     ax,48
    jmp     impStr

impStr:
    mov     [cadena+si],al
    lea     dx,[cadena]
    mov     ah,9
    int     21h
    jmp     finPrograma
errorLetra:
    mov dx,msgMues      ;dx <- offset de 'msgMues' dento del segmento de datos
    mov ah,9            ;servicio 9 para int 21h -- Impmrimir msg en pantalla
    int 21h

    mov dl,[char]       ; dl <- caracter ascii a imprimir
    mov ah,2            ; servicio 2 para int 21h -- Imprime un caracter, que esta en 'dl'
    int 21h
	finPrograma:
    mov     ax,4c00h   ;retorno al DOS
    int     21h
