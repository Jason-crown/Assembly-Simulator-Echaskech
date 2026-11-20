*-----------------------------------------------------------
* Title      : Echaskech
* Written by : Jason Klutse
* Date       : 2026-11-19
* Description: Draw in the simulator using the arrow keys
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
X   equ     8
Y   equ     10
* Put program code here    
                clr.l       d5
                clr.l       d6
Main:           
                jsr         MENU
LOOP:           

                jsr         CHECK_ARROWS
                jsr         CHECK_INPUTS
                move.w      d5,-(a7)
                move.w      d6,-(a7)
                jsr         WRITE
                addq        #8,(a7)
                jsr         SLEEP
                
                jsr         LOOP
                
CHECK_ARROWS:                           ; get arrow inputs\
                move.b      #19,d0    
                move.l      #$25262728,d1
                trap        #15
                
                tst.b       d1
                bne         DOWN

                lsr.l       #8,d1
                tst.b       d1
                bne         RIGHT
                
                lsr.l       #8,d1
                tst.b       d1
                bne         UP
                
                lsr.l       #8,d1
                tst.b       d1
                bne         LEFT
                
                move.b      #19,d0    
                move.l      #'awds',d1
                trap        #15 

                tst.b       d1
                bne         DOWN

                lsr.l       #8,d1
                tst.b       d1
                bne         RIGHT
                
                lsr.l       #8,d1
                tst.b       d1
                bne         UP
                
                lsr.l       #8,d1
                tst.b       d1
                bne         LEFT

                move.b      #19,d0    
                move.l      #'AWDS',d1
                trap        #15 

                tst.b       d1
                bne         DOWN

                lsr.l       #8,d1
                tst.b       d1
                bne         RIGHT
                
                lsr.l       #8,d1
                tst.b       d1
                bne         UP
                
                lsr.l       #8,d1
                tst.b       d1
                bne         LEFT                  
                rts
                
DOWN:
                addi        #1,d5
                rts
RIGHT:           
                addi        #1,d6
                rts
UP:
                subi        #1,d5
                rts
LEFT:
                subi        #1,d6               
                rts
                
CHECK_INPUTS:
                movem.l     d0-d1,-(a6)
                move.b      #19,d0    
                move.l      #'MmCc',d1
                trap        #15
                
                tst.b       d1
                bne         CLEAR
                
                lsr.l       #8,d1
                tst.b       d1
                bne         CLEAR
                
                lsr.l       #8,d1
                tst.b       d1
                bne         MENU
                
                lsr.l       #8,d1
                tst.b       d1
                bne         MENU
                movem.l     (a6)+,d0-d1
                rts 
MENU:
                               
CLEAR:          
                movem.l     d0-d1,-(sp)
                move.w      #$FF00,d1
                move.b      #11,d0
                trap        #15
                movem.l     (sp)+,d0-d1                
                rts    

SLEEP:
                movem.l     d0-d1,-(sp)
                move.b      #23,d0
                move.l      #5,d1
                trap        #15
                movem.l     (sp)+,d0-d1
                rts 
                
    
_SET_COLOR:                 ; $00BBGGRR
                movem.l     d0-d1,-(sp)
                move.l  8(a6),d1
                move.b  #80,d0          ; Task 80: Set pen color
                trap    #15             ; Execute simulator task
                movem.l     (sp)+,d0-d1
                rts

WRITE:
                link        a6,#0
                movem.l     d0-d2,-(a7)
                move.w      X(a6),d1
                move.w      Y(a6),d2
                move.b      #82,d0          ; Task 82: Draw pixel in pen color
                trap        #15             ; Execute simulator task
                movem.l     (a7)+,d0-d2
                unlk        a6 
                rts



    SIMHALT             ; halt simulator

* Put variables and constants here
DIS dc.b   'm = Color (00RRGGBB), c = Clear stage',0
MSG dc.b   'Input (00RRGGBB)',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
