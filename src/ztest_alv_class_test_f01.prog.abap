*&---------------------------------------------------------------------*
*& Include          Z2508R0010_084_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  SELECT  A~EBELN,                        " 구매오더 번호
          A~BEDAT,                        " 구매 날짜
          A~LIFNR,                        " 공급 업체
          C~NAME1,                        " 공급 업체명
          A~ERNAM,                        " 생성자
          SUM( B~NETWR ) AS NETWR,  " 구매 총액
          A~WAERS                         " 단위
    FROM EKKO AS A
    JOIN EKPO AS B ON A~EBELN = B~EBELN
    JOIN LFA1 AS C ON A~LIFNR = C~LIFNR
    WHERE A~EKORG IN @S_EKORG
      AND A~EKGRP IN @S_EKGRP
      AND A~LIFNR IN @S_LIFNR
      AND A~BEDAT IN @S_BEDAT
      AND B~LOEKZ = ''                     " 삭제되지 않은 건 조회
    GROUP BY A~EBELN, A~BEDAT, A~LIFNR, C~NAME1, A~ERNAM, A~WAERS
    ORDER BY A~EBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.



* ALV 출력 전 데이터 출력 확인용
* CL_DEMO_OUTPUT=>WRITE( DATA = GT_DATA  ).
* CL_DEMO_OUTPUT=>DISPLAY( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL.
    PERFORM CREATE_OBJECT.

    PERFORM SET_LAYOUT USING : GO_ALV_TOP, GO_ALV_BOT.
    PERFORM SET_FCAT.

    PERFORM SET_EVENT_HANDLER.
    PERFORM DISPLAY_ALV.

  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  "--- 1. 메인 컨테이너 생성 (스크린의 Custom Control과 연결)
  CREATE OBJECT GO_DOCKING
    EXPORTING
      REPID     = SY-REPID  " 프로그램 명
      SIDE      = GO_DOCKING->DOCK_AT_LEFT
      DYNNR     = SY-DYNNR  " 스크린 넘버
      EXTENSION = 3000.     " 크기

  "--- 2. 스플리터 생성 및 화면 분할
  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING                   " Parent Container
      ROWS    = 3                   " Number of Rows to be displayed
      COLUMNS = 1.                   " Number of Columns to be Displayed

*  " Header Area 생성을 위한 문서 객체 (이것은 그대로 둡니다)
*  CREATE OBJECT GO_DOCU
*    EXPORTING
*      STYLE = 'ALV_GIRD'.

  " 1번 행(헤더)의 높이를 80 픽셀로 고정합니다.
  CALL METHOD GO_SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = 20.

  " 2번 행(상단 ALV)의 높이를 200 픽셀로 고정합니다.
  CALL METHOD GO_SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 2
      HEIGHT = 40.

  " 3번 행(하단 ALV)은 나머지 모든 공간을 사용하도록 설정합니다. ('*')

  "--- 3. 상단/하단 컨테이너 객체 얻기
  GO_CONTAINER_HEAD = GO_SPLITTER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  GO_CONTAINER_TOP = GO_SPLITTER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
  GO_CONTAINER_BOT = GO_SPLITTER->GET_CONTAINER( ROW = 3 COLUMN = 1 ).



  "==================== 4. 상단 ALV 생성 및 표시 ====================
  "--- 4-1. 상단 ALV 핸들러 객체 생성 (고유 이름 부여)
  CREATE OBJECT GO_ALV_TOP
    EXPORTING
      ALV_NAME    = 'ALV_TOP'
      O_CONTAINER = GO_CONTAINER_TOP.


  "==================== 5. 하단 ALV 생성 및 표시 ====================
  CREATE OBJECT GO_ALV_BOT
    EXPORTING
      ALV_NAME    = 'ALV_BOTTOM'
      O_CONTAINER = GO_CONTAINER_BOT.

  CREATE OBJECT GO_UTIL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV.
  GO_ALV_TOP->DISPLAY_ALV(
    CHANGING
      IT_DATA = GT_DATA
  ).
  GO_ALV_BOT->DISPLAY_ALV(
    CHANGING
      IT_DATA = GT_ITEM
  ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT.

  GT_FCAT1 = VALUE #(
  ( FIELDNAME = 'EBELN'  REF_TABLE = 'EKKO'      COLTEXT = TEXT-T01  " Search Condition
    HOTSPOT = 'X' KEY = 'X'    JUST = 'C' )

  ( FIELDNAME = 'BEDAT'  REF_TABLE = 'EKKO'      COLTEXT = TEXT-T02  " PO No.
    JUST = 'C' )

  ( FIELDNAME = 'LIFNR'  REF_TABLE = 'EKKO'      COLTEXT = TEXT-T03   " Ordered Date
    JUST = 'C'  HOTSPOT = 'X'  EMPHASIZE = 'C300'CONVEXIT = 'ALPHA')

  ( FIELDNAME = 'NAME1'  REF_TABLE = 'LFA1'      COLTEXT = TEXT-T04  " Vendor
    EMPHASIZE = 'C300')

  ( FIELDNAME = 'ERNAM'  REF_TABLE = 'EKKO'      COLTEXT = TEXT-T05 )" Name

  ( FIELDNAME = 'NETWR'  REF_TABLE = 'EKPO'      COLTEXT = TEXT-T06  " Created By
    CFIELDNAME = 'WAERS' )

  ( FIELDNAME = 'WAERS'  REF_TABLE = 'EKKO'      COLTEXT = TEXT-T07 )" PO Amount
).
  GO_ALV_TOP->SET_FCAT_T( IT_FCAT = GT_FCAT1 ).


  GT_FCAT2 = VALUE #(
   ( FIELDNAME = 'EBELN' REF_TABLE = 'EKPO'     COLTEXT = TEXT-T01     " PO No.
     KEY = 'X' HOTSPOT = 'X' )

   ( FIELDNAME = 'EBELP' REF_TABLE = 'EKPO'     COLTEXT = TEXT-T08 )   " Line No.

   ( FIELDNAME = 'MATNR' REF_TABLE = 'EKPO'     COLTEXT = TEXT-T09     " Material Code
     CONVEXIT = 'ALPHA' HOTSPOT = 'X' EMPHASIZE = 'C300')

   ( FIELDNAME = 'MAKTX' REF_TABLE = 'MAKT'     COLTEXT = TEXT-T10     " Material Name
     EMPHASIZE = 'C300')

   ( FIELDNAME = 'LGOBE' REF_TABLE = 'T001L'    COLTEXT = TEXT-T11 )   " Storage Location Name

   ( FIELDNAME = 'MENGE' REF_TABLE = 'EKPO'     COLTEXT = TEXT-T12     " PO Quantity
     QFIELDNAME = 'MEINS' )

   ( FIELDNAME = 'MEINS' REF_TABLE = 'EKPO'     COLTEXT = TEXT-T13 )   " Qty. Unit

   ( FIELDNAME = 'NETPR' REF_TABLE = 'EKPO'     COLTEXT = TEXT-T14     " Unit Price
     CFIELDNAME = 'WAERS')

   ( FIELDNAME = 'NETWR' REF_TABLE = 'EKPO'     COLTEXT = TEXT-T15     " Total Amount
     CFIELDNAME = 'WAERS')

   ( FIELDNAME = 'WAERS'REF_TABLE = 'EKKO'      COLTEXT = TEXT-T16 )   " Currency

  ).

  GO_ALV_BOT->SET_FCAT_T( IT_FCAT = GT_FCAT2 ).





ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT USING PO_ALV TYPE REF TO ZCL_ALV_CLASS_087.


  PO_ALV->SET_LAYOUT( EXPORTING IV_FIELD = 'ZEBRA'      IV_VALUE = ABAP_TRUE ).
  PO_ALV->SET_LAYOUT( EXPORTING IV_FIELD = 'CWIDTH_OPT' IV_VALUE = 'A' ).
  PO_ALV->SET_LAYOUT( EXPORTING IV_FIELD = 'SEL_MODE'   IV_VALUE = 'D' ).
*  PO_ALV->SET_LAYOUT( EXPORTING IV_FIELD = 'GRID_TITLE' IV_VALUE = PV_TITLE ).
  PO_ALV->SET_LAYOUT( EXPORTING IV_FIELD = 'SMALLTITLE' IV_VALUE = ABAP_TRUE ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .
  GO_ALV_TOP->REFRESH_ALV( ).
  GO_ALV_BOT->REFRESH_ALV( ).
*  GO_ALV_GRID1->REFRESH_TABLE_DISPLAY( ).
*  GO_ALV_GRID2->REFRESH_TABLE_DISPLAY( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .
  GO_ALV_TOP->SET_HANDLER( ).
  GO_ALV_BOT->SET_HANDLER( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA .
* 검색 결과가 존재하지 않을 때 다음 화면으로 넘어가지 않고 경고 메시지가 뜨도록 함.
  IF GT_DATA IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

* 검색 결과가 있으면 100번 화면 호출
  CALL SCREEN 0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLICK_HEADER_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID_INDEX
*&---------------------------------------------------------------------*
FORM CLICK_HEADER_PO .

  SELECT A~EBELN,  " 구매문서 번호
         EBELP,    " 라인 넘버
         A~MATNR,  " 자재 코드
         MAKTX,    " 자재명
         LGOBE,    " 창고 이름
         MENGE,    " 수량
         MEINS,    " 수량 단위
         NETPR,    " 자재 단가
         NETWR,    " 수량 x 단가 ( 총금액 )
         WAERS,     " 통화
         A~WERKS
    FROM EKPO AS A
     LEFT JOIN MAKT AS B ON A~MATNR = B~MATNR
                        AND B~SPRAS = @SY-LANGU
     JOIN T001L AS C ON A~WERKS = C~WERKS AND A~LGORT = C~LGORT
     JOIN EKKO AS D ON A~EBELN = D~EBELN
     WHERE A~EBELN = @GS_DATA-EBELN
     ORDER BY EBELP
     INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.


** ALV2 LAYOUT 갱신 ( 갱신 안하면 ALV TITLE 동적 구현 안됨. )
*  PERFORM SET_LAYOUT .
*  CALL METHOD GO_ALV_BOT->SET_FRONTEND_LAYOUT
*    EXPORTING
*      IS_LAYOUT = GS_LAYOUT2.

  " ALV2 갱신
  GO_ALV_BOT->REFRESH_ALV( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_set
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_SET .
  S_BEDAT[] = VALUE #( ( SIGN = 'I' OPTION = 'BT' LOW = |{ SY-DATUM(6) - 1 }01|  HIGH = SY-DATUM ) ).
ENDFORM.

FORM HANDLE_HOTSPOT_CLICK USING IV_ALV_NAME  TYPE STRING
                                IS_ROW_ID    TYPE LVC_S_ROW
                                IS_COLUMN_ID    TYPE LVC_S_COL
                                IS_ROW_NO    TYPE LVC_S_ROID.

  CASE IV_ALV_NAME.
    WHEN 'ALV_TOP'.
      PERFORM ON_HOTSPOT_CLICK_TOP USING IS_ROW_ID IS_COLUMN_ID.
    WHEN 'ALV_BOTTOM'.
      PERFORM ON_HOTSPOT_CLICK_BOT USING IS_ROW_ID IS_COLUMN_ID .
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ON_HOTSPOT_CLICK_TOP
*&---------------------------------------------------------------------*
FORM ON_HOTSPOT_CLICK_TOP  USING    PS_ROW_ID     TYPE LVC_S_ROW
                                    PS_COLUMN_ID  TYPE LVC_S_COL.
  CLEAR GS_DATA.
  READ TABLE GT_DATA INTO GS_DATA INDEX PS_ROW_ID-INDEX.

  IF SY-SUBRC = 0.
    CASE PS_COLUMN_ID-FIELDNAME.

* 상단의 PO 번호를 click( hotspot )하면 하단 ALV에 해당 PO의 Line Item Detail 정보를 출력
      WHEN 'EBELN'.
        PERFORM CLICK_HEADER_PO .

* Vendor Code 클릭 시, XK03 화면으로 이동하도록 HotSpot click 이벤트 처리
* 선택된 Vendor Code 입력하고, Address View 만 선택한 상태로 화면으로 진입
      WHEN 'LIFNR'.
        SET PARAMETER ID 'LIF' FIELD GS_DATA-LIFNR.
        SET PARAMETER ID 'KDY' FIELD '/110'.
        CALL TRANSACTION 'XK03' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ON_HOTSPOT_CLICK_BOT
*&---------------------------------------------------------------------*
FORM ON_HOTSPOT_CLICK_BOT  USING    PS_ROW_ID     TYPE LVC_S_ROW
                                    PS_COLUMN_ID  TYPE LVC_S_COL.

  CLEAR GS_ITEM.
  READ TABLE GT_ITEM INTO GS_ITEM INDEX PS_ROW_ID-INDEX.

  IF SY-SUBRC = 0.
    CASE PS_COLUMN_ID-FIELDNAME.

* PO No. 클릭 시, ME23N 화면으로 이동하도록 HotSpot click 이벤트 처리
* PO 번호 입력하여, 선택된 PO 상세 화면으로 바로 진입
      WHEN 'EBELN'.
        GO_UTIL->CALL_ME23N( IV_EBELN = GS_ITEM-EBELN ).
*        SET PARAMETER ID 'BES' FIELD GS_ITEM-EBELN.
*        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

* Material Code 클릭 시, MM03 화면으로 이동하도록 HotSpot click 이벤트 처리
* Material Code 입력하는 화면은 SKIP하고, Basic View 만 선택한 상태로 MM03 화면으로 진입
      WHEN 'MATNR'.
        GO_UTIL->CALL_MM03(
          EXPORTING
            IV_MATNR = GS_ITEM-MATNR
            IV_WERKS = GS_ITEM-WERKS
        ).
*        SET PARAMETER ID 'MAT' FIELD GS_ITEM-MATNR.
*        SET PARAMETER ID 'MXX' FIELD 'K' .
*        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM HANDLE_TOP_OF_PAGE USING         PV_ALV_NAME  TYPE STRING
                                      PO_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT
                                      PV_TABLE_INDEX.
  CASE PV_ALV_NAME.
      WHEN 'ALV_TOP'.

      CALL METHOD PO_DYNDOC_ID->DISPLAY_DOCUMENT
        EXPORTING
          REUSE_CONTROL = 'X'                 " HTML Control Reused
          PARENT        = GO_CONTAINER_HEAD.                 " Contain Object Already Exists

  ENDCASE.


ENDFORM.
