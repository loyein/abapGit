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
*          \_LFA1[ (1) LEFT OUTER ]-NAME1 AS NAME1,
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

  IF GO_CUSTOM IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYOUT.
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

  CREATE OBJECT GO_CUSTOM
    EXPORTING
      CONTAINER_NAME = 'CCON'.                 " Name of the Screen CustCtrl Name to Link Container To

  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_CUSTOM                   " Parent Container
      ROWS    = 2                   " Number of Rows to be displayed
      COLUMNS = 1.                   " Number of Columns to be Displayed

  GO_SPLITTER->GET_CONTAINER(
    EXPORTING
      ROW       = 1                 " Row
      COLUMN    = 1                 " Column
    RECEIVING
      CONTAINER = GO_CONTAINER1                 " Container
  ).

  GO_SPLITTER->GET_CONTAINER(
   EXPORTING
     ROW       = 2                 " Row
     COLUMN    = 1                 " Column
   RECEIVING
     CONTAINER = GO_CONTAINER2                 " Container
 ).

  CREATE OBJECT GO_ALV_GRID1
    EXPORTING
      I_PARENT = GO_CONTAINER1.                  " Parent Container



  CREATE OBJECT GO_ALV_GRID2
    EXPORTING
      I_PARENT = GO_CONTAINER2.                 " Parent Container


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
  GO_ALV_GRID1->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT1                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_DATA                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT1                 " Field Catalog
  ).

  GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT2                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_ITEM                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT2                 " Field Catalog
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


  CLEAR GS_LAYOUT2.
  GS_LAYOUT2-CWIDTH_OPT = 'A'.

* ALV2 GRID_TITLE 동적 설정
  IF GT_ITEM IS NOT INITIAL.      " ALV데이터가 있을 때만 TITLE 세팅
    DATA(LV_TITLE2) = CONV STRING( TEXT-003 ). " [ PO '&1' has &2 line items ]
    REPLACE '&1' IN LV_TITLE2 WITH GS_DATA-EBELN .  " 선택된 구매오더 번호
    REPLACE '&2' IN LV_TITLE2 WITH CONV STRING( LINES( GT_ITEM ) ). " ALV2 행 수
    GS_LAYOUT2-GRID_TITLE = LV_TITLE2.
  ENDIF.
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
  GO_ALV_GRID1->REFRESH_TABLE_DISPLAY( ).
  GO_ALV_GRID2->REFRESH_TABLE_DISPLAY( ).
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
  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID1.
  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK2 FOR GO_ALV_GRID2.
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
         WAERS     " 통화
    FROM EKPO AS A
     LEFT JOIN MAKT AS B ON A~MATNR = B~MATNR
                        AND B~SPRAS = @SY-LANGU
     JOIN T001L AS C ON A~WERKS = C~WERKS AND A~LGORT = C~LGORT
     JOIN EKKO AS D ON A~EBELN = D~EBELN
     WHERE A~EBELN = @GS_DATA-EBELN
     ORDER BY EBELP
     INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.


* ALV2 LAYOUT 갱신 ( 갱신 안하면 ALV TITLE 동적 구현 안됨. )
  PERFORM SET_LAYOUT .
  CALL METHOD GO_ALV_GRID2->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = GS_LAYOUT2.

  " ALV2 갱신
  CALL METHOD GO_ALV_GRID2->REFRESH_TABLE_DISPLAY( ).


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
