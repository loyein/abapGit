*&---------------------------------------------------------------------*
*& Include          Z2508R0010_084_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME.

  SELECT-OPTIONS : S_EKORG FOR EKKO-EKORG NO-EXTENSION NO INTERVALS,  " 구매 조직
                   S_EKGRP FOR EKKO-EKGRP NO-EXTENSION NO INTERVALS,  " 구매 그룹
                   S_LIFNR FOR EKKO-LIFNR NO INTERVALS,               " 공급 업체
                   S_BEDAT FOR EKKO-BEDAT NO-EXTENSION .               " 생성일
SELECTION-SCREEN END OF BLOCK B01.
