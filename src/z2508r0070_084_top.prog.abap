*&---------------------------------------------------------------------*
*& Include          Z2508R0070_084_TOP
*&---------------------------------------------------------------------*

TABLES : EKKO.

DATA : BEGIN OF GS_DATA,
         EBELN TYPE EKKO-EBELN,
         EBELP TYPE EKPO-EBELP,
         MATNR TYPE EKPO-MATNR,
       END OF GS_DATA,
       GT_DATA LIKE TABLE OF GS_DATA.

DATA : GT_LIST_R TYPE REF TO DATA.
FIELD-SYMBOLS <GT_LIST> TYPE STANDARD TABLE.

*--------------------------------------------------------------------*
* ALV 관련 선언
*--------------------------------------------------------------------*

DATA :
  OK_CODE     TYPE SY-UCOMM,
  GO_DOCKING  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID,
  GT_FCAT     TYPE LVC_T_FCAT,
  GS_LAYOUT   TYPE LVC_S_LAYO.
