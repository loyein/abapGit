*&---------------------------------------------------------------------*
*& Report Z2510R0080_084
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z2510R0080_084.

*--------------------------------------------------------------------*
* 선언관련 Include
*--------------------------------------------------------------------*
INCLUDE Z2510R0080_084_TOP. " 전역변수 선언 등
INCLUDE Z2510R0080_084_SCR. " 선택화면(Selection Screen) 생성
*INCLUDE _CLS. " 함수 선언 및 구현.
*--------------------------------------------------------------------*
* 구현관련 Include
*--------------------------------------------------------------------*
*INCLUDE Z2510R0080_084_PBO. " PBO(Process Before Output) Module
*INCLUDE Z2510R0080_084_PAI. " PAI(Process After  Input ) Module
*INCLUDE Z2510R0080_084_F01. " FORM Subroutines

*--------------------------------------------------------------------*
INITIALIZATION.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
AT SELECTION-SCREEN.
*--------------------------------------------------------------------*



*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*

*---메일 타이틀
  MAIL_TITLE = '메일 전송 테스트'.

*---메일 글
  T_MAILTEXT = VALUE #( ( LINE = '메일 테스트 내용 1' )
                         ( LINE = '메일 테스트 내용 2' )
                         ( LINE = '메일 테스트 내용 3' ) ).



  TRY.
      CL_SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).

      CL_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                      I_TYPE         = 'RAW'     " 메시지로 보내는 방법
*                      I_TYPE         = 'HTM'      " HTML로 보내는 방법
                      I_SUBJECT      = MAIL_TITLE
*                    I_LENGTH       =
*                    I_LANGUAGE     = SPACE
*                    I_IMPORTANCE   =
*                    I_SENSITIVITY  =
                      I_TEXT         = T_MAILTEXT
*                    I_HEX          =
*                    I_HEADER       =
*                    I_SENDER       =
*                    IV_VSI_PROFILE =
                    ).

      CL_SEND_REQUEST->SET_DOCUMENT( I_DOCUMENT =  CL_DOCUMENT ).

*--------------------------------------------------------------------*
* EXCEL, PDF 첨부파일 넣기
*--------------------------------------------------------------------*

*--- 수신자 TO 넣기


      SEND_TO = P_EMAIL.
      CL_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( SEND_TO ).
      CL_SEND_REQUEST->ADD_RECIPIENT(
        EXPORTING
          I_RECIPIENT  = CL_RECIPIENT                 " Recipient of Message
*          I_EXPRESS    =                  " Send As Express Message
*          I_COPY       =                  " Send Copy
*          I_BLIND_COPY =                  " Send As Blind Copy
*          I_NO_FORWARD =                  " No Forwarding
      ).

      SENT = CL_SEND_REQUEST->SEND( I_WITH_ERROR_SCREEN = 'X' ).

      IF SENT = ABAP_TRUE.
        COMMIT WORK.
        " 성공메시지 "
        MESSAGE |{ SEND_TO }로 발송 되었습니다.| TYPE 'S'.
       ELSE.
         ROLLBACK WORK.
         " 에러메시지
         MESSAGE '메시지 발송에 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

      CATCH CX_BCS INTO BCS_EXCEPTION.
        ERRORTEXT = BCS_EXCEPTION->IF_MESSAGE~GET_TEXT( ).
        MESSAGE ERRORTEXT TYPE 'S' DISPLAY LIKE 'E'.

  ENDTRY.
