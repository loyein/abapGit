*&---------------------------------------------------------------------*
*& Include          ZRFC0010_084_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  DATA: LT_FCODE TYPE TABLE OF SY-UCOMM,
        LS_FCODE TYPE SY-UCOMM.

  SET TITLEBAR 'T0100'.
  IF R2 = 'X'.
    LS_FCODE = 'SAVE'. APPEND LS_FCODE TO LT_FCODE.
    LS_FCODE = 'SEND'. APPEND LS_FCODE TO LT_FCODE.
    LS_FCODE = 'ADD'. APPEND LS_FCODE TO LT_FCODE.
    LS_FCODE = 'DELETE'. APPEND LS_FCODE TO LT_FCODE.
    SET PF-STATUS 'S0100' EXCLUDING LT_FCODE.
  ELSE.
    SET PF-STATUS 'S0100'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

  IF GO_DOCKING IS INITIAL .

    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYOUT.
    PERFORM SET_FCAT.
    PERFORM DISPLAY_ALV.
    PERFORM SET_EVENT_HANDLER.

  ELSE.

    PERFORM ALV_REFRESH.

  ENDIF.

ENDMODULE.
