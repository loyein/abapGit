*&---------------------------------------------------------------------*
*& Include          Z2508R0040_084_TOP
*&---------------------------------------------------------------------*

TABLES : SSCRFIELDS.

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
         QUAN      TYPE EKPO-MENGE,     " 수량
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


*--------------------------------------------------------------------*
* BDC DATA 선언
*--------------------------------------------------------------------*
DATA: GT_BDCDATA TYPE TABLE OF BDCDATA,                  " BDC 데이터 관련
      GT_BDCMSG  TYPE STANDARD TABLE OF BDCMSGCOLL.      " BDC 메시지 관련
