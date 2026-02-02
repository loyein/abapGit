FUNCTION ZF_RFC_0020_084.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_HEAD) TYPE  ZMT_RFC_0020_084
*"     VALUE(IT_ITEM) TYPE  ZTT_RFC_0020_084
*"  EXPORTING
*"     VALUE(EV_FLAG) TYPE  CHAR1
*"     VALUE(EV_MSG) TYPE  CHAR40
*"----------------------------------------------------------------------

  IF IS_HEAD-QUTNO IS INITIAL.
    EV_FLAG = 'F'.
    EV_MSG = '견적서 번호가 존재하지 않습니다.'.
  ENDIF.

  IF IS_HEAD-LFDAT IS INITIAL.
    EV_FLAG = 'F'.
    EV_MSG = '납품 요청일 정보가 존재하지 않습니다.'.
  ENDIF.

  IF IS_HEAD-QUTDT IS INITIAL.
    EV_FLAG = 'F'.
    EV_MSG = '견적서 생성일 정보가 존재하지 않습니다.'.
  ENDIF.

  LOOP AT IT_ITEM INTO DATA(IS_ITEM).

    IF IS_ITEM-QUTSQ IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = '견적서 항목번호가 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-RFQNO IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = 'RFQ 번호가 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-RFQSQ IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = 'RFQ 항목번호가 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-MATNR IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = '자재번호가 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-MENGE IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = '수량 단위 정보 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-NETPR IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = '단가 정보가 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-NETWR IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = '금액 정보가 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-MEINS IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = '수량 단위 정보가 존재하지 않습니다.'.
    ENDIF.

    IF IS_ITEM-WAERS IS INITIAL.
      EV_FLAG = 'F'.
      EV_MSG = '금액 단위가 존재하지 않습니다.'.
    ENDIF.
  ENDLOOP.

  DATA : LS_HEAD TYPE ZMMT0530_084,
         LT_ITEM TYPE TABLE OF ZMMT0540_084.

  LS_HEAD = VALUE #(
    QUTNO = IS_HEAD-QUTNO
    DLVDT = IS_HEAD-LFDAT " 납품 요청일 -> 배송요청일
    QUTDT = IS_HEAD-QUTDT
  ).

   LOOP AT IT_ITEM INTO DATA(LS_ITEM).
    APPEND VALUE #(
       QUTNO = IS_HEAD-QUTNO
       QUTSQ = LS_ITEM-QUTSQ
       RFQNO = LS_ITEM-RFQNO
       RFQSQ = LS_ITEM-RFQSQ
       MATNR = LS_ITEM-MATNR
       MENGE = LS_ITEM-MENGE
       NETPR = LS_ITEM-NETPR
       NETWR = LS_ITEM-NETWR
       MEINS = LS_ITEM-MEINS
       WAERS = LS_ITEM-WAERS
    ) TO LT_ITEM.

  ENDLOOP.

  MODIFY ZMMT0530_084 FROM LS_HEAD.
  IF SY-SUBRC = 0.
    MODIFY ZMMT0540_084 FROM TABLE LT_ITEM.
    IF SY-SUBRC = 0.
      EV_FLAG = 'S'.
      EV_MSG = '데이터 전송에 성공하였습니다.'.
      LS_HEAD-ZFLAG = 'S'.
      LS_HEAD-ZIFDAT = SY-DATUM.
      LS_HEAD-ZIFTIM = SY-UZEIT.
      MODIFY ZMMT0530_084 FROM LS_HEAD.
      COMMIT WORK.
      RETURN.
      ELSE.
       EV_FLAG = 'F'.
       EV_MSG = '데이터 전송에 실패하였습니다.'.
       LS_HEAD-ZFLAG = 'F'.
       MODIFY ZMMT0530_084 FROM LS_HEAD.
       ROLLBACK WORK.
       RETURN.
    ENDIF.
     ELSE.
       EV_FLAG = 'F'.
       EV_MSG = '데이터 전송에 실패하였습니다.'.
       LS_HEAD-ZFLAG = 'F'.
       MODIFY ZMMT0530_084 FROM LS_HEAD.
       ROLLBACK WORK.
       RETURN.
  ENDIF.


ENDFUNCTION.
