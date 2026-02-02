CLASS ZALV_HANDLER_084 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF TYS_SELSCR_FIELD,
        FTYPE   TYPE SCREEN-GROUP3,
        FSEQ    TYPE SCREEN-GROUP4,
        FNAME   TYPE SCREEN-NAME,
        FNAME2  TYPE SCREEN-NAME,  " 동일라인에 두번째 field
        FNAME3  TYPE SCREEN-NAME, " 동일라인에 세번째 Field
        TITLE   TYPE TEXT72,
        TEXT    TYPE TEXT72,
        POS     TYPE I,
        POS_S   TYPE I,
        RBGNAME TYPE CHAR4,
        DTYPE   TYPE CHAR1,  " Field 의 data type
      END OF TYS_SELSCR_FIELD .
    TYPES:
      BEGIN OF TYS_SELSCR_RBG,
        RBGNAME TYPE CHAR4,
        FNAME   TYPE SCREEN-NAME,
        TEXT    TYPE TEXT72,
      END OF TYS_SELSCR_RBG .
    TYPES:
      TYT_SELSCR_RBG TYPE TABLE OF TYS_SELSCR_RBG .
    TYPES:
      TYT_SELSCR_FIELD TYPE TABLE OF TYS_SELSCR_FIELD .
    TYPES:
      " 표준 Structure인 SCREEN을 INCLUDE하여 정의
      BEGIN OF TYS_SCREEN_INFO,
        INCLUDE TYPE SCREEN.
    TYPES:
      DTYPE TYPE CHAR1,
      END OF TYS_SCREEN_INFO.

    TYPES:
      " ZPPS9040 Structure를 대체하는 로컬 타입
      BEGIN OF TYS_SCREEN_LINE,
        LINE   TYPE I,
        FTYPE  TYPE CHAR3,
        GROUP4 TYPE CHAR3,
        " SCREEN 필드는 여러개의 Screen 정보를 담는 테이블 형태이므로
        " 위에서 정의한 tys_screen_info를 라인으로 갖는 테이블 타입으로 선언합니다.
        SCREEN TYPE STANDARD TABLE OF TYS_SCREEN_INFO WITH EMPTY KEY.
    TYPES:
      END OF TYS_SCREEN_LINE.


    DATA GV_ALV_NAME TYPE STRING .
    DATA O_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER .
    DATA O_CONTAINER_O TYPE REF TO CL_GUI_CONTAINER .
    DATA O_DOCKING_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER .
    DATA O_ALV TYPE REF TO ZCL_GUI_ALV_GRID .
    DATA T_FCAT TYPE LVC_T_FCAT .
    DATA S_LAYO TYPE LVC_S_LAYO .
    DATA T_EXTOOLBAR TYPE UI_FUNCTIONS .
    DATA T_F4 TYPE LVC_T_F4 .
    DATA GV_SELSCR_MAX_LEN TYPE I .
    DATA GV_REPID TYPE SYREPID .
    DATA GT_SELSCR_FIELD TYPE TYT_SELSCR_FIELD .

*--------------------------------------------------------------------*
* METHOD 정의
*--------------------------------------------------------------------*
    METHODS ALV_DATA_CHANGED
      FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
      IMPORTING
        !ER_DATA_CHANGED
        !E_ONF4
        !E_ONF4_BEFORE
        !E_ONF4_AFTER
        !E_UCOMM .
    METHODS ALV_DATA_CHANGED_FINISHED
      FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
      IMPORTING
        !E_MODIFIED
        !ET_GOOD_CELLS .
    METHODS ALV_DOUBLE_CLICK
      FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
      IMPORTING
        !E_ROW
        !E_COLUMN
        !ES_ROW_NO .
    METHODS ALV_HOTSPOT_CLICK
      FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING
        !E_ROW_ID
        !E_COLUMN_ID
        !ES_ROW_NO .
    METHODS ALV_HANDLE_TOOLBAR
      FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
      IMPORTING
        !E_OBJECT
        !E_INTERACTIVE .
    METHODS ALV_ON_F4
      FOR EVENT ONF4 OF CL_GUI_ALV_GRID
      IMPORTING
        !E_FIELDNAME
        !E_FIELDVALUE
        !ES_ROW_NO
        !ER_EVENT_DATA
        !ET_BAD_CELLS
        !E_DISPLAY .
    METHODS ALV_TOP_OF_PAGE
      FOR EVENT TOP_OF_PAGE OF CL_GUI_ALV_GRID
      IMPORTING
        !E_DYNDOC_ID
        !TABLE_INDEX .
    METHODS ALV_USER_COMMAND
      FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
      IMPORTING
        !SENDER
        !E_UCOMM .
    METHODS M_10_CREATE_OBJECT .
    METHODS M_30_ADD_F4_FLD
      IMPORTING
        !I_FIELDNAME TYPE FIELDNAME .
    METHODS M_30_EX_TOOLBAR
      IMPORTING
        !IV_REFRESH   TYPE CHAR01 OPTIONAL
        !IV_CUT       TYPE CHAR01 OPTIONAL
        !IV_APPEND    TYPE CHAR01 OPTIONAL
        !IV_INSERT    TYPE CHAR01 OPTIONAL
        !IV_DELETE    TYPE CHAR01 OPTIONAL
        !IV_FILTER    TYPE CHAR01 OPTIONAL
        !IV_SORT_ASC  TYPE CHAR01 OPTIONAL
        !IV_SORT_DSC  TYPE CHAR01 OPTIONAL
        !IV_SUM       TYPE CHAR01 OPTIONAL
        !IV_SUBTOT    TYPE CHAR01 OPTIONAL
        !IV_PRINT     TYPE CHAR01 OPTIONAL
        !IV_EXPORT    TYPE CHAR01 OPTIONAL
        !IV_VARIANT   TYPE CHAR01 OPTIONAL
        !IV_PASTE     TYPE CHAR01 OPTIONAL
        !IV_PASTE_NEW TYPE CHAR01 OPTIONAL
        !IV_COPY_ROW  TYPE CHAR01 OPTIONAL
        !IV_VIEW      TYPE CHAR01 OPTIONAL
        !IV_CHECK     TYPE CHAR01 OPTIONAL
        !IV_DETAIL    TYPE CHAR01 OPTIONAL
        !IV_COPY      TYPE CHAR01 OPTIONAL
        !IV_INFO      TYPE CHAR01 OPTIONAL
        !IV_UNDO      TYPE CHAR01 OPTIONAL
        !IV_FIND      TYPE CHAR01 OPTIONAL
        !IV_FIND_MORE TYPE CHAR01 OPTIONAL .
    METHODS M_30_SET_HANDLER
      IMPORTING
        !DOUBLE_CLICK          TYPE CHAR01 OPTIONAL
        !DATA_CHANGED          TYPE CHAR01 OPTIONAL
        !TOP_OF_PAGE           TYPE CHAR01 OPTIONAL
        !HOTSPOT_CLICK         TYPE CHAR01 OPTIONAL
        !DATA_CHANGED_FINISHED TYPE CHAR01 OPTIONAL
        !F4                    TYPE CHAR01 OPTIONAL
        !TOOLBAR               TYPE CHAR01 OPTIONAL
        !USER_COMMAND          TYPE CHAR01 OPTIONAL .
    METHODS M_30_SET_LAYOUT
      IMPORTING
        !I_FIELD TYPE STRING OPTIONAL
        !I_VALUE TYPE CLIKE OPTIONAL .
    METHODS M_80_DISPLAY_ALV
      CHANGING
        !T_DATA TYPE STANDARD TABLE .
    METHODS M_90_REFRESH_ALV .
    METHODS CONSTUCTOR
      IMPORTING
        VALUE(ALV_NAME) TYPE STRING OPTIONAL .
    METHODS SET_DROP_DOWN_TABLE
      IMPORTING
        !IT_DROP_DOWN TYPE LVC_T_DROP .
    METHODS CHECK_CHANGED_DATA
      EXPORTING
        !E_VALID TYPE CHAR01 .
    METHODS CALL_EVENT
      IMPORTING
        !IO_GRID  TYPE REF TO CL_GUI_ALV_GRID OPTIONAL
        !IO_DOCU  TYPE REF TO CL_DD_DOCUMENT
        !IV_EVENT TYPE CHAR30 .
    METHODS SET_HEADER_SHOW
      IMPORTING
        !IV_DYNNR          TYPE ANY
        !IV_SHOW_BACKGRAND TYPE FLAG DEFAULT 'X'
        !IV_SHOW_DEFAULT   TYPE FLAG DEFAULT 'X'
      CHANGING
        !CO_DOCU           TYPE REF TO CL_DD_DOCUMENT
        !CO_HEAD           TYPE REF TO CL_GUI_CONTAINER
        !CO_HTML           TYPE REF TO CL_GUI_HTML_VIEWER .
    METHODS SET_HEADER_SHOW_DEFAULT
      CHANGING
        !CO_TAREA TYPE REF TO CL_DD_TABLE_AREA .
  PROTECTED SECTION.
private section.

  methods SET_HEADER_TEXT_P
    importing
      !IV_TITLE type ANY
      !IV_VALUE type ANY
      !IV_VALUE2 type ANY default SPACE
      !IV_VALUE3 type ANY default SPACE
      !IV_VTEXT type ANY default SPACE
    changing
      !CO_TAREA type ref to CL_DD_TABLE_AREA .
  methods SET_HEADER_TEXT_S
    importing
      !IV_TITLE type ANY
      !IT_SELTAB type STANDARD TABLE
      !IV_SELTAB_TYPE type ANY
      !IV_REMARK type ANY optional
    changing
      !CO_TAREA type ref to CL_DD_TABLE_AREA .
  methods EDIT_HEADER_S
    importing
      !IT_SEL type STANDARD TABLE
      !IV_OPT type ANY
    returning
      value(RV_TXT) type SDYDO_TEXT_ELEMENT .
  methods EDIT_HEADER_P
    importing
      !IV_VALUE type ANY
      !IV_DTYPE type ANY
    returning
      value(RV_VALUE) type STRING .
  methods SET_HEADER_INIT
    importing
      !IO_DOCU type ref to CL_DD_DOCUMENT
      !IV_NO_OF_COLUMNS type I default 3
      !IV_BORDER type ANY default '0'
      !IV_WIDTH_TAB type ANY default '70%'
      !IV_WIDTH_COL1 type ANY default '10%'
      !IV_WIDTH_COL2 type ANY default '35%'
      !IV_WIDTH_COL3 type ANY default '55%'
    changing
      !CO_TAREA type ref to CL_DD_TABLE_AREA .
*    " EVENT를 불러오기 위해 FORM 문 확인하는 메소드
*    METHODS:
*      CHECK_FORM_EXISTS
*        IMPORTING
*          IV_FORM_NAME TYPE STRING
*        EXPORTING
*          EV_EXISTS    TYPE ABAP_BOOL.
ENDCLASS.



CLASS ZALV_HANDLER_084 IMPLEMENTATION.


  METHOD ALV_DATA_CHANGED.

    TRY .

        PERFORM HANDLE_DATA_CHANGED IN PROGRAM (SY-CPROG)
            USING GV_ALV_NAME
                  ER_DATA_CHANGED
*                  e_onf4
*                  e_onf4_before
*                  e_onf4_after
                  E_UCOMM .
        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY .

  ENDMETHOD.


  METHOD ALV_DATA_CHANGED_FINISHED.

    TRY .

        PERFORM HANDLE_DATA_CHANGED_FINISHED IN PROGRAM (SY-CPROG)
            USING   GV_ALV_NAME    E_MODIFIED    ET_GOOD_CELLS  .
      CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.
    ENDTRY .

  ENDMETHOD.


  METHOD ALV_DOUBLE_CLICK.

      TRY.
          " FORM이 존재하지 않으면 cx_sy_dyn_call_illegal_form 예외가 발생합니다.
          PERFORM HANDLE_DOUBLE_CLICK IN PROGRAM (SY-CPROG)
            USING GV_ALV_NAME E_ROW E_COLUMN ES_ROW_NO.

          " CATCH 블록에서 발생할 수 있는 예외를 잡아냅니다.
        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.


      ENDTRY.


  ENDMETHOD.


  METHOD ALV_HANDLE_TOOLBAR.

    TRY .

        PERFORM HANDLE_TOOLBAR IN PROGRAM (SY-CPROG)
            USING   GV_ALV_NAME    E_OBJECT   E_INTERACTIVE  .
        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.
    ENDTRY .


  ENDMETHOD.


  METHOD ALV_HOTSPOT_CLICK.

    TRY.

        " FORM이 존재하지 않으면 cx_sy_dyn_call_illegal_form 예외가 발생합니다.
        PERFORM HANDLE_HOTSPOT_CLICK IN PROGRAM (SY-CPROG)
          USING GV_ALV_NAME E_ROW_ID E_COLUMN_ID ES_ROW_NO.

        " CATCH 블록에서 발생할 수 있는 예외를 잡아냅니다.
      CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.

    ENDTRY.


  ENDMETHOD.


  METHOD ALV_ON_F4.

    TRY .

        PERFORM HANDLE_F4 IN PROGRAM (SY-CPROG)
            USING GV_ALV_NAME
                  E_FIELDNAME
                  E_FIELDVALUE
                  ES_ROW_NO
                  ER_EVENT_DATA
                  ET_BAD_CELLS
                  E_DISPLAY .
        CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.
    ENDTRY .

  ENDMETHOD.


  METHOD ALV_TOP_OF_PAGE.

    TRY .

        PERFORM HANDLE_TOP_OF_PAGE IN PROGRAM (SY-CPROG)
            USING   GV_ALV_NAME    E_DYNDOC_ID    TABLE_INDEX .
      CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.
    ENDTRY .

  ENDMETHOD.


  METHOD ALV_USER_COMMAND.

    TRY .

        PERFORM HANDLE_USER_COMMAND IN PROGRAM (SY-CPROG)
            USING GV_ALV_NAME
                  E_UCOMM .
      CATCH CX_SY_DYN_CALL_ILLEGAL_FORM.
    ENDTRY .

  ENDMETHOD.


  METHOD CALL_EVENT.

    CALL METHOD IO_DOCU->INITIALIZE_DOCUMENT
      EXPORTING
        BACKGROUND_COLOR = CL_DD_AREA=>COL_TEXTAREA.


    CALL METHOD O_ALV->LIST_PROCESSING_EVENTS
      EXPORTING
        I_EVENT_NAME = IV_EVENT
        I_DYNDOC_ID  = IO_DOCU.

  ENDMETHOD.


  METHOD CHECK_CHANGED_DATA.

    CALL METHOD O_ALV->CHECK_CHANGED_DATA
      IMPORTING
        E_VALID = E_VALID.  " Entries are Consistent

  ENDMETHOD.


  METHOD CONSTUCTOR.

    ME->GV_ALV_NAME = ALV_NAME .

  ENDMETHOD.


  METHOD edit_header_p.

    DATA: lv_txt TYPE char100.

    CASE iv_dtype.
      WHEN 'N'. " Number.
        WRITE: iv_value TO lv_txt LEFT-JUSTIFIED NO-ZERO.

      WHEN 'D'. " 일자.
        WRITE: iv_value TO lv_txt LEFT-JUSTIFIED USING EDIT MASK '____.__.__'.
*        lv_txt = go_comfunc->ce_date_o( iv_value ).

      WHEN 'T'. " 시간.
        WRITE: iv_value TO lv_txt LEFT-JUSTIFIED USING EDIT MASK '__:__:__'.

      WHEN 'M'. " 년월
        WRITE: iv_value TO lv_txt LEFT-JUSTIFIED USING EDIT MASK '____.__'.

      WHEN OTHERS.
        lv_txt = iv_value.

    ENDCASE.

    rv_value = lv_txt.

  ENDMETHOD.


  METHOD edit_header_s.

    CONSTANTS:
      lc_text_parm1 TYPE txt70 VALUE '&1',
      lc_text_parm2 TYPE txt70 VALUE '&1 ~ &2'.

    DATA: lv_txt      TYPE string,
          lv_comma(2) TYPE c,
          lv_txt101   TYPE char100,
          lv_txt102   TYPE char100.

    FIELD-SYMBOLS:
      <lv_sign>   TYPE any,
      <lv_option> TYPE any,
      <lv_low>    TYPE any,
      <lv_high>   TYPE any,
      <ls_sel>    TYPE any.

    IF it_sel IS INITIAL.
      rv_txt = '*'.
      EXIT.
    ENDIF.

    CLEAR: rv_txt.

    LOOP AT it_sel ASSIGNING <ls_sel>.

      ASSIGN ('<LS_SEL>-SIGN') TO <lv_sign>.
      CHECK <lv_sign> IS ASSIGNED.
      ASSIGN ('<LS_SEL>-OPTION') TO <lv_option>.
      CHECK <lv_option> IS ASSIGNED.
      ASSIGN ('<LS_SEL>-LOW') TO <lv_low>.
      CHECK <lv_low> IS ASSIGNED.
      ASSIGN ('<LS_SEL>-HIGH') TO <lv_high>.
      CHECK <lv_high> IS ASSIGNED.

      lv_txt101 = me->edit_header_p( iv_value = <lv_low> iv_dtype = iv_opt ).
      IF <lv_high> IS NOT INITIAL.
        lv_txt102 = me->edit_header_p( iv_value = <lv_high> iv_dtype = iv_opt ).
      ENDIF.

      IF <lv_sign> = 'E' OR <lv_option> = 'NE'.
        CONCATENATE '(' lv_txt101 ')' INTO lv_txt101.
      ENDIF.

      IF lv_txt101 IS NOT INITIAL AND lv_txt102 IS INITIAL.
        lv_txt = lc_text_parm1.
      ELSE.
        lv_txt = lc_text_parm2.
      ENDIF.

      REPLACE '&1' IN lv_txt    WITH lv_txt101.
      REPLACE '&2' IN lv_txt    WITH lv_txt102  .

      CONCATENATE rv_txt lv_comma lv_txt INTO rv_txt.
      IF strlen( rv_txt ) > 230.
        EXIT.
      ENDIF.
      lv_comma = `, `.
    ENDLOOP.


  ENDMETHOD.


  METHOD M_10_CREATE_OBJECT.

    IF O_CONTAINER IS NOT INITIAL .

      CREATE OBJECT ME->O_ALV
        EXPORTING
          I_PARENT = ME->O_CONTAINER.

    ELSEIF O_CONTAINER_O IS NOT INITIAL .

      CREATE OBJECT ME->O_ALV
        EXPORTING
          I_PARENT = ME->O_CONTAINER_O.

    ELSEIF O_DOCKING_CONTAINER IS NOT INITIAL .

      CREATE OBJECT ME->O_ALV
        EXPORTING
          I_PARENT = ME->O_DOCKING_CONTAINER.

    ENDIF .

  ENDMETHOD.


  METHOD M_30_ADD_F4_FLD .

    DATA LS LIKE LINE OF ME->T_F4 .

    LS-FIELDNAME = I_FIELDNAME .
    LS-REGISTER = 'X' .
    APPEND LS TO ME->T_F4 .

  ENDMETHOD.


  METHOD M_30_EX_TOOLBAR.

    REFRESH T_EXTOOLBAR .

    IF IV_DETAIL = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_DETAIL TO T_EXTOOLBAR .
    ENDIF .
    IF IV_CHECK = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_CHECK TO T_EXTOOLBAR .
    ENDIF .
    IF IV_COPY = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY TO T_EXTOOLBAR .
    ENDIF .
    IF IV_VIEW = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_MB_VIEW TO T_EXTOOLBAR .
    ENDIF .
    IF IV_INFO = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_INFO TO T_EXTOOLBAR .
    ENDIF .

    IF IV_UNDO = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO TO T_EXTOOLBAR .
    ENDIF .
    IF IV_FIND = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_FIND TO T_EXTOOLBAR .
    ENDIF .
    IF IV_FIND_MORE = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_FIND_MORE TO T_EXTOOLBAR .
    ENDIF .

    IF IV_REFRESH = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_REFRESH TO T_EXTOOLBAR .
    ENDIF .
    IF IV_CUT = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_CUT TO T_EXTOOLBAR .
    ENDIF .
    IF IV_APPEND = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW TO T_EXTOOLBAR .
    ENDIF .
    IF IV_INSERT = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW TO T_EXTOOLBAR .
    ENDIF .
    IF IV_DELETE = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW TO T_EXTOOLBAR .
    ENDIF .
    IF IV_SORT_ASC = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_SORT_ASC TO T_EXTOOLBAR .
    ENDIF .
    IF IV_SORT_DSC = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_SORT_DSC TO T_EXTOOLBAR .
    ENDIF .
    IF IV_SUM = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_MB_SUM TO T_EXTOOLBAR .
    ENDIF .
    IF IV_FILTER = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_MB_FILTER TO T_EXTOOLBAR .
    ENDIF .
    IF IV_SUBTOT = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_MB_SUBTOT TO T_EXTOOLBAR .
    ENDIF .
    IF IV_PRINT = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK TO T_EXTOOLBAR .
    ENDIF .
    IF IV_EXPORT = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_MB_EXPORT TO T_EXTOOLBAR .
    ENDIF .
    IF IV_VARIANT = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_MB_VARIANT TO T_EXTOOLBAR .
    ENDIF .
    IF IV_PASTE = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_MB_PASTE TO T_EXTOOLBAR .
    ENDIF .
    IF IV_PASTE_NEW = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW  TO T_EXTOOLBAR .
    ENDIF .
    IF IV_PASTE_NEW = 'X' .
      APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW  TO T_EXTOOLBAR .
    ENDIF .

  ENDMETHOD.


  METHOD M_30_SET_HANDLER.
    SET HANDLER ME->ALV_DOUBLE_CLICK FOR O_ALV.
    SET HANDLER ME->ALV_USER_COMMAND FOR O_ALV.
    SET HANDLER ME->ALV_HOTSPOT_CLICK FOR O_ALV.
    SET HANDLER ME->ALV_ON_F4 FOR O_ALV.
    SET HANDLER ME->ALV_DATA_CHANGED FOR O_ALV.
    SET HANDLER ME->ALV_DATA_CHANGED_FINISHED FOR O_ALV.
    SET HANDLER ME->ALV_TOP_OF_PAGE FOR O_ALV.
    SET HANDLER ME->ALV_HANDLE_TOOLBAR FOR O_ALV.

  ENDMETHOD.


  METHOD M_30_SET_LAYOUT .

    DATA LV_FLD TYPE STRING .
    FIELD-SYMBOLS <F> TYPE ANY .

    LV_FLD = |ME->S_LAYO-{ I_FIELD }| .

    UNASSIGN <F> .
    ASSIGN (LV_FLD) TO <F> .
    IF <F> IS ASSIGNED .
      <F> = I_VALUE .
    ENDIF .

  ENDMETHOD.


  METHOD M_80_DISPLAY_ALV.

    CALL METHOD O_ALV->REGISTER_F4_FOR_FIELDS
      EXPORTING
        IT_F4 = ME->T_F4.                 " F4 FIELDS

    CALL METHOD O_ALV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT            = S_LAYO
        IT_TOOLBAR_EXCLUDING = T_EXTOOLBAR
      CHANGING
        IT_OUTTAB            = T_DATA
        IT_FIELDCATALOG      = T_FCAT.

  ENDMETHOD.


  METHOD M_90_REFRESH_ALV.

*    o_alv->refresh_table_display( ) .

    DATA: LS_STABLE TYPE LVC_S_STBL.

    LS_STABLE-ROW = ABAP_TRUE. " 행 위치 유지
    LS_STABLE-COL = ABAP_TRUE. " 열 위치 유지

    CALL METHOD O_ALV->REFRESH_TABLE_DISPLAY
      EXPORTING
        IS_STABLE = LS_STABLE
      EXCEPTIONS
        FINISHED  = 1
        OTHERS    = 2.

  ENDMETHOD.


  METHOD SET_DROP_DOWN_TABLE.

    CALL METHOD O_ALV->SET_DROP_DOWN_TABLE
      EXPORTING
        IT_DROP_DOWN = IT_DROP_DOWN.  " Dropdown Table

  ENDMETHOD.


  METHOD set_header_init.

    " Table 을 선언한다.
    CALL METHOD io_docu->add_table
      EXPORTING
        no_of_columns      = iv_no_of_columns
        border             = iv_border " '0' " 선표시 하지 않음
        width              = iv_width_tab
      IMPORTING
*       table              = co_tab
        tablearea          = co_tarea
      EXCEPTIONS
        table_already_used = 1.

    " column 의 폭을 설정한다
    CALL METHOD co_tarea->set_column_width
      EXPORTING
        col_no = 1
        width  = iv_width_col1.

    CALL METHOD co_tarea->set_column_width
      EXPORTING
        col_no = 2
        width  = iv_width_col2.

    CALL METHOD co_tarea->set_column_width
      EXPORTING
        col_no = 3
        width  = iv_width_col3.

  ENDMETHOD.


  METHOD set_header_show.

    " 참고 program : DD_ADD_TABLE 2.1

    DATA: lv_width_col1 TYPE sdydo_value,
          lo_tarea      TYPE REF TO cl_dd_table_area.

*    IF gv_selscr_max_len BETWEEN 20 AND 30.
*      lv_width_col1 = '20%'.
*    ELSE.
*      lv_width_col1 = '10%'.
*    ENDIF.

    " Header 초기화
    CALL METHOD me->set_header_init
      EXPORTING
        io_docu       = co_docu
        iv_width_col1 = lv_width_col1
*       iv_border     = '1'
      CHANGING
        co_tarea      = lo_tarea.

* SelScr 정보 출력
    IF iv_show_default = abap_true.
      me->set_header_show_default( CHANGING co_tarea = lo_tarea ).
    ENDIF.

* 추가로 설정해야 하는 Header line 이 있는 경우
*    DATA: lv_formnm TYPE char30.
*    CONCATENATE 'ADD_ALV_TOPPAGE_'  iv_dynnr INTO lv_formnm.
*    PERFORM (lv_formnm) IN PROGRAM (gv_repid) IF FOUND
*                           CHANGING lo_tarea.

* 사용자 정보
*    CALL METHOD me->set_header_text_p
*      EXPORTING
*        iv_title = 'User ID'
*        iv_value = go_comfunc->gv_pernr
*      CHANGING
*        co_tarea = lo_tarea.

    " row 단위 Data 를 Table 로 생성한다.
    CALL METHOD co_docu->merge_document.

* Background Image 설정
    IF iv_show_backgrand = abap_true.
      CALL METHOD co_docu->set_document_background
        EXPORTING
          picture_id = 'ALV_BACKGROUND'.
    ENDIF.

    "  Display Screen(HTML 영역)
    IF co_html IS INITIAL.
      CREATE OBJECT co_html
        EXPORTING
          parent = co_head.
    ENDIF.

    " HTML 영역을 연결한다.
    co_docu->html_control = co_html.

    " 화면에 표시한다.
    CALL METHOD co_docu->display_document
      EXPORTING
        reuse_control      = 'X'
        parent             = co_head "표시할 컨테이너부분
      EXCEPTIONS
        html_display_error = 1.

  ENDMETHOD.


  METHOD set_header_show_default.

    DATA: lo_seltab_w     TYPE REF TO data,
          lv_dtype        TYPE c,
          lv_screen_name  TYPE scrfname,
          lv_fld_par2     TYPE scrfname,
          lv_vtext        TYPE scrfname,
          lv_fld_par1_v   TYPE scrfname,
          lv_fld_par2_v   TYPE scrfname,
          lv_fld_par3     TYPE scrfname,
          lv_fld_par3_v   TYPE scrfname,
          lv_seltab_name  TYPE scrfname,
          ls_selscr_field TYPE tys_selscr_field.

    FIELD-SYMBOLS:
      <lv_scrname>  TYPE any,
      <lv_fld_par2> TYPE any,
      <lv_fld_par3> TYPE any,
      <ls_seltab>   TYPE any,
      <lt_seltab>   TYPE STANDARD TABLE.

    LOOP AT gt_selscr_field INTO ls_selscr_field.

      UNASSIGN: <lv_scrname>, <ls_seltab>, <lt_seltab>.


      CASE ls_selscr_field-ftype.
        WHEN 'LOW'.
          CONCATENATE `(` gv_repid `)` ls_selscr_field-fname '[]' INTO lv_screen_name .
          ASSIGN (lv_screen_name) TO <lt_seltab>.

          IF ls_selscr_field-dtype IS INITIAL.
            CREATE DATA lo_seltab_w LIKE LINE OF <lt_seltab>.
            ASSIGN lo_seltab_w->* TO <ls_seltab>.

            ASSIGN ('<LS_SELTAB>-LOW') TO <lv_scrname>.

            DESCRIBE FIELD <lv_scrname> TYPE lv_dtype.
          ELSE.
            lv_dtype = ls_selscr_field-dtype .
          ENDIF.

          CALL METHOD me->set_header_text_s
            EXPORTING
              iv_title       = ls_selscr_field-title
              it_seltab      = <lt_seltab>
              iv_seltab_type = lv_dtype
            CHANGING
              co_tarea       = co_tarea.

        WHEN 'PAR' OR 'RBG'.
          CLEAR: lv_fld_par1_v.
          CONCATENATE `(` gv_repid `)` ls_selscr_field-fname INTO lv_screen_name .
          ASSIGN (lv_screen_name) TO <lv_scrname>.
          CHECK sy-subrc = 0 AND <lv_scrname> IS NOT INITIAL.
          DESCRIBE FIELD <lv_scrname> TYPE ls_selscr_field-dtype.
          lv_fld_par1_v = me->edit_header_p( iv_value = <lv_scrname> iv_dtype = ls_selscr_field-dtype ).

          IF ls_selscr_field-fname2 IS INITIAL.
            CLEAR: lv_fld_par2_v.
          ELSE.
            CONCATENATE `(` gv_repid `)` ls_selscr_field-fname2 INTO lv_fld_par2 .
            ASSIGN (lv_fld_par2) TO <lv_fld_par2>.
            IF sy-subrc = 0 AND <lv_fld_par2> IS NOT INITIAL.
              DESCRIBE FIELD <lv_fld_par2> TYPE ls_selscr_field-dtype.
              lv_fld_par2_v = me->edit_header_p( iv_value = <lv_fld_par2> iv_dtype = ls_selscr_field-dtype ).
            ENDIF.
          ENDIF.

          IF ls_selscr_field-fname3 IS INITIAL.
            CLEAR: lv_fld_par3_v.
          ELSE.
            CONCATENATE `(` gv_repid `)` ls_selscr_field-fname3 INTO lv_fld_par3 .
            ASSIGN (lv_fld_par3) TO <lv_fld_par3>.
            IF sy-subrc = 0 AND <lv_fld_par3> IS NOT INITIAL.
              DESCRIBE FIELD <lv_fld_par3> TYPE ls_selscr_field-dtype.
              lv_fld_par3_v = me->edit_header_p( iv_value = <lv_fld_par3> iv_dtype = ls_selscr_field-dtype ).
            ENDIF.
          ENDIF.

          CASE ls_selscr_field-ftype..
            WHEN 'RBG'.
              lv_fld_par1_v = ls_selscr_field-text.
              CLEAR ls_selscr_field-text.
            WHEN OTHERS. lv_vtext = ls_selscr_field-text.
          ENDCASE.

          CALL METHOD me->set_header_text_p
            EXPORTING
              iv_title  = ls_selscr_field-title
              iv_value  = lv_fld_par1_v
              iv_value2 = lv_fld_par2_v
              iv_value3 = lv_fld_par3_v
              iv_vtext  = ls_selscr_field-text
            CHANGING
              co_tarea  = co_tarea.

        WHEN OTHERS.
          CONTINUE.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD set_header_text_p.

    DATA: lv_text   TYPE sdydo_text_element,
          lv_txt101 TYPE string,
          lv_txt102 TYPE string.

    " title
    lv_text = iv_title.
    CALL METHOD co_tarea->add_text
      EXPORTING
        text         = lv_text
        sap_fontsize = cl_dd_area=>medium.

    IF iv_value2 IS INITIAL AND iv_value3 IS INITIAL.
      " value
      lv_text =  iv_value.
      CALL METHOD co_tarea->add_text
        EXPORTING
          text         = lv_text
          sap_fontsize = cl_dd_area=>medium.

      " text
      lv_text =  iv_vtext.


    ELSE.
      CALL METHOD co_tarea->span_columns
        EXPORTING
          col_start_span = 2
          no_of_cols     = 2.

      CONCATENATE iv_value iv_vtext iv_value2 iv_value3
             INTO lv_text SEPARATED BY space.
    ENDIF.

    CALL METHOD co_tarea->add_text
      EXPORTING
        text         = lv_text
        sap_fontsize = cl_dd_area=>medium.

    CALL METHOD co_tarea->new_row.

  ENDMETHOD.


  METHOD set_header_text_s.


    DATA: lv_text   TYPE sdydo_text_element,
          lv_txt101 TYPE string,
          lv_txt102 TYPE string.

    CALL METHOD co_tarea->span_columns
      EXPORTING
        col_start_span = 2
        no_of_cols     = 2.

*  lv_text = me->set_header( iv_gubun = 'H'
*                            iv_parm1 = iv_title
*                            iv_parm2 = space ).
    lv_text = iv_title.
    CALL METHOD co_tarea->add_text
      EXPORTING
        text         = lv_text
        sap_fontsize = cl_dd_area=>medium.

    lv_text = me->edit_header_s( it_sel = it_seltab[] iv_opt = iv_seltab_type ).

    CALL METHOD co_tarea->add_text
      EXPORTING
        text         = lv_text
        sap_fontsize = cl_dd_area=>medium.

*  IF co_col_remark IS BOUND.
*    lv_text =  iv_remark.
*    CALL METHOD co_col_remark->add_text
*      EXPORTING
*        text         = lv_text
*        sap_fontsize = cl_dd_area=>medium.
*  ENDIF.

    CALL METHOD co_tarea->new_row.

  ENDMETHOD.
ENDCLASS.
