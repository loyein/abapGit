*&---------------------------------------------------------------------*
*& Include          Z2508R0010_084_TOP
*&---------------------------------------------------------------------*

TABLES : EKKO, LFA1, EKPO.

DATA : BEGIN OF GS_DATA,
         EBELN       TYPE EKKO-EBELN,  " 구매문서 번호
         BEDAT       TYPE EKKO-BEDAT,  " 구매 날짜
         LIFNR       TYPE EKKO-LIFNR,  " 공급업체 번호
         NAME1       TYPE LFA1-NAME1,  " 공급업체 이름
         ERNAM       TYPE EKKO-ERNAM,  " 생성자
         TOTAL_NETWR TYPE EKPO-NETWR,  " 총금액 합계
         WAERS       TYPE EKKO-WAERS,  " 단위
       END OF GS_DATA.

DATA GT_DATA LIKE TABLE OF GS_DATA.

*--------------------------------------------------------------------*
* ALV를 위한 선언
*--------------------------------------------------------------------*

DATA : OK_CODE      TYPE SY-UCOMM,
       GO_CONTAINER  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID  TYPE REF TO CL_GUI_ALV_GRID,
       GS_FCAT      TYPE LVC_S_FCAT,
       GT_FCAT      TYPE LVC_T_FCAT,
       GS_LAYOUT    TYPE LVC_S_LAYO.
