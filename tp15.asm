;******************************************************************
; Ejercicio que transforma un nro en binario a su representacion en
; en ASCII mediante divisiones sucesivas y lo imprime en pantalla
; en base 16
;*******************************************************************

segment pila stack
   resb 1024
segment datos data

    char     resb   1
    hexa        db      'H'
    deci        db      'D'
    msgIng      db      10,13,"H - Hexa to Decimal. D - Decimal to Hexa: ",10,13,'$'
    msgMues     db      10,13,"Ud ingreso: $"
    num         dw  2015
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
    
    lea dx,[msgIng] ;dx <-- offset de 'msgIng' dento del segmento de datos
    mov ah,9            ;servicio 9 para int 21h -- Impmrimir msg en pantalla
    int 21h

    mov ah,8h           ;servicio 1 para int 21h -- lee caracter de teclado y lo muestra, lo deja en 'al'
    int 21h

    mov [char],al   ;guardo en char el ascii del caracter ingresado ya que el servicio
                    ;que se ejecuta a continuación altera 'al' copiando el ascii del signo $
    cmp byte[char],'H'
    je  binToHexa
    cmp byte[char],'D'
    je  binToDec
    jmp errorLetra

    
    ;    jmp        binToHexa
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
