*&---------------------------------------------------------------------*
*& Report ZSH08402
*&---------------------------------------------------------------------*
REPORT ZSH08402.
*--------------------------------------------------------------------*
* 선언관련 Include
*--------------------------------------------------------------------*
INCLUDE ZSH08402_TOP. " 전역변수 선언 등
INCLUDE ZSH08402_SCR. " 선택화면(Selection Screen) 생성
INCLUDE ZSH08402_CLS. " EVENT 구현

*--------------------------------------------------------------------*
* 구현관련 Include
*--------------------------------------------------------------------*
INCLUDE ZSH08402_PBO. " PBO(Process Before Output) Module
INCLUDE ZSH08402_PAI. " PAI(Process After  Input ) Module
INCLUDE ZSH08402_F01. " FORM Subroutines

*--------------------------------------------------------------------*
*AT SELECTION-SCREEN.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_ID-LOW.
  PERFORM F4_ID USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_ID-HIGH.
  PERFORM F4_ID USING 'HIGH'.

* 유효성검사
PERFORM CHECK_VALIDATE.
*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*

PERFORM select_data.
CALL SCREEN 0100.
