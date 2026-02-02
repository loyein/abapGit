*&---------------------------------------------------------------------*
*& Include          Z2508R0030_084_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_DATA_HEADER .

  CLEAR GS_HEADER.

  SELECT SINGLE
         A~VBELN,       " 판매오더
         A~KUNNR,
         NAME1,
         BSTNK ,      " 참조번호
         NETWR ,      " 총액
         WAERK,
         VDATU ,      " 배송 요청일
         B~ZTERM ,      " 지급조건
         INCO1       " 인도조건

    FROM VBAK AS A
    JOIN VBKD AS B ON A~VBELN = B~VBELN
*    AND B~POSNR IS NULL
    JOIN KNA1 AS C ON A~KUNNR = C~KUNNR

    WHERE A~VBELN IN @S_VBELN
    INTO CORRESPONDING FIELDS OF @GS_HEADER.

  SELECT SINGLE
    BUTXT ,      " 사명
    TEL_NUMBER , " 회사 전화번호
    ( CITY1 && STREET ) AS CITY        " 회사 주소
  FROM T001 AS A
  JOIN ADRC AS B ON A~ADRNR = B~ADDRNUMBER
    WHERE A~BUKRS IN @S_BUKRS
    INTO CORRESPONDING FIELDS OF @GS_HEADER.

*  IF SY-SUBRC = 0.
*    CL_DEMO_OUTPUT=>WRITE( DATA = GS_HEADER ).
*    CL_DEMO_OUTPUT=>DISPLAY( ).
*  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SELECT_DATA_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_DATA_ITEM .

  CLEAR GT_ITEM.
  SELECT  A~POSNR,    " 항번
  A~MATNR,    " 자재번호
  B~MAKTX,    " 자재명
  A~NETPR,    " 단가
  A~WAERK,    " 통화
  A~KWMENG,   " 수량
  A~MEINS,    " 수량 단위
  ( NETPR * KWMENG ) AS TOTAL,    " 금액
  C~LGOBE    " 창고명
FROM VBAP AS A
LEFT JOIN MAKT AS B ON A~MATNR = B~MATNR AND B~SPRAS = @SY-LANGU
LEFT JOIN T001L AS C ON A~LGORT = C~LGORT AND A~WERKS = C~WERKS
WHERE A~VBELN IN @S_VBELN
ORDER BY POSNR
INTO CORRESPONDING FIELDS OF TABLE @GT_ITEM.

*  CL_DEMO_OUTPUT=>WRITE( DATA = GT_ITEM ).
*  CL_DEMO_OUTPUT=>DISPLAY( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_DATA .

  IF GS_HEADER IS NOT INITIAL AND GT_ITEM IS NOT INITIAL.



    PERFORM SET_SAVE_PATH CHANGING GV_SAVEPATH.   " 저장 경로 설정

    PERFORM SAVE_TEMPLATE USING GV_SAVEPATH.      " SMW0에서 템플릿 가져오기

    PERFORM SET_EXCEL_DATA USING GV_SAVEPATH.


  ELSE.
    RETURN.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SAVE_TEMPLATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_SAVEPATH
*&---------------------------------------------------------------------*
FORM SAVE_TEMPLATE  USING  PV_SAVEPATH .
  DATA: LS_WWWDATA TYPE WWWDATATAB,
        LV_FILE    TYPE RLGRAP-FILENAME.

  SELECT SINGLE * INTO CORRESPONDING FIELDS OF LS_WWWDATA
    FROM WWWDATA
    WHERE OBJID = 'Z2508R0030_084'.

  LV_FILE = PV_SAVEPATH.

  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = LS_WWWDATA
      DESTINATION = LV_FILE
    EXCEPTIONS
      OTHERS      = 1.

  IF SY-SUBRC <> 0.
    MESSAGE '템플릿 다운로드 실패' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_EXCEL_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_TEMPLATE_PATH
*&---------------------------------------------------------------------*
FORM SET_EXCEL_DATA  USING    PV_SAVEPATH.

  DATA: LO_EXCEL     TYPE OLE2_OBJECT,
        LO_WORKBOOKS TYPE OLE2_OBJECT,
        LO_WORKBOOK  TYPE OLE2_OBJECT,
        LO_COLUMNS   TYPE OLE2_OBJECT.

  CREATE OBJECT LO_EXCEL 'Excel.Application'.
  SET PROPERTY OF LO_EXCEL 'Visible' = 0.     " 엑셀 화면 보이게 설정 : 1 안보이게 설정 : 0

  CALL METHOD OF LO_EXCEL 'Workbooks' = LO_WORKBOOKS.
  CALL METHOD OF LO_WORKBOOKS 'Open' = LO_WORKBOOK
    EXPORTING
      #1 = PV_SAVEPATH.

  CALL METHOD OF LO_EXCEL 'ActiveSheet' = GO_SHEET.  " worksheet로도 이름을 짓고 , 이때 엑셀이 불러와짐
  SET PROPERTY OF GO_SHEET 'NAME' = '판매오더 내역'.     " 시트 이름 세팅

*--------------------------------------------------------------------*
* 헤더 값 세팅
*--------------------------------------------------------------------*

  PERFORM SET_HEADER_CELLS.

*--------------------------------------------------------------------*
* ITEM 값 세팅
*--------------------------------------------------------------------*

  PERFORM INSERT_ROWS. " GT_ITEM 행 수에 따라 행 INSERT

  PERFORM SET_ITEM.    " ITEM 테이블 값 입력

  " 입력된 값에 대한 컬럼 폭 맞추기
  CALL METHOD OF GO_SHEET 'COLUMNS' = LO_COLUMNS.
  CALL METHOD OF LO_COLUMNS 'AUTOFIT'.


*** Excel 저장
**  CALL METHOD OF LO_WORKBOOK 'Save' .
***       EXPORTING #1 = PV_SAVEPATH . " SaveAS를 사용하면 다른 경로로 저장 가능
**
**
***PDF 전환 설정
**  DATA : LO_PAGESETUP TYPE OLE2_OBJECT.
**
**  GET PROPERTY OF GO_SHEET 'PAGESETUP' = LO_PAGESETUP.
**  SET PROPERTY OF LO_PAGESETUP 'ORIENTATION' = 2.  " 세로 = 1 (default) , 가로 = 2
**  SET PROPERTY OF LO_PAGESETUP'ZOOM' = ABAP_FALSE.  " 폭 맞춰 출력하기. ( 필드 안짤리고 나옴 )
**
**  DATA(LV_PDF_PATH) = SUBSTRING_BEFORE( VAL = PV_SAVEPATH SUB = '.' ). " 전체 경로에서 .xlsm 제거
***  REPLACE '.xlsx' IN PV_SAVEPATH WITH '.pdf'. ".pdf 안써도 상관은 없음.
**  CALL METHOD OF LO_WORKBOOK 'ExportAsFixedFormat'
**    EXPORTING
**      #1 = 0              " 파일형식 pdf
**      #2 = LV_PDF_PATH.

  " 닫기 및 종료
  CALL METHOD OF LO_WORKBOOK 'Close'.
  CALL METHOD OF LO_EXCEL 'Quit'.

  " 객체 해제
  FREE OBJECT LO_EXCEL.
  FREE OBJECT LO_WORKBOOKS.
  FREE OBJECT LO_WORKBOOK.
  FREE OBJECT GO_SHEET.
  FREE OBJECT GO_CELL.
  FREE OBJECT LO_COLUMNS.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_HEADER  USING    VALUE(P_ROW)
                          VALUE(P_COL)
                          VALUE(P_VALUE).

  CALL METHOD OF GO_SHEET 'Cells' = GO_CELL
  EXPORTING
    #1 = P_ROW
    #2 = P_COL.
  SET PROPERTY OF GO_CELL 'Value' = P_VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INSERT_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INSERT_ROWS .
  DATA: LO_ROW  TYPE OLE2_OBJECT,
        LV_ROWS TYPE STRING.
  DATA(LV_ITEM_COUNT) = LINES( GT_ITEM ).


  IF LV_ITEM_COUNT > 12.
    DATA(LV_EXTRA_ROWS) = 17 + LV_ITEM_COUNT - 12.

    LV_ROWS = |17:{ LV_EXTRA_ROWS }|.
    CALL METHOD OF GO_SHEET 'Rows' = LO_ROW
      EXPORTING
        #1 = LV_ROWS.

    CALL METHOD OF LO_ROW 'Insert'.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITEM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITEM .

  DATA:

    LS_EXCEL TYPE C LENGTH 1500,
    LT_EXCEL LIKE TABLE OF LS_EXCEL,
    DELI     TYPE C,
    LV_RC    TYPE I.
  DELI = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.

  DATA : LV_NETPR TYPE C LENGTH 30,
         LV_TOTAL TYPE C LENGTH 30.

  CLEAR GS_ITEM.
  " gt_item 값을 c타입으로 lt_excel로 옯겨주는 작업
  LOOP AT GT_ITEM INTO GS_ITEM .

    WRITE GS_ITEM-NETPR TO LV_NETPR CURRENCY GS_ITEM-WAERK.
    WRITE GS_ITEM-TOTAL TO LV_TOTAL CURRENCY GS_ITEM-WAERK.

    LS_EXCEL = |{ GS_ITEM-POSNR } { DELI } { GS_ITEM-MATNR } { DELI } { GS_ITEM-MAKTX } { DELI } {   " GS_ITEM을 1열 STRING 으로 세팅
                  LV_NETPR } { DELI } { GS_ITEM-WAERK } { DELI } { GS_ITEM-KWMENG } { DELI }{
                  GS_ITEM-MEINS } { DELI } { LV_TOTAL } { DELI } { GS_ITEM-LGOBE } { DELI }|.
    APPEND LS_EXCEL TO LT_EXCEL.
    CLEAR LS_EXCEL.
  ENDLOOP.


  " 클립보드를 통해 LT_EXCEL 데이터 옮기기
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_EXPORT
    EXPORTING
      NO_AUTH_CHECK        = 'X'            " Switch off Check for Access Rights
    IMPORTING
      DATA                 = LT_EXCEL                 " Data
    CHANGING
      RC                   = LV_RC                 " Return Code
    EXCEPTIONS
      CNTL_ERROR           = 1                " Control error
      ERROR_NO_GUI         = 2                " No GUI available
      NOT_SUPPORTED_BY_GUI = 3                " GUI does not support this
      NO_AUTHORITY         = 4                " Authorization check failed
      OTHERS               = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CALL METHOD OF GO_SHEET 'Cells' = GO_CELL EXPORTING #1 = 16 #2 = 2.  " 시작 위치 선정
  CALL METHOD OF GO_CELL 'SELECT'.                                     " 셀 선택
  CALL METHOD OF GO_SHEET 'PASTE'.                                     " 셀 복사


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SAVE_PATH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_SAVEPATH
*&---------------------------------------------------------------------*
FORM SET_SAVE_PATH  CHANGING PV_SAVEPATH.

  DATA : LV_PATH          TYPE STRING.
*         LV_SAVE_FILENAME TYPE STRING.
  DATA(LV_FILENAME) = |Template_| & |{ SY-DATUM }| & |.xlsx|.

  CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG(
    EXPORTING
      DEFAULT_FILE_NAME         = LV_FILENAME                           " 파일명
      FILE_FILTER               = 'Excel files (*.XLS;*.XLSX)|*.XLSX'   " 파일 형식
      INITIAL_DIRECTORY         = 'D:\'                                 " 파일 기본 경로
    CHANGING
      FILENAME                  = LV_FILENAME
      PATH                      = LV_PATH
      FULLPATH                  = PV_SAVEPATH
    EXCEPTIONS
      CNTL_ERROR                = 1                " Control error
      ERROR_NO_GUI              = 2                " No GUI available
      NOT_SUPPORTED_BY_GUI      = 3                " GUI does not support this
      INVALID_DEFAULT_FILE_NAME = 4                " Invalid default file name
      OTHERS                    = 5
  ).
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_HEADER_CELLS
*&---------------------------------------------------------------------*
FORM SET_HEADER_CELLS .

  PERFORM SET_HEADER USING 5 5 GS_HEADER-BUTXT. " 회사명  E5
  PERFORM SET_HEADER USING 6 5 GS_HEADER-CITY.  " 회사 주소

  DATA(LV_TEL) = |Tel:{ GS_HEADER-TEL_NUMBER } | . " 전화번호 출력값 세팅
  PERFORM SET_HEADER USING 7 5 LV_TEL.              " 전화번호

  DATA(LV_VBELN) = |'{ GS_HEADER-VBELN }|.   " '를 통해 왼쪽정렬 할 수 있음.
  PERFORM SET_HEADER USING 10 3 LV_VBELN .   " 판매오더    VBELN -> C110 (row 10, col 3)

  DATA(LV_KUNNR) = |{ GS_HEADER-KUNNR ALPHA = OUT }|.
  CONDENSE LV_KUNNR NO-GAPS .
  DATA(LV_BUYER) = |{ LV_KUNNR }( { GS_HEADER-NAME1 } )|.
  PERFORM SET_HEADER USING 11 3 LV_BUYER. " 바이어    BUYER -> C11 (row 11, col 3)

  PERFORM SET_HEADER USING 12 3 GS_HEADER-BSTNK. " 참조번호    BSTNK -> C12 (row 12, col 3)
  PERFORM SET_HEADER USING 13 3 SY-DATUM.        " 날짜 -> 오늘 날짜로

  DATA : LV_NETWR TYPE C LENGTH 30.
  WRITE GS_HEADER-NETWR TO LV_NETWR CURRENCY GS_HEADER-WAERK.
  DATA(LV_TOTAL) = |{ LV_NETWR } { GS_HEADER-WAERK }|.
  PERFORM SET_HEADER USING 10 6 LV_TOTAL. " 총액    NETWR -> F10 (row 10, col 6)
  PERFORM SET_HEADER USING 11 6 GS_HEADER-VDATU. " 배송 요청일    NETWR -> F11 (row 11, col 6)
  PERFORM SET_HEADER USING 12 6 GS_HEADER-ZTERM. " 지급조건    NETWR -> F11 (row 11, col 6)
  PERFORM SET_HEADER USING 13 6 GS_HEADER-INCO1. " 인도조건    NETWR -> F11 (row 11, col 6)


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SEND_MAIL .

  DATA : LO_BCS       TYPE REF TO CL_BCS,
         LO_DOCUMENT  TYPE REF TO CL_DOCUMENT_BCS,
         LO_SENDER    TYPE REF TO IF_SENDER_BCS,
         LO_RECIPIENT TYPE REF TO IF_RECIPIENT_BCS.

  DATA : LV_HTML_BODY TYPE STRING,
         LT_OBJCON    TYPE TABLE OF SOLI,
         LV_TITLE     TYPE SO_OBJ_DES.

  " 제목
  LV_TITLE = |이메일 전송 테스트|.

  LT_OBJCON = VALUE #( ( LINE = '메일 테스트 내용 1' )
                         ( LINE = '메일 테스트 내용 2' )
                         ( LINE = '메일 테스트 내용 3' ) ).


  TRY.
      " 송신 요청 생성
      LO_BCS = CL_BCS=>CREATE_PERSISTENT( ).
      LO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                                                        I_TYPE    = 'RAW'       " HTML
                                                        I_TEXT    = LT_OBJCON   " 본문
                                                        I_SUBJECT = LV_TITLE ). " 제목
      LO_BCS->SET_DOCUMENT( LO_DOCUMENT ).


*--------------------------------------------------------------------*
* EXCEL, PDF 첨부파일 넣기
*--------------------------------------------------------------------*

      " 파일 명
      ATTACHMENT_SUBJECT = |Template_| & |{ SY-DATUM }| & |.xlsx|.

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
          FILENAME   = GV_SAVEPATH   " 또는 AL11 경로
          FILETYPE   = 'BIN'
        IMPORTING
          FILELENGTH = LV_SIZE
        TABLES
          DATA_TAB   = LT_ROWREC.


      " EXCEL 첨부파일 설정 "
      LO_DOCUMENT->ADD_ATTACHMENT(
        I_ATTACHMENT_TYPE    = 'XML'
        I_ATTACHMENT_SUBJECT = ATTACHMENT_SUBJECT
        I_ATTACHMENT_SIZE    = SOOD_BYTECOUNT
        I_ATT_CONTENT_HEX    = LT_ROWREC
        I_ATTACHMENT_HEADER  = T_ATTACHMENT_HEADER ).

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

ENDFORM.
