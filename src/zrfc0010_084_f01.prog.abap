*&---------------------------------------------------------------------*
*& Include          ZRFC0010_084_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  DATA LV_FLAG TYPE C.

  CASE 'X'.
    WHEN R1. " 미정송 건만 보기
      LV_FLAG = ''.
    WHEN R2. " 전송 완료 건만 보기
      LV_FLAG = 'S'.
  ENDCASE.

  SELECT A~RFQNO  ,  " RFQ Number
           RFQSQ  ,  " RFQ Line Number
         A~RFQDT  ,  " RFQ 생성일
           DLVDT  ,  " 배송 요청일
           MATNR  ,  " 제품 코드
           MENGE  ,  " 수량
           NETPR  ,  " 단가
           NETWR  ,  " 금액
           MEINS  ,  " 수량 단위
           WAERS  ,  " 금액 단위
           ZIFFLG ,  " 전송 FLAG
           ZIFDAT ,  " 전송 Date
           ZIFTIM    " 전송 TIME
    FROM ZMMT0510_084 AS A
    JOIN ZMMT0520_084 AS B
      ON A~RFQNO = B~RFQNO
    WHERE RFQDT IN @S_ERDAT
      AND A~RFQNO IN @S_RFQNO
      AND ZIFFLG = @LV_FLAG
    ORDER BY A~RFQNO, RFQSQ
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  CREATE OBJECT GO_DOCKING
    EXPORTING
      SIDE      = GO_DOCKING->DOCK_AT_LEFT     " Side to Which Control is Docked
      EXTENSION = 5000.               " Control Extension

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT = GO_DOCKING.                 " Parent Container


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
FORM SET_LAYOUT .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-NO_ROWINS = 'X'.
  GS_LAYOUT-NO_ROWMOVE = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT .


  GT_FCAT = VALUE #(
    (   FIELDNAME = 'CHECK'    COLTEXT = 'Check'  CHECKBOX = 'X'  EDIT = 'X'   )
    (   FIELDNAME = 'STATUS'   COLTEXT = 'Status'  ICON = 'X'   )
    (   FIELDNAME = 'RFQNO'    COLTEXT = 'RFQ Number'  )
    (   FIELDNAME = 'RFQSQ'    COLTEXT = 'RFQ Line Number'  )
    (   FIELDNAME = 'RFQDT'    COLTEXT = 'RFQ 생성일' )
    (   FIELDNAME = 'DLVDT'    REF_TABLE = 'ZMMT0510_084' COLTEXT = '배송 요청일' EDIT = 'X'  )
    (   FIELDNAME = 'MATNR'    REF_TABLE = 'ZMMT0520_084' COLTEXT = '제품 코드'   EDIT = 'X')
    (   FIELDNAME = 'MENGE'    REF_TABLE = 'ZMMT0520_084' COLTEXT = '수량'       EDIT = 'X'  QFIELDNAME = 'MEINS')
    (   FIELDNAME = 'NETPR'    REF_TABLE = 'ZMMT0520_084' COLTEXT = '단가'       EDIT = 'X'  CFIELDNAME = 'WAERS')
    (   FIELDNAME = 'NETWR'    REF_TABLE = 'ZMMT0520_084' COLTEXT = '금액'       EDIT = 'X'  CFIELDNAME = 'WAERS')
    (   FIELDNAME = 'MEINS'    REF_TABLE = 'ZMMT0520_084'  COLTEXT = '수량 단위'   EDIT = 'X' )
    (   FIELDNAME = 'WAERS'    REF_TABLE = 'ZMMT0520_084' REF_FIELD = 'WAERS' COLTEXT = '금액 단위'   EDIT = 'X' )
    (   FIELDNAME = 'ZIFFLG'    COLTEXT = '전송 Flag'  )
    (   FIELDNAME = 'ZIFDAT'    COLTEXT = '전송 Date'  )
    (   FIELDNAME = 'ZIFTIM'    COLTEXT = '전송 Time'  )
    ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_DATA                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog

  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_REFRESH
*&---------------------------------------------------------------------*
FORM ALV_REFRESH .

  GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_NEW_ROW
*&---------------------------------------------------------------------*
FORM ADD_NEW_ROW .

  DATA LS_NEW LIKE GS_DATA.
  CLEAR LS_NEW.
  LS_NEW-STATUS = ICON_CREATE.
  APPEND LS_NEW TO GT_DATA.

  CALL METHOD GO_ALV_GRID->CHECK_CHANGED_DATA.

  GO_ALV_GRID->REFRESH_TABLE_DISPLAY(
    EXPORTING
      IS_STABLE      = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' )                 " With Stable Rows/Columns

  ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELECT_ROW
*&---------------------------------------------------------------------*
FORM DELECT_ROW .

  DATA : LT_ROWS TYPE LVC_T_ROW,
         LS_ROW  TYPE LVC_S_ROW.

  CALL METHOD GO_ALV_GRID->CHECK_CHANGED_DATA. " CHECK된지 확인하기 위해 필드의 변화 확인.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DELETE>) WHERE CHECK = 'X' AND ZIFFLG IS INITIAL. " 체크 되고 전송되지 않은 건만 삭제 가능
    <FS_DELETE>-STATUS = ICON_DELETE.
  ENDLOOP.

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).
*    EXPORTING
*      IS_STABLE = VALUE LVC_S_STBL( ROW = 'X' COL = 'X' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHANGED
*&---------------------------------------------------------------------*
FORM DATA_CHANGED  USING    PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL.

  DATA P_VALUE TYPE LVC_VALUE.

  LOOP AT PR_DATA_CHANGED->MT_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<FS_GOOD>).

    " 변경된 값 읽기
    CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
      EXPORTING
        I_ROW_ID    = <FS_GOOD>-ROW_ID                 " Row ID
        I_FIELDNAME = <FS_GOOD>-FIELDNAME "P_FIELDNAME                 " Field Name
      IMPORTING
        E_VALUE     = P_VALUE.                 " Cell Content

    " 내부 테이블에서 해당 행 찾기
    READ TABLE GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>)
         INDEX <FS_GOOD>-ROW_ID.
    IF SY-SUBRC = 0 AND <FS_GOOD>-FIELDNAME <> 'CHECK'.

      " 변경된 필드에 값 반영
      ASSIGN COMPONENT <FS_GOOD>-FIELDNAME OF STRUCTURE <FS_DATA> TO FIELD-SYMBOL(<FS_FIELD>).
      IF SY-SUBRC = 0 .
        <FS_FIELD> = P_VALUE.
      ENDIF.

      " 금액 다시 계산
      <FS_DATA>-NETWR = <FS_DATA>-MENGE * <FS_DATA>-NETPR.

      " ALV 화면에도 금액값 반영 (이게 핵심)
      CALL METHOD PR_DATA_CHANGED->MODIFY_CELL
        EXPORTING
          I_ROW_ID    = <FS_GOOD>-ROW_ID
          I_FIELDNAME = 'NETWR'
          I_VALUE     = <FS_DATA>-NETWR.

      IF <FS_DATA>-RFQNO IS NOT INITIAL.
        <FS_DATA>-STATUS = ICON_CHANGE.
      ENDIF.
    ENDIF.

  ENDLOOP.


  GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).
ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .

  SET HANDLER LCL_EVENT_HANDLER=>ON_DATA_CHANGED FOR ALL INSTANCES.

  CALL METHOD GO_ALV_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.                 " Event ID


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_CHECKED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> P_
*&---------------------------------------------------------------------*
FORM DATA_CHECKED  USING   PS_DATA LIKE GS_DATA.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) WHERE RFQNO = PS_DATA-RFQNO.

    IF PS_DATA-CHECK = 'X'.
      <FS_DATA>-CHECK = 'X'.
    ELSE.
      <FS_DATA>-CHECK = ' '.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
FORM SAVE_DATA .

  DATA(LV_ANSWER) = ''.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '데이터 저장'
      TEXT_QUESTION         = '데이터를 저장하겠습니까? 체크하지 않은 새로운 데이터는 사라질 수 있습니다.'
      TEXT_BUTTON_1         = '확인'     " → 승인 처리로 연결
      TEXT_BUTTON_2         = '취소'    "  → 아무것도 하지 않음
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = ' '
    IMPORTING
      ANSWER                = LV_ANSWER.
  IF SY-SUBRC <> 0.
    RETURN.

  ELSEIF LV_ANSWER = '1'.
    PERFORM DATA_SAVE.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_SAVE
*&---------------------------------------------------------------------*
FORM DATA_SAVE .


  DATA: LT_CREATE LIKE GT_DATA,
        LT_CHANGE LIKE GT_DATA,
        LT_DELETE LIKE GT_DATA.

  CALL METHOD GO_ALV_GRID->CHECK_CHANGED_DATA.

  " 체크된 데이터 상태별로 분리
  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) WHERE CHECK = 'X' AND ZIFFLG IS INITIAL.
    CASE <FS_DATA>-STATUS.
      WHEN ICON_CREATE.  " 새로 생성된 행
        APPEND <FS_DATA> TO LT_CREATE.

      WHEN ICON_CHANGE.  " 기존 행 수정
        APPEND <FS_DATA> TO LT_CHANGE.

      WHEN ICON_DELETE.  " 기존 행 삭제
        APPEND <FS_DATA> TO LT_DELETE.

      WHEN OTHERS.
        MESSAGE '수정사항이 없습니다.'TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDCASE.
  ENDLOOP.

  IF SY-SUBRC <> 0.
    MESSAGE '선택한 데이터를 확인해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 상태별로 나눠서 한 번씩만 처리
  IF LT_CREATE IS NOT INITIAL.
    PERFORM CRETAE_DATA USING LT_CREATE.
  ENDIF.

  IF LT_CHANGE IS NOT INITIAL.
    PERFORM CHANGE_DATA USING LT_CHANGE.
  ENDIF.

  IF LT_DELETE IS NOT INITIAL.
    PERFORM DELETE_DATA USING LT_DELETE.
  ENDIF.

  PERFORM SELECT_DATA.
  PERFORM ALV_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CRETAE_DATA
*&---------------------------------------------------------------------*
FORM CRETAE_DATA  USING    PT_DATA LIKE GT_DATA.

  DATA : LV_RFQNO  TYPE C LENGTH 10,
         LV_NUM    TYPE C LENGTH 4,
         LV_ITEMNO TYPE N LENGTH 3,
         LS_HEAD   TYPE ZMMT0510_084,
         LS_ITEM   TYPE ZMMT0520_084,
         LT_ITEM   LIKE TABLE OF ZMMT0520_084.

* 1. 넘버레인지로 RFQ 번호 발급
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR = '01'                 " Number range number
      OBJECT      = 'ZRFQNO_084'                 " Name of number range object
    IMPORTING
      NUMBER      = LV_NUM.                " free number
  IF SY-SUBRC <> 0.
    MESSAGE 'RFQ 번호를 채번하는데 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  CONCATENATE SY-DATUM+2(6) LV_NUM INTO LV_RFQNO.

  LV_ITEMNO = 0.
  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>)..
    " 2. 필수 값 체크
    IF  <FS_DATA>-DLVDT IS INITIAL OR
                      <FS_DATA>-MATNR IS INITIAL OR
                      <FS_DATA>-MENGE IS INITIAL OR
                      <FS_DATA>-NETPR IS INITIAL OR
                      <FS_DATA>-NETWR IS INITIAL OR
                      <FS_DATA>-MEINS IS INITIAL OR
                      <FS_DATA>-WAERS IS INITIAL.
      MESSAGE '필수 입력값이 비어있습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    LV_ITEMNO = LV_ITEMNO + 10. " 아이템 번호 10 씩 증가

    <FS_DATA>-RFQNO = LV_RFQNO.
    <FS_DATA>-RFQSQ = LV_ITEMNO.
    <FS_DATA>-RFQDT = SY-DATUM.

    " 아이템 데이터 준비
    MOVE-CORRESPONDING <FS_DATA> TO LS_ITEM .
    APPEND LS_ITEM TO LT_ITEM.
  ENDLOOP.

  " 헤더 데이터 업데이트 헤더 정보 같으므로 첫번째 라인의 데이터 기준으로 헤더 생성
  READ TABLE PT_DATA ASSIGNING <FS_DATA> INDEX 1.
  IF SY-SUBRC = 0.
    MOVE-CORRESPONDING <FS_DATA> TO LS_HEAD.
    " ALV 데이터에 없는 값 추가
    LS_HEAD-LIFNR = 'S4H'.
    LS_HEAD-CHDAT = SY-DATUM.
  ENDIF.

  IF LS_HEAD IS NOT INITIAL AND LT_ITEM IS NOT INITIAL.
    INSERT ZMMT0510_084 FROM LS_HEAD.
    IF SY-SUBRC = 0.
      INSERT ZMMT0520_084 FROM TABLE LT_ITEM.
      IF SY-SUBRC = 0.
        MESSAGE '데이터 생성에 성공하였습니다.' TYPE 'S'.
      ELSE.
        MESSAGE '아이템 데이터 저장 중 오류가 발생했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
        ROLLBACK WORK.
      ENDIF.
    ELSE.
      MESSAGE '헤더 데이터 저장 중 오류가 발생했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_DATA
*&---------------------------------------------------------------------*
FORM CHANGE_DATA  USING PT_DATA LIKE GT_DATA.

  DATA : LS_ITEM TYPE ZMMT0520_084.

  LOOP AT PT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>).

    " 헤더 값 (배송요청일) 업데이트
    UPDATE ZMMT0510_084 SET DLVDT = <FS_DATA>-DLVDT WHERE RFQNO = <FS_DATA>-RFQNO.

    IF SY-SUBRC = 0.
      MOVE-CORRESPONDING <FS_DATA> TO LS_ITEM.
      MODIFY ZMMT0520_084 FROM LS_ITEM  .
      MESSAGE '데이터가 수정되었습니다.' TYPE 'S'.
      COMMIT WORK.
    ELSE.
      MESSAGE '데이터 수정에 실패하였습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_DATA
*&---------------------------------------------------------------------*
FORM SEND_DATA .

  DATA : LV_RFQNO TYPE ZMMT0510_084-RFQNO,
         LV_FLAG  TYPE CHAR1,
         LV_MSG   TYPE CHAR40.

  DATA : BEGIN OF LS_HEAD,
           RFQNO TYPE ZMMT0510_084-RFQNO,
           DLVDT TYPE ZMMT0510_084-DLVDT,
           RFQDT TYPE ZMMT0510_084-RFQDT,
         END OF LS_HEAD,

         BEGIN OF LS_ITEM,
           RFQNO TYPE ZMMT0510_084-RFQNO,
           RFQSQ TYPE ZMMT0520_084-RFQSQ,
           MATNR TYPE ZMMT0520_084-MATNR,
           MENGE TYPE ZMMT0520_084-MENGE,
           NETPR TYPE ZMMT0520_084-NETPR,
           NETWR TYPE ZMMT0520_084-NETWR,
           MEINS TYPE ZMMT0520_084-MEINS,
           WAERS TYPE ZMMT0520_084-WAERS,
         END OF LS_ITEM ,
         LT_ITEM LIKE TABLE OF LS_ITEM.

  CLEAR : LS_HEAD, LS_ITEM, LT_ITEM.
  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) WHERE CHECK = 'X' .
    IF <FS_DATA> IS INITIAL.
      MESSAGE '선택한 행이 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    " 저장된 데이터인지 확인
    IF <FS_DATA>-STATUS IS NOT INITIAL.
      MESSAGE '저장되지 않은 건이 포함되어 있습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    " 같은 RFQNO 값을 갖는지 확인용
    IF LV_RFQNO IS INITIAL.
      LV_RFQNO = <FS_DATA>-RFQNO.
    ELSEIF <FS_DATA>-RFQNO <> LV_RFQNO.
      MESSAGE '선택한 건들의 RFQ 번호가 동일해야 합니다.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING <FS_DATA> TO LS_HEAD.
    MOVE-CORRESPONDING <FS_DATA> TO LS_ITEM.
    APPEND LS_ITEM TO LT_ITEM.

  ENDLOOP.

  CALL FUNCTION 'ZF_RFC_0010_084'
    DESTINATION 'ecc'
    EXPORTING
      IS_HEAD = LS_HEAD
      IT_ITEM = LT_ITEM
    IMPORTING
      EV_FLAG = LV_FLAG
      EV_MSG  = LV_MSG.

  CASE LV_FLAG.
    WHEN 'S'.
      MESSAGE LV_MSG TYPE 'S'.

      UPDATE ZMMT0510_084 SET ZIFFLG = 'S' ZIFDAT = SY-DATUM ZIFTIM = SY-UZEIT WHERE RFQNO = LV_RFQNO .
      " ALV에 성공 플래그 세팅
      LOOP AT GT_DATA ASSIGNING <FS_DATA> WHERE RFQNO = LV_RFQNO.
        <FS_DATA>-ZIFFLG = 'S'.
        <FS_DATA>-ZIFDAT = SY-DATUM.
        <FS_DATA>-ZIFTIM = SY-UZEIT.
        PERFORM LOCK_FIELD USING <FS_DATA>.
      ENDLOOP.
      IF SY-SUBRC = 0.
        COMMIT WORK.
        " MESSAGE '데이터베이스에 성공적으로 반영되었습니다.' TYPE 'S'.
      ELSE.
        ROLLBACK WORK.
        " MESSAGE '데이터베이스 업데이트에 실패했습니다.' TYPE 'E'.
      ENDIF.


    WHEN 'F'.
      MESSAGE LV_MSG TYPE 'S' DISPLAY LIKE 'E'.
      UPDATE ZMMT0510_084 SET ZIFFLG = 'F' ZIFDAT = SY-DATUM ZIFTIM = SY-UZEIT WHERE RFQNO = LV_RFQNO .
      IF SY-SUBRC = 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
  ENDCASE.

  PERFORM ALV_REFRESH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_DATA
*&---------------------------------------------------------------------*
FORM DELETE_DATA  USING    PT_DELETE LIKE GT_DATA.

  LOOP AT PT_DELETE ASSIGNING FIELD-SYMBOL(<FS_DATA>) WHERE ZIFFLG IS INITIAL.
    DELETE FROM ZMMT0510_084
            WHERE RFQNO = <FS_DATA>-RFQNO.

    DELETE FROM ZMMT0520_084
            WHERE RFQNO = <FS_DATA>-RFQNO
              AND RFQSQ = <FS_DATA>-RFQSQ.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOCK_FIELD
*&---------------------------------------------------------------------*
FORM LOCK_FIELD  USING    PS_DATA LIKE GS_DATA.

  DATA LS_STYLE TYPE LVC_S_STYL.
  CLEAR LS_STYLE.

  LS_STYLE-FIELDNAME = 'CHECK'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.  " CELLTAB 은 테이블 타입임.

  LS_STYLE-FIELDNAME = 'DLVDT'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.  " CELLTAB 은 테이블 타입임.

  LS_STYLE-FIELDNAME = 'MATNR'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.

  LS_STYLE-FIELDNAME = 'MENGE'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.

  LS_STYLE-FIELDNAME = 'NETPR'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.

  LS_STYLE-FIELDNAME = 'NETPR'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.

  LS_STYLE-FIELDNAME = 'NETWR'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.

  LS_STYLE-FIELDNAME = 'MEINS'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.

  LS_STYLE-FIELDNAME = 'WAERS'.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE PS_DATA-CELLTAB.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATA_MODIFIED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_MODIFIED
*&      --> ET_GOOD_CELLS
*&---------------------------------------------------------------------*
FORM DATA_MODIFIED  USING    PV_MODIFIED
                             PT_GOOD_CELLS  TYPE LVC_T_MODI.

  LOOP AT PT_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<FS_GOOD>).

    READ TABLE GT_DATA ASSIGNING FIELD-SYMBOL(<FS_DATA>) INDEX <FS_GOOD>-ROW_ID.

    IF SY-SUBRC = 0 AND <FS_GOOD>-FIELDNAME <> 'CHECK'.
      CASE <FS_GOOD>-FIELDNAME.
        WHEN 'NETPR' OR 'MENGE'.
          <FS_DATA>-NETWR = <FS_DATA>-NETPR * <FS_DATA>-MENGE.

      ENDCASE.
      " 기존의 값을 수정할 때 수정 아이콘으로 변경해주기.
      IF <FS_DATA>-RFQNO IS NOT INITIAL.
        <FS_DATA>-STATUS = ICON_CHANGE.
      ENDIF.
    ELSEIF <FS_GOOD>-FIELDNAME = 'CHECK'.
      PERFORM DATA_CHECKED USING <FS_DATA>.
    ENDIF.


  ENDLOOP.
  PERFORM ALV_REFRESH.

ENDFORM.
