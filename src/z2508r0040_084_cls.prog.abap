*&---------------------------------------------------------------------*
*& Include          Z2508R0040_084_CLS
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.

    CLASS-METHODS ON_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
    METHOD ON_HOTSPOT_CLICK.
      CLEAR GS_DATA.
      READ TABLE GT_DATA INTO GS_DATA INDEX E_ROW_ID-INDEX.
      SET PARAMETER ID 'BES' FIELD GS_DATA-EBELN.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    ENDMETHOD.
ENDCLASS.
