*&---------------------------------------------------------------------*
*& Include          Z2508R0010_084_CLS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class (DEFINITION) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
* 구매오더 헤더 ALV 핫스팟 이벤트
    CLASS-METHODS ON_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID .

* 구매오더 아이템 ALV 핫스팟 이벤트
    CLASS-METHODS ON_HOTSPOT_CLICK2 FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
      IMPORTING E_ROW_ID E_COLUMN_ID .
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) LCL_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.

    METHOD ON_HOTSPOT_CLICK.

    CLEAR GS_DATA.
    READ TABLE GT_DATA INTO GS_DATA INDEX E_ROW_ID-INDEX.

    IF SY-SUBRC = 0.
      CASE E_COLUMN_ID-FIELDNAME.

* 상단의 PO 번호를 click( hotspot )하면 하단 ALV에 해당 PO의 Line Item Detail 정보를 출력
        WHEN 'EBELN'.
          PERFORM CLICK_HEADER_PO .

* Vendor Code 클릭 시, XK03 화면으로 이동하도록 HotSpot click 이벤트 처리
* 선택된 Vendor Code 입력하고, Address View 만 선택한 상태로 화면으로 진입
        WHEN 'LIFNR'.
          SET PARAMETER ID 'LIF' FIELD GS_DATA-LIFNR.
          SET PARAMETER ID 'KDY' FIELD '/110'.
          CALL TRANSACTION 'XK03' AND SKIP FIRST SCREEN.
      ENDCASE.
    ENDIF.

  ENDMETHOD.

  METHOD  ON_HOTSPOT_CLICK2.

    CLEAR GS_ITEM.
    READ TABLE GT_ITEM INTO GS_ITEM INDEX E_ROW_ID-INDEX.

    IF SY-SUBRC = 0.
      CASE E_COLUMN_ID-FIELDNAME.

* PO No. 클릭 시, ME23N 화면으로 이동하도록 HotSpot click 이벤트 처리
* PO 번호 입력하여, 선택된 PO 상세 화면으로 바로 진입
        WHEN 'EBELN'.
          SET PARAMETER ID 'BES' FIELD GS_ITEM-EBELN.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

* Material Code 클릭 시, MM03 화면으로 이동하도록 HotSpot click 이벤트 처리
* Material Code 입력하는 화면은 SKIP하고, Basic View 만 선택한 상태로 MM03 화면으로 진입
        WHEN 'MATNR'.
          SET PARAMETER ID 'MAT' FIELD GS_ITEM-MATNR.
          SET PARAMETER ID 'MXX' FIELD 'K' .
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDCASE.
    ENDIF.


  ENDMETHOD.

ENDCLASS.
