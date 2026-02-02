*&---------------------------------------------------------------------*
*& Include          ZSH08401_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  SELECT A~CUST_ID,
         A~CUST_NAME,
         A~EMAIL,
         BIRTH_DATE,
         COUNT( CASE WHEN B~RTDATE IS INITIAL THEN B~ISBN END ) AS CNT_RENTAL, " 반납되지 않은(대여중인) 도서 수
         COUNT( B~ISBN ) AS CNT_TOTAL                                          " 전체 대여 도서 수
    FROM ZS4H084T04 AS A
    LEFT JOIN ZS4H084T05 AS B  " 대여 이력이 없는 사용자도 포함
      ON A~CUST_ID = B~CUST_ID
         WHERE A~CUST_ID IN @SO_ID
           AND A~CUST_NAME IN @SO_NAME
    GROUP BY A~CUST_ID, A~CUST_NAME, A~EMAIL, A~BIRTH_DATE
    ORDER BY A~CUST_ID
    INTO CORRESPONDING FIELDS OF TABLE @GT_CUST.

  IF SY-SUBRC <> 0.
    MESSAGE '데이터가 존재하지 않습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .


  CREATE OBJECT GO_CONTAINER
    EXPORTING
      REPID     = SY-REPID
      DYNNR     = SY-DYNNR
      SIDE      = GO_CONTAINER->DOCK_AT_LEFT
      EXTENSION = 5000.

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT = GO_CONTAINER.                 " Parent Container

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_FCAT
*&---------------------------------------------------------------------*
FORM ALV_FCAT .

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'CUST_ID'.
  GS_FCAT-COLTEXT  = '사용자 ID'.
  GS_FCAT-KEY = 'X'.
  GS_FCAT-CONVEXIT = 'ALPHA'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'CUST_NAME'.
  GS_FCAT-COLTEXT   = '사용자 명'.
  GS_FCAT-KEY = 'X'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'BIRTH_DATE'.
  GS_FCAT-COLTEXT = '생년월일'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'EMAIL'.
  GS_FCAT-COLTEXT   = '전자메일'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'CNT_RENTAL'.
  GS_FCAT-COLTEXT   = '대여중인 도서 수'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-EMPHASIZE = 'C300'.
  APPEND GS_FCAT TO GT_FCAT.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = 'CNT_TOTAL'.
  GS_FCAT-COLTEXT   = '전체 대여도서 수'.
  GS_FCAT-JUST = 'C'.
  GS_FCAT-EMPHASIZE = 'C300'.
  APPEND GS_FCAT TO GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY(
  EXPORTING
*    IS_VARIANT                    =                  " Layout
*    I_SAVE                        =                  " Save Layout
*    I_DEFAULT                     = 'X'              " Default Display Variant
      IS_LAYOUT                    = GS_LAYOUT                 " Layout
*    IS_PRINT                      =                  " Print Control
*    IT_SPECIAL_GROUPS             =                  " Field Groups
*    IT_TOOLBAR_EXCLUDING          =                  " Excluded Toolbar Standard Functions
*    IT_HYPERLINK                  =                  " Hyperlinks
*    IT_ALV_GRAPHICS               =                  " Table of Structure DTC_S_TC
*    IT_EXCEPT_QINFO               =                  " Table for Exception Quickinfo
*    IR_SALV_ADAPTER               =                  " Interface ALV Adapter
    CHANGING
      IT_OUTTAB                     = GT_CUST                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
  ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_LAYOUT
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-SEL_MODE = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .

  GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FILL_POPUP_DATA
*&---------------------------------------------------------------------*
FORM FILL_POPUP_DATA .

* 선택한 ALV라인에 대한 고객 정보 가져오기.

  DATA : LT_INDEX TYPE LVC_T_ROW, "ALV 선택라인 저장 인터널테이블
         LS_INDEX LIKE LINE OF LT_INDEX. "ALV 선택라인 저장 스트럭쳐


  GO_ALV_GRID->GET_SELECTED_ROWS(
           IMPORTING
             ET_INDEX_ROWS = LT_INDEX                 " Indexes of Selected Rows
                                           ).

  IF LT_INDEX IS INITIAL.
    MESSAGE '정보를 변경할 사용자를 선택해주세요.' TYPE 'E'.

  ELSEIF LINES( LT_INDEX ) > 1.
    MESSAGE '한명의 사용자를 선택해주세요.' TYPE 'E'.
  ENDIF.

  LOOP AT LT_INDEX INTO LS_INDEX.
    READ TABLE GT_CUST INTO GS_CUST INDEX LS_INDEX-INDEX.
    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING GS_CUST TO GS_POPUP.
      S_ID = GS_POPUP-CUST_ID.
      S_NAME = GS_POPUP-CUST_NAME.
      S_EMAIL = GS_POPUP-EMAIL.
      S_BIRTH = GS_POPUP-BIRTH_DATE.

    ENDIF.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_FIELD
*&---------------------------------------------------------------------*
FORM CLEAR_FIELD .
  CLEAR : S_ID, S_NAME, S_BIRTH, S_EMAIL.
ENDFORM.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE MODIFY_SCREEN OUTPUT.

  " 수정모드일 때 스크린
  IF R3 EQ 'X'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'S_NAME'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  " 생성모드일 때 스크린
  IF R2 EQ 'X' AND GV_STATUS EQ 'S'.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'USR'. " 사용자 id 와 사용자 이름 필드 그룹
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Form F4_ID
*&---------------------------------------------------------------------*
FORM F4_ID USING PV_FILTER.

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
      WINDOW_TITLE = '사용자 코드 (ID)'                 " Title for the hit list
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
*& Form check_validate
*&---------------------------------------------------------------------*
FORM CHECK_VALIDATE .

  " 입력된 ID가 실제 테이블에 존재하는지 확인
  LOOP AT SO_ID INTO DATA(LS_ID).
    IF LS_ID-LOW IS NOT INITIAL.
      IF  STRLEN( LS_ID-LOW ) <> 10 OR LS_ID-LOW NA '0123456789'.
        MESSAGE '고객 ID는 10자리 숫자로 입력해야 합니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
    SELECT SINGLE CUST_ID INTO @DATA(LV_ID)
      FROM ZS4H084T04
      WHERE CUST_ID = @LS_ID-LOW.
    IF SY-SUBRC <> 0.
      MESSAGE |입력한 고객 ID { LS_ID-LOW } 는 존재하지 않습니다.| TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form STATUS_0100
*&---------------------------------------------------------------------*
FORM STATUS_0100 .

  DATA LT_EXCLUDE TYPE TABLE OF SY-UCOMM.

  LT_EXCLUDE = VALUE #( ( 'MODIF' ) ( 'ADD' ) ).

  IF R2 = 'X'.        " 라디오버튼 생성일 때
    SET PF-STATUS 'S0100'
    EXCLUDING 'MODIF'.
    SET TITLEBAR 'T0100' WITH '사용자 생성'.

  ELSEIF R3 = 'X'.    " 라디오 버튼 변경일 때
    SET PF-STATUS 'S0100'
    EXCLUDING 'ADD'.
    SET TITLEBAR 'T0100' WITH '사용자 정보 변경'.

  ELSE.             " 라디오 버튼 조회일 때
    SET PF-STATUS 'S0100' EXCLUDING LT_EXCLUDE.
    SET TITLEBAR 'T0100' WITH '도서 대여 현황'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM ALV_DOUBLE_CLICK  USING    P_COLUMN
                                P_ROW.
  CLEAR : GS_CUST, GV_POP.
  REFRESH GT_POPUP2.
  " 대여중 필드 더블클릭하면 해당 사용자 정보와 대여도서 정보 팝업 띄우기.
  READ TABLE GT_CUST INTO GS_CUST INDEX P_ROW.
  S_ID = GS_CUST-CUST_ID.
  S_NAME = GS_CUST-CUST_NAME.
  S_BIRTH = GS_CUST-BIRTH_DATE.
  S_EMAIL = GS_CUST-EMAIL.

  CASE P_COLUMN.
    WHEN 'CNT_RENTAL'.
      SELECT A~ISBN && '-' && A~SEQ AS ISBN,
             B~BNAME,
             A~RDATE
        FROM ZS4H084T05 AS A JOIN ZS4H084T02 AS B
        ON A~ISBN = B~ISBN
        WHERE CUST_ID = @GS_CUST-CUST_ID
          AND RTDATE IS INITIAL
        ORDER BY RDATE DESCENDING
        INTO CORRESPONDING FIELDS OF TABLE @GT_POPUP2.


      IF SY-SUBRC = 0.
        GV_POP = 'R'.
        CALL SCREEN 0102 STARTING AT 30 5.
      ELSE.
        MESSAGE '해당 고객은 대여중인 도서가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

    WHEN 'CNT_TOTAL'.
      SELECT A~ISBN && '-' && A~SEQ AS ISBN,
             B~BNAME,
             A~RDATE,
             A~RTDATE
        FROM ZS4H084T05 AS A JOIN ZS4H084T02 AS B
        ON A~ISBN = B~ISBN
        WHERE CUST_ID = @GS_CUST-CUST_ID
        ORDER BY RDATE DESCENDING
        INTO CORRESPONDING FIELDS OF TABLE @GT_POPUP2.

      IF SY-SUBRC = 0.
        GV_POP = 'T'.
        CALL SCREEN 0102 STARTING AT 30 5.
      ELSE.
        MESSAGE '해당 고객은 대여 이력이 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_EVENT
*&---------------------------------------------------------------------*
FORM ALV_EVENT .

  SET HANDLER LCL_EVENT_HANDLER=>ON_DOUBLE_CLICK FOR GO_ALV_GRID.

ENDFORM.
