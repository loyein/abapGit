*&---------------------------------------------------------------------*
*& Include          ZRFC0010_084_TOP
*&---------------------------------------------------------------------*

TABLES: ZMMT0510_084, ZMMT0520_084.

DATA: BEGIN OF GS_DATA,
        CHECK  TYPE C,
        STATUS TYPE ICON-ID,
        RFQNO  TYPE ZMMT0510_084-RFQNO,  " RFQ Number
        RFQSQ  TYPE ZMMT0520_084-RFQSQ,  " RFQ Line Number
        RFQDT  TYPE ZMMT0510_084-RFQDT,  " RFQ 생성일
        DLVDT  TYPE ZMMT0510_084-DLVDT,  " 배송 요청일
        MATNR  TYPE ZMMT0520_084-MATNR,  " 제품 코드
        MENGE  TYPE ZMMT0520_084-MENGE,  " 수량
        NETPR  TYPE ZMMT0520_084-NETPR,  " 단가
        NETWR  TYPE ZMMT0520_084-NETWR,  " 금액
        MEINS  TYPE ZMMT0520_084-MEINS,  " 수량 단위
        WAERS  TYPE ZMMT0520_084-WAERS,  " 금액 단위
        ZIFFLG TYPE ZMMT0510_084-ZIFFLG, " 전송 FLAG
        ZIFDAT TYPE ZMMT0510_084-ZIFDAT, " 전송 Date
        ZIFTIM TYPE ZMMT0510_084-ZIFTIM, " 전송 TIME
        CELLTAB TYPE LVC_T_STYL,
      END OF GS_DATA,
      GT_DATA LIKE TABLE OF GS_DATA.


*--------------------------------------------------------------------*
* FOR SCREEN 0100
*--------------------------------------------------------------------*
DATA : OK_CODE     TYPE SY-UCOMM,
       GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
       GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID,
       GT_FCAT     TYPE LVC_T_FCAT,
       GS_LAYOUT   TYPE LVC_S_LAYO.
