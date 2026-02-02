*&---------------------------------------------------------------------*
*& Include          Z2508R0040_084_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  LOOP AT GT_DATA INTO GS_DATA.
    IF  GS_DATA-LIGHT = ICON_RED_LIGHT OR GV_CHECK = 'X'.
      SET PF-STATUS 'S0100' EXCLUDING 'BDC'.
      EXIT.
    ELSE.
      SET PF-STATUS 'S0100'.
    ENDIF.
  ENDLOOP.

SET TITLEBAR 'T0100' .
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'S0200'.
  SET TITLEBAR 'T0200' WITH S_WERKS.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0200 OUTPUT.

  IF GO_DOCKING IS INITIAL.
    PERFORM CREATE_OBJECT_0200.
    PERFORM SET_LAYOUT_0200.
    PERFORM SET_FCAT_0200.
    PERFORM SET_EVENT_HANDLER_0200.
    PERFORM DISPLAY_ALV_0200.

  ELSE.
    PERFORM REFRESH_ALV_0200.

  ENDIF.

ENDMODULE.
