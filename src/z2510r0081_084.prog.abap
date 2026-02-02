*&---------------------------------------------------------------------*
*& Report Z2510R0080_084
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z2510R0081_084.

*--------------------------------------------------------------------*
* 선언관련 Include
*--------------------------------------------------------------------*
INCLUDE Z2510R0081_084_TOP. " 전역변수 선언 등
INCLUDE Z2510R0081_084_SCR. " 선택화면(Selection Screen) 생성
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

  DATA : LO_BCS       TYPE REF TO CL_BCS,
         LO_DOCUMENT  TYPE REF TO CL_DOCUMENT_BCS,
         LO_SENDER    TYPE REF TO IF_SENDER_BCS,
         LO_RECIPIENT TYPE REF TO IF_RECIPIENT_BCS.

  DATA : LV_HTML_BODY TYPE STRING,
         LT_OBJCON    TYPE TABLE OF SOLI,
         LS_OBJCON    TYPE SOLI,
         LV_TITLE     TYPE SO_OBJ_DES.

  SELECT *
    FROM SCARR
    INTO TABLE GT_LIST.

  LV_TITLE = '이메일 전송 테스트 html'.

*--- html head 설정
  CONCATENATE
    '<head>'
      '<meta charset="UTF-8">'
      '<style>'
        'table { border-collapse: collapse; width: 100%; }'
        'td, th { border: 1px solid #000; padding: 5px; }'
      '</style>'
    '</head>'
  INTO LS_OBJCON-LINE.
  APPEND LS_OBJCON TO LT_OBJCON.
  CLEAR LS_OBJCON.

*--- html body 설정
  CONCATENATE
    '<body>'
      '안녕하세요.<br><br>'
      '포테이토입니다.<br><br>'
  INTO LS_OBJCON-LINE.
  APPEND LS_OBJCON TO LT_OBJCON.
  CLEAR LS_OBJCON.

  LS_OBJCON-LINE = '<table width=700 border=1>'.
  APPEND LS_OBJCON TO LT_OBJCON.
  CLEAR LS_OBJCON.

*--- 표 형식으로 head 설정. column 명
  CONCATENATE
    '<thead>'
      '<tr align="CENTER">'
        '<th width="150">항공사 코드</th>'
        '<th width="150">항공사이름</th>'
        '<th width="150">항공사의 현지통화</th>'
        '<th width="150">항공사 URL</th>'
      '</tr>'
    '</thead>'
  INTO LS_OBJCON-LINE.
  APPEND LS_OBJCON TO LT_OBJCON.
  CLEAR LS_OBJCON.

*--- 표 형식으로 head 설정. loop를 통해 행 값 입력
  LOOP AT GT_LIST INTO GS_LIST.
    CONCATENATE
      '<tr align=CENTER>'
      '<td>' GS_LIST-CARRID '</td>'
      '<td>' GS_LIST-CARRNAME '</td>'
      '<td>' GS_LIST-CURRCODE '</td>'
      '<td>' GS_LIST-URL '</td>'
      '</tr>'
    INTO LS_OBJCON-LINE.
    APPEND LS_OBJCON TO LT_OBJCON.
    CLEAR LS_OBJCON.
  ENDLOOP.

  LS_OBJCON-LINE = '</table><br>'.
  APPEND LS_OBJCON TO LT_OBJCON.
  CLEAR LS_OBJCON.

  LS_OBJCON-LINE = '<span style="color:red;">감자합니다!</span><br><br>'.
  APPEND LS_OBJCON TO LT_OBJCON.
  CLEAR LS_OBJCON.

  LS_OBJCON-LINE = '<body>'.
  APPEND LS_OBJCON TO LT_OBJCON.
  CLEAR LS_OBJCON.

  TRY.
      " 송신 요청 생성
      LO_BCS = CL_BCS=>CREATE_PERSISTENT( ).
      LO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                                                        I_TYPE    = 'HTM'       " HTML
                                                        I_TEXT    = LT_OBJCON   " 본문
                                                        I_SUBJECT = LV_TITLE ). " 제목
      LO_BCS->SET_DOCUMENT( LO_DOCUMENT ).

      " 송신자 설정
      LO_SENDER = CL_SAPUSER_BCS=>CREATE( SY-UNAME ).
      LO_BCS->SET_SENDER( I_SENDER = LO_SENDER ).

      " 수신자 설정
      LO_RECIPIENT = CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS( P_EMAIL ).
      LO_BCS->ADD_RECIPIENT( I_RECIPIENT = LO_RECIPIENT ).

      LO_BCS->SET_SEND_IMMEDIATELY( I_SEND_IMMEDIATELY = 'X' ).

      " 이메일 발송
      DATA(LV_SUCCESS) = LO_BCS->SEND( ).
      IF LV_SUCCESS = ABAP_TRUE.
        COMMIT WORK.
        " 성공메시지 "
        MESSAGE |{ P_EMAIL }로 발송 되었습니다.| TYPE 'S'.
      ELSE.
        ROLLBACK WORK.
        " 에러메시지
        MESSAGE '메시지 발송에 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    CATCH CX_BCS INTO DATA(LO_BCS_EXCEPTION).
      ROLLBACK WORK.
      MESSAGE LO_BCS_EXCEPTION->GET_TEXT( ) TYPE 'S' DISPLAY LIKE 'E'.


  ENDTRY.
