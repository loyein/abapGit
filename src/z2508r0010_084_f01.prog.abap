*&---------------------------------------------------------------------*
*& Include          Z2508R0010_084_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SELECT_DATA .

  SELECT  A~EBELN,                        " 구매오더 번호
          A~BEDAT,                        " 구매 날짜
          A~LIFNR,                        " 공급 업체
          C~NAME1,                        " 공급 업체명
          A~ERNAM,                        " 생성자
          SUM( B~NETWR ) AS TOTAL_NETWR,  " 구매 총액
          A~WAERS                         " 단위
    FROM EKKO AS A
    JOIN EKPO AS B ON A~EBELN = B~EBELN
    JOIN LFA1 AS C ON A~LIFNR = C~LIFNR
    WHERE A~EKORG IN @S_EKORG
      AND A~EKGRP IN @S_EKGRP
      AND A~LIFNR IN @S_LIFNR
      AND A~BEDAT IN @S_BEDAT
      AND B~LOEKZ = ''                     " 삭제되지 않은 건 조회
    GROUP BY A~EBELN, A~BEDAT, A~LIFNR, C~NAME1, A~ERNAM, A~WAERS
    ORDER BY A~EBELN
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.



* ALV 출력 전 데이터 출력 확인용
* CL_DEMO_OUTPUT=>WRITE( DATA = GT_DATA  ).
* CL_DEMO_OUTPUT=>DISPLAY( ).


ENDFORM.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE INIT_ALV_0100 OUTPUT.

  IF GO_CONTAINER IS INITIAL.
    PERFORM CREATE_OBJECT.
    PERFORM SET_LAYOUT.
    PERFORM SET_FCAT.
    PERFORM SET_EVENT_HANDLER.
    PERFORM DISPLAY_ALV.
  ELSE.
    PERFORM REFRESH_ALV.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form CREATE_OBJECT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CREATE_OBJECT .

  CREATE OBJECT GO_CONTAINER
    EXPORTING
      SIDE      = GO_CONTAINER->DOCK_AT_LEFT     " 왼쪽부터 정렬 시키는 도킹 컨테이터
      EXTENSION = 5000.                          " Control Extension

  CREATE OBJECT GO_ALV_GRID
    EXPORTING
      I_PARENT = GO_CONTAINER.                 " Parent Container
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DISPLAY_ALV.
  GO_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY(
    EXPORTING
      IS_LAYOUT                     = GS_LAYOUT                 " Layout
    CHANGING
      IT_OUTTAB                     = GT_DATA                 " Output Table
      IT_FIELDCATALOG               = GT_FCAT                 " Field Catalog
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FCAT.

  GT_FCAT = VALUE #(
  ( FIELDNAME = 'EBELN'       COLTEXT = 'PO No.'       HOTSPOT = 'X' KEY = 'X' JUST = 'C' )
  ( FIELDNAME = 'BEDAT'       COLTEXT = 'Ordered Date' JUST = 'C' )
  ( FIELDNAME = 'LIFNR'       REF_TABLE = 'EKKO'       COLTEXT = 'Vendor' JUST = 'C' )
  ( FIELDNAME = 'NAME1'       COLTEXT = 'NAME' )
  ( FIELDNAME = 'ERNAM'       COLTEXT = 'Create By' )
  ( FIELDNAME = 'TOTAL_NETWR' COLTEXT = 'PO Amount'    CFIELDNAME = 'WAERS' )
  ( FIELDNAME = 'WAERS'       COLTEXT = 'Unit' )
).

** 구매 문서 번호
*  CLEAR GS_FCAT.
*  GS_FCAT-FIELDNAME = 'EBELN'.
*  GS_FCAT-COLTEXT = 'PO No.'.
*  GS_FCAT-HOTSPOT = 'X'.
*  GS_FCAT-KEY = 'X'.
*  GS_FCAT-JUST = 'C'.
*  APPEND GS_FCAT TO GT_FCAT.
*
** 구매 날짜
*  CLEAR GS_FCAT.
*  GS_FCAT-FIELDNAME = 'BEDAT'.
*  GS_FCAT-COLTEXT = 'Ordered Date'.
*  GS_FCAT-JUST = 'C'.
*  APPEND GS_FCAT TO GT_FCAT.
*
** 공급업체코드
*  CLEAR GS_FCAT.
*  GS_FCAT-FIELDNAME = 'LIFNR'.
*  GS_FCAT-REF_TABLE = 'EKKO'.    " EKKO안에 LIFNR의 도메인의 루틴이 이미 ALPHA로 지정되어 있어 레퍼런스 해도 됨.
*  GS_FCAT-COLTEXT = 'Vendor'.
*  GS_FCAT-JUST = 'C'.
**  GS_FCAT-CONVEXIT = 'ALPHA'.    " 앞에 0000 생략해줌 (데이터 필드의 변환 룰을 지정)
*  APPEND GS_FCAT TO GT_FCAT.
*
** 공급업체명
*  CLEAR GS_FCAT.
*  GS_FCAT-FIELDNAME = 'NAME1'.
*  GS_FCAT-COLTEXT = 'NAME'.
*  APPEND GS_FCAT TO GT_FCAT.
*
** 생성자
*  CLEAR GS_FCAT.
*  GS_FCAT-FIELDNAME = 'ERNAM'.
*  GS_FCAT-COLTEXT = 'Create By'.
*  APPEND GS_FCAT TO GT_FCAT.
*
** 총액 합계
*  CLEAR GS_FCAT.
*  GS_FCAT-FIELDNAME = 'TOTAL_NETWR'.
*  GS_FCAT-COLTEXT = 'PO Amount'.
*  GS_FCAT-CFIELDNAME = 'WAERS'.   " CURRENCY 적용
*  APPEND GS_FCAT TO GT_FCAT.
*
** 단위
*  CLEAR GS_FCAT.
*  GS_FCAT-FIELDNAME = 'WAERS'.
*  GS_FCAT-COLTEXT = 'Unit'.
*  APPEND GS_FCAT TO GT_FCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT.
  CLEAR GS_LAYOUT.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_ALV .
  GO_ALV_GRID->REFRESH_TABLE_DISPLAY( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT_HANDLER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_EVENT_HANDLER .
  SET HANDLER LCL_EVENT_HANDLER=>ON_HOTSPOT_CLICK FOR GO_ALV_GRID.
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
* 검색 결과가 존재하지 않을 때 다음 화면으로 넘어가지 않고 경고 메시지가 뜨도록 함.
  IF GT_DATA IS INITIAL.
    MESSAGE '검색 결과가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

* 검색 결과가 있으면 100번 화면 호출
  CALL SCREEN 0100.

ENDFORM.
