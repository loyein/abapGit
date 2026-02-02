*&---------------------------------------------------------------------*
*& Include          Z2508R0030_084_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-T01.

  SELECT-OPTIONS: S_BUKRS FOR T001-BUKRS NO INTERVALS NO-EXTENSION OBLIGATORY DEFAULT '4000',
                  S_VBELN  FOR VBAK-VBELN NO INTERVALS NO-EXTENSION OBLIGATORY.
  PARAMETERS      P_EMAIL TYPE ADR6-SMTP_ADDR.
SELECTION-SCREEN END OF BLOCK B01.
