*&---------------------------------------------------------------------*
*& Include          ZSH08401_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  PERFORM STATUS_0100.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

  IF GO_CONTAINER IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM ALV_LAYOUT.
    PERFORM ALV_FCAT.
    PERFORM DISPLAY_ALV.
    PERFORM ALV_EVENT.
  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0101 OUTPUT.
  IF GV_STATUS = 'S'.
    SET PF-STATUS 'S0101'
    EXCLUDING 'OK'.
  ELSE.
    SET PF-STATUS 'S0101'.
  ENDIF.

  IF R2 = 'X'.
    SET TITLEBAR 'T0101' WITH '생성'.

  ELSEIF R3 = 'X'.
    SET TITLEBAR 'T0101' WITH '변경'.

  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0102 OUTPUT.
  SET PF-STATUS 'S0102'.
  CASE GV_POP.
    WHEN 'R'.
      SET TITLEBAR 'T0102' WITH '대여중인 도서 목록'.
    WHEN 'T'.
      SET TITLEBAR 'T0102' WITH '전체 대여 도서 목록'.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV2 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV2 OUTPUT.
  IF GO_CONTAINER2 IS INITIAL.

    CREATE OBJECT GO_CONTAINER2
      EXPORTING
        CONTAINER_NAME = 'CCON'.                 " Name of the Screen CustCtrl Name to Link Container To


    CREATE OBJECT GO_ALV_GRID2
      EXPORTING
        I_PARENT = GO_CONTAINER2.                 " Parent Container

    GT_FCAT2 = VALUE #( ( FIELDNAME = 'ISBN' COLTEXT = 'ISBN')
                        ( FIELDNAME = 'BNAME' COLTEXT = '도서명')
                        ( FIELDNAME = 'RDATE' COLTEXT = '대여일')
                        ( FIELDNAME = 'RTDATE' COLTEXT = '반납일')
                        ).

    GS_LAYOUT2-CWIDTH_OPT = 'A'.

    GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY(
      EXPORTING
*        IS_VARIANT                    =                  " Layout
*        I_SAVE                        =                  " Save Layout
        IS_LAYOUT                     = GS_LAYOUT2                 " Layout
      CHANGING
        IT_OUTTAB                     = GT_POPUP2                  " Output Table
        IT_FIELDCATALOG               = GT_FCAT2
        ).
  ELSE.
    GO_ALV_GRID2->REFRESH_TABLE_DISPLAY( ).
  ENDIF.
ENDMODULE.
