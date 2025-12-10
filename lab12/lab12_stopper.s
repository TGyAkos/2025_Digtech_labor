;*******************************************************************************
;* Digitális technika (VIMIAA03) 12. gyakorlat és laboratórium                 *
;* Stopperóra hardveres idõzítés és megszakítás használatával.                 *
;*******************************************************************************
DEF TR   0x82               ; Timer kezdõállapot regiszter         (csak írható)
DEF TM   0x82               ; Timer számláló regiszter             (csak olvasható)
DEF TC   0x83               ; Timer parancs regiszter              (csak írható)
DEF TS   0x83               ; Timer státusz regiszter              (csak olvasható)
DEF BT   0x84               ; Nyomógomb adatregiszter              (csak olvasható)
DEF BTIE 0x85               ; Nyomógomb megszakítás eng. regiszter (írható/olvasható)
DEF BTIF 0x86               ; Nyomógomb megszakítás flag regiszter (olvasható és a bit 1 beírásával törölhetõ)
DEF DIG0 0x90               ; Kijelzõ DIG0 adatregiszter           (írható/olvasható)
DEF DIG1 0x91               ; Kijelzõ DIG1 adatregiszter           (írható/olvasható)
DEF DIG2 0x92               ; Kijelzõ DIG2 adatregiszter           (írható/olvasható)
DEF DIG3 0x93               ; Kijelzõ DIG3 adatregiszter           (írható/olvasható)
DEF LD   0x80               ; LED-ek                               (írható/olvasható)

; A stopperóra állapotai.
DEF IDLE 0x02               ; A stopper nullázva van és áll.
DEF RUN  0x01               ; A stopper fut.
DEF STOP 0x00               ; A stopper áll, mutatja a mért idõt.


    CODE

;*******************************************************************************
;* A program kezdete. A programmemória 0x00 és a 0x01 címe a reset, illetve    *
;* a megszakítás vektor. Ide ugró utasításokat kell elhelyezni, amelyek a      *
;* megfelelõ programrészre ugranak.                                            *
;*******************************************************************************
reset_vector:
    jmp     start           ;Ugrás a program kezdetése.
irq_vector:
    jmp     irq_handler     ;Ugrás a megszakításkezelõ rutinra.


;*******************************************************************************
;* Fõprogram.                                                                  *
;*******************************************************************************
start:
    mov r15, #0
    jsr stopper_init        ;Stopper szalmalok inicializasa
    jsr tmr_init            ;Timer inicializalas
    jsr btn_init            ;Button inicializasa
    sti                     ;Megszakitasok engedelyezese
loop:                       ;Végtelen ciklus. A megszakításkezelõ rutinban
    jmp     loop            ;végezzük el a szükséges feladatokat.
    

;*******************************************************************************
;* A stopper alapállapotba állítása.                                           *
;*******************************************************************************
stopper_init:
    mov r11, #0              ;0.1s szamalo nullazasa 0..9
    mov r12, #0              ;1s   szamalo nullazasa 0..9
    mov r13, #0              ;10s  szamalo nullazasa 0..5
    mov r14, #0              ;1m   szamalo nullazasa 0..9
    rts                     ;Visszatérés a hívóhoz.
    
    
;*******************************************************************************
;* Az idõzítõ inicializálása ismétlõdéses módban 100 ms periódusidõvel és      *
;* megszakításkéréssel.                                                        *
;*******************************************************************************
tmr_init:
    mov r0, TS              ;Statusz kiolvasasa (a timer statusz kiolvasasa a timer interupt nyugtazasa)
    mov r0, #97             ;Szamlalo kezdoertek
    mov TR, r0
    mov r0, #0xE3           ;IT engedely, 16... leosztas, repetativ mod (TC: 1110 0011) 11. eloadas dia alapjan
    mov TC, r0              ;Timer config bellitasa
    rts                     ;Visszatérés a hívóhoz.


;*******************************************************************************
;* A nyomógomb periféria inicializálása. A BT0 állapotváltozása esetén legyen  *
;* megszakításkérés.                                                           *
;*******************************************************************************
btn_init:
    mov r0, #0x01           ;BTO ITE (InTerrupt Enable)
    mov BTIE, r0            ;Button 0 IT engedelyezese
    rts                     ;Visszatérés a hívóhoz.
    
    
;*******************************************************************************
;* Egydigites megjelenítés a hétszegmenses kijelzõn.                           *
;* Paraméterek:                                                                *
;*   r8: A megjelenítendõ szám az alsó 4 biten, MSb a tizedespont állapota.    *
;*   r9: A használandó digit regiszter címe.                                   *
;*******************************************************************************
disp_wr:
    and r8, #0x0F           ;Az also 4 bit megtartasa (maszkolas)
    add r8, #bin_7seg       ;A szegmens kod cimenek eloallitasa
    mov r8, (r8)            ;Az r8-ba belemozgatjuk az r8 ertekeben tarolt erteket cimkent
    mov (r9), r8            ;Megjelenites, az r9-ben mutatott cimbe belemozgatjuk az r8-ban tarolt erteket
    rts                     ;Visszatérés a hívóhoz.
  

;*******************************************************************************
;* Megszakításkezelõ rutin.                                                    *
;*******************************************************************************
irq_handler:
    ;Az idõzítõ megszakítás ellenõrzése.
    mov r8, TS              ;Timer statusz kiolvasas (nyugtazas)
    tst r8, #0x80           ;Timer IT volt-e?
    jnz tmr_irq
    
    ;A nyomógomb megszakítás ellenõrzése.
    mov r8, BTIF            ;BuTton Interrupt Flag-ek beolvasasa
    tst r8, #0x01           ;BuTton 0-ra teszteles
    jnz btn_irq
    ;Érvénytelen megszakítás.
bad_irq:
    jmp     bad_irq         ;Nem várt megszakítás esetén végtelen ciklus.
    
    ;Az idõzítõ megszakítás kezelése.
tmr_irq:
    ;mov LD, r15             ;LED villogtatas
    ;xor r15, #0xFF          ;Invertalas
    
    ;A tizedmásodpercek számlálója.
    add r11, #1             ;adjunk hozza 0.1s szamlalohoz
    cmp r11, #10            ;teszteljuk hogy elerte-e a veget
    jnz disp_refresh        ;ha nem akkor refresh display
    mov r11, #0             ;Tulsordulas 0-zas
    ;A másodpercek számlálja.
    add r12, #1             ;adjunk hozza 1s szamlalohoz
    cmp r12, #10
    jnz disp_refresh
    mov r12, #0             ;Tulsordulas 0-zas
    ;A tíz másodpercek számlálója.
    add r13, #1             ;adjunk hozza 10s szamlalohoz
    cmp r13, #6
    jnz disp_refresh
    mov r13, #0             ;Tulsordulas 0-zas
    ;A percek számlálója.
    add r14, #1             ;adjunk hozza 1m szamlalohoz
    cmp r14, #10
    jnz disp_refresh
    mov r14, #0             ;Tulsordulas 0-zas
    ;A számlálók értékének megjelenítése a hétszegmenses kijelzõn.
    jmp tmr_irq_end         ;IT (interrupt) vege
disp_refresh:
    mov r8, r11             ;A 0.1s szamlalo erteket r8-ba mintha disp_wr(r8 ertek, r9 melyik_kijelzore)
    mov r9, #DIG0           ;r9 ertekenek megadasa melyik kijelzore jelezzuk
    jsr disp_wr             ;A subroutine meghivasa
    
    mov r8, r12             ;A 1s szamlalo erteket r8-ba mintha disp_wr(r8 ertek, r9 melyik_kijelzore)
    mov r9, #DIG1           ;r9 ertekenek megadasa melyik kijelzore jelezzuk
    jsr disp_wr             ;A subroutine meghivasa
    
    mov r8, r13             ;A 10s szamlalo erteket r8-ba mintha disp_wr(r8 ertek, r9 melyik_kijelzore)
    mov r9, #DIG2           ;r9 ertekenek megadasa melyik kijelzore jelezzuk
    jsr disp_wr             ;A subroutine meghivasa
    
    mov r8, r14             ;A 1m szamlalo erteket r8-ba mintha disp_wr(r8 ertek, r9 melyik_kijelzore)
    mov r9, #DIG3           ;r9 ertekenek megadasa melyik kijelzore jelezzuk
    jsr disp_wr             ;A subroutine meghivasa
tmr_irq_end:
    rti                     ;Visszatérés a megszakításból.
    
    ;A nyomógomb megszakítás kezelése.
btn_irq:
    mov r8, #0x01           ;BTO ITE (InTerrupt Enable) ujbol, ha, mert ki tudja mi tortent
    mov BTIF, r8            ;BT Interupt nyugtazasa
    mov LD, r15             ;LED villogtatas
    xor r15, #0xFF          ;Invertalas

btn_irq_end:
    rti                     ;Visszatérés a megszakításból.
    
    
;*******************************************************************************
;* Az adatmemória inicializálása a hétszegmenses dekóder táblázattal.          *
;*******************************************************************************
    DATA
    
bin_7seg:
    DB      0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
    DB      0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71
