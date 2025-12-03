;*******************************************************************************
;* Digitális technika (VIMIAA03) 11. gyakorlat és laboratórium                 *
;* Knight Rider futófény szoftveres és hardveres idõzítéssel.                  *
;*******************************************************************************
DEF LD  0x80                ; LED adatregiszter            (írható/olvasható)
DEF TR  0x82                ; Timer kezdõállapot regiszter (csak írható)
DEF TM  0x82                ; Timer számláló regiszter     (csak olvasható)
DEF TC  0x83                ; Timer parancs regiszter      (csak írható)
DEF TS  0x83                ; Timer státusz regiszter      (csak olvasható)


;*******************************************************************************
;* A program kezdete. A programmemória 0x00 és a 0x01 címe a reset, illetve    *
;* a megszakítás vektor. Ide ugró utasításokat kell elhelyezni, amelyek a      *
;* megfelelõ programrészre ugranak. Ha nem használunk megszakítást, akkor a    *
;* program kezdõdhet a 0x00 címen is.                                          *
;*******************************************************************************
start:
    jsr tmr_init
    mov r0, #0xE0   ;kezdoertek
    
shr_loop:                   ;Ciklus a jobbra léptetéshez.
    mov LD, r0      ;kijelzes
    jsr tmr_wait     ;varakozas
    sr0 r0          ;jobbra taszitjuk
    cmp r0, #0x07   ;vegeztunk-e
    jnz shr_loop    ;ha nem akkor ujbol
shl_loop:                   ;Ciklus a balra léptetéshez.
    mov LD, r0      ;kijelzes
    jsr tmr_wait     ;varakozas
    sl0 r0          ;jobbra taszitjuk
    cmp r0, #0xE0   ;vegeztunk-e
    jnz shl_loop    ;ha nem akkor ujbol
    jmp shr_loop    ;egyebkent ugrunk a loopok elejere

;*******************************************************************************
;* Szoftveres idõzítési szubrutin. 24 bites ciklusváltozót kell használnunk,   *
;* melyet nulláról indítva és egyesével növelve kb. 12,58 másodpercig fog      *
;* futni a szubrutin. Tehát a kívánt 0,25 másodperces várakozáshoz a ciklus-   *
;* változót 50-nel kell növelni.                                               *
;*******************************************************************************
sw_wait:
    mov r10, #0
    mov r11, #0
    mov r12, #0
sw_wait_loop:
    add r10, #40            ;8MHz az orajel alatt 0.25 sec-et akarunk varni = 2 alatt 4 operaciot kell megcsinalni (=500 000), hogy tulcsorduljon a 24 bit, 2^24/500 000=
    adc r11, #0             ;adjuk hozza csak a carry erteket
    adc r12, #0             ;adjuk hozza csak a carry erteket
    jnc sw_wait_loop        ;varakozas az utolso regiszter tulcsordulasara
    rts                     ;Visszatérés a hívóhoz.
    

;*******************************************************************************
;* A timer perifériát inicializáló szubrutin. Ismétlõdéses mûködési módot kell *
;* beállítani. Ha elõosztásnak 65536-ot választunk, akkor az idõzítõ számláló  *
;* kezdõértéke 60 kell, hogy legyen a 0,25 másodperces idõzítési periódushoz.  *
;* (60 + 1) * 65536 * 62,5 ns ~ 0,25 s                                         *
;*******************************************************************************
tmr_init:
    mov r10, #122           ;
    mov TR, r10             ;kezdoertek
    mov r10, #0x63          ;TC erteke 16384 leosztas, repetativ timer engedelyezve
    mov TC, r10             ;Timer elinditasa
    rts                     ;Visszatérés a hívóhoz.

    
;*******************************************************************************
;* Hardveres idõzítési szubrutin. A timer periféria státusz regiszterében a    *
;* TOUT bit (bit 2) jelzi az idõzítési periódus végét, erre kell várakoznunk.  *
;* A státusz regiszter olvasása automatikusan törli a TOUT bitet.              *
;*******************************************************************************
tmr_wait:
    mov r10, TS
    tst r10, #0x04          ;TOUT bit tesztelese
    jz tmr_wait             ;varunk amig le nem jart az idozites
    rts                     ;Visszatéts a hívóhoz.
    
