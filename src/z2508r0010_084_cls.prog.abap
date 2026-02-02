*&---------------------------------------------------------------------*
*& Include          Z2508R0010_084_CLS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class (DEFINITION) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
* 구매 번호의 핫스팟 이벤트
    CLASS-METHODS ON_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID .
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD ON_HOTSPOT_CLICK.

    READ TABLE GT_DATA INTO GS_DATA INDEX E_ROW_ID-INDEX.
    SET PARAMETER ID 'BES' FIELD GS_DATA-EBELN.    " ME23N에서 EBELN 필드의 파라미터 id  확인 방법 F1 -> 공구모양을 통해 확인 가능.
    CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN. " 검색 screen인 첫번째 스크린 스킵 가능 .

  ENDMETHOD.
ENDCLASS.
