class ZCL_ZPO_CRUD_DPC_EXT definition
  public
  inheriting from ZCL_ZPO_CRUD_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.
private section.

  data:
    BEGIN OF is_data,
        ebeln   TYPE ekko-ebeln,
        lifnr   TYPE ekko-lifnr,
        name1   TYPE lfa1-name1,
        bedat   TYPE ekko-bedat,
        zterm   TYPE ekko-zterm,
*             total_price TYPE ekpo-netwr,
        waers   TYPE ekko-waers,
        ekorg   TYPE ekko-ekorg,
        ekotx   TYPE t024e-ekotx,
        ekgrp   TYPE ekko-ekgrp,
        eknam   TYPE t024-eknam,
        bukrs   TYPE ekko-bukrs,
        butxt   TYPE t001-butxt,

        ebelp   TYPE ekpo-ebelp,
        matnr   TYPE ekpo-matnr,
        maktx   TYPE makt-maktx,
        lgort   TYPE ekpo-lgort,
        lgobe   TYPE t001l-lgobe,
        menge   TYPE ekpo-menge,
        meins   TYPE ekpo-meins,
        netpr   TYPE ekpo-netpr,
        netpr_c TYPE char30,
        netwr   TYPE ekpo-netwr,
        netwr_c TYPE char30,
      END OF is_data .
  data:
    it_data LIKE TABLE OF is_data .
  data IV_TOTAL_PRICE type NETWR .
  data IV_TEMPLATEID type STRING .
  data IV_XSTRING type XSTRING .

  methods SET_CELL_STYLE
    importing
      !IV_COL type CHAR1
      !IV_ROW type INTEGER
      !IV_ALLIGNMENT type STRING
      !IV_BORDER type STRING default 'ALL'
      !IV_FONT type STRING optional
      !IO_WORKSHEET type ref to ZCL_EXCEL_WORKSHEET
      !IV_VALUE type ANY
      !IO_EXCEL type ref to ZCL_EXCEL
      !IV_CURR type ABAP_BOOLEAN default ' ' .
  methods SET_EXCEL_DATA .
ENDCLASS.



CLASS ZCL_ZPO_CRUD_DPC_EXT IMPLEMENTATION.


  METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.

    " 모든 ENTITY TYPE이 공통으로 사용하는 METHOD 이기 때문에 ENTITY SET NAME으로 구분
    IF IV_ENTITY_SET_NAME EQ 'ZS4H084_I01'.

      DATA : BEGIN OF LS_DEEP_ENTITY.
               INCLUDE TYPE ZCL_ZPO_CRUD_MPC_EXT=>TS_ZS4H084_I01TYPE.
      DATA :   TO_ITEM TYPE ZCL_ZPO_CRUD_MPC_EXT=>TT_ZPO_ITEMTYPE,
             END OF LS_DEEP_ENTITY.

      " LS_DEEP_ENTITY의 구조를 기반으로 동적 구조체인 ER_DEEP_ENTITY 선언
      " ER_DEEP_ENTITY 는 출력값이고, 이 객체에 데이터가 채워지지 않은 경우 UI5 APP에서 오류를 뱉음
      CREATE DATA ER_DEEP_ENTITY LIKE LS_DEEP_ENTITY.

      TRY.
          IO_DATA_PROVIDER->READ_ENTRY_DATA(  " 입력된 데이터 READ
           IMPORTING
             ES_DATA = LS_DEEP_ENTITY
          ).
        CATCH /IWBEP/CX_MGW_TECH_EXCEPTION.
          RETURN.
      ENDTRY.

      IF SY-SUBRC EQ 0.
*--------------------------------------------------------------------*
* CREATE
*--------------------------------------------------------------------*
        IF LS_DEEP_ENTITY-PurchaseOrder IS INITIAL.

          DATA : LS_EKKO   TYPE BAPIMEPOHEADER,
                 LS_EKKOX  TYPE BAPIMEPOHEADERX,
                 LT_EKPO   TYPE TABLE OF BAPIMEPOITEM,
                 LT_EKPOX  TYPE TABLE OF BAPIMEPOITEMX,
                 LT_RETURN TYPE TABLE OF BAPIRET2.

          SELECT MATNR,
                 MEINS
            FROM MARA
            INTO TABLE @DATA(LT_MEINS).

          LS_DEEP_ENTITY-Currency = 'KRW'.

          " Header 세팅
          LS_EKKO-DOC_TYPE = 'NB'.  " 표준 PO 유형
          LS_EKKO-VENDOR = LS_DEEP_ENTITY-Vendor.             "공급업체
          LS_EKKO-PURCH_ORG = LS_DEEP_ENTITY-PurchasingOrg.   "구매 조직
          LS_EKKO-PUR_GROUP = LS_DEEP_ENTITY-PurchasingGroup. "구매 그룹
          LS_EKKO-COMP_CODE = LS_DEEP_ENTITY-BUKRS.           "회사 코드
          LS_EKKO-CURRENCY = 'KRW'. "LS_DEEP_ENTITY-Currency.         "통화코드

          LS_EKKOX-DOC_TYPE = 'X'.
          LS_EKKOX-VENDOR = 'X'.
          LS_EKKOX-PURCH_ORG = 'X'.
          LS_EKKOX-PUR_GROUP = 'X'.
          LS_EKKOX-COMP_CODE = 'X'.
          LS_EKKOX-CURRENCY = 'X'.

          DATA LV_PO_NUMBER TYPE C LENGTH 10.

          DATA(LV_EBELP) = 10.

          " Item & ItemX 세팅
          LOOP AT LS_DEEP_ENTITY-TO_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
            <FS_ITEM>-PurchaseOrderItem = LV_EBELP.
            LV_EBELP += 10.

            <FS_ITEM>-Currency = 'KRW'.

            READ TABLE LT_MEINS INTO DATA(LS_MEINS) WITH KEY MATNR = <FS_ITEM>-Material.
            IF SY-SUBRC EQ 0.
              <FS_ITEM>-Unit = LS_MEINS-MEINS.
            ENDIF.

            <FS_ITEM>-NetAmount = <FS_ITEM>-NetPrice * <FS_ITEM>-Quantity.

            APPEND VALUE #(
              PO_ITEM  = <FS_ITEM>-PurchaseOrderItem
              MATERIAL = <FS_ITEM>-Material
              QUANTITY = <FS_ITEM>-Quantity
              PO_UNIT   = <FS_ITEM>-Unit
              NET_PRICE = <FS_ITEM>-NetPrice
*              CURRENCY  = <FS_ITEM>-Currency
              PLANT    = <FS_ITEM>-Plant
*              STGE_LOC = <FS_ITEM>-LGORT
            ) TO LT_EKPO.

            APPEND VALUE #(
              PO_ITEM = <FS_ITEM>-PurchaseOrderItem
              PO_ITEMX = 'X'
              MATERIAL = 'X'
              QUANTITY = 'X'
              PO_UNIT   = 'X'
              NET_PRICE = 'X'
*              CURRENCY  = 'X'
              PLANT    = 'X'
*              STGE_LOC = 'X'
            ) TO LT_EKPOX.

          ENDLOOP.

          " CREATE를 위한 BAPI 태우기
          CALL FUNCTION 'BAPI_PO_CREATE1' "DESTINATION 'NONE'
            EXPORTING
              POHEADER         = LS_EKKO
              POHEADERX        = LS_EKKOX
            IMPORTING
              EXPPURCHASEORDER = LV_PO_NUMBER
            TABLES
              RETURN           = LT_RETURN
              POITEM           = LT_EKPO
              POITEMX          = LT_EKPOX.

          " RETURN MESSAGE TYPE에 따른 예외 처리
          LOOP AT LT_RETURN INTO DATA(LS_RETURN).
            IF LS_RETURN-TYPE = 'E' OR LS_RETURN-TYPE = 'A'.
              RAISE EXCEPTION TYPE /IWBEP/CX_MGW_BUSI_EXCEPTION
                EXPORTING
                  TEXTID  = /IWBEP/CX_MGW_BUSI_EXCEPTION=>BUSINESS_ERROR
                  MESSAGE = LS_RETURN-MESSAGE.
            ENDIF.
          ENDLOOP.

          IF LV_PO_NUMBER IS NOT INITIAL.  " 생성할 아이템이 1건 이상인 경우에만 이후 트랜잭션 진행

            FIELD-SYMBOLS : <LR_ER_ENTITY> LIKE LS_DEEP_ENTITY.

            ASSIGN ER_DEEP_ENTITY->* TO <LR_ER_ENTITY>.

            IF <LR_ER_ENTITY> IS ASSIGNED.
              MOVE-CORRESPONDING LS_DEEP_ENTITY TO <LR_ER_ENTITY>.
              <LR_ER_ENTITY>-PurchaseOrder = LV_PO_NUMBER.
            ENDIF.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                WAIT = 'X'.                 " Use of Command `COMMIT AND WAIT`

          ELSE.

            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

          ENDIF.
*--------------------------------------------------------------------*
* UPDATE & DELETE
*--------------------------------------------------------------------*
        ELSE.



        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM.

     DATA : lv_ebeln       TYPE ekko-ebeln,
           lv_total_price TYPE char30,
           lv_max_len     TYPE i VALUE 10.

    LOOP AT it_key_tab ASSIGNING FIELD-SYMBOL(<fs_key>).

      CASE <fs_key>-name.
        WHEN 'Ebeln'.
          lv_ebeln = <fs_key>-value.
        WHEN OTHERS.
          iv_templateid = <fs_key>-value.
      ENDCASE.

    ENDLOOP.

    CLEAR it_data.
    SELECT a~ebeln, a~lifnr, c~name1,
           a~waers, a~ekorg, f~ekotx, a~ekgrp, g~eknam, a~bukrs, h~butxt, a~bedat, a~zterm,
           b~ebelp, b~matnr, d~maktx, b~lgort, e~lgobe,
           b~menge, b~meins, b~netpr, b~netwr
      INTO CORRESPONDING FIELDS OF TABLE @it_data
      FROM ekko AS a INNER JOIN ekpo AS b
                             ON a~ebeln = b~ebeln
                     LEFT OUTER JOIN lfa1 AS c
                                  ON a~lifnr = c~lifnr
*                                 AND c~spras = @sy-langu
                     LEFT OUTER JOIN makt AS d
                                  ON b~matnr = d~matnr
                                 AND d~spras = @sy-langu
                     LEFT OUTER JOIN t001l AS e
                                  ON b~werks = e~werks
                                 AND b~lgort = e~lgort
                     LEFT OUTER JOIN t024e AS f
                                  ON a~ekorg = f~ekorg
                     LEFT OUTER JOIN t024 AS g
                                  ON a~ekgrp = g~ekgrp
                     LEFT OUTER JOIN t001 AS h
                                  ON a~bukrs = h~bukrs
      WHERE a~ebeln = @lv_ebeln
      ORDER BY a~ebeln, b~ebelp.

    CLEAR iv_total_price.
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      " netwr 통화키 반영
      WRITE <fs_data>-netwr CURRENCY <fs_data>-waers TO <fs_data>-netwr_c
                                                     NO-GAP.
      CONDENSE <fs_data>-netwr_c NO-GAPS.

      " netpr 통화키 반영
      WRITE <fs_data>-netpr CURRENCY <fs_data>-waers TO <fs_data>-netpr_c
                                                     NO-GAP.
      CONDENSE <fs_data>-netpr_c NO-GAPS.

      " 총 금액 계산
      iv_total_price += <fs_data>-netwr.

      " 최대 길이의 창고명 추출
      IF strlen( <fs_data>-lgobe ) > lv_max_len.
        lv_max_len = strlen( <fs_data>-lgobe ).
      ENDIF.

    ENDLOOP.

    WRITE iv_total_price CURRENCY <fs_data>-waers TO lv_total_price
                                               NO-GAP.
    CONDENSE lv_total_price NO-GAPS.

    DATA: lt_mime       TYPE TABLE OF w3mime,
          lt_solix      TYPE solix_tab,
          ls_object     TYPE wwwdatatab,
          lv_total_size TYPE i,
          ls_stream     TYPE ty_s_media_resource.

    " SMW0에서 파일 로드 (Binary로 올렸는지 꼭 확인!)
    SELECT SINGLE * FROM wwwdata
      INTO CORRESPONDING FIELDS OF @ls_object
      WHERE objid = @iv_templateid.

*   파일 사이즈 추출
    DATA : lv_filesize  TYPE i,
           lv_filesizec TYPE c LENGTH 10.
    CALL FUNCTION 'WWWPARAMS_READ'
      EXPORTING
        relid = ls_object-relid
        objid = ls_object-objid
        name  = 'filesize'
      IMPORTING
        value = lv_filesizec.

    lv_filesize = lv_filesizec.

    CALL FUNCTION 'WWWDATA_IMPORT'
      EXPORTING
        key  = ls_object
      TABLES
        mime = lt_mime.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_filesize
      IMPORTING
        buffer       = iv_xstring
      TABLES
        binary_tab   = lt_mime
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.

    me->set_excel_data( ).

    ls_stream-mime_type = 'application/octet-stream'.
    ls_stream-value = iv_xstring.
    copy_data_to_ref(
       EXPORTING
         is_data = ls_stream
       CHANGING
         cr_data = er_stream ).

*    " Key 값 읽기
*    READ TABLE IT_KEY_TAB INTO DATA(LS_KEY_TAB) WITH KEY NAME = 'Ebeln'.
*    DATA(LV_EBELN) = LS_KEY_TAB-VALUE.
*
*
***** CDS 뷰의 데이터 채우기
*    SELECT * FROM ZS4H084_I01
*      INTO TABLE @DATA(IT_HEADER)
*      WHERE PURCHASEORDER = @LV_EBELN.
*
*    IF IT_HEADER IS NOT INITIAL.
*      DATA(LV_PO_NUMBER) = IT_HEADER[ 1 ]-PURCHASEORDER.
*
*      " 2. 아이템 뷰(zpo_item)에서 실제 개별 아이템들을 조회합니다.
*      SELECT *
*        FROM ZPO_ITEM
*        INTO TABLE @DATA(IT_ITEMS)
*        WHERE PURCHASEORDER = @LV_EBELN.
*
*      " 이제 it_items 테이블에 lv_po_number에 해당하는 모든 아이템이 담깁니다.
*    ENDIF.
*
***** SWM0 파일 XSTRING으로 변환하기
*    DATA: LS_OBJECT TYPE WWWDATATAB,
*          LT_MIME   TYPE TABLE OF W3MIME.
*
*
*    SELECT SINGLE *
*      FROM WWWDATA
*      INTO CORRESPONDING FIELDS OF @LS_OBJECT
*     WHERE OBJID = 'Z2508R0050_084'. " IT_KEY_TAB에 들어있는 fileName과 language로 템플릿 파일을 찾는것도 가능.
*
**   파일 사이즈 추출
*    DATA : LV_FILESIZE  TYPE I,
*           LV_FILESIZEC TYPE C LENGTH 10.
*    CALL FUNCTION 'WWWPARAMS_READ'
*      EXPORTING
*        RELID = LS_OBJECT-RELID
*        OBJID = LS_OBJECT-OBJID
*        NAME  = 'filesize'
*      IMPORTING
*        VALUE = LV_FILESIZEC.
*    LV_FILESIZE = LV_FILESIZEC.
*
*    CALL FUNCTION 'WWWDATA_IMPORT'
*      EXPORTING
*        KEY  = LS_OBJECT
*      TABLES
*        MIME = LT_MIME.
*
*    DATA : LV_XSTRING TYPE XSTRING.
*    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
*      EXPORTING
*        INPUT_LENGTH = LV_FILESIZE
*      IMPORTING
*        BUFFER       = LV_XSTRING
*      TABLES
*        BINARY_TAB   = LT_MIME
*      EXCEPTIONS
*        FAILED       = 1
*        OTHERS       = 2.
*
*
*
*    DATA : LS_STREAM     TYPE TY_S_MEDIA_RESOURCE.
*    LS_STREAM-MIME_TYPE = 'application/msexcel'.
*    LS_STREAM-VALUE = LV_XSTRING.
*    COPY_DATA_TO_REF(
*       EXPORTING
*         IS_DATA = LS_STREAM
*       CHANGING
*         CR_DATA = ER_STREAM ).

  ENDMETHOD.


  METHOD set_cell_style.

    DATA : lo_cell_style      TYPE REF TO zcl_excel_style,

           lo_style_alignment TYPE REF TO zcl_excel_style.

    " 기존 cell 스타일 가져오기
*    CALL METHOD io_worksheet->get_cell
*      EXPORTING
*        ip_column = iv_col
*        ip_row    = iv_row
*      IMPORTING
*        ep_style  = lo_cell_style.

*    IF lo_cell_style IS NOT BOUND.

      lo_cell_style = io_excel->add_new_style( ).

*    ENDIF.

    " 금액 or 수량이라면
    IF iv_curr = abap_true.
      lo_cell_style->number_format->format_code = '#,##0'.
      " 여백
*      lo_cell_style->alignment->indent = 1.
    ENDIF.

    " 테두리
    DATA(lo_excel_style_border) = NEW zcl_excel_style_border( ).
    CASE iv_border.
      WHEN 'ALL'.
        lo_excel_style_border->border_style = zcl_excel_style_border=>c_border_thin.
        lo_cell_style->borders->allborders = lo_excel_style_border.
    ENDCASE.

    " 정렬
    CASE iv_allignment.
      WHEN 'L'.
        lo_cell_style->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_left.
      WHEN 'C'.
        lo_cell_style->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_center.
      WHEN 'R'.
        lo_cell_style->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
    ENDCASE.

    io_worksheet->set_cell( ip_column = iv_col ip_row = iv_row ip_value = iv_value ip_style = lo_cell_style->get_guid( ) ).

  ENDMETHOD.


  METHOD set_excel_data.

    DATA: lo_excel              TYPE REF TO zcl_excel,
          lo_reader             TYPE REF TO zcl_excel_reader_2007,
          lo_writer             TYPE REF TO zcl_excel_writer_2007,
          lo_worksheet          TYPE REF TO zcl_excel_worksheet,
*          lo_ws                 TYPE REF TO zcl_excel_worksheet,
          lo_style_left         TYPE REF TO zcl_excel_style,
          lo_style_right        TYPE REF TO zcl_excel_style,
          lo_style_center       TYPE REF TO zcl_excel_style,
          lo_style_center_clear TYPE REF TO zcl_excel_style,
          lo_style_border       TYPE REF TO zcl_excel_style,
          lv_style_guid         TYPE zexcel_guid, " ★ 스타일 GUID 타입
          lv_total_price        TYPE char30,
          lv_max_len            TYPE i VALUE 10.

    " abap2xlsx 리더로 Excel 로드
    CREATE OBJECT lo_reader.
    lo_excel = lo_reader->zif_excel_reader~load( i_excel2007 = iv_xstring ).

**********************************************************************
    " 워크시트 선택 후 셀 채우기
    lo_worksheet = lo_excel->get_active_worksheet( ).
    DATA(lo_column) = lo_worksheet->get_column( ip_column = 'J' ).
    lo_column->set_width( lv_max_len * 2 + 3 ).
*ADD_NEW_ROW
**********************************************************************
* 스타일 세팅
**********************************************************************
    " 전방향 테두리 스타일 생성
    DATA(lo_excel_style_border) = NEW zcl_excel_style_border( ).
    lo_excel_style_border->border_style = zcl_excel_style_border=>c_border_thin.

    " 좌측 정렬 스타일 생성
    lo_style_left = lo_excel->add_new_style( ).
    lo_style_left->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_left.
    lo_style_left->borders->allborders = lo_excel_style_border.

    " 우측 정렬 스타일 생성
    lo_style_right = lo_excel->add_new_style( ).
    lo_style_right->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_right.
    lo_style_right->borders->allborders = lo_excel_style_border.
    lo_style_right->number_format->format_code = '#,##0'.
    lo_style_right->fill->filltype = zcl_excel_style_fill=>c_fill_solid.
    lo_style_right->fill->fgcolor-rgb = 'D9D9D9'.
*
    " 중앙 정렬 스타일 생성
    lo_style_center = lo_excel->add_new_style( ).
    lo_style_center->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_center.
    lo_style_center->borders->allborders = lo_excel_style_border.
    lo_style_center->fill->filltype = zcl_excel_style_fill=>c_fill_solid.
    lo_style_center->fill->fgcolor-rgb = 'D9D9D9'.

    " 중앙 정렬 스타일(배경X, 테두리X) 생성
    lo_style_center_clear = lo_excel->add_new_style( ).
    lo_style_center_clear->alignment->horizontal = zcl_excel_style_alignment=>c_horizontal_center.

    " 하단 border
    lo_style_border = lo_excel->add_new_style( ).
    lo_style_border->borders->down = lo_excel_style_border.

**********************************************************************
* 헤더 정보
**********************************************************************
    DATA : lv_row    TYPE i VALUE 5,
           lv_vendor TYPE string.

    CONSTANTS : lv_col TYPE i VALUE 5.
    FIELD-SYMBOLS : <fs_field> TYPE any.

    lv_vendor = |{ it_data[ 1 ]-lifnr ALPHA = OUT }|.
    CONDENSE lv_vendor NO-GAPS.

* Excel 출력 기업 정보 3개
    me->set_cell_style( iv_col = 'E' iv_row = 5 iv_allignment = 'L' iv_border = '' io_worksheet = lo_worksheet iv_value = |{ it_data[ 1 ]-ekorg }({ it_data[ 1 ]-ekotx })| io_excel = lo_excel ).
    me->set_cell_style( iv_col = 'E' iv_row = 6 iv_allignment = 'L' iv_border = '' io_worksheet = lo_worksheet iv_value = |{ it_data[ 1 ]-ekgrp }({ it_data[ 1 ]-eknam })| io_excel = lo_excel ).
    me->set_cell_style( iv_col = 'E' iv_row = 7 iv_allignment = 'L' iv_border = '' io_worksheet = lo_worksheet iv_value = |{ it_data[ 1 ]-bukrs }({ it_data[ 1 ]-butxt })| io_excel = lo_excel ).

* PO 헤더 정보
    me->set_cell_style( iv_col = 'C' iv_row = 10 iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { it_data[ 1 ]-ebeln }| io_excel = lo_excel ).
    me->set_cell_style( iv_col = 'C' iv_row = 11 iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { lv_vendor }({ it_data[ 1 ]-name1 })|  io_excel = lo_excel ).
    me->set_cell_style( iv_col = 'C' iv_row = 12 iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { sy-datum }| io_excel = lo_excel ).
    me->set_cell_style( iv_col = 'F' iv_row = 10 iv_allignment = 'R' io_worksheet = lo_worksheet iv_value = |{ lv_total_price } { it_data[ 1 ]-waers }| io_excel = lo_excel ).
    me->set_cell_style( iv_col = 'F' iv_row = 11 iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { it_data[ 1 ]-bedat }| io_excel = lo_excel ).
    me->set_cell_style( iv_col = 'F' iv_row = 12 iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { it_data[ 1 ]-zterm }| io_excel = lo_excel ).

**********************************************************************
* 아이템 정보
**********************************************************************
    DATA : lv_netwr TYPE decfloat34,
           lv_netpr TYPE decfloat34,
           lv_ebelp TYPE string,
           lv_start TYPE i VALUE 15.

    DATA(lv_index) = 15.
    LOOP AT it_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      lv_ebelp = |{ <fs_data>-ebelp ALPHA = OUT }|.
      CONDENSE lv_ebelp NO-GAPS.

      REPLACE ALL OCCURRENCES OF ',' IN <fs_data>-netpr_c WITH ''.
      lv_netpr = <fs_data>-netpr_c.

      REPLACE ALL OCCURRENCES OF ',' IN <fs_data>-netwr_c WITH ''.
      lv_netwr = <fs_data>-netwr_c.

      me->set_cell_style( iv_col = 'B' iv_row = lv_index iv_allignment = 'R' io_worksheet = lo_worksheet iv_value = |{ lv_ebelp } |                            io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'C' iv_row = lv_index iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { <fs_data>-matnr }|                     io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'D' iv_row = lv_index iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { <fs_data>-maktx }|                     io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'E' iv_row = lv_index iv_allignment = 'R' io_worksheet = lo_worksheet iv_value = lv_netpr        iv_curr = abap_true        io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'F' iv_row = lv_index iv_allignment = 'C' io_worksheet = lo_worksheet iv_value = <fs_data>-waers                            io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'G' iv_row = lv_index iv_allignment = 'R' io_worksheet = lo_worksheet iv_value = <fs_data>-menge iv_curr = abap_true        io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'H' iv_row = lv_index iv_allignment = 'C' io_worksheet = lo_worksheet iv_value = <fs_data>-meins                            io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'I' iv_row = lv_index iv_allignment = 'R' io_worksheet = lo_worksheet iv_value = lv_netwr        iv_curr = abap_true        io_excel = lo_excel ).
      me->set_cell_style( iv_col = 'J' iv_row = lv_index iv_allignment = 'L' io_worksheet = lo_worksheet iv_value = | { <fs_data>-lgobe }|                     io_excel = lo_excel ).

      lv_index += 1.

    ENDLOOP.

    " 하단 셀 설정(합계, 서명)
    IF lv_index < 27.
      lv_index = 27.
    ENDIF.
    lo_worksheet->set_merge( ip_column_start = 'B' ip_column_end = 'D' ip_row = lv_index ip_style = lo_style_center->get_guid( )  ip_value = '합계' ).
    lo_worksheet->set_cell( ip_column = 'E' ip_row = lv_index ip_style = lo_style_center->get_guid( )  ip_value = '' ).
    lo_worksheet->set_cell( ip_column = 'F' ip_row = lv_index ip_style = lo_style_center->get_guid( )  ip_value = '' ).
    lo_worksheet->set_cell( ip_column = 'G' ip_row = lv_index ip_style = lo_style_right->get_guid( )  ip_value = 0 ip_abap_type = cl_abap_typedescr=>typekind_decfloat ip_formula = |SUM(G15:G{ lv_index - 1 })| ).
    lo_worksheet->set_cell( ip_column = 'H' ip_row = lv_index ip_style = lo_style_center->get_guid( )  ip_value = '' ).
    lo_worksheet->set_cell( ip_column = 'I' ip_row = lv_index ip_style = lo_style_right->get_guid( )  ip_value = 0 ip_abap_type = cl_abap_typedescr=>typekind_decfloat ip_formula = |SUM(I15:I{ lv_index - 1 })| ).
    lo_worksheet->set_cell( ip_column = 'J' ip_row = lv_index ip_style = lo_style_center->get_guid( )  ip_value = '' ).

    lo_worksheet->set_row_height( ip_row = lv_index + 3 ip_height_fix = 63 ).
    lo_worksheet->set_cell( ip_column = 'D' ip_row = lv_index + 3 ip_style = lo_style_border->get_guid( ) ip_value = '' ).
    lo_worksheet->set_merge( ip_column_start = 'F' ip_column_end = 'I' ip_row = lv_index + 3 ip_style = lo_style_border->get_guid( )  ip_value = '' ).
    "lo_style_center_clear
    lo_worksheet->set_cell( ip_column = 'D' ip_row = lv_index + 4 ip_style = lo_style_center_clear->get_guid( ) ip_value = '서명 : 영업 총괄' ).
    lo_worksheet->set_merge( ip_column_start = 'F' ip_column_end = 'I' ip_row = lv_index + 4 ip_style = lo_style_center_clear->get_guid( )  ip_value = '서명 : 영업 담당자' ).

**********************************************************************
    " XSTRING 변환
    CREATE OBJECT lo_writer.
    iv_xstring = lo_writer->zif_excel_writer~write_file( lo_excel ).

  ENDMETHOD.
ENDCLASS.
