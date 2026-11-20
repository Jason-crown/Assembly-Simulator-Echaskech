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
                move.l      #$00FFFFFF,d1
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
                move.b      #14,d0
                trap        #15
                
                lea         BUF,a1
                move.b      #2,d0
                trap        #15
                
                clr.l       d2
                clr.l       d3
                
PARSE_LOOP:
                move.b      (a1)+,d3
                beq         DONE
                
                cmp.b       #'$',d3
                beq         PARSE_LOOP
                
                cmp.b       #'0',d3
                blt         INVALID
                cmp.b       #'9',d3
                ble         IS_DIGIT
                
                and.b       #$DF,d3
                cmp.b       #'A',d3
                blt         INVALID
                cmp.b       #'F',d3
                bgt         INVALID
                
                sub.b       #'A'-10,d3
                bra         SHIFT_IN
                
IS_DIGIT:
                sub.b       #'0',d3
SHIFT_IN:       
                lsl.l       #4,d2
                or.b        d3,d2
                bra         PARSE_LOOP
INVALID:        
                lea         ESG,a1
                move.b      #13,d0
                trap        #15
                bra         START
DONE:
                move.l      d2,d1        
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
                
NEW_LINE:   
                movem.l     d0-d1,-(a7)
                move.w      #6,d1
                move.w      #$0D,d1
                trap        #15
                move.w      #$0A,d1
                trap        #15
                movem.l     (a7)+,d0-d1
                rts
                


    SIMHALT             ; halt simulator

* Put variables and constants here
DIS dc.b   '0 = Color (00RRGGBB), 1 = Clear stage',0
MSG dc.b   'Input (00RRGGBB)',0
BUF ds.b   82
ESG dc.b   'Invalid hex character!',0
BLK dc.b   '                                                                                 ',0
    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
