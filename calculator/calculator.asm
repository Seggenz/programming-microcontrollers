    LJMP START
    ORG 100H
START:
    LCALL LCD_CLR ;---clearing display
    LCALL WAIT_KEY
    MOV R1,A ;--- saving first number to R1
    LCALL WRITE_BCD
    
INPUT_SIGN:
    LCALL WAIT_KEY 
    LCALL SIGN        
 
    MOV A,#'='
    LCALL WRITE_DATA

    MOV A,R4
    LCALL WRITE_BCD
    CJNE R5,#0,PRINT_REMAINDER
END:
    MOV A,#10
    LCALL DELAY_100MS
    LJMP START
    SJMP $
    NOP

WRITE_BCD: ;-- subprogram to print out numbers in BCD
    MOV B,#10
    DIV AB
    SWAP A
    ADD A,B
    MOV B,#0
    LCALL WRITE_HEX
    RET

SECOND_NUMBER: ;-- subprogram to input second number
    LCALL WAIT_KEY
    MOV R2,A ;--- saving second number to R2
    LCALL WRITE_BCD
    RET

PRINT_REMAINDER: ;-- subprogram to print out remainder
    MOV DPTR,#TEXT_REMAINDER
    LCALL WRITE_TEXT
    MOV A,R5
    LCALL WRITE_BCD
    MOV R5,#0
    LJMP END

SIGN: ;--subprogram to checking sign
    CJNE A,#11,ADDITION
    CJNE A,#0,SUBTRACTION
    RET

ADDITION:
    CJNE A,#10,SUBTRACTION
    MOV A,#'+'
    LCALL WRITE_DATA
    LCALL SECOND_NUMBER
    MOV A,R1
    ADD A,R2
    MOV R4,A ;-- saving result to R4
    RET

SUBTRACTION:
    CJNE A,#11,MULTIPLICATION
    MOV A,#'-'
    LCALL WRITE_DATA
    LCALL SECOND_NUMBER
    MOV A,R1
    CLR C
    SUBB A,R2
    JB ACC.7,NEGATIVE
    MOV R4,A
    RET

MULTIPLICATION:
    CJNE A,#12,DIVISION
    MOV A,#'*'
    LCALL WRITE_DATA
    LCALL SECOND_NUMBER
    MOV A,R1
    MOV B,R2
    MUL AB
    MOV R4,A
    RET

DIVISION:
    CJNE A,#13,INPUT_SIGN
    MOV A,#'/'
    LCALL WRITE_DATA
    LCALL SECOND_NUMBER
    LCALL CHECK_FOR_ZERO
    MOV A,R1
    MOV B,R2
    DIV AB
    MOV R4,A
    MOV R5,B
    RET

CHECK_FOR_ZERO: ;-- subprogram to checking for zero in division
    CJNE R2,#0,NOT_ZERO
    LCALL LCD_CLR
    MOV DPTR,#TEXT
    LCALL WRITE_TEXT
    MOV A,#10
    LCALL DELAY_100MS
    LJMP START

NOT_ZERO:
    RET
    
TEXT:
    DB 'Zero Division Error!',0

TEXT_REMAINDER:
    DB 'r',0
    RET

NEGATIVE: ;-- subprogram to printing out minus sign
    MOV R2, #1
    CPL A
    ADD A, #1
    MOV R5, A
    MOV A,#'='
    LCALL WRITE_DATA
    MOV A,#'-'
    LCALL WRITE_DATA
    MOV A,R5
    MOV R5,#0
    LCALL WRITE_HEX

    MOV A,#5
    LCALL DELAY_100MS
    LJMP START
    RET