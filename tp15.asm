;******************************************************************
; Ejercicio que transforma un nro en binario a su representacion en
; en ASCII mediante divisiones sucesivas y lo imprime en pantalla
; en base 16
;*******************************************************************

segment pila stack
   resb 1024
segment datos data
;    msjDeci     times 10  db  '0000002015'
;    msjHexa     times 10  db  '00000007DF'
    otraCadena times 10 db '0000000000'
         db '$'
    cadena      times 10 db '0'
                db '$'
    cadenaAux times 10 db '0000000000'
         db '$'
    
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
    
;para agregar el fin de string para imprimir por pantalla

segment codigo code
..start:
    mov     ax,datos       ;ds <-- dir del segmento de datos
    mov     ds,ax
    mov     ax,pila     ;ss <-- dir del segmento de pila
    mov     ss,ax

; aca comienza lectura por teclado .
    mov  si,0       ;Reg SI apunta al ppio de la cadena
nextChar:
    ;Leo un caracter del teclado (queda en AL)
    mov  ah,8h      
    int  21h

    cmp  al,13      ;presionó enter?
    je   finIngreso
    
    cmp  al,8       ;presionó back space?
    jne  noBorra
    
    cmp  si,0       ;presionó backspace al inicio?
    je   nextChar
    dec   si
    mov  byte[otraCadena+si],'0'    ;borro caracter ingresado anteriormente
    

    ;Imprimo backspace (vuelve para atras el cursor)
    mov  dl,al
    mov  ah,2
    int  21h    

    ;Imprimo un espacio en blanco para q borre el caracter anterior
    mov  dl,32
    mov  ah,2
    int  21h    

    ;Imprimo de nuevo el backspace para q el cursor quede en la posicion del caracter borrado
    mov  dl,8
    mov  ah,2
    int  21h    

    jmp  nextChar

noBorra:    
    ;Copio en la cadena el caracter ingresado
    mov  [otraCadena+si],al
    ;Imprimo en pantalla el caracter ingresado
    mov  dl,al      ; dl <-- caracter ascii a imprimir
    mov  ah,2
    int  21h    
    
    ;Me fijo si es el fin de la cadena
    inc  si
    cmp  si,10
    jl  nextChar

finIngreso:
    mov  byte[otraCadena+si],'$'
;   sub  si,1
    mov  di,10
    sub  di,si
    mov  si,0
otroChar:
    cmp  di,10
    je   finOtroChar
    mov  ah,byte[otraCadena+si]
    mov  byte[cadenaAux+di],ah
    add  di,1
    add  si,1
    jmp  otroChar
finOtroChar:
    mov  byte[cadenaAux+10],'$'
    
    mov  dx,msgMues        ;dx <-- offset de 'msgMues' dento del segmento de datos
    mov  ah,9                   ; servicio 9 para int 21h -- Impmrimir msg en pantalla
    int  21h

    mov  dx,cadenaAux
    mov  ah,9
    int  21h


 
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
    jmp     cnvNumHexa
    mov     di,0
    
otroHexa:
    cmp     di,9
    jg      cnvNumHexa
    cmp     byte[cadenaAux+di],'0'
    jb      error
    cmp     byte[cadenaAux+di],'9'
    jbe     otroHexa
    cmp     byte[cadenaAux+di],'A'
    jb      error
    cmp     byte[cadenaAux+di],'F'
    jbe     otroHexa
sumDiHexa:
    add     di,10
    jmp     otroHexa

error:
    jmp     finPrograma

charToDeci:
    jmp     cnvNumDec
    mov     di,0
otroDeci:
    cmp     di,9
    jg      cnvNumDec
    cmp     byte[cadenaAux+di],'0'
    jb      error
    cmp     byte[cadenaAux+di],'9'
    ja      error
    add     di,1
    jmp     otroDeci

cnvNumHexa:
    mov     di,0
otroCharHex:
    cmp     di,10
    je      finCnvHex
    mov     si,9
    sub     si,di
    mov     ah,0
    mov     al,byte[cadenaAux+di]
    cmp     ax,57
    jbe     subDecHex
; no tendria que haber error antes de que llegue a esta parte.
    sub     ax,55
    jmp     otraMulHex
subDecHex:
    sub     ax,48
    jmp     otraMulHex
subCharHex:
   
otraMulHex:
    cmp  si,0
    je   finMulHex
    mul  word[dieciseis]
    sub  si,1
    jmp  otraMulHex
finMulHex:
    add  di,1
    add  [num],ax
    jmp  otroCharHex
finCnvHex:
    jmp  binToDec   

    
cnvNumDec:
; para poder pasar de caracter a binario tengo que tomar un caracter y restarle 48, luego
; tengo que multiplicar ese binario por la posicion que ocupa en la cadena.
    mov  di,0 ; pongo direccionamiento en 0.
otroCharDec:    
    cmp  di,10
    je   finCnvDec
    mov  si,9 
    sub  si,di
    mov  ah,0
    mov  al,byte[cadenaAux+di] ;cargo caracter
    sub  ax,48 ; convierto a binario
    
otraMulDec:
    cmp  si,0
    je   finMulDec
    mul  word[diez]
    sub  si,1
    jmp  otraMulDec
finMulDec:
    add  di,1
    add  [num],ax
    jmp  otroCharDec
finCnvDec:
    jmp  binToHexa

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
