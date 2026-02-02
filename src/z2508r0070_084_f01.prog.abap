*&---------------------------------------------------------------------*
*& Include          Z2508R0070_084_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  SELECT A~EBELN
           EBELP
           MATNR
    FROM EKKO AS A
    JOIN EKPO AS B ON A~EBELN = B~EBELN
    INTO CORRESPONDING FIELDS OF TABLE GT_DATA
    WHERE A~EBELN IN S_EBELN
    ORDER BY A~EBELN EBELP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT
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
*& Form SET_FCAT
*&---------------------------------------------------------------------*
FORM SET_FCAT .

  DATA : LV_MAX_ITEM TYPE I,
         LS_FCAT     TYPE LVC_S_FCAT.

  "  가장 큰 항목 수를 세서 그만큼 필드 카탈로그를 반복적으로 만들어줌.
  SELECT COUNT( DISTINCT EBELP )
    INTO @LV_MAX_ITEM
    FROM EKPO
    WHERE EBELN IN @S_EBELN.

  CLEAR GT_FCAT.

  CLEAR LS_FCAT.
  LS_FCAT-FIELDNAME = 'EBELN'.
  LS_FCAT-COLTEXT = 'PO번호'.
  LS_FCAT-REF_TABLE = 'EKKO'.
  APPEND LS_FCAT TO GT_FCAT.

*  GT_FCAT = VALUE #(
*    ( FIELDNAME = 'EBELN'   REF_TABLE = 'EKKO'     COLTEXT = 'PO번호'   )
*    ).


  DO LV_MAX_ITEM  TIMES.
    CLEAR LS_FCAT.
    LS_FCAT-FIELDNAME = |EBELP{ SY-INDEX }|.
    LS_FCAT-COLTEXT = '항목번호'.
    LS_FCAT-REF_TABLE = 'EKPO'.
    LS_FCAT-REF_FIELD = 'EBELP'.
    APPEND LS_FCAT TO GT_FCAT.

    CLEAR LS_FCAT.
    LS_FCAT-FIELDNAME = |MATNR{ SY-INDEX }|.
    LS_FCAT-COLTEXT = '자재번호'.
    LS_FCAT-REF_TABLE = 'EKPO'.
    LS_FCAT-REF_FIELD = 'MATNR'.
    APPEND LS_FCAT TO GT_FCAT.

  ENDDO.


  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
*     I_STYLE_TABLE   =                  " Add Style Table
      IT_FIELDCATALOG = GT_FCAT                 " Field Catalog
*     I_LENGTH_IN_BYTE          =                  " Boolean Variable (X=True, Space=False)
    IMPORTING
      EP_TABLE        = GT_LIST_R.                " Pointer to Dynamic Data Table

  UNASSIGN <GT_LIST>.  " 할당 해제
  ASSIGN GT_LIST_R->* TO <GT_LIST>.  " 할당


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
      IS_LAYOUT                     = GS_LAYOUT                 " Layout
    CHANGING
      IT_OUTTAB                     = <GT_LIST>                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT
      ).



ENDFORM.
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
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-ZEBRA = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DYNAMIC_TABLE
*&---------------------------------------------------------------------*
FORM SET_DYNAMIC_TABLE .

*--- 동적 필드 참조를 위한 필드심볼 선언
  FIELD-SYMBOLS : <FS_LIST>  TYPE DATA,
                  <LV_VALUE> TYPE DATA.

*--- 동적 데이터 및 보조 변수 선언
  DATA : LV_DATA  TYPE REF TO DATA,  " 주소를 담을 참조변수
*         LV_FNAME TYPE FIELDNAME,
         LV_CNT   TYPE I.

*--- <GT_LIST> 의 한 줄 구조를 생성해서 <FS_LIST> 에 연결

  " 동적 데이터 객체 생성, lv_data는 생성된 객체를 가리키는 참조변수(주소) 실제로 데이터 가리키지 않음
  CREATE DATA LV_DATA LIKE LINE OF <GT_LIST>.
  ASSIGN LV_DATA->* TO <FS_LIST>.   " LV_DATA->*는 생성된 실제 데이터 구조, 그 실제 데이터를 <FS_list> 로 연결

  LOOP AT GT_DATA INTO GS_DATA.

    AT NEW EBELN." 구매번호가 바뀔 때마다 새로운 행 준비
      LV_CNT = 1.
      ASSIGN COMPONENT 'EBELN' OF STRUCTURE <FS_LIST> TO <LV_VALUE>.
      <LV_VALUE> = GS_DATA-EBELN.
    ENDAT.

    ASSIGN COMPONENT |EBELP{ LV_CNT }| OF STRUCTURE <FS_LIST> TO <LV_VALUE>.
    <LV_VALUE> = GS_DATA-EBELP.

    ASSIGN COMPONENT |MATNR{ LV_CNT }| OF STRUCTURE <FS_LIST> TO <LV_VALUE>.
    <LV_VALUE> = GS_DATA-MATNR.
    LV_CNT += 1.

    AT END OF EBELN.
      APPEND <FS_LIST> TO <GT_LIST>.
      CLEAR <FS_LIST>.

    ENDAT.
  ENDLOOP.

ENDFORM.
