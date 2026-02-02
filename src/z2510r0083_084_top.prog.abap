*&---------------------------------------------------------------------*
*& Include          Z2508R0030_084_TOP
*&---------------------------------------------------------------------*

TABLES : T001 , VBAK.

DATA : BEGIN OF GS_HEADER ,
         VBELN      TYPE VBAK-VBELN,        " 판매오더
         KUNNR      TYPE VBAK-KUNNR,
         NAME1      TYPE KNA1-NAME1,
*         BUYER      TYPE C LENGTH 20 , " 바이어
         BSTNK      TYPE VBAK-BSTNK,        " 참조번호
         NETWR      TYPE VBAK-NETWR,        " 총액
         VDATU      TYPE VBAK-VDATU,        " 배송 요청일
         ZTERM      TYPE VBKD-ZTERM,        " 지급조건
         INCO1      TYPE VBKD-INCO1,        " 인도조건
         BUTXT      TYPE T001-BUTXT,        " 사명
         TEL_NUMBER TYPE ADRC-TEL_NUMBER,   " 회사 전화번호
         CITY       TYPE C LENGTH 100,   " 회사 주소
         WAERK      TYPE VBAK-WAERK,
       END OF GS_HEADER .

DATA : BEGIN OF GS_ITEM,
         POSNR  TYPE VBAP-POSNR,   " 항번
         MATNR  TYPE VBAP-MATNR,   " 자재번호
         MAKTX  TYPE MAKT-MAKTX,   " 자재명
         NETPR  TYPE VBAP-NETPR,   " 단가
         WAERK  TYPE VBAP-WAERK,   " 통화
         KWMENG TYPE VBAP-KWMENG,  " 수량
         MEINS  TYPE VBAP-MEINS,   " 수량 단위
         TOTAL  TYPE VBAP-NETPR,   " 금액
         LGOBE  TYPE T001L-LGOBE,  " 창고명
       END OF GS_ITEM,
       GT_ITEM LIKE TABLE OF GS_ITEM.

DATA GV_SAVEPATH TYPE STRING.


* ABAP OLE 클래스
DATA :
*       GO_CONTROL     TYPE REF TO I_OI_CONTAINER_CONTROL,
*       GO_DOC_PROXY   TYPE REF TO I_OI_DOCUMENT_PROXY,
*       GO_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET,
  GO_SHEET TYPE OLE2_OBJECT,   " WORKSHEET
  GO_CELL  TYPE OLE2_OBJECT.   " CELL
*** INCLUDE Z2510R0083_084_TOP
*** INCLUDE Z2510R0083_084_TOP

 DATA: BCS_EXCEPTION        TYPE REF TO CX_BCS,
        ERRORTEXT            TYPE STRING,
        CL_SEND_REQUEST      TYPE REF TO CL_BCS,
        CL_DOCUMENT          TYPE REF TO CL_DOCUMENT_BCS,
        CL_RECIPIENT         TYPE REF TO IF_RECIPIENT_BCS,
        T_ATTACHMENT_HEADER  TYPE SOLI_TAB,
        WA_ATTACHMENT_HEADER LIKE LINE OF T_ATTACHMENT_HEADER,
        ATTACHMENT_SUBJECT   TYPE SOOD-OBJDES,

        SOOD_BYTECOUNT       TYPE SOOD-OBJLEN,
        MAIL_TITLE           TYPE SO_OBJ_DES,
        T_MAILTEXT           TYPE SOLI_TAB,
        WA_MAILTEXT          LIKE LINE OF T_MAILTEXT,
        SEND_TO              TYPE ADR6-SMTP_ADDR,
        SENT                 TYPE ABAP_BOOL.
