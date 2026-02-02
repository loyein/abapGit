*&---------------------------------------------------------------------*
*& Report Z2510R0080_084
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z2510R0082_084.

*--------------------------------------------------------------------*
* 선언관련 Include
*--------------------------------------------------------------------*
INCLUDE Z2510R0082_084_TOP.
*INCLUDE Z2510R0080_084_TOP. " 전역변수 선언 등
INCLUDE Z2510R0082_084_SCR.
*INCLUDE Z2510R0080_084_SCR. " 선택화면(Selection Screen) 생성
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
                      I_SUBJECT      = MAIL_TITLE  " 메일 타이틀 넣기
*                    I_LENGTH       =
*                    I_LANGUAGE     = SPACE
*                    I_IMPORTANCE   =
*                    I_SENSITIVITY  =
                      I_TEXT         = T_MAILTEXT  " 메일 글 넣기
*                    I_HEX          =
*                    I_HEADER       =
*                    I_SENDER       =
*                    IV_VSI_PROFILE =
                    ).

      CL_SEND_REQUEST->SET_DOCUMENT( I_DOCUMENT =  CL_DOCUMENT ).

*--------------------------------------------------------------------*
* EXCEL, PDF 첨부파일 넣기
*--------------------------------------------------------------------*

      " 메일로 보냈을 때 파일 명
      ATTACHMENT_SUBJECT = 'OLE_20250903.PDF'.

      CONCATENATE '&SO_FILENAME=' ATTACHMENT_SUBJECT INTO WA_ATTACHMENT_HEADER.
      APPEND WA_ATTACHMENT_HEADER TO T_ATTACHMENT_HEADER.
      CLEAR:
        WA_ATTACHMENT_HEADER.

*      " 파일 용량 "
      SOOD_BYTECOUNT = '     '.

*      " 파일 데이터( 16진수 ) "
*      DATA:
*        LT_ROWREC TYPE SOLIX_TAB.
*      LT_ROWREC = '3571892943827'.
      DATA: LT_ROWREC TYPE SOLIX_TAB,
            LV_SIZE   TYPE I.

      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          FILENAME   = 'C:\Users\USER\Desktop\Email 파일\4주차\OLE_20250903.PDF'   " 현재 PC에 있는 파일 경로
                                                                                   " OLE의 경울 SAVEPATH 넣으면 됨.
          FILETYPE   = 'BIN'
        IMPORTING
          FILELENGTH = LV_SIZE
        TABLES
          DATA_TAB   = LT_ROWREC.


      " EXCEL 첨부파일 설정 "
      CL_DOCUMENT->ADD_ATTACHMENT(
        I_ATTACHMENT_TYPE    = 'PDF'
        I_ATTACHMENT_SUBJECT = ATTACHMENT_SUBJECT
        I_ATTACHMENT_SIZE    = SOOD_BYTECOUNT
        I_ATT_CONTENT_HEX    = LT_ROWREC
        I_ATTACHMENT_HEADER  = T_ATTACHMENT_HEADER ).

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

      CL_SEND_REQUEST->SET_SEND_IMMEDIATELY( I_SEND_IMMEDIATELY = 'X' ).
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
