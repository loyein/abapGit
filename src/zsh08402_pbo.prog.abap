*&---------------------------------------------------------------------*
*& Include          ZSH08402_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF P_STATUS IS INITIAL.  " 연체 도서 체크박스 미선택
    SET PF-STATUS 'S0100'.
  ELSE.                    " 연체 도서 조회
    SET PF-STATUS 'S0100'
    EXCLUDING 'RENTAL'.
  ENDIF.

  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

  IF GO_CONTAINER IS INITIAL.

    PERFORM CREATE_OBJECT.
    PERFORM SET_ALV_LAYOUT.
    PERFORM SET_ALV_FCAT.
    PERFORM SET_HANDLER.
    PERFORM DISPLAY_ALV.

  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  SET PF-STATUS 'S0101'.
  SET TITLEBAR 'T0101'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0102 OUTPUT.
  SET PF-STATUS 'S0102'.
  SET TITLEBAR 'T0102'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0102 OUTPUT.

  IF GO_CONTAINER2 IS INITIAL.
    CREATE OBJECT GO_CONTAINER2
      EXPORTING
        CONTAINER_NAME = 'CCON2'.                 " Name of the Screen CustCtrl Name to Link Container To

    CREATE OBJECT GO_ALV_GRID2
      EXPORTING
        I_PARENT = GO_CONTAINER2.                 " Parent Container

    CLEAR GS_LAYOUT2.
    GS_LAYOUT2-ZEBRA = 'X'.

    PERFORM ALV_FCAT2.

    GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY(
      EXPORTING
        IS_LAYOUT                     = GS_LAYOUT2                 " Layout

      CHANGING
        IT_OUTTAB                     = GT_POPUP                 " Output Table
        IT_FIELDCATALOG               = GT_FCAT2                 " Field Catalog

).

  ELSE.
    GO_ALV_GRID2->REFRESH_TABLE_DISPLAY( ).
  ENDIF.

ENDMODULE.
