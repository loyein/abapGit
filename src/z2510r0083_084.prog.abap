************************************************************************
* Program ID   : Z2508R0030_084
* Title        : [HW3] Excel Down
* Create Date  : 2025-08-11
* Developer    : S4H084 강예인
* Tech. Script :
************************************************************************
* Change History.
************************************************************************
* Mod. 01 |Date           |Developer |Description(Reason)
************************************************************************
*         |2025-08-11     |강예인      | inital Coding
************************************************************************

REPORT Z2508R0083_084.

*--------------------------------------------------------------------*
* 선언관련 Include
*--------------------------------------------------------------------*
INCLUDE Z2510R0083_084_TOP.
INCLUDE Z2510R0083_084_SCR.
*--------------------------------------------------------------------*
* 구현관련 Include
*--------------------------------------------------------------------*
INCLUDE Z2510R0083_084_F01.

*--------------------------------------------------------------------*
INITIALIZATION.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
AT SELECTION-SCREEN.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*

  PERFORM SELECT_DATA_HEADER.
  PERFORM SELECT_DATA_ITEM.
*--------------------------------------------------------------------*
*  방법 1.
*  OLE 방식으로 EXCEL 다운 후 전송
*  PERFORM CHECK_DATA.
*  PERFORM SEND_MAIL.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* 방법 2.
* abap2xlsx 방식으로 EXCEL 다운 안받고 데이터 입력 후 바로 발송
*--------------------------------------------------------------------*
  DATA: LO_EXCEL     TYPE REF TO ZCL_EXCEL,
        LO_WORKSHEET TYPE REF TO ZCL_EXCEL_WORKSHEET,
        LO_WRITER    TYPE REF TO ZIF_EXCEL_WRITER,
        LV_XSTRING   TYPE XSTRING,
        LT_SOLIX     TYPE SOLIX_TAB,
        LV_SIZE      TYPE SO_OBJ_LEN.

  " 1. 엑셀 객체 생성
  CREATE OBJECT LO_EXCEL.

  " 2. 시트 생성
  LO_WORKSHEET = LO_EXCEL->GET_ACTIVE_WORKSHEET( ).
  LO_WORKSHEET->SET_TITLE( '판매오더 내역' ).  " 엑셀 시트 이름
  " 전체 열 자동 맞춤


  " 3. 헤더용 스타일 생성 ----------------------------------------
  DATA(LO_HEADER_STYLE) = LO_EXCEL->ADD_NEW_STYLE(  ).

  IF LO_HEADER_STYLE->BORDERS IS INITIAL.
    CREATE OBJECT LO_HEADER_STYLE->BORDERS.
  ENDIF.

  IF LO_HEADER_STYLE->BORDERS->TOP IS INITIAL.
    CREATE OBJECT LO_HEADER_STYLE->BORDERS->TOP.
  ENDIF.
  IF LO_HEADER_STYLE->BORDERS->DOWN IS INITIAL.
    CREATE OBJECT LO_HEADER_STYLE->BORDERS->DOWN.
  ENDIF.
  IF LO_HEADER_STYLE->BORDERS->LEFT IS INITIAL.
    CREATE OBJECT LO_HEADER_STYLE->BORDERS->LEFT.
  ENDIF.
  IF LO_HEADER_STYLE->BORDERS->RIGHT IS INITIAL.
    CREATE OBJECT LO_HEADER_STYLE->BORDERS->RIGHT.
  ENDIF.


  IF LO_HEADER_STYLE IS NOT INITIAL.
    " 글자 속성 설정
    LO_HEADER_STYLE->FONT->BOLD = ABAP_TRUE.        " 글자 굵게
    LO_HEADER_STYLE->FONT->SIZE = 14.               " 글자 크기
    LO_HEADER_STYLE->FONT->NAME = '맑은 고딕'.      " 폰트 이름
    LO_HEADER_STYLE->FONT->COLOR-RGB = '00B050'.    " 글자 색 : 진한 초록

    " 셀 테두리 설정
    LO_HEADER_STYLE->BORDERS->TOP->BORDER_STYLE   = ZCL_EXCEL_STYLE_BORDER=>C_BORDER_THIN.
    LO_HEADER_STYLE->BORDERS->DOWN->BORDER_STYLE  = ZCL_EXCEL_STYLE_BORDER=>C_BORDER_THIN.
    LO_HEADER_STYLE->BORDERS->LEFT->BORDER_STYLE  = ZCL_EXCEL_STYLE_BORDER=>C_BORDER_THIN.
    LO_HEADER_STYLE->BORDERS->RIGHT->BORDER_STYLE = ZCL_EXCEL_STYLE_BORDER=>C_BORDER_THIN.
  ELSE.
    MESSAGE 'Style object creation failed' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  " 4. 헤더 작성 (스타일 적용)
  LO_WORKSHEET->SET_CELL( IP_ROW = 1 IP_COLUMN = 1 IP_VALUE = '판매오더' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 1 IP_COLUMN = 2 IP_VALUE = GS_HEADER-VBELN IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 2 IP_COLUMN = 1 IP_VALUE = '바이어' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 2 IP_COLUMN = 2 IP_VALUE = GS_HEADER-NAME1 IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 3 IP_COLUMN = 1 IP_VALUE = '참조번호' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 3 IP_COLUMN = 2 IP_VALUE = GS_HEADER-BSTNK IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 4 IP_COLUMN = 1 IP_VALUE = '출력일' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 4 IP_COLUMN = 2 IP_VALUE = SY-DATUM IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 1 IP_COLUMN = 4 IP_VALUE = '총액' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 1 IP_COLUMN = 5 IP_VALUE = GS_HEADER-NETWR IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 2 IP_COLUMN = 4 IP_VALUE = '배송 요청일' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 2 IP_COLUMN = 5 IP_VALUE = GS_HEADER-VDATU IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 3 IP_COLUMN = 4 IP_VALUE = '지급조건' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 3 IP_COLUMN = 5 IP_VALUE = GS_HEADER-ZTERM IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 4 IP_COLUMN = 4 IP_VALUE = '인도조건' IP_STYLE = LO_HEADER_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 4 IP_COLUMN = 5 IP_VALUE = GS_HEADER-INCO1 IP_STYLE = LO_HEADER_STYLE ).

  " 4. 아이템 테이블 출력
  " 필드명 입력

  DATA(LO_ITEM_STYLE) = LO_EXCEL->ADD_NEW_STYLE(  ). " 아이템(필드명) 스타일 설정
  LO_ITEM_STYLE->FONT->BOLD = 'X'.                   " 글자색 진하게 설정
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 1 IP_VALUE = '항번' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 2 IP_VALUE = '자재' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 3 IP_VALUE = '자재명' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 4 IP_VALUE = '단가' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 5 IP_VALUE = '통화' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 6 IP_VALUE = '수량' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 7 IP_VALUE = '수량단위' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 8 IP_VALUE = '금액' IP_STYLE = LO_ITEM_STYLE ).
  LO_WORKSHEET->SET_CELL( IP_ROW = 6 IP_COLUMN = 9 IP_VALUE = '창고명' IP_STYLE = LO_ITEM_STYLE ).

  DATA(LV_ROW) = 7.
  LOOP AT GT_ITEM INTO GS_ITEM.
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 1 IP_VALUE = GS_ITEM-POSNR ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 2 IP_VALUE = GS_ITEM-MATNR ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 3 IP_VALUE = GS_ITEM-MAKTX ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 4 IP_VALUE = GS_ITEM-NETPR ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 5 IP_VALUE = GS_ITEM-WAERK ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 6 IP_VALUE = GS_ITEM-KWMENG ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 7 IP_VALUE = GS_ITEM-MEINS ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 8 IP_VALUE = GS_ITEM-TOTAL ).
    LO_WORKSHEET->SET_CELL( IP_ROW = LV_ROW IP_COLUMN = 9 IP_VALUE = GS_ITEM-LGOBE ).
    ADD 1 TO LV_ROW.
  ENDLOOP.

  LO_WORKSHEET->CALCULATE_COLUMN_WIDTHS( ).

  " 5. XLSX 바이너리로 변환
  CREATE OBJECT LO_WRITER TYPE ZCL_EXCEL_WRITER_2007.
  LV_XSTRING = LO_WRITER->WRITE_FILE( LO_EXCEL ).

  " 6. 바이너리 → SOLIX 변환
  LT_SOLIX = CL_BCS_CONVERT=>XSTRING_TO_SOLIX( IV_XSTRING = LV_XSTRING ).
  LV_SIZE = XSTRLEN( LV_XSTRING ).

  " 7. 메일 객체 생성
  DATA: LO_BCS       TYPE REF TO CL_BCS,
        LO_DOCUMENT  TYPE REF TO CL_DOCUMENT_BCS,
        LO_SENDER    TYPE REF TO IF_SENDER_BCS,
        LO_RECIPIENT TYPE REF TO IF_RECIPIENT_BCS.

  LO_BCS = CL_BCS=>CREATE_PERSISTENT( ).
  LO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                  I_TYPE    = 'RAW'
                  I_TEXT    = VALUE SOLI_TAB( ( LINE = '판매오더 엑셀 첨부입니다.' ) )
                  I_SUBJECT = '판매오더 내역 엑셀' ).

  " 8. 첨부파일 추가
  LO_DOCUMENT->ADD_ATTACHMENT(
    I_ATTACHMENT_TYPE    = 'BIN'
    I_ATTACHMENT_SUBJECT = 'SalesOrder.xlsx'
    I_ATTACHMENT_SIZE    = LV_SIZE
    I_ATT_CONTENT_HEX    = LT_SOLIX ).

  LO_BCS->SET_DOCUMENT( LO_DOCUMENT ).

  " 송신자 / 수신자 설정
  LO_SENDER = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
  LO_BCS->SET_SENDER( LO_SENDER ).

  LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( P_EMAIL ).
  LO_BCS->ADD_RECIPIENT( LO_RECIPIENT ).

  LO_BCS->SET_SEND_IMMEDIATELY( ABAP_TRUE ).

  " 9. 메일 전송
  IF LO_BCS->SEND( ) = ABAP_TRUE.
    COMMIT WORK.
    MESSAGE '메일 전송 성공' TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE '메일 전송 실패' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
