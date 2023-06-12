  TITLE 'str-001-clst.asm: Test CLST Instruction'
*
***********************************************************************
*
*Testcase str-001-clst  --  Test cases for variations on the CLST
*                           (Compare Logical String) instruction.
*
***********************************************************************
*
*                        str-001-clst.asm
*
* Created and placed into the public domain 2018-12-27 by Bob Polmanter
* Remove runtest *Compare dependency on 2022-03-08 by Fish
*
* The CLST instruction is tested against the definition in the
* z/Architecture Principles of Operation, SA22-7832.
*
* Test data is assembled into this program, and some test data is
* generated by this program. The program itself verifies the resulting
* status of registers and condition codes via simple CLC comparison.
*
*
*
* Tests performed with CLST (Compare Logical String):
*
* 1.  Ensure that a non-zero bit in R0 bits 32-55 gives PIC06
* 2.  Simple equality test; no operands cross page boundary
* 3.  Operand 1 first byte is the termination character
* 4.  Operand 2 first byte is the termination character
* 5.  Operand 1 string "less than" operand 2 string
* 6.  Operand 1 string "greater than" operand 2 string
* 7.  Operand 1 string "shorter than" operand 2 string
* 8.  Operand 1 string "longer than" operand 2 string
* 9.  Operand 1 (only) crosses a page boundary
* 10. Operand 2 (only) crosses a page boundary
* 11. Both operands cross, operand 1 closer to boundary
* 12. Both operands cross, operand 2 closer to boundary
* 13. Both operands cross, ops equidistant, large multipage compare.
*
*
* NOTE - the nature of the string instructions is such that this test
*        case will only validate properly for the string instruction
*        improvement modifications committed in December 2018.  The
*        computation of the CPU determined number of bytes is an
*        unpredictable number on real hardware (at least above the
*        minimum value) and the method used in Hercules prior to
*        instruction improvements calculated it differently than the
*        improved method.  As a result, the operand registers will
*        likely contain different values when compared by the test
*        due to the different CPU number of bytes determined.
*        None of the methods are wrong, and failing results in the
*        test are not necessarily wrong.  But this program and the
*        resulting test comparisons were written for the method used
*        by the improved string instructions (CLST, MVST, SRST).
*
*
***********************************************************************
*
*
CLST001  START 0
STRTLABL EQU   *
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
*
*
         USING *,R15
*
* Selected z/Arch low core layout
*
         ORG   STRTLABL+X'8C'      Program check interrution code
PGMINTC  DS    F
*
PGMOPSW  EQU   STRTLABL+X'150'     z/Arch Program check old PSW
*
         ORG   STRTLABL+X'1A0'     z/Arch Restart PSW
         DC    X'0000000180000000',A(0,START)
*
         ORG   STRTLABL+X'1D0'     z/Arch Program check new PSW
PGMNPSW  DC    X'0000000180000000',A(0,PROGCHK)
*
* Program check routine.  We are looking for a single specification
* exeception.  Any other program check is not expected to occur and
* results in a hard wait.
*
         ORG   STRTLABL+X'200'
PROGCHK  DS    0H               Program check occured...
         CLI   DIDTHIS,X'00'    First/only time here?
         BNE   FAIL             No?! Then something is wrong!
         CLI   PGMINTC+3,X'06'  Specification Exception?
         BNE   FAIL             No?! Then something is wrong!
         MVI   DIDTHIS,X'FF'    Remember we did this once already
         B     CONTINUE         Continue, as this is expected (once!)
FAIL     LPSWE FAILPSW          Unexpected PIC, disabled wait
DIDTHIS  DC    X'00'            X'FF' == we already did this
         EJECT
***********************************************************************
*
*  Main program.
*
START    DS    0H
*
**********
* TEST 1 * Ensure any non-zero bits in R0 bits 32-55 gives PIC 06
**********
*
         LA    R0,X'400'               Set invalid termination char
         LA    R6,SHORT1               -> short string
         LA    R7,SHORT2               -> another short string
         CLST  R6,R7                   Attempt a CLST, should get PIC 6
*
CONTINUE EQU   *
         CLI   DIDTHIS,X'FF'           Did PIC 06 happen?
         BNE   FAIL                    No?! Then something is wrong!
         MVC   PGMNPSW,FAILPSW         Going forward, all other
*                                      program checks should halt.
*
**********
* TEST 2 * Compare short equal strings; no page boundary crossings.
**********
*
         LA    R6,SHORT1               -> string 1
         LA    R7,SHORT2               -> string 2
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT2           Save test result regs
*
**********
* TEST 3 * Compare a short string; operand 1 is the termination
********** character in the first byte.
*
         LA    R6,TERM                 -> string 1
         LA    R7,SHORT2               -> string 2
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT3           Save test result regs
*
**********
* TEST 4 * Compare a short string; operand 2 is the termination
********** character in the first byte.
*
         LA    R6,SHORT1               -> string 1
         LA    R7,TERM                 -> string 2
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT4           Save test result regs
*
**********
* TEST 5 * Compare a short string; operand 1 string is "lesser"
********** than the operand 2 string.
*
         LA    R6,LESSER               -> string 1
         LA    R7,GREATER              -> string 2
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT5           Save test result regs
*
**********
* TEST 6 * Compare a short string; operand 1 string is "greater"
********** than the operand 2 string.
*
         LA    R6,GREATER              -> string 1
         LA    R7,LESSER               -> string 2
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT6           Save test result regs
*
**********
* TEST 7 * Compare a short string; operand 1 string is "shorter"
********** than the operand 2 string.
*
         LA    R6,SHORT1               -> string 1
         LA    R7,LONGER               -> string 2
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT7           Save test result regs
*
**********
* TEST 8 * Compare a short string; operand 1 string is "longer"
********** than the operand 2 string.
*
         LA    R6,LONGER               -> string 1
         LA    R7,SHORT2               -> string 2
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT8           Save test result regs
*
**********
* PREP   * Prepare a multi-page frame area for more lengthy compares.
**********
*
         LM    R2,R5,AREA              -> large area and length
         MVCL  R2,R4                   Pad it full of X'AA'
*
**********
* TEST 9 * Compare a string; operand 1 string crosses a
********** page boundary.
*
         LM    R4,R7,TEST9             Get lengths and string ptrs
         MVI   0(R4),C'$'              Set a termination char
         MVI   0(R5),C'$'              Set a termination char
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT9           Save test result regs
         MVI   0(R4),X'AA'             Reset the termination char
         MVI   0(R5),X'AA'             Reset the termination char
*
***********
* TEST 10 * Compare a string; operand 2 string crosses a
*********** page boundary.
*
         LM    R4,R7,TEST10            Get lengths and string ptrs
         MVI   0(R4),C'$'              Set a termination char
         MVI   0(R5),C'$'              Set a termination char
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT10          Save test result regs
         MVI   0(R4),X'AA'             Reset the termination char
         MVI   0(R5),X'AA'             Reset the termination char
*
***********
* TEST 11 * Compare a string; both operands cross page boundaries;
*********** operand 1 is closer to the boundary
*
         LM    R4,R7,TEST11            Get lengths and string ptrs
         MVI   0(R4),C'$'              Set a termination char
         MVI   0(R5),C'$'              Set a termination char
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT11          Save test result regs
         MVI   0(R4),X'AA'             Reset the termination char
         MVI   0(R5),X'AA'             Reset the termination char
*
***********
* TEST 12 * Compare a string; both operands cross page boundaries;
*********** operand 2 is closer to the boundary
*
         LM    R4,R7,TEST12            Get lengths and string ptrs
         MVI   0(R4),C'$'              Set a termination char
         MVI   0(R5),C'$'              Set a termination char
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT12          Save test result regs
         MVI   0(R4),X'AA'             Reset the termination char
         MVI   0(R5),X'AA'             Reset the termination char
*
***********
* TEST 13 * Compare a string; both operands cross page boundaries;
*********** both operands equidistant from boundary; large compare.
*
         LM    R4,R7,TEST13            Get lengths and string ptrs
         MVI   0(R4),C'$'              Set a termination char
         MVI   0(R5),C'$'              Set a termination char
         BAS   R9,COMPARE              Compare the string
         STM   R6,R8,RESULT13          Save test result regs
         MVI   0(R4),X'AA'             Reset the termination char
         MVI   0(R5),X'AA'             Reset the termination char
*
**       Verify results...
*
         CLC   GRESLT2,RESULT2        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT3,RESULT3        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT4,RESULT4        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT5,RESULT5        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT6,RESULT6        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT7,RESULT7        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT8,RESULT8        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT9,RESULT9        Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT10,RESULT10      Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT11,RESULT11      Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT12,RESULT12      Expected results?
         BNE   FAIL                   No?! Then something is wrong!
         CLC   GRESLT13,RESULT13      Expected results?
         BNE   FAIL                   No?! Then something is wrong!
*
         LPSWE GOODPSW                load SUCCESS disabled wait PSW
*
*-- CLST routine used by the tests
*
COMPARE  EQU   *
         LA    R0,C'$'                 Load termination character
         SR    R8,R8                   Init CLST counter
*
INVOKE   EQU   *
         CLST  R6,R7                   Compare the strings
         LA    R8,1(,R8)               Count executions of CLST
         BC    1,INVOKE                Restart the compare
         IPM   R8                      Put final CC in high R8
         BR    R9                      Return
*
*
         DS    0D             Ensure correct alignment for psw
GOODPSW  DC    X'0002000000000000',A(0,0) Normal end - disabled wait
FAILPSW  DC    X'0002000000000000',XL4'00',X'0000DEAD' Abnormal end
*
GRESLT2  DC    XL12'000007000000071000000001'
GRESLT3  DC    XL12'000007500000071010000001'
GRESLT4  DC    XL12'000007000000075020000001'
GRESLT5  DC    XL12'000007270000073710000001'
GRESLT6  DC    XL12'000007370000072720000001'
GRESLT7  DC    XL12'0000070C0000074C10000001'
GRESLT8  DC    XL12'0000074C0000071C20000001'
GRESLT9  DC    XL12'000030000000430000000002'
GRESLT10 DC    XL12'00002A000000500000000002'
GRESLT11 DC    XL12'000030800000500000000002'
GRESLT12 DC    XL12'00002F4000004F8000000001'
GRESLT13 DC    XL12'000060000000C00000000005'
*
*                                      core
*                                     offset
         ORG   STRTLABL+X'700'         7xx
SHORT1   DC    CL16'SHORT STRING$   '   00
SHORT2   DC    CL16'SHORT STRING$   '   10
LESSER   DC    CL16'STRING < LOW   $'   20
GREATER  DC    CL16'STRING > HIGH  $'   30
LONGER   DC    CL16'SHORT STRING XL$'   40
TERM     DC    C'$'                     50
FFS      DC    15X'FF'                  51
*
AREA     DC    X'00002000'             -> start of multi-page area
AREALEN  DC    A(4096*16)              Size of multi=page area
ZERO     DC    A(0)
PAD      DC    X'AA000000'             MVCL pad char
*
*-- Storage addresses for Tests 9-13.  Four addresses are
*-- provided:  where to place the termination character in
*-- strings 1 and 2, and where string 1 and 2 start.
*
*
TEST9    DS    0F                      Op 1 (only) crosses page
         DC    X'00003200'   len=x400  -> where to place term chr op 1
         DC    X'00004500'   len=x400  -> where to place term chr op 2
         DC    X'00002E00'             -> start of string (operand 1)
         DC    X'00004100'             -> start of string (operand 2)
*
TEST10   DS    0F                      Op 2 (only) crosses page
         DC    X'00002B00'   len=x800  -> where to place term chr op 1
         DC    X'00005100'   len=x800  -> where to place term chr op 2
         DC    X'00002300'             -> start of string (operand 1)
         DC    X'00004900'             -> start of string (operand 2)
*
TEST11   DS    0F                      Both cross; Op1 closer to bound
         DC    X'00003090'   len=x110  -> where to place term chr op 1
         DC    X'00005010'   len=x110  -> where to place term chr op 2
         DC    X'00002F80'             -> start of string (operand 1)
         DC    X'00004F00'             -> start of string (operand 2)
*
TEST12   DS    0F                      Both cross; Op2 closer to bound
         DC    X'00003030'   len=x0F0  -> where to place term chr op 1
         DC    X'00005070'   len=x0F0  -> where to place term chr op 2
         DC    X'00002F40'             -> start of string (operand 1)
         DC    X'00004F80'             -> start of string (operand 2)
*
TEST13   DS    0F                      Both cross; ops equidistant
         DC    X'00006080'   len=x3480 -> where to place term chr op 1
         DC    X'0000C080'   len=x3480 -> where to place term chr op 2
         DC    X'00002C00'             -> start of string (operand 1)
         DC    X'00008C00'             -> start of string (operand 2)
*
*
*  Locations for results
*
* Result fields are kept on 16-byte boundaries to more easily
* track their assembled offsets.
*
*                              offset
         ORG   STRTLABL+X'800'   8xx
RESULT2  DS    4F                 00   Register results test 2
RESULT3  DS    4F                 10   Register results test 3
RESULT4  DS    4F                 20   Register results test 4
RESULT5  DS    4F                 30   Register results test 5
RESULT6  DS    4F                 40   Register results test 6
RESULT7  DS    4F                 50   Register results test 7
RESULT8  DS    4F                 60   Register results test 8
RESULT9  DS    4F                 70   Register results test 9
RESULT10 DS    4F                 80   Register results test 10
RESULT11 DS    4F                 90   Register results test 11
RESULT12 DS    4F                 A0   Register results test 12
RESULT13 DS    4F                 B0   Register results test 13
*
         END