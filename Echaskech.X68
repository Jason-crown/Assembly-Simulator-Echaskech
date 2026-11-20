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
Main:           
LOOP:           

                jsr         CHECK_ARROWS
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
                move.w      #6,d0
                move.w      #'D',d1
                trap        #15
                rts
RIGHT:           
                move.w      #6,d0
                move.w      #'R',d1
                trap        #15
                rts
UP:
                move.w      #6,d0
                move.w      #'U',d1
                trap        #15
                rts
LEFT:
                move.w      #6,d0
                move.w      #'L',d1
                trap        #15               
                rts
SLEEP:
                movem.l     d0-d1,-(sp)
                move.b      #23,d0
                move.l      #5,d1
                trap        #15
                movem.l     (sp)+,d0-d1
                rts 
                
    
_SET_COLOR:                 ; $00BBGGRR
    move.b  #80,d0          ; Task 80: Set pen color
    trap    #15             ; Execute simulator task
    rts





    SIMHALT             ; halt simulator

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
