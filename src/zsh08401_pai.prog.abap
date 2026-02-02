*&---------------------------------------------------------------------*
*& Include          ZSH08401_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CLEAR :  GV_STATUS.

  CASE OK_CODE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'ADD'.  " 사용자 생성
      PERFORM CLEAR_FIELD.
      CALL SCREEN 0101 STARTING AT 20 5.
    WHEN 'MODIF'. " 사용자 정보 수정
      PERFORM FILL_POPUP_DATA.
      CALL SCREEN 0101 STARTING AT 20 5.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0101 INPUT.

  DATA: LV_MESSAGE TYPE C LENGTH 100,
        LV_USER_ID TYPE C LENGTH 10.

  CASE OK_CODE.

*--------------------------------------------------------------------*
* 취소 버튼을 눌렀을 때
*--------------------------------------------------------------------*
    WHEN 'CANC'.

      DATA(LV_ANSWER) = ''.

      "  생성 버튼 후 취소
      IF R2 EQ 'X' AND ( S_NAME  IS NOT INITIAL
                         OR S_BIRTH IS NOT INITIAL
                         OR S_EMAIL IS NOT INITIAL ) AND GV_STATUS NE 'S'.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            TITLEBAR              = '사용자 생성 취소'
            TEXT_QUESTION         = '사용자 생성을 취소하시겠습니까?'
            TEXT_BUTTON_1         = '확인'
            TEXT_BUTTON_2         = '취소'
            DEFAULT_BUTTON        = '1'
            DISPLAY_CANCEL_BUTTON = ' '
          IMPORTING
            ANSWER                = LV_ANSWER
          EXCEPTIONS
            OTHERS                = 1.
        IF SY-SUBRC <> 0.
          RETURN.
        ELSEIF LV_ANSWER = '2'. "취소
          RETURN.
        ENDIF.

        " 생성 성공 후 취소버튼
      ELSEIF R2 EQ 'X' AND GV_STATUS = 'S'.
        PERFORM SELECT_DATA.
        LEAVE TO SCREEN 0.


        " 수정 버튼 후 취소
      ELSEIF R3 EQ 'X'.

        " 수정된 정보가 존재하지 않을 경우
        IF S_BIRTH EQ GS_POPUP-BIRTH_DATE AND S_EMAIL EQ GS_POPUP-EMAIL.
          MESSAGE '고객수정을 취소하였습니다.' TYPE 'I'.

        ELSE.
          " 수정된 정보가 존재할 경우
          CALL FUNCTION 'POPUP_TO_CONFIRM'
            EXPORTING
              TITLEBAR              = '사용자 변경 취소'
              TEXT_QUESTION         = '변경된 값이 있습니다 취소하겠습니까?'
              TEXT_BUTTON_1         = '확인'
              TEXT_BUTTON_2         = '취소'
              DEFAULT_BUTTON        = '1'
              DISPLAY_CANCEL_BUTTON = ' '
            IMPORTING
              ANSWER                = LV_ANSWER
            EXCEPTIONS
              OTHERS                = 1.
          IF SY-SUBRC <> 0.
            RETURN.
          ELSEIF LV_ANSWER = '2'. "취소
            RETURN.
          ENDIF.
        ENDIF.
      ENDIF.
      PERFORM SELECT_DATA.
      LEAVE TO SCREEN 0.


* 확인버튼 눌렀을 때
    WHEN 'OK'.
      " 생성버튼 후 확인.
      IF R2 EQ 'X'.
        CALL FUNCTION 'ZFM_MAINTAIN_USER_01'
          EXPORTING
            IV_MODE    = 'I'                 " 생성/변경 구분 (I/M)
            IV_NAME    = S_NAME                 " 사용자 이름
            IV_BIRTH   = S_BIRTH                " 생년월일 (YYYYMMDD)
            IV_EMAIL   = S_EMAIL                 " 전자메일 주소
            IV_USER_ID = ''
          IMPORTING
            EV_STATUS  = GV_STATUS                  " 성공/실패 (S/F)
            EV_MESSAGE = LV_MESSAGE
            EV_USER_ID = LV_USER_ID.

        IF GV_STATUS EQ 'S'.
          MESSAGE LV_MESSAGE TYPE 'I' DISPLAY LIKE 'S'.
          S_ID = LV_USER_ID.
          RETURN.
        ELSEIF GV_STATUS EQ 'F'.
          MESSAGE LV_MESSAGE TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.

        " 수정버튼 후 확인.
      ELSEIF R3 EQ 'X'.
        CALL FUNCTION 'ZFM_MAINTAIN_USER_01'
          EXPORTING
            IV_MODE    = 'M'                 " 생성/변경 구분 (I/M)
            IV_NAME    = S_NAME                 " 사용자 이름
            IV_BIRTH   = S_BIRTH                " 생년월일 (YYYYMMDD)
            IV_EMAIL   = S_EMAIL                 " 전자메일 주소
            IV_USER_ID = S_ID
          IMPORTING
            EV_STATUS  = GV_STATUS                  " 성공/실패 (S/F)
            EV_MESSAGE = LV_MESSAGE.

        " 변경 여부 확인.
        IF GV_STATUS EQ 'S' AND ( S_BIRTH NE GS_POPUP-BIRTH_DATE OR S_EMAIL NE GS_POPUP-EMAIL ). " 변경된 값이 있을 경우 변경 후 성공메시지
          MESSAGE LV_MESSAGE TYPE 'S'.
          PERFORM SELECT_DATA.
          LEAVE TO SCREEN 0.
        ELSEIF GV_STATUS EQ 'S' AND ( S_BIRTH EQ GS_POPUP-BIRTH_DATE AND S_EMAIL EQ GS_POPUP-EMAIL ). " 변경 사항이 없을 경우 알림메시지
          MESSAGE '변동사항이 없습니다' TYPE 'I'.
          LEAVE TO SCREEN 0.
        ELSEIF GV_STATUS EQ 'F'.
          MESSAGE LV_MESSAGE TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
        CLEAR : GV_STATUS.
      ENDIF.




  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0102  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0102 INPUT.
  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
