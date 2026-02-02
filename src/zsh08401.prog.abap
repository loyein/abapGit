*&---------------------------------------------------------------------*
*& Report ZSH08401
*&---------------------------------------------------------------------*
REPORT ZSH08401.

*--------------------------------------------------------------------*
* 선언관련 Include
*--------------------------------------------------------------------*

INCLUDE ZSH08401_TOP. " 전역변수 선언 등
INCLUDE ZSH08401_SCR. " 선택화면(Selection Screen) 생성
INCLUDE ZSH08401_CLS. " Class 선언 및 구현

*--------------------------------------------------------------------*
* 구현관련 Include
*--------------------------------------------------------------------*
INCLUDE ZSH08401_PBO. " PBO(Process Before Output) Module
INCLUDE ZSH08401_PAI. " PAI(Process After  Input ) Module
INCLUDE ZSH08401_F01. " FORM Subroutines


*--------------------------------------------------------------------*
INITIALIZATION.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*--------------------------------------------------------------------*

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'SO'.   " MODIF ID
      IF R1 = 'X' OR R3 = 'X'.  " 라디오버튼이 조회, 변경일 때
        SCREEN-ACTIVE = '1'.
      ELSEIF R2 = 'X' .         " 라디오버튼이 생성일 때.
        SCREEN-ACTIVE = '0'.
        REFRESH : SO_ID, SO_NAME.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


*--------------------------------------------------------------------*
*AT SELECTION-SCREEN.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_ID-LOW.
  PERFORM F4_ID USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR SO_ID-HIGH.
  PERFORM F4_ID USING 'HIGH'.

  " 유효성 검사
  PERFORM CHECK_VALIDATE.

*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*

  PERFORM SELECT_DATA.
  CALL SCREEN 0100.
