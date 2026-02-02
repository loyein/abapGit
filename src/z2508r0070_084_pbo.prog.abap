*&---------------------------------------------------------------------*
*& Include          Z2508R0070_084_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CLEAR_OK_CODE OUTPUT.

  CLEAR OK_CODE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYOUT.
    PERFORM SET_FCAT.
    PERFORM SET_DYNAMIC_TABLE.
    PERFORM DISPLAY_ALV.
  ELSE.
*    PERFORM REFRESH_ALV.
    GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).
  ENDIF.

ENDMODULE.
