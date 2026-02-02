*&---------------------------------------------------------------------*
*& Include          ZSH08402_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  DATA(LV_BNAME) = |%{ P_BNAME }%|.
  DATA(LV_PUB)   = |%{ P_PUB }%|.
  DATA(LV_AUTH)   = |%{ P_AUTH }%|.

  SELECT C~BCAT_TEXT,
         C~BCODE,
         A~BNAME,
         A~AUTHOR,
         A~PUBLISHER,
         D~CUST_NAME,
         B~CUST_ID,
         B~RDATE,
         B~RTDUE,
         B~RTDATE,
         A~ISBN && '-' && E~SEQ AS ISBN
    FROM ZS4H084T02 AS A
    JOIN ZS4H084T01 AS C
    ON A~BCODE = C~BCODE
    JOIN ZS4H084T03 AS E
    ON A~ISBN = E~ISBN
    LEFT OUTER JOIN ZS4H084T05 AS B
    ON A~ISBN = B~ISBN AND B~SEQ = E~SEQ AND B~RTDATE IS INITIAL
    LEFT OUTER JOIN ZS4H084T04 AS D
    ON B~CUST_ID = D~CUST_ID
    WHERE D~CUST_ID IN @SO_ID
      AND D~CUST_NAME IN @SO_NAME
      AND A~BNAME LIKE @LV_BNAME
      AND A~AUTHOR LIKE @LV_AUTH
      AND A~PUBLISHER LIKE @LV_PUB
    ORDER BY C~BCODE, A~ISBN , E~SEQ
  INTO CORRESPONDING FIELDS OF TABLE @GT_DISPLAY.

  IF SY-SUBRC <> 0.
    MESSAGE '데이터가 존재하지 않습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  LOOP AT GT_DISPLAY ASSIGNING FIELD-SYMBOL(<FS>).

    AT NEW ISBN(13).
      GS_SCOL-FNAME = 'ISBN'.
      GS_SCOL-COLOR-COL = '3'.   " 노란색
      GS_SCOL-COLOR-INT = '0'.   " 강조 여부
      GS_SCOL-COLOR-INV = '0'.   " 반전 여부
      APPEND GS_SCOL TO <FS>-GT_SCOL.
    ENDAT.

*    ON CHANGE OF <FS>-ISBN(13).
*      CLEAR: GS_SCOL.
*      GS_SCOL-FNAME = 'ISBN'.
*      GS_SCOL-COLOR-COL = '3'.   " 노란색
*      GS_SCOL-COLOR-INT = '0'.   " 강조 여부
*      GS_SCOL-COLOR-INV = '0'.   " 반전 여부
*      APPEND GS_SCOL TO <FS>-GT_SCOL.
*    ENDON.

    " 연체된 도서 STATUS
    IF <FS>-RTDATE IS INITIAL AND <FS>-RTDUE IS NOT INITIAL AND SY-DATUM > <FS>-RTDUE.
      <FS>-STATUS = 'X'.
      " 셀 색상 설정
      CLEAR: GS_SCOL.
      GS_SCOL-FNAME = 'STATUS'.
      GS_SCOL-COLOR-COL = '6'.   " 빨간색
      GS_SCOL-COLOR-INT = '0'.   " 강조 여부
      GS_SCOL-COLOR-INV = '1'.   " 반전 여부
      APPEND GS_SCOL TO <FS>-GT_SCOL.
    ENDIF.
  ENDLOOP.

  " 연체 도서 조회하면 연체되지 않은 데이터 삭제.
  IF P_STATUS = 'X'.
    DELETE GT_DISPLAY WHERE STATUS <> 'X'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  CREATE OBJECT GO_CONTAINER
    EXPORTING
      SIDE      = GO_CONTAINER->DOCK_AT_LEFT     " Side to Which Control is Docked
      EXTENSION = 5000.               " Control Extension

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT = GO_CONTAINER.                 " Parent Container

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_LAYOUT
*&---------------------------------------------------------------------*
FORM SET_ALV_LAYOUT .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-SEL_MODE = 'A'.
  GS_LAYOUT-CTAB_FNAME = 'GT_SCOL'.
  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'A'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ALV_FCAT
*&---------------------------------------------------------------------*
FORM SET_ALV_FCAT .

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'BCAT_TEXT'.
  GS_FCAT-COLTEXT = '도서분류'.
  GS_FCAT-KEY = 'X'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'BNAME'.
  GS_FCAT-COLTEXT = '도서명'.
  GS_FCAT-KEY = 'X'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'ISBN'.
  GS_FCAT-COLTEXT = 'ISBN'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'AUTHOR'.
  GS_FCAT-COLTEXT = '저자'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'PUBLISHER'.
  GS_FCAT-COLTEXT = '출판사'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'CUST_NAME'.
  GS_FCAT-COLTEXT = '대여자'.
  GS_FCAT-EMPHASIZE = 'C500'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'CUST_ID'.
  GS_FCAT-COLTEXT = '대여자 ID'.
  GS_FCAT-EMPHASIZE = 'C500'.
  APPEND GS_FCAT TO GT_FCAT.


  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'RDATE'.
  GS_FCAT-COLTEXT = '대여일'.
  GS_FCAT-EMPHASIZE = 'C500'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'STATUS'.
  GS_FCAT-COLTEXT = '연체여부'.
  GS_FCAT-JUST    = 'C'.
  APPEND GS_FCAT TO GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      IS_VARIANT                    = GS_VARIANT                 " Layout
      I_SAVE                        = GV_SAVE                 " Save Layout
      IS_LAYOUT                     = GS_LAYOUT                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_DISPLAY                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1                " Wrong Parameter
      PROGRAM_ERROR                 = 2                " Program Errors
      TOO_MANY_LINES                = 3                " Too many Rows in Ready for Input Grid
      OTHERS                        = 4
  ).
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RENTAL_BOOK
*&---------------------------------------------------------------------*
FORM RENTAL_BOOK .

  DATA : LT_INDEX TYPE LVC_T_ROW,
         LS_INDEX LIKE LINE OF LT_INDEX.

  "선택한 ALV 행 정보 가져오기.
  GO_ALV_GRID->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX                 " Indexes of Selected Rows
  ).

  IF LINES( LT_INDEX ) = 0.
    MESSAGE '대여처리할 도서를 선택해주세요' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ELSEIF  LINES( LT_INDEX ) > 1.
    MESSAGE '행을 하나만 선택해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.

  ENDIF.

  LOOP AT LT_INDEX INTO LS_INDEX.
    READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_INDEX-INDEX.
    IF SY-SUBRC = 0.

      " 이미 대여중인 도서에 대한 처리
      IF GS_DISPLAY-RDATE IS NOT INITIAL.
        MESSAGE |해당 도서는 이미 { GS_DISPLAY-CUST_NAME }에게 대여 중입니다.| TYPE 'S' DISPLAY LIKE 'E'.

        " 대여 가능한 도서 대여처리
      ELSE.
        CALL SCREEN 0101 STARTING AT 20 5.

      ENDIF.

    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CUST
*&---------------------------------------------------------------------*
FORM CHECK_CUST .


  SELECT B~CUST_ID, ISBN, RTDUE, RTDATE, B~CUST_NAME
    FROM ZS4H084T05 AS A
    JOIN ZS4H084T04 AS B
      ON A~CUST_ID = B~CUST_ID
    WHERE B~CUST_ID = @GV_ID
      AND A~RTDATE IS INITIAL
    INTO TABLE @DATA(LT_CUST).

* 사용자 존재 여부 확인

  SELECT SINGLE CUST_ID
    FROM ZS4H084T04
    WHERE CUST_ID = @GV_ID
    INTO @DATA(LV_EXIST_ID).

  IF SY-SUBRC <> 0.
    MESSAGE |입력한 사용자 ID '{ GV_ID }'는 존재하지 않습니다.| TYPE 'I' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT LT_CUST INTO DATA(LS_CUST).

* 사용자 ID로 연체중인 항목이 존재할 경우 error -> 연체도서 반납 후 대여 가능합니다.
    IF SY-DATUM > LS_CUST-RTDUE.
      MESSAGE '연체도서 반납 후 대여 가능합니다.' TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

* 사용자 ID로 대여중인 도서 5권이상일 경우 error -> [사용자 이름]의 대여한도가 초과 했습니다.
    IF LINES( LT_CUST ) >= 5.
*      READ TABLE LT_CUST INTO LS_CUST INDEX 1.
      MESSAGE |{ LS_CUST-CUST_NAME }의 대여한도가 초과했습니다.| TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

* 사용자 ID로 동일한 ISBN의 도서 대여중일 경우 error -> 사용자 [사용자 이름] 의 대여도서 [도서명]이 미반납
    IF GS_DISPLAY-ISBN(13) = LS_CUST-ISBN.
      MESSAGE | 사용자 '{ LS_CUST-CUST_NAME }'의 대여도서 '{ GS_DISPLAY-BNAME }'이(가) 미반납 상태입니다.| TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.




  ENDLOOP.


* 대여 성공

  DATA: LS_INSERT    TYPE ZS4H084T05,
        LV_TIMESTAMP TYPE TIMESTAMPL.

  GET TIME STAMP FIELD LV_TIMESTAMP." 밀리초 추출: 타임스탬프는 YYYYMMDDhhmmssmmmuu 형식(21자리)

  CLEAR LS_INSERT.
  LS_INSERT-RDATE = SY-DATUM.
  LS_INSERT-RTIME = SY-UZEIT.
  LS_INSERT-RSECOND = LV_TIMESTAMP.
  LS_INSERT-CUST_ID = GV_ID.
  LS_INSERT-BCODE = GS_DISPLAY-BCODE.
  LS_INSERT-ISBN = GS_DISPLAY-ISBN(13).
  LS_INSERT-SEQ = GS_DISPLAY-ISBN+14.
  LS_INSERT-RTDUE = SY-DATUM + 10.
  LS_INSERT-ERNAM = SY-UNAME.
  LS_INSERT-ERDAT = SY-DATUM.
  LS_INSERT-ERZET = SY-UZEIT.

  INSERT ZS4H084T05 FROM LS_INSERT.
  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
    MESSAGE '대여에 실패했습니다.' TYPE 'E'.
  ENDIF.
  COMMIT WORK.
  MESSAGE '대여가 성공적으로 처리되었습니다.' TYPE 'S'.
  PERFORM SELECT_DATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .

  GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).

  CLEAR: GV_ID, GS_DISPLAY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_ID
*&---------------------------------------------------------------------*

FORM F4_ID  USING    VALUE(PV_FILTER).
  DATA : LT_RETURN     TYPE TABLE OF DDSHRETVAL WITH HEADER LINE,
         LV_FIELD      TYPE HELP_INFO-DYNPROFLD,
         LT_DYNPFIELDS TYPE TABLE OF DYNPREAD   WITH HEADER LINE.


  CASE PV_FILTER.
    WHEN 'LOW'.
      LV_FIELD = 'SO_ID-LOW'.
    WHEN 'HIGH'.
      LV_FIELD = 'SO_ID-HIGH'.
  ENDCASE.

* SEARCH HELP 테이블 준비
  SELECT CUST_ID, CUST_NAME
    FROM ZS4H084T04
    INTO TABLE @DATA(LT_HELP)
    ORDER BY CUST_ID.

* F4팝업 실행
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD     = 'CUST_ID'                 " Name of return field in FIELD_TAB
      DYNPPROG     = SY-REPID            " Current program
      DYNPNR       = SY-DYNNR            " Screen number
      DYNPROFIELD  = LV_FIELD            " Name of screen field for value return
      WINDOW_TITLE = '고객 ID'                 " Title for the hit list
      VALUE_ORG    = 'S'              " Value return: C: cell by cell, S: structured
    TABLES
      VALUE_TAB    = LT_HELP                 " Table of values: entries cell by cell
      RETURN_TAB   = LT_RETURN.

  IF LT_RETURN IS INITIAL.
    RETURN.
  ENDIF.

* 선택된 CUST_ID로 CUST_NAME 찾기
  READ TABLE LT_HELP INTO DATA(LS_HELP) WITH KEY CUST_ID = LT_RETURN-FIELDVAL BINARY SEARCH.
  IF SY-SUBRC <> 0.
    RETURN.
  ENDIF.

* 선택된 값 LT_DYNPFIELDS에 추가
  CLEAR LT_DYNPFIELDS.
  APPEND VALUE #( FIELDNAME = 'SO_NAME-LOW' FIELDVALUE = LS_HELP-CUST_NAME ) TO LT_DYNPFIELDS.
  APPEND VALUE #( FIELDNAME = LV_FIELD       FIELDVALUE = LS_HELP-CUST_ID   ) TO LT_DYNPFIELDS.

* 구문법으로는 아래와 같음.
*  DATA LS_DYNPFIELD TYPE DYNPREAD.
*  CLEAR LS_DYNPFIELD.
*  LS_DYNPFIELD-FIELDNAME  = LV_FIELD.
*  LS_DYNPFIELD-FIELDVALUE = LS_HELP-CUST_ID.
*  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.


* 값을 화면에 업데이트 해줌
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME     = SY-CPROG                " Program Name
      DYNUMB     = SY-DYNNR                " Screen number
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.                " Screen field value reset table
ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_book
*&---------------------------------------------------------------------*
FORM RETURN_BOOK .

  DATA : LT_INDEX TYPE LVC_T_ROW,
         LS_INDEX LIKE LINE OF LT_INDEX,
         LV_CUST  TYPE ZS4H084T04-CUST_ID,
         LS_MODIF TYPE ZS4H084T05.

  "선택한 ALV 행 정보 가져오기.
  GO_ALV_GRID->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX                 " Indexes of Selected Rows
  ).

  IF LT_INDEX IS INITIAL.
    MESSAGE '반납처리할 도서를 선택해 주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT LT_INDEX INTO LS_INDEX.
    READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_INDEX-INDEX.
    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

    IF GS_DISPLAY-RDATE IS INITIAL . "대여처리 되지 않은 도서
      MESSAGE '해당 도서는 대여처리 되지 않은 도서입니다.' TYPE 'S' DISPLAY LIKE'E'.
      RETURN.
    ENDIF.

    IF LV_CUST IS INITIAL.
      LV_CUST = GS_DISPLAY-CUST_ID.
    ELSEIF GS_DISPLAY-CUST_ID NE LV_CUST.
      MESSAGE '동일한 대여자의 도서만 처리 가능합니다.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

  LOOP AT LT_INDEX INTO LS_INDEX.
    READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX LS_INDEX-INDEX.

    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

* 오류 없을 시 반납처리 후 업데이트.
    UPDATE ZS4H084T05
 SET RTDATE = @SY-DATUM,
     AENAM = @SY-UNAME,
     AEDAT = @SY-DATUM,
     AEZET = @SY-UZEIT
 WHERE CUST_ID = @GS_DISPLAY-CUST_ID
  AND  ISBN = @GS_DISPLAY-ISBN(13)
  AND  SEQ  = @GS_DISPLAY-ISBN+14(2).
  ENDLOOP.

  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
    MESSAGE '반납에 실패하였습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  COMMIT WORK.
  PERFORM SELECT_DATA.
  MESSAGE '반납이 성공적으로 처리되었습니다.' TYPE 'S'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HANDLER
*&---------------------------------------------------------------------*
FORM SET_HANDLER .

  SET HANDLER LCL_EVENT_HANDLER=>ON_DOUBLE_CLICK FOR GO_ALV_GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_COLUMN
*&      --> E_ROW
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK  USING    P_COLUMN
                                P_ROW
                                PS_ROW_NO.

  READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX P_ROW.
  IF SY-SUBRC <> 0.
    RETURN.
  ENDIF.

  CHECK P_COLUMN = 'BNAME'.
  " 팝업 도서정보 채우기.
  S_BNAME = GS_DISPLAY-BNAME.
  S_AUTHOR = GS_DISPLAY-AUTHOR.
  S_PUBLISHER = GS_DISPLAY-PUBLISHER.
  MOVE-CORRESPONDING GS_DISPLAY TO GS_POPUP.

  PERFORM SELECT_POPUP_DATA.
  CALL SCREEN 0102 STARTING AT 30 5.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_POPUP_DATA
*&---------------------------------------------------------------------*
FORM SELECT_POPUP_DATA .

  SELECT A~CUST_ID, A~CUST_NAME, B~RDATE, B~RTDATE
    FROM ZS4H084T04 AS A
    JOIN ZS4H084T05 AS B
      ON A~CUST_ID = B~CUST_ID
    LEFT OUTER JOIN ZS4H084T02 AS C
    ON B~ISBN = C~ISBN
     WHERE C~BNAME = @S_BNAME
       AND C~AUTHOR = @S_AUTHOR
       AND C~PUBLISHER = @S_PUBLISHER
    ORDER BY RDATE DESCENDING
    INTO CORRESPONDING FIELDS OF TABLE @GT_POPUP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_FCAT2
*&---------------------------------------------------------------------*
FORM ALV_FCAT2 .

  CLEAR GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'CUST_ID'.
  GS_FCAT2-COLTEXT = '사용자 ID'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'CUST_NAME'.
  GS_FCAT2-COLTEXT = '사용자 명'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'RDATE'.
  GS_FCAT2-COLTEXT = '대여일'.
  APPEND GS_FCAT2 TO GT_FCAT2.

  CLEAR GS_FCAT2.
  GS_FCAT2-FIELDNAME = 'RTDATE'.
  GS_FCAT2-COLTEXT = '반납일'.
  APPEND GS_FCAT2 TO GT_FCAT2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALIDATE
*&---------------------------------------------------------------------*
FORM CHECK_VALIDATE .


*  SELECT-OPTIONS : SO_NAME   FOR GS_DISPLAY-CUST_NAME NO INTERVALS NO-EXTENSION,
*                   SO_ID     FOR ZS4H084T04-CUST_ID NO-EXTENSION.
*
*   PARAMETERS : P_BNAME LIKE GS_DISPLAY-BNAME,
*                P_PUB   LIKE GS_DISPLAY-PUBLISHER,
*                P_AUTH  LIKE GS_DISPLAY-AUTHOR.


ENDFORM.
