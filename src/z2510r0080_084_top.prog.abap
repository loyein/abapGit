*&---------------------------------------------------------------------*
*& Include          Z2510R0080_084_TOP
*&---------------------------------------------------------------------*
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
