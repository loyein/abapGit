*----------------------------------------------------------------------*
***INCLUDE LZFGS4H08402F01.
*----------------------------------------------------------------------*
FORM BEFORE_SAVE.

  CONSTANTS : L_NAME TYPE STRING VALUE 'N_____'.
  DATA : L_INDEX LIKE SY-TABIX.
  DATA : LS_COMPONENT TYPE ABAP_COMPONENTDESCR,
         LT_COMPONENT TYPE ABAP_COMPONENT_TAB,

         LR_STRUCTURE TYPE REF TO CL_ABAP_STRUCTDESCR,
         LR_HANDLE    TYPE REF TO DATA,
         LR_BEFORE    TYPE REF TO DATA,
         LR_CHANGE    TYPE REF TO DATA,
         LR_MOVE      TYPE REF TO DATA.

  FIELD-SYMBOLS : <L_STRUCTURE> TYPE ANY,
                  <L_FIELD>     TYPE ANY,
                  <LS_CHANGE>   TYPE ANY,
                  <LV_VIEW>     TYPE ANY.

*-- Get data
  LR_STRUCTURE  ?=
     CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_NAME( X_HEADER-VIEWNAME ).
  LT_COMPONENT = LR_STRUCTURE->GET_COMPONENTS( ).
  LS_COMPONENT-TYPE ?= CL_ABAP_DATADESCR=>DESCRIBE_BY_DATA( <ACTION> ).
  LS_COMPONENT-NAME = L_NAME.
  APPEND LS_COMPONENT TO LT_COMPONENT.

  LR_STRUCTURE = CL_ABAP_STRUCTDESCR=>CREATE( LT_COMPONENT ).

  CREATE DATA LR_HANDLE TYPE HANDLE LR_STRUCTURE.
  ASSIGN LR_HANDLE->* TO <L_STRUCTURE>.


*-- Set user, time, date
  LOOP AT TOTAL.

    IF <ACTION> = NEUER_EINTRAG OR <ACTION> = AENDERN.

      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.

      IF SY-SUBRC EQ 0.
        L_INDEX = SY-TABIX.
      ELSE.
        CLEAR L_INDEX.
      ENDIF.

      CHECK L_INDEX GT 0.
      MOVE-CORRESPONDING TOTAL TO <L_STRUCTURE>.

      CASE <ACTION>.
        WHEN AENDERN. "Change/Update
          ASSIGN COMPONENT 'AEDAT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-DATUM TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AEZET' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UZEIT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AENAM' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UNAME TO <L_FIELD>.
          ENDIF.

        WHEN NEUER_EINTRAG. "New Entries
          ASSIGN COMPONENT 'MANDT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-MANDT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERDAT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-DATUM TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERZET' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UZEIT TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'ERNAM' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SY-UNAME TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AEDAT' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SPACE TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AEZET' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE  SPACE TO <L_FIELD>.
          ENDIF.

          ASSIGN COMPONENT 'AENAM' OF STRUCTURE <L_STRUCTURE>
                                             TO <L_FIELD>.
          IF SY-SUBRC = 0.
            MOVE SPACE TO <L_FIELD>.
          ENDIF.
      ENDCASE.

      MOVE-CORRESPONDING <L_STRUCTURE> TO TOTAL.
      MODIFY TOTAL.
      EXTRACT = TOTAL.
      MODIFY EXTRACT INDEX L_INDEX.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IV_NAME
*&      --> IV_BIRTH
*&      --> IV_EMAIL
*&      <-- EV_USER_ID
*&      <-- EV_STATUS
*&      <-- EV_MESSAGE
*&---------------------------------------------------------------------*
FORM CREATE_USER  USING    P_IV_NAME
                           P_IV_BIRTH
                           P_IV_EMAIL
                  CHANGING P_EV_USER_ID
                           P_EV_STATUS
                           P_EV_MESSAGE.

  DATA : LS_USER    TYPE ZS4H084T04,
         LV_EMAIL   LIKE ZS4H084T04-EMAIL,
         LV_USER_ID LIKE ZS4H084T04-CUST_ID,
         LV_CHECK   VALUE ABAP_FALSE,
         LR_MATCHER TYPE REF TO CL_ABAP_MATCHER.


  DATA(LV_NAME_PATTERN) = '[a-zA-Zㄱ-힣]+$'.
  DATA(LV_EMAIL_PATTERN) =  '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'.

* 필수 입력값 확인.
  IF P_IV_NAME IS INITIAL .
    P_EV_MESSAGE = '사용자 이름이 입력되지 않았습니다.'.
    RETURN.
  ENDIF.

  IF P_IV_BIRTH IS INITIAL .
    P_EV_MESSAGE = '사용자 생년월일이 입력되지 않았습니다.'.
    RETURN.
  ENDIF.

  IF P_IV_EMAIL IS INITIAL .
    P_EV_MESSAGE = '사용자 이메일이 입력되지 않았습니다.'.
    RETURN.
  ENDIF.

  " 사용자 이름 유효성 검사
  LR_MATCHER = CL_ABAP_MATCHER=>CREATE( PATTERN = LV_NAME_PATTERN TEXT = P_IV_NAME ).
  LV_CHECK = LR_MATCHER->MATCH( ).

  IF LV_CHECK IS INITIAL.
    P_EV_MESSAGE = '올바른 이름 형식이 아닙니다.'.
    RETURN.
  ENDIF.

  " 생년월일 유효성 검사
  IF  P_IV_BIRTH > SY-DATUM.
    P_EV_MESSAGE = '생년월일은 오늘 날짜보다 클 수 없습니다.'.
    RETURN.
  ENDIF.

  " 이메일 유효성 검사
  LR_MATCHER = CL_ABAP_MATCHER=>CREATE( PATTERN = LV_EMAIL_PATTERN TEXT = P_IV_EMAIL   ).
  LV_CHECK = LR_MATCHER->MATCH( ).

  IF LV_CHECK IS INITIAL.
    P_EV_MESSAGE = '올바른 이메일 형식이 아닙니다.'.
    RETURN.
  ENDIF.



* 이메일 입력 값 있을 경우 중복 확인
  SELECT SINGLE EMAIL
    FROM ZS4H084T04
    INTO LV_EMAIL
    WHERE EMAIL = P_IV_EMAIL.
  IF SY-SUBRC = 0.
    P_EV_MESSAGE = '이미 존재하는 사용자 이메일입니다.'.
    RETURN.
  ENDIF.


  " 고객 ID 넘버레인지
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = '01'                 " Number range number
      OBJECT                  = 'ZCUSTID'                 " Name of number range object
      QUANTITY                = '1'              " Number of numbers
    IMPORTING
      NUMBER                  = LV_USER_ID                 " free number
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1                " Interval not found
      NUMBER_RANGE_NOT_INTERN = 2                " Number range is not internal
      OBJECT_NOT_FOUND        = 3                " Object not defined in TNRO
      QUANTITY_IS_0           = 4                " Number of numbers requested must be > 0
      QUANTITY_IS_NOT_1       = 5                " Number of numbers requested must be 1
      INTERVAL_OVERFLOW       = 6                " Interval used up. Change not possible.
      BUFFER_OVERFLOW         = 7                " Buffer is full
      OTHERS                  = 8.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    RETURN.
  ENDIF.

  CLEAR LS_USER.
  LS_USER-CUST_ID = LV_USER_ID.
  LS_USER-CUST_NAME = P_IV_NAME.
  LS_USER-BIRTH_DATE = P_IV_BIRTH.
  LS_USER-EMAIL = P_IV_EMAIL.
  LS_USER-ERNAM = SY-UNAME.
  LS_USER-ERDAT = SY-DATUM.
  LS_USER-ERZET = SY-UZEIT.

  INSERT ZS4H084T04 FROM LS_USER.

  IF SY-SUBRC = 0.

    COMMIT WORK.
    P_EV_STATUS = 'S'.
    P_EV_MESSAGE = |사용자 '{ P_IV_NAME }' ({ LV_USER_ID }) 등록을 완료하였습니다.|. "ex)사용자 '홍길동'(1234567890) 등록을 완료 하였습니다.
    P_EV_USER_ID = LV_USER_ID.
  ELSE.
    ROLLBACK WORK.
    P_EV_MESSAGE = '사용자 생성에 실패하였습니다.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_USER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IV_NAME
*&      --> IV_BIRTH
*&      --> IV_EMAIL
*&      <-- EV_USER_ID
*&      <-- EV_STATUS
*&      <-- EV_MESSAGE
*&---------------------------------------------------------------------*
FORM MODIFY_USER  USING    P_IV_NAME
                           P_IV_BIRTH
                           P_IV_EMAIL
                           P_IV_USER_ID
                  CHANGING P_EV_USER_ID
                           P_EV_STATUS
                           P_EV_MESSAGE.

  DATA : LS_USER    TYPE ZS4H084T04,
         LV_CHECK   VALUE ABAP_FALSE,
         LR_MATCHER TYPE REF TO CL_ABAP_MATCHER.
   DATA(LV_EMAIL_PATTERN) =  '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'.

* 사용자 ID 필수 입력 체크
  IF P_IV_USER_ID IS INITIAL.
    P_EV_MESSAGE = '사용자 ID를 입력해주세요.'.
    RETURN.
  ENDIF.

* 입력값 가져오기
  CLEAR LS_USER.
  SELECT SINGLE CUST_ID, CUST_NAME, BIRTH_DATE, EMAIL
    FROM ZS4H084T04
    INTO CORRESPONDING FIELDS OF @LS_USER
    WHERE CUST_ID = @P_IV_USER_ID.

  " 입력된 사용자 ID가 존재하지 않을 경우
  IF SY-SUBRC <> 0.
    P_EV_MESSAGE = '존재하지 않는 회원 번호입니다.'.
    RETURN.
  ENDIF.

  " 이메일 입력 받았을 경우 중복 확인
  IF P_IV_EMAIL IS NOT INITIAL AND P_IV_EMAIL NE LS_USER-EMAIL.
    SELECT SINGLE EMAIL
      FROM ZS4H084T04
      INTO @DATA(LV_EMAIL)
      WHERE EMAIL = @P_IV_EMAIL.
    IF SY-SUBRC = 0.
      P_EV_MESSAGE = '이미 존재하는 사용자 이메일입니다.'.
      RETURN.
    ENDIF.
    LS_USER-EMAIL = P_IV_EMAIL.
  ENDIF.

  " 이메일 유효성 검사
  LR_MATCHER = CL_ABAP_MATCHER=>CREATE( PATTERN = LV_EMAIL_PATTERN TEXT = P_IV_EMAIL   ).
  LV_CHECK = LR_MATCHER->MATCH( ).

  IF LV_CHECK IS INITIAL.
    P_EV_MESSAGE = '올바른 이메일 형식이 아닙니다.'.
    RETURN.
  ENDIF.

  " 생일 입력 받았을 경우
  IF P_IV_BIRTH IS NOT INITIAL.
    IF  P_IV_BIRTH > SY-DATUM.
      P_EV_MESSAGE = '생년월일은 오늘 날짜보다 클 수 없습니다.'.
      RETURN.
    ENDIF.
    LS_USER-BIRTH_DATE = P_IV_BIRTH.
  ENDIF.


  " 오류 없을 경우 업데이트
  UPDATE ZS4H084T04
  SET BIRTH_DATE = @LS_USER-BIRTH_DATE,
  EMAIL = @LS_USER-EMAIL,
  AENAM = @SY-UNAME,
  AEDAT = @SY-DATUM,
  AEZET = @SY-UZEIT
  WHERE CUST_ID = @P_IV_USER_ID.

  " 변경 성공했을 경우.
  IF SY-SUBRC = 0.
    COMMIT WORK.
    P_EV_STATUS = 'S'.
    P_EV_MESSAGE = |사용자 { P_IV_NAME }의 정보 변경을 완료 하였습니다. |.
  ELSE.
    ROLLBACK WORK.
    P_EV_MESSAGE = '사용자 정보 변경에 실패하였습니다.'.
  ENDIF.

ENDFORM.
