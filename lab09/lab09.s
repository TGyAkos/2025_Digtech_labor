DEF LD 0x80 ; A LED-ek memoria cime
DEF SW 0x81 ; A Switch memoria cime

CODE


szoroz:
    mov r0, SW
    mov r1, r0
    and r0, #0x0f   ; A operandus elokeszitese
    swp r1          ; Inkrementalas
    and r1, #0x0f   
    mov r2, #0      
    mov r3, #4
    
mul:
    SR0 r0         ; szorzoshift jobb
    jnc skipadd   ; ha 0 a szorzo nincs osszeadas
    add r2,r1      ; eredemny novelese
skipadd:
    sl0 r1         ; szorzando shift
    sub r3, #1     ; ciklus valtozo csokkentese
    jnz mul        ; 4 szer kell vegrehajtani
    
    mov LD, r2
    
    jmp szoroz
    
    
; osszeado
start: 
    mov r0, SW      ; Switchek ertekenek beolvasasa
    mov r1, r0      ; Switch ertekek csereje
    and r0, #0x0f   ; A operandus elokeszitese
    swp r1          ; Inkrementalas
    and r0, #0x0f   
    mov LD, r0      ; LED-ekre kiiras
    jmp start
    
; Kettes komplemens
start2: 
    mov r0, SW      ; Switchek ertekenek beolvasasa
    xor r0, #0xFF   ; Negalas
    add r0, #1      ; Inkrementalas
    mov LD, r0      ; LED-ekre kiiras
    jmp start2