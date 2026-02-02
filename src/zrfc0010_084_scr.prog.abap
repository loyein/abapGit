*&---------------------------------------------------------------------*
*& Include          ZRFC0010_084_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: S_ERDAT FOR ZMMT0510_084-RFQDT NO-EXTENSION,
                  S_RFQNO FOR ZMMT0510_084-RFQNO NO-EXTENSION NO INTERVALS.

  SELECTION-SCREEN SKIP.

  PARAMETERS: R1 RADIOBUTTON GROUP R1,
              R2 RADIOBUTTON GROUP R1.

SELECTION-SCREEN END OF BLOCK B01.
