*&---------------------------------------------------------------------*
*& Include          ZSH08402_CLS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class (DEFINITION) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS ON_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_COLUMN E_ROW ES_ROW_NO.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
    METHOD ON_DOUBLE_CLICK.

      PERFORM ALV_DOUBLE_CLICK USING E_COLUMN E_ROW ES_ROW_NO.

    ENDMETHOD.
ENDCLASS.
