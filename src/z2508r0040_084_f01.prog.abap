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

  IF GT_DATA IS NOT INITIAL.

    " 거래처명 (NAME1) 조회
    SELECT LIFNR, NAME1
      FROM LFA1
      FOR ALL ENTRIES IN @GT_DATA" INIT CHECK 필요 ::
*                                -> 안하면 덤프나요
      WHERE LIFNR = @GT_DATA-VENDOR
      INTO TABLE @DATA(LT_VENDOR).

  ENDIF.



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

    SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID.

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
      ' ' 'BDC_OKCODE' '/00',

*      " Org 정보 입력
*      PERFORM BDC_DATA
*      USING :
      'X' 'SAPLMEGUI' '0014',
      ' ' 'MEPO1222-EKORG' P_EKORG,
      ' ' 'MEPO1222-EKGRP' P_EKGRP,
      ' ' 'MEPO1222-BUKRS' P_BUKRS,
      ' ' 'BDC_OKCODE' '=TABHDT1',

*      " 지급 조건 입력
*      PERFORM BDC_DATA
*      USING :
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
