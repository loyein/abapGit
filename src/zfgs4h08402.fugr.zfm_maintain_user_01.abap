FUNCTION ZFM_MAINTAIN_USER_01.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IV_MODE) TYPE  CHAR1
*"     REFERENCE(IV_NAME) TYPE  ZS4H084T04-CUST_NAME
*"     REFERENCE(IV_BIRTH) TYPE  ZS4H084T04-BIRTH_DATE
*"     REFERENCE(IV_EMAIL) TYPE  ZS4H084T04-EMAIL
*"     REFERENCE(IV_USER_ID) TYPE  ZS4H084T04-CUST_ID
*"  EXPORTING
*"     REFERENCE(EV_USER_ID) TYPE  ZS4H084T04-CUST_ID
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------



  CLEAR :  EV_STATUS, EV_MESSAGE.

  " 결과 상태 초기값 설정
  EV_STATUS = 'F'.
*--------------------------------------------------------------------*
*  Case1. 생성
*--------------------------------------------------------------------*
  CASE IV_MODE.

    WHEN 'I'.
      PERFORM CREATE_USER USING IV_NAME IV_BIRTH IV_EMAIL
                          CHANGING EV_USER_ID EV_STATUS EV_MESSAGE.

    WHEN 'M'.

    PERFORM MODIFY_USER USING IV_NAME IV_BIRTH IV_EMAIL IV_USER_ID
                          CHANGING EV_USER_ID EV_STATUS EV_MESSAGE.

    WHEN OTHERS.
      EV_MESSAGE = '올바른 입력값이 아닙니다.'.


  ENDCASE.

ENDFUNCTION.
