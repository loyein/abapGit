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

    PERFORM SET_LAYOUT.
    PERFORM SET_FCAT.

    PERFORM SET_EVENT_HANDLER.
    PERFORM DISPLAY_ALV.

    GO_ALV_TOP->CALL_EVENT(
      EXPORTING
        IO_DOCU  = GO_DOCU                 " ALV List Viewer
        IV_EVENT = 'TOP_OF_PAGE'                 " 30 Characters
    ).

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
      HEIGHT = 13.

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

  " Header Area 생성.
  CREATE OBJECT GO_DOCU
    EXPORTING
      STYLE = 'ALV_GIRD'.

  "==================== 4. 상단 ALV 생성 및 표시 ====================
  "--- 4-1. 상단 ALV 핸들러 객체 생성 (고유 이름 부여)
  CREATE OBJECT GO_ALV_TOP.
  GO_ALV_TOP->GV_ALV_NAME = 'TOP_ALV'.
  "--- 4-2. 핸들러에 상단 컨테이너 정보 전달
  GO_ALV_TOP->O_CONTAINER_O = GO_CONTAINER_TOP.

  "--- 4-3. ALV 컨트롤 객체 생성
  GO_ALV_TOP->M_10_CREATE_OBJECT( ).



  "==================== 5. 하단 ALV 생성 및 표시 ====================
  "--- 5-1. 하단 ALV 핸들러 객체 생성 (고유 이름 부여)
  CREATE OBJECT GO_ALV_BOT.
  GO_ALV_BOT->GV_ALV_NAME = 'BOTTOM_ALV'.
  "--- 5-2. 핸들러에 하단 컨테이너 정보 전달
  GO_ALV_BOT->O_CONTAINER_O = GO_CONTAINER_BOT.
  "--- 5-3. ALV 컨트롤 객체 생성
  GO_ALV_BOT->M_10_CREATE_OBJECT( ).
*
  "==================== 6. 헤더에 검색정보용 생성 ====================
*  CREATE OBJECT GO_ALV_HEAD.
*  GO_ALV_HEAD->GV_ALV_NAME = 'HEAD_ALV'.
*  GO_ALV_HEAD->O_CONTAINER_O = GO_CONTAINER_HEAD.
*  GO_ALV_HEAD->M_10_CREATE_OBJECT( ).

  " ZCL_COM_UTIL_FROM_DONGIN 오브젝트 생성
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
*  DATA: LT_DUMMY TYPE TABLE OF TY_DUMMY.
*
*  GO_ALV_HEAD->M_80_DISPLAY_ALV(
*    CHANGING
*      T_DATA = LT_DUMMY
*  ).
  GO_ALV_TOP->M_80_DISPLAY_ALV(
    CHANGING
      T_DATA = GT_DATA
  ).
  GO_ALV_BOT->M_80_DISPLAY_ALV(
    CHANGING
      T_DATA = GT_ITEM
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
  GO_ALV_TOP->T_FCAT = GT_FCAT1.


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

  GO_ALV_BOT->T_FCAT = GT_FCAT2.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT .

  CLEAR GS_LAYOUT1.
  GS_LAYOUT1-ZEBRA = 'X'.
  GS_LAYOUT1-CWIDTH_OPT = 'X'.

* ALV1 GRID_TITLE 동적 설정
  " text symbol의 타입 지정 후 inline 선언.
  DATA(LV_TITLE1) = CONV STRING( TEXT-002 ). "[ Found  &1 PO's ]
  REPLACE '&1' IN LV_TITLE1 WITH CONV STRING( LINES( GT_DATA ) ).  " text symbol의 &1의 값을 gt_data 라인 수로 대체
  GS_LAYOUT1-GRID_TITLE = LV_TITLE1.
*  GS_LAYOUT1-GRID_TITLE = |Found { LINES( GT_DATA ) } PO's|."

  GO_ALV_TOP->S_LAYO = GS_LAYOUT1.

  CLEAR GS_LAYOUT2.
  GS_LAYOUT2-CWIDTH_OPT = 'A'.

* ALV2 GRID_TITLE 동적 설정
  IF GT_ITEM IS NOT INITIAL.      " ALV데이터가 있을 때만 TITLE 세팅
    DATA(LV_TITLE2) = CONV STRING( TEXT-003 ). " [ PO '&1' has &2 line items ]
    REPLACE '&1' IN LV_TITLE2 WITH GS_DATA-EBELN .  " 선택된 구매오더 번호
    REPLACE '&2' IN LV_TITLE2 WITH CONV STRING( LINES( GT_ITEM ) ). " ALV2 행 수
    GS_LAYOUT2-GRID_TITLE = LV_TITLE2.
  ENDIF.
  GO_ALV_TOP->S_LAYO = GS_LAYOUT2.
*  GS_LAYOUT2-GRID_TITLE = | PO '{ GS_DATA-EBELN }' has '{ LINES( GT_ITEM ) }' line items |.

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
  GO_ALV_TOP->M_90_REFRESH_ALV( ).
  GO_ALV_BOT->M_90_REFRESH_ALV( ).
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
*  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID1.
*  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK2 FOR GO_ALV_GRID2.
  GO_ALV_TOP->M_30_SET_HANDLER( ).
  GO_ALV_BOT->M_30_SET_HANDLER( ).
*  GO_ALV_HEAD->M_30_SET_HANDLER( ).
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
  GO_ALV_BOT->M_90_REFRESH_ALV( ).


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
                                IS_COLUMN_ID TYPE LVC_S_COL
                                IS_ROW_NO    TYPE LVC_S_ROID.

  CASE IV_ALV_NAME.
    WHEN 'TOP_ALV'.
      PERFORM ON_HOTSPOT_CLICK_TOP USING IS_ROW_ID IS_COLUMN_ID.
    WHEN 'BOTTOM_ALV'.
      PERFORM ON_HOTSPOT_CLICK_BOT USING IS_ROW_ID IS_COLUMN_ID.
    WHEN OTHERS.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ON_HOTSPOT_CLICK_TOP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IS_ROW_ID
*&      --> IS_COLUMN_ID
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
*& Form HANDLE_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM HANDLE_TOP_OF_PAGE USING      IV_ALV_NAME   TYPE STRING
                                   E_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT
                                   TABLE_INDEX   TYPE SY-TABIX.


  CALL METHOD E_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = |구매 조직 : { S_EKORG-LOW }|                 " Single Text, Up To 255 Characters Long
      SAP_STYLE    = CL_DD_AREA=>KEY                 " Recommended Styles
      SAP_COLOR    = CL_DD_AREA=>LIST_HEADING                 " Not Release 99
      SAP_FONTSIZE = CL_DD_AREA=>HEADING.                 " Recommended Font Sizes

  CALL METHOD E_DYNDOC_ID->NEW_LINE( ).

  CALL METHOD E_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = |구매 조직 : { S_EKGRP-LOW }|                 " Single Text, Up To 255 Characters Long
      SAP_STYLE    = CL_DD_AREA=>KEY                 " Recommended Styles
      SAP_COLOR    = CL_DD_AREA=>LIST_HEADING                 " Not Release 99
      SAP_FONTSIZE = CL_DD_AREA=>HEADING.                 " Recommended Font Sizes

  CALL METHOD E_DYNDOC_ID->NEW_LINE( ).

  CALL METHOD E_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = |공급 업체 : { S_LIFNR-LOW }|                 " Single Text, Up To 255 Characters Long
      SAP_STYLE    = CL_DD_AREA=>KEY                 " Recommended Styles
      SAP_COLOR    = CL_DD_AREA=>LIST_HEADING                 " Not Release 99
      SAP_FONTSIZE = CL_DD_AREA=>HEADING.                 " Recommended Font Sizes

  CALL METHOD E_DYNDOC_ID->NEW_LINE( ).

  CALL METHOD E_DYNDOC_ID->ADD_TEXT
    EXPORTING
      TEXT         = |생성일 : { S_BEDAT-LOW } To { S_BEDAT-HIGH }|                 " Single Text, Up To 255 Characters Long
      SAP_STYLE    = CL_DD_AREA=>KEY                 " Recommended Styles
      SAP_COLOR    = CL_DD_AREA=>LIST_HEADING                 " Not Release 99
      SAP_FONTSIZE = CL_DD_AREA=>HEADING.                 " Recommended Font Sizes

  CALL METHOD E_DYNDOC_ID->SET_DOCUMENT_BACKGROUND
    EXPORTING
      PICTURE_ID = 'ALV_BACKGROUND'.                 " Object ID of Picture in BDS (TA OAOR)

  CALL METHOD E_DYNDOC_ID->DISPLAY_DOCUMENT
    EXPORTING
      REUSE_CONTROL = 'X'                 " HTML Control Reused
      PARENT        = GO_CONTAINER_HEAD.                 " Contain Object Already Exists
  GO_ALV_TOP->SET_HEADER_SHOW(
    EXPORTING
      IV_DYNNR          = SY-DYNNR
      IV_SHOW_BACKGRAND = 'X'              " 배경유무
*     IV_SHOW_DEFAULT   = 'X'              " General Flag
    CHANGING
      CO_DOCU           = E_DYNDOC_ID                 " Dynamic Documents: Document
      CO_HEAD           = GO_CONTAINER_HEAD                 " Abstract Container for GUI Controls
      CO_HTML           = GO_HTML                 " HTML Control Proxy Class
  ).

ENDFORM.
