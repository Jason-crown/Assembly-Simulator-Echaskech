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
                move.l      #$00FF00FF,d1
                jsr         STCOL
Main:           
                move.w      #100,d5
                move.w      #100,d6
                lea         DIS,a1
                move.b      #13,d0
                trap        #15
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
                
                movem.l     d0-d1,-(a7)
                move.b      #19,d0    
                move.l      #'0011',d1
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
                movem.l     (a7)+,d0-d1
                rts 
MENU:
                jsr         CLR_LN
                lea         MSG,a1
                move.b      #13,d0
                trap        #15
                
                lea         BUF,a1
                move.b      #2,d0
                trap        #15
                
                jsr         ASCII_TO_HEX
                
                move.l      d0,d1
                move.b      #16,d2
                move.b      #15,d0
                trap        #15
                        
                jsr         STCOL
                jsr         LOOP
                rts
CLEAR:          
                movem.l     d0-d1,-(sp)
                move.w      #$FF00,d1
                move.b      #11,d0
                trap        #15
                movem.l     (sp)+,d0-d1 
                jsr         Main               
                rts    

SLEEP:
                movem.l     d0-d1,-(sp)
                move.b      #23,d0
                move.l      #5,d1
                trap        #15
                movem.l     (sp)+,d0-d1
                rts 
                  
STCOL:                 ; $00BBGGRR
                move.b      #80,d0          ; Task 80: Set pen color
                trap        #15             ; Execute simulator task
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
CLR_LN:
                movem.l     d0-d1/a1,-(a7)
                move.b      #11,d0
                move.w      #$0000,d1
                trap        #15
                
                lea         DIS,a1
                move.b      #13,d0
                trap        #15
                movem.l     (a7)+,d0-d1/a1
                rts
ONECHO:
                movem.l     d0-d1,-(a7)
                move.b      #12,d0
                move.b      4(a6),d1
                trap        #15
                movem.l     (a7)+,d0-d1
                rts
                
NEW_LINE:   
                movem.l     d0-d1,-(a7)
                move.w      #6,d1
                move.w      #$0D,d1
                trap        #15
                move.w      #$0A,d1
                trap        #15
                movem.l     (a7)+,d0-d1
                rts
                


ASCII_TO_HEX:
                movem.l     d2-d3/A0,-(a7)
                clr.l       d0
                clr.l       d1
                moveq       #7,d2
NEXT_CHAR:      move.b      (a0)+,d3
                cmpi.b      #'0',d3
                blt.s       INVALID_CHAR
                cmpi.b      #'9',d3
                ble.s       IS_DIGIT
                andi.b      #$DF,d3
                cmpi.b      #'A',d3
                blt.s       INVALID_CHAR
                cmpi.b      #'F',d3
                bgt.s       INVALID_CHAR
                subi.b      #'A'-10,d3
                bra.s       SHIFT_IN
IS_DIGIT:       subi.b      #'0',d3
SHIFT_IN:       lsl.l       #4,d0
                andi.l      #$0F,d3
                or.b        d3,d0
                dbra        d2,NEXT_CHAR
                bra.s       done
INVALID_CHAR:   moveq       #1,d1
DONE:           movem.l     (a7)+,d2-d3/a0
                rts
    SIMHALT             ; halt simulator

* Put variables and constants here
DIS dc.b   '0 = Color (00RRGGBB), 1 = Clear stage',0
MSG dc.b   'Input (00RRGGBB)',0
BUF ds.b    80
BLK dc.b   '                                                                                 ',0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
