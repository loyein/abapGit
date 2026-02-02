*&---------------------------------------------------------------------*
*& Report Z2508R0040_084
*&---------------------------------------------------------------------*
************************************************************************
* Program ID   : Z2508R0050_084
* Title        : [HW5] 구매오더 변경
* Create Date  : 2025-08-22
* Developer    : S4H084 강예인
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. 01 |Date           |Developer |Description(Reason)
************************************************************************
*         |2025-08-22     |강예인      | inital Coding
************************************************************************
REPORT Z2508R0050_084.

*--------------------------------------------------------------------*
* 선언관련 Include
*--------------------------------------------------------------------*
INCLUDE Z2508R0050_084_TOP.
INCLUDE Z2508R0050_084_SCR.
INCLUDE Z2508R0050_084_CLS.
*--------------------------------------------------------------------*
* 구현관련 Include
*--------------------------------------------------------------------*
INCLUDE Z2508R0050_084_PBO.
INCLUDE Z2508R0050_084_PAI.
INCLUDE Z2508R0050_084_F01.

*--------------------------------------------------------------------*
INITIALIZATION.
*--------------------------------------------------------------------*


  " Table of OK codes to be excluded

  " Application Toolbar에 버튼 추가
*  SSCRFIELDS-FUNCTXT_01 = TEXT-T01. "Download Template

  S_BEDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = |{ SY-DATUM(6) - 1 }01|  HIGH = SY-DATUM ) ).

*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*--------------------------------------------------------------------*

  LOOP AT SCREEN.
    CASE 'X'.
      WHEN R1.
        IF SCREEN-GROUP1 = 'SC2'.
          SCREEN-ACTIVE = 0.
          SCREEN-REQUIRED = 2.

        ELSEIF SCREEN-GROUP1 = 'SC1'.
          SCREEN-ACTIVE = 1.
          SCREEN-REQUIRED = 2.               " 필수입력 모양은 뜨지만 필수는 아님
          SSCRFIELDS-FUNCTXT_01 = TEXT-T01.  " APPLICATION TOOLBAR 세팅
        ENDIF.

      WHEN R2.
        IF SCREEN-GROUP1 = 'SC1' .
          SCREEN-ACTIVE = 0.
          SCREEN-REQUIRED = 2.
          CLEAR SSCRFIELDS-FUNCTXT_01. "APPLICATION TOOLBAR 안보이게 초기화
        ENDIF.

    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
*--------------------------------------------------------------------*
  " 파일 업로드 도움말
  PERFORM UPLOAD_FILE CHANGING P_FILE.

*--------------------------------------------------------------------*
AT SELECTION-SCREEN.
*--------------------------------------------------------------------*

  " Download Template 버튼을 눌렀을 때
  PERFORM DOWNLOAD_TEMPLATE.
*  PERFORM DATA_VALIDATION.

*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*

  CASE 'X'.
    WHEN R1.
      IF P_FILE IS NOT INITIAL. " 필수 입력값 체크

        PERFORM GET_EXCEL_DATA.  " 업로드한 엑셀에서 데이터 가져오기

        PERFORM SELECT_DATA.     " 엑셀에 없는 데이터 DB에서 가져오기

        CALL SCREEN 0100.

      ELSE.
        MESSAGE '파일을 업로드 해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN R2 .

      PERFORM SELECT_HEADER_DATA. " 구매오더 변경을 위한 데이터 SELECT
      CALL SCREEN 0200.

  ENDCASE.
