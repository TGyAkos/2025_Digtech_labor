;*******************************************************************************
;* Digitális technika (VIMIAA03) 10. gyakorlat és laboratórium                 *
;* Legnagyobb közös osztó számítása szoftveresen.                              *
;*******************************************************************************
DEF SW   0x81                ; DIP kapcsoló adatregiszter           (csak olvasható)
DEF BT   0x84                ; Nyomógomb adatregiszter              (csak olvasható)
DEF DIG0 0x90                ; Kijelzõ DIG0 adatregiszter           (írható/olvasható)
DEF DIG1 0x91                ; Kijelzõ DIG1 adatregiszter           (írható/olvasható)
DEF DIG2 0x92                ; Kijelzõ DIG2 adatregiszter           (írható/olvasható)
DEF DIG3 0x93                ; Kijelzõ DIG3 adatregiszter           (írható/olvasható)


;*******************************************************************************
;* A program kezdete. A programmemória 0x00 és a 0x01 címe a reset, illetve    *
;* a megszakítás vektor. Ide ugró utasításokat kell elhelyezni, amelyek a      *
;* megfelelõ programrészre ugranak. Ha nem használunk megszakítást, akkor a    *
;* program kezdõdhet a 0x00 címen is.                                          *
;*******************************************************************************
start:
    mov r0, BT ; gombok beolvasasa
    tst r0, #0x01 ; BT0 tesztelese
    jz start      ; BT0 lenyomasara varunk
    
read_a:
    mov r1, SW  ; Switch ertek beolvasasa
    
    mov r8, r1  ; szam megjeleitetese
    mov r9, #DIG0
    jsr disp_wr;
    
    mov r0, BT  ; Gombok beolvasasa
    tst r0, #0x02 ; Varakozas BT2-re
    jz read_a
read_b:
    mov r2, SW  ; Switch ertek beolvasasa
    
    mov r8, r2  ; szam megjeleitetese
    mov r9, #DIG1
    jsr disp_wr;
    
    mov r0, BT  ; Gombok beolvasasa
    tst r0, #0x04 ; Varakozas BT2-re
    jz read_b
gcd_loop:                       ;Az LNKO számítás kezdete.
    mov r8, r1  ; szam megjeleitetese
    mov r9, #DIG0
    jsr disp_wr;
    
    mov r8, r2  ; szam megjeleitetese
    mov r9, #DIG1
    jsr disp_wr;
    
    cmp r1, r2      ; z ha egyenlo, c ha r2>r1 (B>A)
    jc b_gt_a
    jz start
a_gt_b:                         ;A > B eset.
    sub r1,r2
    jmp     gcd_loop            ;Ugrás a ciklus elejére.
    
b_gt_a:                         ;A < B eset.
    sub r2, r1
    jmp     gcd_loop            ;Ugrás a cuklus elejére.
    

;*******************************************************************************
;* Két digites megjelenítés a hétszegmenses kijelzõn.                          *
;* Paraméterek:                                                                *
;*   r8: A megjelenítendõ szám.                                                *
;*   r9: Az egyesek helyiértékéhez tartozó digit regiszter címe.               *
;*******************************************************************************
disp_wr:
    mov r10,r8      ; megjeleditendo
    and r10, #0x0f  ; also negy bit megtartasa
    add r10, #bin_7seg
    mov r10, (r10) ; mutatott ertek bemutatasa az r10-be
    mov (r9), r10
    mov r10, r8
    swp r10
    and r10, #0x0f
    add r9, #1
    add r10, #bin_7seg
    mov r10, (r10)
    mov (r9), r10
    rts                         ;Visszatérés a hívóhoz.


;*******************************************************************************
;* Két digites BCD kivonás.                                                    *
;* Paraméterek:                                                                *
;*   r8: Kisebbítendõ.                                                         *
;*   r9: Kivonandó.                                                            *
;* Visszatérési érték:                                                         *
;*   r8: Különbség.                                                            *
;*******************************************************************************
;bcd_sub:
    ;mov     r10, r8             ;Másolat készítése a kisebbítendõrõl.
    ;mov     r11, r9             ;Másolat készítése a kivonandóról.
    ;and     r10, #0x0f          ;A felsõ 4 bit törlése a másolatokban.
    ;and     r11, #0x0f
    ;sub     r10, r11            ;A kivonás elvégzése az egyesek helyiértékén.
    ;mov     r11, r10            ;Másolat készítése a különbségrõl.
    ;tst     r10, #0x10          ;A 4 bites különbség negatív (volt átvitel)?
    ;jz      no_corr1            ;Ugrás, ha nem.
    ;add     r10, #0x0a          ;Negatív különbség esetén BCD korrekció (+10).
;no_corr1:
    ;and     r10, #0x0f          ;A különbség alsó 4 bitje kell csak.
    ;and     r11, #0x10          ;A másolatból az átvitel kell csak.
    
    ;and     r8, #0xf0           ;Az alsó 4 bit törlése az eredeti adatokban.
    ;and     r9, #0xf0
    ;add     r9, r11             ;A kivonandóhoz hozzáadjuk az átvitelt.
    ;sub     r8, r9              ;A kivonás elvégzése a tizesek helyiértékén.
    ;jnc     no_corr10           ;Ugrás, ha a különbség nemnegatív.
    ;add     r8, #0xa0           ;Negatív különbség esetén BCD korrekció (+10).
;no_corr10:

    ;or      r8, r10             ;A teljes 2 digites különbség.
    ;rts                         ;Visszatérés a hívóhoz.


;*******************************************************************************
;* Az adatmemória inicializálása a hétszegmenses dekóder táblázattal.          *
;*******************************************************************************
    DATA
    
bin_7seg:
    DB      0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
    DB      0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71
    