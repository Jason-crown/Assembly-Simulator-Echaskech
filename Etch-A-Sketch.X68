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
                clr         d0
                clr         d1
                clr         d2              
                clr         d3              ; Board color
                clr         d4              ; Border color
                clr         d5              ; Y
                clr         d6              ; X
                clr         d7              ; Speed (sleep interval)
                
                * Default Colors
                move.l      #$00FFFFFF,d3   ; White
                move.l      #$000000FF,d4   ; Red
                move.w      #1,d7           ; Speed = 5 (6-d7 = speed)
                
                * Initialize 
                jsr         STCOL
                jsr         CRTBRD
                jsr         Main
                
CRTBRD:                                     ; Create drawing Board
                movem.l     d0-d2,-(a7)
                move.l      d3,d1
                jsr         STCOL
                                            ; Create Square
                move.w      #0,-(a7)
                move.w      #0,-(a7)
                move.w      #638,-(a7)
                move.w      #480,-(a7)
                jsr         _SHAPE
                addi        #8,(a7)
                
                movem.l     (a7)+,d0-d2
                jsr         CRTBOR
CRTBOR:                                     ; Create Borders
                movem.l     d0-d2,-(a7)
                move.l      d4,d1
                jsr         STCOL
                                            ; Top rectangle
                move.w      #0,-(a7)        
                move.w      #0,-(a7)
                move.w      #638,-(a7)
                move.w      #50,-(a7)
                jsr         _SHAPE
                addi        #8,(a7)
                
                move.w      #587,-(a7)      ; Right rectangle
                move.w      #0,-(a7)
                move.w      #638,-(a7)
                move.w      #480,-(a7)
                jsr         _SHAPE
                addi        #8,(a7)
                
                move.w      #0,-(a7)        ; Left rectangle
                move.w      #0,-(a7)
                move.w      #50,-(a7)
                move.w      #480,-(a7)
                jsr         _SHAPE
                addi        #8,(a7)
                
                move.w      #0,-(a7)        ; Bottem rectangle
                move.w      #430,-(a7)
                move.w      #638,-(a7)
                move.w      #480,-(a7)
                jsr         _SHAPE
                addi        #8,(a7)
                
                move.l      #$00000000,d1   ; Pen Color
                jsr         STCOL                
                movem.l     (a7)+,d0-d2
                
Main:                                       ; Main Subroutine
                                            ; Set Default starting position
                move.w      #100,d5
                move.w      #100,d6

                move.b      #11,d0
                move.w      #$0000,d1
                trap        #15

                lea         DIS,a1
                move.b      #13,d0
                trap        #15
LOOP:                                       ; Main LOOP
                                            ; Check inputs
                jsr         CHECK_ARROWS
                jsr         CHECK_INPUTS
                                            ; Write pixel (d6,d5)
                move.w      d5,-(a7)
                move.w      d6,-(a7)
                jsr         WRITE
                addq        #4,(a7)
                                            ; Pause for d7 ms
                move.l      d7,-(a7)
                jsr         SLEEP
                addq        #4,(a7)
                
                jsr         LOOP
                
CHECK_ARROWS:                               ; Get movements
                                            ; Arrow input
                move.b      #19,d0    
                move.l      #$25262728,d1
                trap        #15
                                            ; Down
                tst.b       d1
                bne         DOWN
                                            ; Right
                lsr.l       #8,d1
                tst.b       d1
                bne         RIGHT
                                            ; Up
                lsr.l       #8,d1      
                tst.b       d1
                bne         UP
                                            ; Left
                lsr.l       #8,d1
                tst.b       d1
                bne         LEFT
                                            ; 'W' 'A' 'S' 'D' input
                move.b      #19,d0    
                move.l      #'AWDS',d1
                trap        #15 
                
                and.b       #$DF,d1         ; Convert to uppercase
                                            ; Down                
                tst.b       d1
                bne         DOWN
                                            ; Right
                lsr.l       #8,d1
                tst.b       d1
                bne         RIGHT
                                            ; Up                
                lsr.l       #8,d1
                tst.b       d1
                bne         UP
                                            ; Left                
                lsr.l       #8,d1
                tst.b       d1
                bne         LEFT                  
                rts
                
DOWN:                                       ; Move down
                cmpi        #429,d5
                bge         CHECK_ARROWS
                addi        #1,d5
                rts
RIGHT:                                      ; Move right
                cmpi.w      #587,d6
                bge         CHECK_ARROWS
                addi        #1,d6
                rts
UP:                                         ; Move up
                cmpi.w      #50,d5
                ble         CHECK_ARROWS
                subi        #1,d5
                rts
LEFT:                                       ; Move left
                cmpi.w      #51,d6
                ble         CHECK_ARROWS
                subi        #1,d6   
                rts
            
CHECK_INPUTS:                               ; Check CLI inputs
                movem.l     d0-d1,-(a7)
                move.b      #19,d0    
                move.l      #'0123',d1
                trap        #15
                                            ; Clean drawing screen
                tst.b       d1
                bne         WIPE
                                            ; Change pause interval (speed)
                lsr.l       #8,d1
                tst.b       d1
                bne         SPEED
                                            ; Reset board
                lsr.l       #8,d1
                tst.b       d1
                bne         CLEAR
                                            ; Color Change sub task
                lsr.l       #8,d1
                tst.b       d1
                bne         COLOR
                movem.l     (a7)+,d0-d1
                rts 
                              
SPEED:                                      ; Change pause interval (speed) 
                movem.l     d0-d6,-(a7)
                                            ; Print Speed message
                jsr         CLR_LN
                lea         SMG,a1
                move.b      #14,d0
                trap        #15
                                            ; Get input
                move.b      #4,d0
                trap        #15
                                            ; Verify input
                cmpi        #6,d1
                bge         SPDERR
                cmpi        #0,d1
                ble         SPDERR
                                            ; Convert input into pause value
                subi        #6,d1
                neg         d1
                                            
                move.l      d1,d7
                bra         SPDEND
SPDERR:
                                            ; Display error text
                jsr         CLR_LN
                lea         EIG,a1
                move.b      #14,d0
                trap        #15
                                            ; 100ms delay
                move.l      #100,-(a7)
                jsr         SLEEP
                addq        #4,(a7)
                                            ; Try again
                jsr         SPEED                
SPDEND:
                movem.l     (a7)+,d0-d6
                jsr         LOOP        
                
COLOR:                                      ; Converts ASCII input into a hexadecimal output
                movem.l     d0-d2/d5-d7,-(a7)
                                            ; Prints message
                jsr         CLR_LN
                lea         MSG,a1
                move.b      #14,d0
                trap        #15
                                            ; Gets input and stores it in BUF
                lea         BUF,a1
                move.b      #2,d0
                trap        #15
                
                clr.l       d2
                clr.l       d5
PARSE_LOOP:                                 ; Loops through converting all 8 characters
                move.b      (a1)+,d5
                beq         DONE            ; Branch if 0 flag is set (end of the string)
                                            ; Ingnores '$' character
                cmp.b       #'$',d5
                beq         PARSE_LOOP
                                            ; Validate number inputs
                cmp.b       #'0',d5
                blt         INVALID
                cmp.b       #'9',d5
                ble         IS_DIGIT
                                            ; Validate letter inputs
                and.b       #$DF,d5         ; Converts to uppercase
                cmp.b       #'A',d5
                blt         INVALID
                cmp.b       #'F',d5
                bgt         INVALID
                
                sub.b       #'A'-10,d5      ; Converts letters
                bra         SHIFT_IN
IS_DIGIT:
                sub.b       #'0',d5         ; Converts numbers
SHIFT_IN:       
                lsl.l       #4,d2
                or.b        d5,d2
                bra         PARSE_LOOP
INVALID:                                    ; Prints error message
                jsr         CLR_LN
                lea         ESG,a1
                move.b      #13,d0
                trap        #15
                                            ; 100ms delay
                move.l      #100,-(a7)
                jsr         SLEEP
                addq        #4,(a7)
                                            ; Try again
                jsr         COLOR
DONE:                                       ; Sub Color CLI
                                            ; Prints options
                jsr         CLR_LN
                lea         MNU,a1
                move.b      #14,d0
                trap        #15
                                            ; Gets input
                move.w      #4,d0
                trap        #15
                                            ; Picks input
                cmpi.w      #4,d1
                beq         PENCOL
                cmpi.w      #5,d1
                beq         BORCOL
                cmpi.w      #6,d1
                beq         BRDCOL
BRDCOL:                                     ; Change board color
                move.l      d2,d3
                jsr         WIPE
                bra         CCEND
BORCOL:                                     ; Change Border color
                move.l      d2,d4
                jsr         CRTBOR          ; Print border
                                            ; Moves Cursor back to beginning of page
                move.b      #11,d0
                move.w      #$0000,d1
                trap        #15
                                            ; Redisplays options
                lea         DIS,a1
                move.b      #13,d0
                trap        #15
                
                bra         CCEND
PENCOL:                                     ; Change Pen color
                move.l      d2,d1 
                jsr         STCOL
CCEND:                                          
                jsr         CLR_LN          ; Clears text in row 2 and redisplays options
                movem.l     (a7)+,d0-d2/d5-d7   
                jsr         LOOP
                
CLEAR:                                      ; Resets board
                movem.l     d0-d1,-(sp)
                                            ; Clears Simulator
                move.w      #$FF00,d1       
                move.b      #11,d0
                trap        #15
                movem.l     (sp)+,d0-d1 
                jsr         CRTBRD            

SLEEP:                                      ; Pauses execuation for a inputed time time
                link        a6,#0
                movem.l     d0-d2,-(a7)
                                            ; Pauses for a set time
                move.l      8(a6),d1
                move.b      #23,d0
                trap        #15
                
                movem.l     (a7)+,d0-d2
                unlk        a6 
                rts 
                  
STCOL:                                      ; Sets pen color in ($00BBGGRR) form
                move.b      #80,d0          ; Task 80: Set pen color
                trap        #15
                rts

WRITE:                                      ; Writes a colored pixel at a inputed X and Y position
                link        a6,#0
                movem.l     d0-d2,-(a7)
                                            ; Draws a pixel at (d1,d2)
                move.w      X(a6),d1
                move.w      Y(a6),d2
                move.b      #82,d0          ; Task 82: Draw pixel in pen color
                trap        #15
                
                movem.l     (a7)+,d0-d2
                unlk        a6 
                rts
                
WIPE:                                       ; Overrides the Drawing portions of the board
                movem.l d0-d1,-(a7)
                                            ; Uses saved set board color
                move.l  d3,d1               
                jsr     STCOL
                                            ; Creates rectangle to Override drawings
                move.w  #50,-(a7)           
                move.w  #50,-(a7)
                move.w  #587,-(a7)
                move.w  #430,-(a7)
                jsr     _SHAPE
                addi    #8,(a7)
                                            ; Uses saved set pen color
                move.l  #$00000000,d1               
                jsr     STCOL
                
                movem.l (a7)+,d0-d1                
                jsr     LOOP 

CLR_LN:                                     ; Redisplays CLI and clears row 1 of text
                movem.l     d0-d1/a1,-(a7)  
                                            ; Moves cursor to position (0,0)
                move.b      #11,d0
                move.w      #$0000,d1
                trap        #15
                                            ; Displays CLI
                lea         DIS,a1
                move.b      #13,d0
                trap        #15
                                            ; Clears Next line
                lea         BLK,a1
                move.b      #13,d0
                trap        #15
                                            ; Moves to row 1
                move.b      #11,d0
                move.w      #$0001,d1
                trap        #15
                
                movem.l     (a7)+,d0-d1/a1
                rts
                
_SHAPE:                                     ; Creates rectangles with passed in parameters
                link    a6,#-2
                movem.l d0-d4,-(a7)
                move.w  14(a6),d1           ; X
                move.w  12(a6),d2           ; Y
                move.w  10(a6),d3           ; Width
                move.w  8(a6),d4            ; Height
                move.w  d1,-2(a6)           ; Saved left bound
loop2:    
loop1:  
                addq.w  #1,d1               ; Next column
                                            ; Draws pixel
                move.b  #82,d0
                trap    #15
                                            ; Width bounds loop condition
                cmp     d3,d1               
                blo     loop1
                                            
                addq.w  #1,d2               ; Next row
                move.w  -2(a6),d1           ; Move back to left bound
                                            ; Height bounds loop condition
                cmp     d4,d2
                blo     loop2
                
                movem.l (a7)+,d0-d4
                unlk    a6
                rts
  
EXIT:                                       
    SIMHALT             ; halt simulator

* Put variables and constants here
BLK dc.b   '                                                                                 ',0
DIS dc.b   '       0 = Color (00RRGGBB), 1 = reset stage, 2 = Speed, 3 = Clear Board        ',0
MNU dc.b   'Change - Pen(4),  border(5),  board(6): ',0

MSG dc.b   'Input (00RRGGBB): ',0
SMG dc.b   'Speed (1-5): ',0

ESG dc.b   'Invalid hex character!',0
EIG dc.b   'Invalid Input!',0

BUF ds.b   82

    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
