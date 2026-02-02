*&---------------------------------------------------------------------*
*& Include          ZSH08402_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.

      "도서 대여
    WHEN 'RENTAL'.
      PERFORM RENTAL_BOOK.

      " 도서 반납
    WHEN 'RETURN'.
      DATA(LV_ANSWER) = ''.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TEXT_QUESTION  = '선택한 도서를 반납하겠습니까?'
          TEXT_BUTTON_1  = '확인'
          TEXT_BUTTON_2  = '취소'
          DEFAULT_BUTTON = '1'
          DISPLAY_CANCEL_BUTTON = ' '
        IMPORTING
          ANSWER         = LV_ANSWER.

      IF LV_ANSWER = 2.
        RETURN.
      ENDIF.

      PERFORM RETURN_BOOK.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  CASE OK_CODE.
    WHEN 'OK'.
      IF GV_ID IS INITIAL.
        MESSAGE '사용자 ID를 입력해주세요' TYPE 'I' DISPLAY LIKE 'E'.
        LEAVE TO SCREEN 0101.
      ELSE.
        PERFORM CHECK_CUST.
      ENDIF.
    WHEN 'CANC'.
      CLEAR GV_ID.
      RETURN.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
