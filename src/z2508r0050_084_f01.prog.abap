*&---------------------------------------------------------------------*
*& Include          Z2508R0040_084_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form UPLOAD_FILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPLOAD_FILE CHANGING P_FILE.

  CALL FUNCTION 'WS_FILENAME_GET'
    IMPORTING
      FILENAME         = P_FILE                 " Selected file name
    EXCEPTIONS
      INV_WINSYS       = 1                " File selector not available on this windows system
      NO_BATCH         = 2                " Cannot execute front-end function in background
      SELECTION_CANCEL = 3                " Selection was cancelled
      SELECTION_ERROR  = 4                " Communication error
      OTHERS           = 5.
  CASE SY-SUBRC.
    WHEN 0.
      MESSAGE |{ P_FILE }파일을 선택하였습니다.| TYPE 'S'.
    WHEN 3.
      MESSAGE '선택을 취소하였습니다.'(M01) TYPE 'S' DISPLAY LIKE 'E'.
    WHEN OTHERS.
      MESSAGE '파일 선택에 실패하였습니다.'(M02) TYPE 'S' DISPLAY LIKE 'E'.
  ENDCASE.
*  DATA : LT_FILE TYPE FILETABLE,
*         LV_RC   TYPE I.
*
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*    CHANGING
*      FILE_TABLE = LT_FILE               " 선택한 파일 보관하는 테이블
*      RC         = LV_RC.                 " 반환 코드, 파일 수 또는 오류 발생시 -1
*
*  READ TABLE LT_FILE INTO DATA(LS_FILE) INDEX 1.
*  IF SY-SUBRC = 0.
*    P_FILE = LS_FILE.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DOWNLOAD_TEMPLATE .

  CASE SY-UCOMM.
    WHEN 'FC01'.
      CALL METHOD ZCL_UTIL=>SMW0_DOWNLOAD
        EXPORTING
          I_OBJID = 'Z2508R0040_084'                 " SAP WWW Gateway Object Name
          I_TITLE = |PO 템플릿 { SY-DATUM }{ SY-UZEIT }|.                 " Filename
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_EXCEL_DATA .

  DATA : LT_INTERN TYPE TABLE OF ALSMEX_TABLINE.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME    = P_FILE
      I_BEGIN_COL = 1                        "가져오기 시작할 열
      I_BEGIN_ROW = 2                        "가져오기 시작할 행
      I_END_COL   = 256
      I_END_ROW   = 10000
    TABLES
      INTERN      = LT_INTERN.                " 가져온 테이블 담을 곳

  LOOP AT LT_INTERN ASSIGNING FIELD-SYMBOL(<LS_INTERN>). " LS_INTERN은 ROW, COL, VALUE 필드를 가짐

    " 엑셀의 열 번호인 LS_INTERN-COL에 따라 GS_EXCEL 구조체의 필드를 동적으로 가리킴
    ASSIGN COMPONENT <LS_INTERN>-COL OF STRUCTURE GS_EXCEL TO FIELD-SYMBOL(<FS_FIELD>).

    IF SY-SUBRC = 0.

      IF <LS_INTERN>-COL = 1.
        <FS_FIELD> = |{ <LS_INTERN>-VALUE ALPHA = IN }|. " COL = 1인 행은 VENDOR 를의미함.
        " SAP의 ALPHA 변환 규칙을 적용 (예: 0000123456 형태로 Vendor Code 포맷 맞추기).
      ELSE.
        TRY.  " VALUE값의 형식이 잘못 되었을 경우(숫자타입 아니거나, 음수일 경우)에 대한 예외처리.
            <FS_FIELD> = <LS_INTERN>-VALUE.
          CATCH CX_ROOT.
            " 잘못된 형식이면 예외 발생 → Catch 블록 실행 → 값은 세팅 안됨(=0으로 들어감).
        ENDTRY.
        UNASSIGN <FS_FIELD>.  " 동적 필드심볼 해제
      ENDIF.
    ENDIF.

    AT END OF ROW.  " LT_INTER의 한 행에 대한 모든 셀을 처리한 뒤 GT_EXCEL에 추가.
      APPEND GS_EXCEL TO GT_EXCEL.
      CLEAR GS_EXCEL.
    ENDAT.
  ENDLOOP.

  MOVE-CORRESPONDING GT_EXCEL TO GT_DATA.   " 엑셀로 가져온 필드와 같은 이름의 필드 값 옮겨주기.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_DATA .
  "-◈ :: 개선 예시 코드 ::

***DATA LT LIKE TABLE OF GT_DATA .
***
***REFRESH LT[] .
***LT[] = GT_DATA[] .
***
***SELECT LT~MATNR, T~MAKTX,
***  T~LIFNR, L~NAME1,
***  T~LGORT, C~LGORT AS LGORT_CHECK
***  FROM @LT AS T
***  LEFT OUTER JOIN LFA1 AS L
***    ON L~LIFNR = T~LIFNR
***  LEFT OUTER JOIN MARA AS M
***    ON M~MATNR = T~MATNR
***  LEFT OUTER JOIN MARC AS C
***    ON C~MATNR = T~MATNR
***   AND C~WERKS = @P_WERKS
***  LEFT OUTER JOIN MAKT AS K
***    ON K~MATNR = T~MATNR
***   AND K~SPRAS = @SY-LANGU
***  INTO CORRESPONDING FIELDS OF TABLE @GT_DATA .


  " 거래처명 (NAME1) 조회
  SELECT LIFNR, NAME1
    FROM LFA1
    FOR ALL ENTRIES IN @GT_DATA" INIT CHECK 필요 ::
*                                -> 안하면 덤프나요
    WHERE LIFNR = @GT_DATA-VENDOR
    INTO TABLE @DATA(LT_VENDOR).


  SELECT A~MATNR, C~MAKTX
    FROM @GT_DATA AS A
    JOIN MARC AS B ON A~MATNR = B~MATNR
    LEFT JOIN MAKT AS C ON A~MATNR = C~MATNR
*                  AND C~SPRAS = @SY-LANGU
    INTO TABLE @DATA(LT_MAKT).

  " 거래처명, 자재명 채워넣기
  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<FS>).
    " 거래처명
    READ TABLE LT_VENDOR INTO DATA(LS_VENDOR) WITH KEY LIFNR = <FS>-VENDOR.
    IF SY-SUBRC = 0.
      <FS>-NAME1 = LS_VENDOR-NAME1.
    ELSE.
      <FS>-MESSAGE = TEXT-M01 .  " VENDOR 데이터가 존재하지 않을 경우
      CLEAR: GS_SCOL.
      GS_SCOL-FNAME = 'VENDOR'.
      GS_SCOL-COLOR-COL = '6'.   " 빨간색
      GS_SCOL-COLOR-INT = '0'.   " 강조 여부
      GS_SCOL-COLOR-INV = '0'.   " 반전 여부
      APPEND GS_SCOL TO <FS>-GT_SCOL.

    ENDIF.

    " 자재명
    READ TABLE LT_MAKT INTO DATA(LS_MAKT) WITH KEY MATNR = <FS>-MATNR.
    IF SY-SUBRC = 0.
      <FS>-MAKTX = LS_MAKT-MAKTX.
    ELSE.
      IF <FS>-MESSAGE IS NOT INITIAL.
        <FS>-MESSAGE = |{ <FS>-MESSAGE } / { TEXT-M02 } |.
      ELSE.
        <FS>-MESSAGE = TEXT-M02.
      ENDIF.
      CLEAR: GS_SCOL.
      GS_SCOL-FNAME = 'MATNR'.
      GS_SCOL-COLOR-COL = '6'.   " 빨간색
      GS_SCOL-COLOR-INT = '0'.   " 강조 여부
      GS_SCOL-COLOR-INV = '0'.   " 반전 여부
      APPEND GS_SCOL TO <FS>-GT_SCOL.
    ENDIF.

    "KRW 통화키로 금액 100배 되는 현상 제거
    PERFORM CURRENCY_CONV USING <FS>-UNITPRICE.
    <FS>-SUM = <FS>-UNITPRICE * <FS>-QUAN.
  ENDLOOP.

  PERFORM CHECK_VALIDATAION.



ENDFORM.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

  IF GO_CONTAINER IS INITIAL.

    CREATE OBJECT GO_CONTAINER
      EXPORTING
        SIDE      = GO_CONTAINER->DOCK_AT_LEFT     " Side to Which Control is Docked
        EXTENSION = 5000.               " Control Extension

    CREATE OBJECT GO_ALV_GRID
      EXPORTING
        I_PARENT = GO_CONTAINER.                 " Parent Container

    PERFORM SET_FCAT.

    PERFORM SET_LAYOUT.

    SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR ALL INSTANCES.

    PERFORM DISPLAY_ALV.

  ELSE.
    GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT .



  GT_FCAT = VALUE #(
            ( COL_POS = 1   FIELDNAME = 'LIGHT'           COLTEXT = 'Light'    )
            ( COL_POS = 10  FIELDNAME = 'VENDOR'          COLTEXT = 'Vendor'    CONVEXIT = 'ALPHA' )
            ( COL_POS = 20  FIELDNAME = 'NAME1'           COLTEXT = 'Name'   )
            ( COL_POS = 30  FIELDNAME = 'MATNR'           COLTEXT = 'Meterial Code'   )
            ( COL_POS = 40  FIELDNAME = 'MAKTX'           COLTEXT = 'Name'   )
            ( COL_POS = 50  FIELDNAME = 'QUAN'            COLTEXT = 'Quantity'   QFIELDNAME = 'UNIT' )
            ( COL_POS = 60  FIELDNAME = 'UNIT'            COLTEXT = 'Unit'   )
            ( COL_POS = 70  FIELDNAME = 'UNITPRICE'       COLTEXT = 'UnitPrice'  CFIELDNAME = 'CURRENCY' )
            ( COL_POS = 80  FIELDNAME = 'SUM'             COLTEXT = 'Sum'        CFIELDNAME = 'CURRENCY')
            ( COL_POS = 90  FIELDNAME = 'CURRENCY'        COLTEXT = 'Currency'     )
            ( COL_POS = 100  FIELDNAME = 'WERKS'             COLTEXT = 'Plant'   )
            ( COL_POS = 110  FIELDNAME = 'LGORT'             COLTEXT = 'Storage Location'   )
            ( COL_POS = 120  FIELDNAME = 'EBELN'             COLTEXT = 'Po'  HOTSPOT = 'X' )
            ( COL_POS = 130  FIELDNAME = 'MESSAGE'           COLTEXT = 'Message'   )

  ).

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-CWIDTH_OPT = 'A'.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CTAB_FNAME = 'GT_SCOL'.
  GS_VARIANT-REPORT = SY-CPROG.
  GV_SAVE = 'A'.
  GS_LAYOUT-SEL_MODE = 'D'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV .

  GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      IS_VARIANT                    = GS_VARIANT                 " Layout
      I_SAVE                        = GV_SAVE                 " Save Layout
*      I_DEFAULT                     = 'X'              " Default Display Variant
      IS_LAYOUT                     =  GS_LAYOUT                " Layout
    CHANGING
      IT_OUTTAB                     = GT_DATA                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
  ).
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_LIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_LIGHT .

  LOOP AT GT_DATA INTO GS_DATA.
    CASE GV_CHECK.
      WHEN 'R'.
        GS_DATA-LIGHT = ICON_RED_LIGHT.
      WHEN 'G'.
        GS_DATA-LIGHT = ICON_GREEN_LIGHT.
      WHEN OTHERS.
        GS_DATA-LIGHT = ICON_YELLOW_LIGHT.
    ENDCASE.

    MODIFY GT_DATA FROM GS_DATA TRANSPORTING LIGHT.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_VALIDATAION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_VALIDATAION .


  CLEAR GS_DATA.
  LOOP AT GT_DATA INTO GS_DATA.

    PERFORM CHECK_QUAN.

    IF GS_DATA-MESSAGE IS INITIAL.
      GS_DATA-LIGHT = ICON_YELLOW_LIGHT.
    ELSE.
      GS_DATA-LIGHT = ICON_RED_LIGHT.
    ENDIF.

    MODIFY GT_DATA FROM GS_DATA TRANSPORTING LIGHT MESSAGE.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_MATNR .

  SELECT MATNR, WERKS
    FROM MARC
    FOR ALL ENTRIES IN @GT_DATA
    WHERE MATNR = @GT_DATA-MATNR
    INTO TABLE @DATA(LT_MATNR).

  READ TABLE LT_MATNR ASSIGNING FIELD-SYMBOL(<FS>) WITH KEY MATNR = GS_DATA-MATNR BINARY SEARCH.
  " Vendor 존재 여부 체크
  IF SY-SUBRC <> 0.
    GS_DATA-LIGHT = ICON_RED_LIGHT.
    GS_DATA-MESSAGE = 'Vendor가 LFA1에 없습니다.'(M03).
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_QUAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_QUAN .

  " QUAN이 0 이하 또는 숫자가 아닌 경우 검사
*  DATA(LV_QUAN_CHAR) = CONV STRING( GS_DATA-QUAN ).
  IF GS_DATA-QUAN <= 0 .

    IF GS_DATA-MESSAGE IS NOT INITIAL.
      GS_DATA-MESSAGE = |{ GS_DATA-MESSAGE } / { TEXT-M03 } |.
    ELSE.
      GS_DATA-MESSAGE = TEXT-M03.
    ENDIF.
    CLEAR: GS_SCOL.
    GS_SCOL-FNAME = 'QUAN'.
    GS_SCOL-COLOR-COL = '6'.   " 빨간색
    GS_SCOL-COLOR-INT = '0'.   " 강조 여부
    GS_SCOL-COLOR-INV = '0'.   " 반전 여부
    APPEND GS_SCOL TO GS_DATA-GT_SCOL.
    MODIFY GT_DATA FROM GS_DATA.

  ENDIF.

  IF GS_DATA-UNITPRICE <= 0.
    IF GS_DATA-MESSAGE IS NOT INITIAL.
      GS_DATA-MESSAGE = |{ GS_DATA-MESSAGE } / { TEXT-M04 } |.
    ELSE.
      GS_DATA-MESSAGE = TEXT-M04.
    ENDIF.

    CLEAR: GS_SCOL.
    GS_SCOL-FNAME = 'UNITPRICE'.
    GS_SCOL-COLOR-COL = '6'.   " 빨간색
    GS_SCOL-COLOR-INT = '0'.   " 강조 여부
    GS_SCOL-COLOR-INV = '0'.   " 반전 여부
    APPEND GS_SCOL TO GS_DATA-GT_SCOL.
    MODIFY GT_DATA FROM GS_DATA.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form BDC_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BDC_DATA
  USING
       VALUE(P_SCREEN)
       VALUE(P_NAME)
       VALUE(P_VALUE).

  DATA
    LS_BDCDATA TYPE BDCDATA.


  IF P_SCREEN EQ 'X'.
    LS_BDCDATA-DYNBEGIN = P_SCREEN.  " BDC screen start "
    LS_BDCDATA-PROGRAM  = P_NAME.    " BDC Program "
    LS_BDCDATA-DYNPRO   = P_VALUE.   " BDC Screen Number "
  ELSE.
    LS_BDCDATA-FNAM     = P_NAME.    " Field Name "
    LS_BDCDATA-FVAL       = P_VALUE. " BDC Field Value "
  ENDIF.

  APPEND LS_BDCDATA TO GT_BDCDATA.

  CLEAR LS_BDCDATA.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_PO .

  SORT GT_DATA BY VENDOR.
  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>).

*--------------------------------------------------------------------*
* 헤더 정보 입력 ( 같은 vendor 코드 당 한번 )
*--------------------------------------------------------------------*
    AT NEW VENDOR.
      DATA(LV_CNT) = 1.
      REFRESH GT_BDCDATA.

      " vendor 코드 입력
      PERFORM BDC_DATA
      USING :
      'X' 'SAPLMEGUI' '0014',
      ' ' 'MEPO_TOPLINE-SUPERFIELD' <LS_DATA>-VENDOR,
      ' ' 'BDC_OKCODE' '/00'.

      " Org 정보 입력
      PERFORM BDC_DATA
      USING :
      'X' 'SAPLMEGUI' '0014',
      ' ' 'MEPO1222-EKORG' P_EKORG,
      ' ' 'MEPO1222-EKGRP' P_EKGRP,
      ' ' 'MEPO1222-BUKRS' P_BUKRS,
      ' ' 'BDC_OKCODE' '=TABHDT1'.

      " 지급 조건 입력
      PERFORM BDC_DATA
      USING :
      'X' 'SAPLMEGUI' '0014',
      ' ' 'MEPO1226-ZTERM' 'CV01',
      ' ' 'BDC_OKCODE' '=MEV4001BUTTON'.

      PERFORM BDC_DATA USING : 'X' 'SAPLMEGUI' '0014',
                               ' ' 'BDC_OKCODE' '/00'.


    ENDAT.

*--------------------------------------------------------------------*
* item 정보 입력
*--------------------------------------------------------------------*

    " 필드명 동적 생성
    DATA(LV_EMATN) = |MEPO1211-EMATN({ LV_CNT })|.   " 자재번호
    DATA(LV_MENGE) = |MEPO1211-MENGE({ LV_CNT })|.   " 수량
    DATA(LV_MEINS) = |MEPO1211-MEINS({ LV_CNT })|.   " 단위
    DATA(LV_NETPR) = |MEPO1211-NETPR({ LV_CNT })|.   " 단가
    DATA(LV_NAME1) = |MEPO1211-NAME1({ LV_CNT })|.   " PLANT
    DATA(LV_LGOBE) = |MEPO1211-LGOBE({ LV_CNT })|.   " STOREGE LACATION

    DATA : LV_QUAN  TYPE C LENGTH 30,
           LV_PRICE TYPE C LENGTH 30.


    WRITE <LS_DATA>-QUAN UNIT <LS_DATA>-UNIT TO LV_QUAN.
    WRITE <LS_DATA>-UNITPRICE CURRENCY <LS_DATA>-CURRENCY TO LV_PRICE.
    CONDENSE : LV_QUAN, LV_PRICE NO-GAPS.

    PERFORM BDC_DATA
        " 아이템 정보 입력
        USING :
        ' ' LV_EMATN <LS_DATA>-MATNR,
        ' ' LV_MENGE LV_QUAN,
        ' ' LV_MEINS <LS_DATA>-UNIT,
        ' ' LV_NETPR LV_PRICE,
        ' ' LV_NAME1 <LS_DATA>-WERKS,
        ' ' LV_LGOBE <LS_DATA>-LGORT.

    LV_CNT += 1.

    " 아이템 다 추가 후 저장
    AT END OF VENDOR.

      PERFORM BDC_DATA
        USING :
        'X' 'SAPLMEGUI' '0014',
        ' ' 'BDC_OKCODE' '=MESAVE'.

      " 옵션 설정
      DATA LS_OPTIONS TYPE CTU_PARAMS.
      LS_OPTIONS-DISMODE  = 'N'.           " 화면 표시 방식 지정 ('A': 전부, 'E': 에러만, 'N': 표시안함)
      LS_OPTIONS-UPDMODE  = 'S'.           " 업데이트 모드를 지정 ('A': 비동기, 'S': 동기, 'L': 로컬)
      LS_OPTIONS-CATTMODE = ' '.           " CATT모드 사용 여부를 결정 ('N': 개별화면 제어가 없는 CATT, 'A': 개별화면 제어가 있는 CATT, ' ': CATT아님)
      LS_OPTIONS-DEFSIZE  = 'X'.           " 기본 윈도우 사이즈 설정 ('X': 예, ' ': 아니오)
      LS_OPTIONS-NOBINPT  = ' '.           " Batch Input Mode 사용안함 ('X': 예, ' ': 아니오)
      LS_OPTIONS-NOBIEND  = ' '.           " 배치 돌릴때 에러 발생시 Foreground로 전환, DISMODE가 'E'일 때만 사용가능 ('X': 예, ' ': 아니오)
      LS_OPTIONS-DEFSIZE  = 'X'.           " 기본 윈도우 사이즈 설정 ('X': 예, ' ': 아니오)


      " 실행
      CALL TRANSACTION 'ME21N' USING GT_BDCDATA OPTIONS FROM LS_OPTIONS MESSAGES INTO GT_BDCMSG.

      " MESSAGE
      PERFORM BDC_MESSAGE USING <LS_DATA>-VENDOR.

    ENDAT.
  ENDLOOP.

  LEAVE TO SCREEN 0100. " REFRESH 대신 사용. 필드 카탈로그, 레이아웃 다 적용시키기 위함.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BDC_MESSAGE USING PV_VENDOR.

  DATA: LV_INDEX    TYPE SY-TABIX,
*        LS_MSG TYPE BDCMSGCOLL,
        LV_MSG      TYPE STRING,
        LV_FULL_MSG TYPE STRING,
        LV_PO       TYPE EKKO-EBELN.


  DESCRIBE TABLE GT_BDCMSG LINES LV_INDEX.

  READ TABLE GT_BDCMSG INTO DATA(LS_BDCMSG) INDEX LV_INDEX.
*    IF sy-subrc <> 0.
*    READ TABLE GT_BDCMSG WITH KEY msgtyp = 'E'.
*  ENDIF.

  LOOP AT GT_DATA ASSIGNING FIELD-SYMBOL(<LS_DATA>) WHERE VENDOR = PV_VENDOR.
    IF    LS_BDCMSG-MSGTYP = 'S'
      AND LS_BDCMSG-MSGID = '06'
      AND LS_BDCMSG-MSGNR = '017'.

      <LS_DATA>-LIGHT = ICON_GREEN_LIGHT.
      <LS_DATA>-EBELN = LS_BDCMSG-MSGV2.
    ELSE.

      <LS_DATA>-LIGHT = ICON_RED_LIGHT.
    ENDIF.

    " 메시지 텍스트 변환
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = LS_BDCMSG-MSGID
        MSGNR               = LS_BDCMSG-MSGNR
        MSGV1               = LS_BDCMSG-MSGV1
        MSGV2               = LS_BDCMSG-MSGV2
        MSGV3               = LS_BDCMSG-MSGV3
        MSGV4               = LS_BDCMSG-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = <LS_DATA>-MESSAGE.
    GV_CHECK = 'X'. " Execute 버튼 비활성화용
    CLEAR : GT_BDCMSG.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form COV_INTERNAL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> UNITPRICE
*&---------------------------------------------------------------------*
FORM CURRENCY_CONV  USING    PV_VALUE.
  DATA: EXTERNAL LIKE BAPICURR-BAPICURR.

  EXTERNAL = PV_VALUE.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
    EXPORTING
      CURRENCY             = 'KRW'   "한국 통화로
      AMOUNT_EXTERNAL      = EXTERNAL
      MAX_NUMBER_OF_DIGITS = 15
    IMPORTING
      AMOUNT_INTERNAL      = EXTERNAL.

  PV_VALUE = EXTERNAL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_HEADER_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_HEADER_DATA .

*  DATA(lv_loekz_cond) = COND string(
*                        WHEN p_check = 'X'
*                        THEN ''
*                        ELSE 'AND A~LOEKZ IS INITIAL AND B~LOEKZ IS INITIAL' ).
*
*  DATA(lv_query) = | SELECT DISTINCT
*                     B~WERKS,
*                     A~LIFNR,
*                     C~NAME1,
*                     COUNT( A~EBELN ) AS COUNT_PO,
*                     SUM( B~MENGE ) AS TOTAL_QUAN,
*                     B~MEINS,
*                     SUM( B~NETWR ) AS TOTAL_PRICE ,     " 총 금액
*                     A~WAERS
*                  FROM EKKO AS A
*                  JOIN EKPO AS B ON A~EBELN = B~EBELN
*                  JOIN LFA1 AS C ON A~LIFNR = C~LIFNR
*                  JOIN EKET AS D ON A~EBELN = D~EBELN AND B~EBELP = D~EBELP
*                 WHERE B~WERKS IN @s_werks
*                   AND B~MATNR IN @s_matnr
*                   AND A~LIFNR IN @s_lifnr
*                   AND A~EBELN IN @s_ebeln
*                   AND A~BEDAT IN @s_bedat
*                   AND D~EINDT IN @s_eindt
*                   { lv_loekz_cond }
*                 GROUP BY
*                     A~LIFNR, B~WERKS, C~NAME1, A~WAERS, B~MEINS
*                 ORDER BY A~LIFN|.
*
**EXEC SQL.
**  PERFORMING move_to_itab INTO GT_HEADER
**  { lv_query }
**ENDEXEC.


  CASE P_CHECK.
    WHEN 'X'. " 삭제 포함 LOEKZ 필드에 'X'
      SELECT DISTINCT
         B~WERKS       ,     " 플렌트
         A~LIFNR        ,    " Vendor
         C~NAME1       ,     " Vendor 이름
         COUNT( A~EBELN ) AS COUNT_PO,  " PO 건수
         SUM( B~MENGE ) AS TOTAL_QUAN  ,     " 총 수량
         MEINS       ,     " 수량 단위
         SUM( B~NETWR ) AS TOTAL_PRICE ,     " 총 금액
         A~WAERS          " 통화
    FROM EKKO AS A
    JOIN EKPO AS B ON A~EBELN = B~EBELN
    JOIN LFA1 AS C ON A~LIFNR = C~LIFNR
    JOIN EKET AS D ON A~EBELN = D~EBELN AND B~EBELP = D~EBELP
   WHERE  B~WERKS IN @S_WERKS
     AND  B~MATNR IN @S_MATNR
     AND  A~LIFNR IN @S_LIFNR
     AND  A~EBELN IN @S_EBELN
     AND  A~BEDAT IN @S_BEDAT
     AND  D~EINDT IN @S_EINDT

      GROUP BY
               A~LIFNR ,
               B~WERKS,
               C~NAME1,
               A~WAERS,
               B~MEINS
    ORDER BY A~LIFNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_HEADER.


    WHEN OTHERS.
      SELECT DISTINCT
       B~WERKS       ,     " 플렌트
       A~LIFNR        ,    " Vendor
       C~NAME1       ,     " Vendor 이름
       COUNT( B~EBELN ) AS COUNT_PO,  " PO 건수
       SUM( B~MENGE ) AS TOTAL_QUAN  ,     " 총 수량
       MEINS       ,     " 수량 단위
       SUM( B~MENGE * B~NETPR ) AS TOTAL_PRICE ,     " 총 금액
       A~WAERS          " 통화
  FROM EKKO AS A
  JOIN EKPO AS B ON A~EBELN = B~EBELN
  JOIN LFA1 AS C ON A~LIFNR = C~LIFNR
  JOIN EKET AS D ON A~EBELN = D~EBELN AND B~EBELP = D~EBELP
 WHERE  B~WERKS IN @S_WERKS
   AND  B~MATNR IN @S_MATNR
   AND  A~LIFNR IN @S_LIFNR
   AND  A~EBELN IN @S_EBELN
   AND  A~BEDAT IN @S_BEDAT
   AND  D~EINDT IN @S_EINDT
   AND  A~LOEKZ IS INITIAL
   AND  B~LOEKZ IS INITIAL
    GROUP BY
             A~LIFNR,
             B~WERKS,
             C~NAME1,
             A~WAERS,
             B~MEINS

  ORDER BY A~LIFNR
  INTO CORRESPONDING FIELDS OF TABLE @GT_HEADER.

  ENDCASE.

*  CL_DEMO_OUTPUT=>WRITE( DATA = GT_HEADER  ).
*  CL_DEMO_OUTPUT=>DISPLAY( ).

  PERFORM MODIFY_BUTTON.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT_0200 .

  CREATE OBJECT GO_DOCKING
    EXPORTING
      SIDE      = GO_DOCKING->DOCK_AT_LEFT     " Side to Which Control is Docked
      EXTENSION = 5000.               " Control Extension

  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING                   " Parent Container
      ROWS    = 2                   " Number of Rows to be displayed
      COLUMNS = 1.                   " Number of Columns to be Displayed

  GO_SPLITTER->GET_CONTAINER(
    EXPORTING
      ROW       = 1                 " Row
      COLUMN    = 1                 " Column
    RECEIVING
      CONTAINER = GO_CON1                 " Container
  ).

  GO_SPLITTER->GET_CONTAINER(
    EXPORTING
      ROW       = 2                  " Row
      COLUMN    = 1                 " Column
    RECEIVING
      CONTAINER = GO_CON2                 " Container
  ).

  CREATE OBJECT GO_ALV_GRID1
    EXPORTING
      I_PARENT = GO_CON1.                 " Parent Container

  CREATE OBJECT GO_ALV_GRID2
    EXPORTING
      I_PARENT = GO_CON2.                 " Parent Container

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV_0200 .

  GO_ALV_GRID1->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT1                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_HEADER                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT1                 " Field Catalog
).
  GO_ALV_GRID2->SET_TABLE_FOR_FIRST_DISPLAY(
  EXPORTING
    IS_LAYOUT                     = GS_LAYOUT2                 " Layout
  CHANGING
    IT_OUTTAB                     = GT_ITEM                 " Output Table
    IT_FIELDCATALOG               = GT_FCAT2                 " Field Catalog
).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT_0200 .

*
  GT_FCAT1 = VALUE #(
  ( COL_POS = 1   FIELDNAME = 'BTN_ICON' COLTEXT = '상세정보' OUTPUTLEN = 5 JUST = 'C'  )
  ( COL_POS = 10  FIELDNAME = 'WERKS'   REF_TABLE = 'EKPO'      COLTEXT = '플랜트'    )
  ( COL_POS = 20  FIELDNAME = 'LIFNR'   REF_TABLE = 'EKKO'     COLTEXT = '공급업체'    )
  ( COL_POS = 30  FIELDNAME = 'NAME1'  REF_TABLE = 'LFA1'     COLTEXT = '공급업체 이름'   )
  ( COL_POS = 40  FIELDNAME = 'COUNT_PO'    COLTEXT = 'PO건수'   )
  ( COL_POS = 50  FIELDNAME = 'TOTAL_QUAN'  REF_TABLE = 'EKPO'   REF_FIELD = 'NETPR'   COLTEXT = '총 수량'  QFIELDNAME = 'MEINS' )
  ( COL_POS = 60  FIELDNAME = 'MEINS'  REF_TABLE = 'EKPO'     COLTEXT = '단위'   )
  ( COL_POS = 70  FIELDNAME = 'TOTAL_PRICE'  REF_TABLE = 'EKPO'  REF_FIELD = 'NETWR'   COLTEXT = '총 금액'  CFIELDNAME = 'WAERS' )
  ( COL_POS = 80  FIELDNAME = 'WAERS'  REF_TABLE = 'EKKO'      COLTEXT = '통화'   )
  ).

  GT_FCAT2 = VALUE #(
    ( COL_POS = 1  FIELDNAME = 'STATUS' ICON = 'X' COLTEXT = '상태'    )
    ( COL_POS = 10  FIELDNAME = 'CHECK' CHECKBOX = 'X'      EDIT = 'X' COLTEXT = '체크박스'   )
    ( COL_POS = 20  FIELDNAME = 'EBELN'  REF_TABLE = 'EKKO'    COLTEXT = '구매오더번호'   )
    ( COL_POS = 30  FIELDNAME = 'EBELP'   REF_TABLE = 'EKPO'    COLTEXT = '구매오더품목'    )
    ( COL_POS = 40  FIELDNAME = 'MATNR'  REF_TABLE = 'EKPO'     COLTEXT = '자재'   )
    ( COL_POS = 50  FIELDNAME = 'MAKTX'  REF_TABLE = 'MAKT'     COLTEXT = '자재내역'   )
    ( COL_POS = 60  FIELDNAME = 'MENGE'  REF_TABLE = 'EKPO'   EDIT = 'X'  COLTEXT = '수량'   QFIELDNAME = 'MEINS' )
    ( COL_POS = 70  FIELDNAME = 'MEINS'  REF_TABLE = 'EKPO'     COLTEXT = '단위'   )
    ( COL_POS = 80  FIELDNAME = 'NETPR'  REF_TABLE = 'EKPO'   EDIT = 'X'  COLTEXT = '금액'   CFIELDNAME = 'WAERS'  )
    ( COL_POS = 90  FIELDNAME = 'WAERS'  REF_TABLE = 'EKKO'     COLTEXT = '통화'   )
    ( COL_POS = 100  FIELDNAME = 'NETWR'  REF_TABLE = 'EKPO'     COLTEXT = '총액'   CFIELDNAME = 'WAERS' )
    ( COL_POS = 110  FIELDNAME = 'EINDT'  REF_TABLE = 'EKET'  EDIT = 'X'   COLTEXT = '납품일'   )
    ( COL_POS = 120  FIELDNAME = 'BEDAT'  REF_TABLE = 'EKKO'     COLTEXT = '증빙일 '   )
    ( COL_POS = 130  FIELDNAME = 'MESSAGE'  HOTSPOT = 'X' COLTEXT = '메시지 '   )
    ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MODIFY_BUTTON
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_BUTTON .


  DATA: LT_STYLE TYPE LVC_T_STYL,
        LS_STYLE TYPE LVC_S_STYL.

  CLEAR GS_HEADER.
  LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<FS>).

    <FS>-BTN_ICON = ICON_ENTER_MORE.  " 초기 ICON 모양 세팅

    LT_STYLE = VALUE #(
      ( FIELDNAME = 'BTN_ICON'
        STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON
        )
    ).

    <FS>-STYLE = LT_STYLE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_0200 .

  CLEAR GS_LAYOUT1.
  GS_LAYOUT1-CWIDTH_OPT = 'A'.
  GS_LAYOUT1-STYLEFNAME = 'STYLE'.

  CLEAR GS_LAYOUT2.
  GS_LAYOUT2-CWIDTH_OPT = 'A'.
  GS_LAYOUT2-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_ITEM USING PS_HEADER LIKE GS_HEADER PV_ROW_ID.

  CASE P_CHECK.
    WHEN 'X'.
      PERFORM INCLUDE_LOEKZ USING PS_HEADER.  " 삭제 지시자 포함
    WHEN OTHERS.
      PERFORM EXCLUDE_LOEKZ USING PS_HEADER.  " 삭제 지시자 미포함
  ENDCASE.




  IF SY-SUBRC = 0.
    "  모든 행 아이콘 초기화
    LOOP AT GT_HEADER ASSIGNING FIELD-SYMBOL(<FS_HEADER>).
      <FS_HEADER>-BTN_ICON = ICON_ENTER_MORE. " 기본값
    ENDLOOP.

    "  클릭된 행만 변경
    READ TABLE GT_HEADER ASSIGNING FIELD-SYMBOL(<FS_SEL_HEADER>) INDEX PV_ROW_ID.
    IF SY-SUBRC = 0.
      <FS_SEL_HEADER>-BTN_ICON = ICON_DISPLAY_MORE.
    ENDIF.

    PERFORM REFRESH_ALV_0200.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER_0200 .

  SET HANDLER LCL_EVENT_HANDLER=>ON_BUTTON_CLICK FOR GO_ALV_GRID1.
  SET HANDLER LCL_EVENT_HANDLER=>ON_TOOLBAR1 FOR GO_ALV_GRID1.
  SET HANDLER LCL_EVENT_HANDLER=>ON_TOOLBAR2 FOR GO_ALV_GRID2.
  SET HANDLER LCL_EVENT_HANDLER=>ON_USER_COMMAND FOR ALL INSTANCES.
  SET HANDLER LCL_EVENT_HANDLER=>ON_DATA_CHANGED FOR GO_ALV_GRID2.
  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR ALL INSTANCES.
  SET HANDLER LCL_EVENT_HANDLER=>ON_DOUBLE_CLICK FOR GO_ALV_GRID2.

  CALL METHOD GO_ALV_GRID2->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.                 " Event ID

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV_0200 .

  GO_ALV_GRID1->REFRESH_TABLE_DISPLAY( ).
  GO_ALV_GRID2->REFRESH_TABLE_DISPLAY( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form MODIFY_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> P_
*&      --> LV_MEINS
*&      --> ENDMETHOD
*&---------------------------------------------------------------------*
FORM MODIFY_ITEM  USING    PR_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                           P_FIELDNAME
                           P_VALUE.

  LOOP AT PR_DATA_CHANGED->MT_GOOD_CELLS ASSIGNING FIELD-SYMBOL(<FS_CELLS>).
    CALL METHOD PR_DATA_CHANGED->GET_CELL_VALUE
      EXPORTING
        I_ROW_ID    = <FS_CELLS>-ROW_ID                 " Row ID
        I_FIELDNAME = P_FIELDNAME                 " Field Name
      IMPORTING
        E_VALUE     = P_VALUE.                 " Cell Content

    CHECK P_VALUE IS NOT INITIAL.
    " GT_ITEM에서 해당 row 찾아서 반영
    READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>)
      INDEX <FS_CELLS>-ROW_ID.
    IF SY-SUBRC = 0 AND <FS_CELLS>-FIELDNAME <> 'CHECK'.
      ASSIGN COMPONENT P_FIELDNAME OF STRUCTURE <FS_ITEM> TO FIELD-SYMBOL(<FS_FIELD>).
      IF SY-SUBRC = 0.
        <FS_FIELD> = P_VALUE.
        <FS_ITEM>-STATUS = ICON_LED_YELLOW.
        <FS_ITEM>-NETWR = <FS_ITEM>-NETPR * <FS_ITEM>-MENGE.
      ENDIF.
    ENDIF.

  ENDLOOP.

  GO_ALV_GRID2->REFRESH_TABLE_DISPLAY( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_ITEM .

  GO_ALV_GRID2->CHECK_CHANGED_DATA( ).

  SORT GT_ITEM BY EBELN.

  DATA: LT_RETURN   TYPE TABLE OF BAPIRET2,
        LS_RETURN   TYPE BAPIRET2,
        LT_POITEM   TYPE TABLE OF BAPIMEPOITEM,    " 아이템 값
        LT_POITEMX  TYPE TABLE OF BAPIMEPOITEMX,   " 아이템 값 변경 플래그
        LT_POSCHED  TYPE TABLE OF BAPIMEPOSCHEDULE, " 스케줄 값
        LT_POSCHEDX TYPE TABLE OF BAPIMEPOSCHEDULX, " 스케줄 값 변경 플래그
        LS_POITEM   TYPE BAPIMEPOITEM,
        LS_POITEMX  TYPE BAPIMEPOITEMX.
  DATA : LV_NETPR TYPE C LENGTH 30.

  DATA: LT_ITEM LIKE GT_ITEM.

*  1. 변경 대상 아이템만 추출
  CLEAR GS_ITEM.
  LOOP AT GT_ITEM INTO GS_ITEM WHERE CHECK = 'X' AND STATUS = ICON_LED_YELLOW.
    APPEND GS_ITEM TO LT_ITEM.
  ENDLOOP.

  SORT LT_ITEM BY EBELN EBELP.

* 2. 방금 가져온 값에 대해 루프를 돌려 BAPI 실행
  LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).

    IF <FS_ITEM>-STATUS = ICON_LED_YELLOW .

* NET PRICE CURRENCY에 맞게 CUARRENCY 적용 후 넣기
      WRITE <FS_ITEM>-NETPR CURRENCY <FS_ITEM>-WAERS TO LV_NETPR.
      CONDENSE LV_NETPR NO-GAPS.
      REPLACE ALL OCCURRENCES OF ',' IN LV_NETPR WITH ''.

* 수량 필드 및 단가가 0 일때 아이템 삭제
      IF <FS_ITEM>-MENGE = 0 .
        LS_POITEM  = VALUE #( PO_ITEM = <FS_ITEM>-EBELP
                              DELETE_IND = 'X' ).
        LS_POITEMX = VALUE #( PO_ITEM = <FS_ITEM>-EBELP
                              DELETE_IND = 'X' ).
      ELSE.

* BAPI에 전달할 수량, 단가 데이터 채우기
        LS_POITEM = VALUE #( PO_ITEM = <FS_ITEM>-EBELP
                             QUANTITY = <FS_ITEM>-MENGE
                             NET_PRICE = LV_NETPR ).
        LS_POITEMX = VALUE #( PO_ITEM = <FS_ITEM>-EBELP
                              QUANTITY = 'X'
                              NET_PRICE = 'X' ).

* 납품일 데이터 채우기
        DATA(LS_POSCHED) = VALUE BAPIMEPOSCHEDULE( PO_ITEM = <FS_ITEM>-EBELP  DELIVERY_DATE = <FS_ITEM>-EINDT ).
        DATA(LS_POSCHEDX) = VALUE BAPIMEPOSCHEDULX( PO_ITEM = <FS_ITEM>-EBELP  DELIVERY_DATE = 'X' ).
        APPEND LS_POSCHED TO LT_POSCHED.
        APPEND LS_POSCHEDX TO LT_POSCHEDX.

      ENDIF.

      APPEND LS_POITEM TO LT_POITEM.
      APPEND LS_POITEMX TO LT_POITEMX.

* 같은 EBELN에 대해 단위 처리
      AT END OF EBELN.

        " BAPI  호출
        IF LT_POITEM IS NOT INITIAL.
          CALL FUNCTION 'BAPI_PO_CHANGE'
            EXPORTING
              PURCHASEORDER = <FS_ITEM>-EBELN                 " Purchasing Document Number
            TABLES
              RETURN        = LT_RETURN                 " Return Parameter
              POITEM        = LT_POITEM                 " Item Data
              POITEMX       = LT_POITEMX                " Item Data (Change Parameter)
              POSCHEDULE    = LT_POSCHED                 " Delivery Schedule
              POSCHEDULEX   = LT_POSCHEDX.                 " Delivery Schedule (Change Parameter)

          IF LT_RETURN IS NOT INITIAL.

            " 결과 메시지 매핑 (같은 EBELN 아이템 전체)
            LOOP AT LT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM_REF>)
                 WHERE EBELN = <FS_ITEM>-EBELN.

              READ TABLE LT_RETURN INTO LS_RETURN INDEX 1.
              IF SY-SUBRC = 0 AND LS_RETURN-TYPE = 'S'.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    WAIT = 'X'.

                <FS_ITEM_REF>-STATUS  = ICON_LED_GREEN.
                <FS_ITEM_REF>-MESSAGE = LS_RETURN-MESSAGE.
                <FS_ITEM_REF>-RETURN_MSG[] = LT_RETURN[].

                " 고정단가 오류 메시지 체크
                READ TABLE LT_RETURN INTO LS_RETURN
                     WITH KEY ID = 'ME' NUMBER = '664'
                              ROW = <FS_ITEM_REF>-EBELP / 10.
                IF SY-SUBRC = 0 .
                  <FS_ITEM_REF>-STATUS  = ICON_LED_RED.
                  <FS_ITEM_REF>-MESSAGE = LS_RETURN-MESSAGE.
                ENDIF.

              ELSE.
                CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

                <FS_ITEM_REF>-STATUS  = ICON_LED_RED.
                <FS_ITEM_REF>-MESSAGE = LS_RETURN-MESSAGE.
                <FS_ITEM_REF>-RETURN_MSG[] = LT_RETURN[].
              ENDIF.

              " GT_ITEM 동기화
              READ TABLE GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_GT_ITEM>)
                   WITH KEY EBELN = <FS_ITEM_REF>-EBELN
                            EBELP = <FS_ITEM_REF>-EBELP.
              IF SY-SUBRC = 0.
                <FS_GT_ITEM>-STATUS     = <FS_ITEM_REF>-STATUS.
                <FS_GT_ITEM>-MESSAGE    = <FS_ITEM_REF>-MESSAGE.
                <FS_GT_ITEM>-RETURN_MSG = <FS_ITEM_REF>-RETURN_MSG.
              ENDIF.

            ENDLOOP.
          ENDIF.
          "테이블 초기화
          CLEAR: LT_POITEM[], LT_POITEMX[], LT_POSCHED[], LT_POSCHEDX[].
          REFRESH: LT_POITEM, LT_POITEMX, LT_POSCHED, LT_POSCHEDX.

        ENDIF.
      ENDAT.
    ENDIF.
  ENDLOOP.

  PERFORM SELECT_HEADER_DATA.
  PERFORM REFRESH_ALV_0200.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form LOCK_CELL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM LOCK_CELL .

  DATA LS_STYLE TYPE LVC_S_STYL.
  DATA LT_STYLE TYPE LVC_T_STYL.

  CLEAR LT_STYLE.

  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) WHERE STATUS = ICON_LED_GREEN.

    LS_STYLE-FIELDNAME = 'CHECK'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

    CLEAR LS_STYLE.
    LS_STYLE-FIELDNAME = 'MENGE'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

    CLEAR LS_STYLE.
    LS_STYLE-FIELDNAME = 'EINDT'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

    CLEAR LS_STYLE.
    LS_STYLE-FIELDNAME = 'NETPR'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_LOEKZ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_LOEKZ USING PS_HEADER LIKE GS_HEADER.

  SELECT DISTINCT
             A~EBELN ,     " 구매오더번호
             B~EBELP ,     " 구매오더품목
             B~MATNR ,     " 자재번호
             MAKTX ,     " 자재명
             B~MENGE ,
             B~MEINS ,     " 수량 단위
             B~NETPR ,     " 순 오더금액
             A~WAERS ,     " 통화
             B~NETWR ,     " 총 금액
             EINDT ,     "납품일
             A~BEDAT       "증빙일

      FROM EKKO AS A
      JOIN EKPO AS B ON A~EBELN = B~EBELN
      LEFT JOIN MAKT AS C ON B~MATNR = C~MATNR
                    AND C~SPRAS = @SY-LANGU
      JOIN EKET AS D ON B~EBELN = D~EBELN
                    AND B~EBELP = D~EBELP
      JOIN LFA1 AS E ON A~LIFNR = E~LIFNR
       WHERE  B~WERKS IN @S_WERKS
       AND  B~MATNR IN @S_MATNR
       AND  A~LIFNR IN @S_LIFNR
       AND  A~EBELN IN @S_EBELN
       AND  A~BEDAT IN @S_BEDAT
       AND  D~EINDT IN @S_EINDT
       AND  A~LIFNR = @PS_HEADER-LIFNR
       AND  A~WAERS = @PS_HEADER-WAERS
       AND  B~WERKS = @PS_HEADER-WERKS
       AND  B~LOEKZ IS INITIAL
      ORDER BY A~EBELN, B~EBELP
      INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.


  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>).
    <FS_ITEM>-STATUS = ICON_LED_INACTIVE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INCLUDE_LOEKZ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INCLUDE_LOEKZ USING PS_HEADER LIKE GS_HEADER.

  DATA LS_STYLE TYPE LVC_S_STYL.

  SELECT DISTINCT
             A~EBELN ,     " 구매오더번호
             B~EBELP ,     " 구매오더품목
             B~MATNR ,     " 자재번호
             MAKTX ,       " 자재명
             B~MENGE ,     " 수량
             B~MEINS ,     " 수량 단위
             B~NETPR ,     " 순 오더금액
             A~WAERS ,     " 통화
             B~NETWR ,     " 총 금액
             EINDT ,       "납품일
             A~BEDAT,      "증빙일
             B~LOEKZ       " 삭제 지시자
      FROM EKKO AS A
      JOIN EKPO AS B ON A~EBELN = B~EBELN
      LEFT JOIN MAKT AS C ON B~MATNR = C~MATNR
                    AND C~SPRAS = @SY-LANGU
      JOIN EKET AS D ON B~EBELN = D~EBELN
                    AND B~EBELP = D~EBELP
      JOIN LFA1 AS E ON A~LIFNR = E~LIFNR
       WHERE  B~WERKS IN @S_WERKS
       AND  B~MATNR IN @S_MATNR
       AND  A~LIFNR IN @S_LIFNR
       AND  A~EBELN IN @S_EBELN
       AND  A~BEDAT IN @S_BEDAT
       AND  D~EINDT IN @S_EINDT
       AND  A~LIFNR = @PS_HEADER-LIFNR
       AND  A~WAERS = @PS_HEADER-WAERS
       AND  B~WERKS = @PS_HEADER-WERKS
      ORDER BY A~EBELN, B~EBELP
      INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.



  LOOP AT GT_ITEM ASSIGNING FIELD-SYMBOL(<FS_ITEM>) WHERE LOEKZ IS NOT INITIAL .

    LS_STYLE-FIELDNAME = 'CHECK'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

    CLEAR LS_STYLE.
    LS_STYLE-FIELDNAME = 'MENGE'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

    CLEAR LS_STYLE.
    LS_STYLE-FIELDNAME = 'NETPR'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

    CLEAR LS_STYLE.
    LS_STYLE-FIELDNAME = 'EINDT'.
    LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
    INSERT LS_STYLE INTO TABLE <FS_ITEM>-CELLTAB.

    <FS_ITEM>-STATUS = ICON_LED_RED.
    <FS_ITEM>-MESSAGE = '삭제된 데이터입니다.'.

  ENDLOOP.

ENDFORM.
