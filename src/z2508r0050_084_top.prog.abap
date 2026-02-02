*&---------------------------------------------------------------------*
*& Include          Z2508R0040_084_TOP
*&---------------------------------------------------------------------*

TABLES : SSCRFIELDS, EKKO, EKPO, MARA, T001W, EKET, LFA1.

DATA : BEGIN OF GS_EXCEL,
         VENDOR    TYPE EKKO-LIFNR ,    " Vendor
         MATNR     TYPE MAKT-MATNR,     " 자재코드
         QUAN      TYPE EKPO-MENGE,     " 수량
         UNIT      TYPE EKPO-MEINS,     " 수량 단위 '
         UNITPRICE TYPE EKPO-NETPR,     " 단가
         CURRENCY  TYPE EKKO-WAERS,     " 통화
         WERKS     TYPE EKPO-WERKS,     " 공장
         LGORT     TYPE EKPO-LGORT,     " 창고
       END OF GS_EXCEL,
       GT_EXCEL LIKE TABLE OF GS_EXCEL.

DATA : BEGIN OF GS_DATA,
         LIGHT     TYPE ICON-ID,
         VENDOR    TYPE EKKO-LIFNR ,    " Vendor
         NAME1     TYPE LFA1-NAME1,     " Vendor 이름
         MATNR     TYPE MAKT-MATNR,     " 자재코드
         MAKTX     TYPE MAKT-MAKTX,     " 자재명
         QUAN      TYPE EKPO-MENGE,     " 수량 단위
         UNIT      TYPE EKPO-MEINS,     " 수량 단위
         UNITPRICE TYPE EKPO-NETPR,     " 단가
         SUM       TYPE EKPO-NETWR,     " 단가 X 수량
         CURRENCY  TYPE EKKO-WAERS,     " 통화
         WERKS     TYPE EKPO-WERKS,     " 공장
         LGORT     TYPE EKPO-LGORT,     " 창고
         EBELN     TYPE EKKO-EBELN,     " 구매번호
         MESSAGE   TYPE C LENGTH 100,           " 메시지
         GT_SCOL   TYPE LVC_T_SCOL,
       END OF GS_DATA,
       GT_DATA LIKE TABLE OF GS_DATA.

DATA GV_CHECK TYPE C.

*--------------------------------------------------------------------*
* 구매오더 수정을 위한 헤더 데이터
*--------------------------------------------------------------------*
DATA : BEGIN OF GS_HEADER,
         EBELN       TYPE EKKO-EBELN,     " 구매번호
         WERKS       TYPE EKPO-WERKS,
         LIFNR       TYPE EKKO-LIFNR ,    " Vendor
         NAME1       TYPE LFA1-NAME1,     " Vendor 이름
         COUNT_PO    TYPE I,     " po건수
         TOTAL_QUAN  TYPE EKPO-MENGE,     " 총 수량
         MEINS       TYPE EKPO-MEINS,     " 수량 단위
         TOTAL_PRICE TYPE EKPO-NETWR,     " 총 금액
         WAERS       TYPE EKKO-WAERS,     " 통화
         BEDAT       TYPE EKKO-BEDAT,
         BTN_ICON    TYPE ICON-NAME, " 아이콘 조회 버튼
         STYLE       TYPE LVC_T_STYL,
       END OF GS_HEADER,
       GT_HEADER LIKE TABLE OF GS_HEADER.
*--------------------------------------------------------------------*
* 구매오더 수정을 위한 아이템 데이터
*--------------------------------------------------------------------*
DATA : BEGIN OF GS_ITEM,
         EBELN   TYPE EKKO-EBELN,     " 구매오더번호
         EBELP   TYPE EKPO-EBELP,     " 구매오더품목
         MATNR   TYPE EKPO-MATNR,     " 자재번호
         MAKTX   TYPE MAKT-MAKTX,     " 자재명
         MENGE   TYPE EKPO-MENGE,
         MEINS   TYPE EKPO-MEINS,     " 수량 단위
         NETPR   TYPE EKPO-NETPR,     " 순 오더금액
         WAERS   TYPE EKKO-WAERS,     " 통화
         NETWR   TYPE EKPO-NETWR,     " 총 금액
         EINDT   TYPE EKET-EINDT,     "납품일
         BEDAT   TYPE EKKO-BEDAT,     "증빙일
         LOEKZ   TYPE EKPO-LOEKZ,
         CHECK   TYPE C,
         STATUS  TYPE ICON-ID,
         MESSAGE TYPE C LENGTH 100,
         CELLTAB TYPE LVC_T_STYL,
         RETURN_MSG TYPE BAPIRET2_T,

       END OF GS_ITEM,
       GT_ITEM LIKE TABLE OF GS_ITEM.

*--------------------------------------------------------------------*
* ALV DATA 선언
*--------------------------------------------------------------------*
DATA : OK_CODE      TYPE SY-UCOMM,
       GO_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID  TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT      TYPE LVC_T_FCAT,
       GS_LAYOUT    TYPE LVC_S_LAYO,
       GS_VARIANT   TYPE DISVARIANT,
       GV_SAVE      TYPE C,
       GS_SCOL      LIKE LINE OF GS_DATA-GT_SCOL.

DATA : GO_DOCKING   TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_SPLITTER  TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
       GO_CON1      TYPE REF TO CL_GUI_CONTAINER,
       GO_CON2      TYPE REF TO CL_GUI_CONTAINER,
       GO_ALV_GRID1 TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID2 TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT1     TYPE LVC_T_FCAT,
       GT_FCAT2     TYPE LVC_T_FCAT,
       GS_LAYOUT1   TYPE LVC_S_LAYO,
       GS_LAYOUT2   TYPE LVC_S_LAYO.


*--------------------------------------------------------------------*
* BDC DATA 선언
*--------------------------------------------------------------------*
       DATA:       GT_BDCDATA TYPE TABLE OF BDCDATA,                  " BDC 데이터 관련
       GT_BDCMSG   TYPE STANDARD TABLE OF BDCMSGCOLL.      " BDC 메시지 관련


*--------------------------------------------------------------------*
*
*--------------------------------------------------------------------*
" BAPI 에러 메시지와 PO 번호를 함께 저장할 구조체
DATA: BEGIN OF GS_MSG,
        EBELN   TYPE EKPO-EBELN,
        TYPE    TYPE BAPIRET2-TYPE,
        MESSAGE TYPE BAPIRET2-MESSAGE,
      END OF GS_MSG,
      GT_MSG LIKE TABLE OF GS_MSG.
