*&---------------------------------------------------------------------*
*& Include          ZSH08402_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME.

  SELECT-OPTIONS : SO_NAME   FOR GS_DISPLAY-CUST_NAME NO INTERVALS NO-EXTENSION,
                   SO_ID     FOR ZS4H084T04-CUST_ID.

   PARAMETERS : P_BNAME LIKE GS_DISPLAY-BNAME,
                P_PUB   LIKE GS_DISPLAY-PUBLISHER,
                P_AUTH  LIKE GS_DISPLAY-AUTHOR.

  SELECTION-SCREEN SKIP.

  PARAMETERS       P_STATUS TYPE C AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK B01.
