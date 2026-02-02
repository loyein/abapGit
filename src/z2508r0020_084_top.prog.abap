*&---------------------------------------------------------------------*
*& Include          Z2508R0010_084_TOP
*&---------------------------------------------------------------------*

TABLES : EKKO, LFA1, EKPO.

DATA : BEGIN OF GS_DATA,
         EBELN TYPE EKKO-EBELN,  " 구매문서 번호
         BEDAT TYPE EKKO-BEDAT,  " 구매 날짜
         LIFNR TYPE EKKO-LIFNR,  " 공급업체 번호
         NAME1 TYPE LFA1-NAME1,  " 공급업체 이름
         ERNAM TYPE EKKO-ERNAM,  " 생성자
         NETWR TYPE EKPO-NETWR,  " 총금액 합계
         WAERS TYPE EKKO-WAERS,  " 통화
       END OF GS_DATA.

DATA GT_DATA LIKE TABLE OF GS_DATA.


DATA : BEGIN OF GS_ITEM,
         EBELN TYPE EKPO-EBELN, " 구매문서 번호
         EBELP TYPE EKPO-EBELP, " 라인 넘버
         MATNR TYPE EKPO-MATNR, " 자재 코드
         MAKTX TYPE MAKT-MAKTX, " 자재명
         LGOBE TYPE T001L-LGOBE, " 창고 이름
         MENGE TYPE EKPO-MENGE, " 수량
         MEINS TYPE EKPO-MEINS, " 수량 단위
         NETPR TYPE EKPO-NETPR, " 자재 단가
         NETWR TYPE EKPO-NETWR, " 수량 x 단가 ( 총금액 )
         WAERS TYPE EKKO-WAERS, " 통화
       END OF GS_ITEM.

DATA GT_ITEM LIKE TABLE OF GS_ITEM.
*--------------------------------------------------------------------*
* ALV를 위한 선언
*--------------------------------------------------------------------*

DATA : OK_CODE       TYPE SY-UCOMM,
       GO_CUSTOM     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,      " Splitter 할 큰 custom container
       GO_SPLITTER   TYPE REF TO CL_GUI_SPLITTER_CONTAINER,

       GO_CONTAINER1 TYPE REF TO CL_GUI_CONTAINER, " 헤더 정보를 담을 컨테이너1
       GO_CONTAINER2 TYPE REF TO CL_GUI_CONTAINER, " 아이템 정보를 담을 컨테이너2

       GO_ALV_GRID1  TYPE REF TO CL_GUI_ALV_GRID,
       GO_ALV_GRID2  TYPE REF TO CL_GUI_ALV_GRID,

       GT_FCAT1      TYPE LVC_T_FCAT,
       GT_FCAT2      TYPE LVC_T_FCAT,

       GS_LAYOUT1    TYPE LVC_S_LAYO,
       GS_LAYOUT2    TYPE LVC_S_LAYO.
