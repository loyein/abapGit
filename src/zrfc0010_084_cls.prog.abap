*&---------------------------------------------------------------------*
*& Include          ZRFC0010_084_CLS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class (DEFINITION) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
*    CLASS-METHODS ON_DATA_CHANGED FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
*      IMPORTING ER_DATA_CHANGED.

  CLASS-METHODS ON_DATA_CHANGED FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING E_MODIFIED ET_GOOD_CELLS .

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
  METHOD ON_DATA_CHANGED.
*    PERFORM DATA_CHANGED USING ER_DATA_CHANGED .
    PERFORM DATA_MODIFIED USING E_MODIFIED ET_GOOD_CELLS.
*    PERFORM DATA_CHECKED USING ER_DATA_CHANGED 'CHECK'.
  ENDMETHOD.

ENDCLASS.
