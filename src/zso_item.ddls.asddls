@AbapCatalog.sqlViewName: 'ZSOITEM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view ZSO_ITEM
  as select from    vbap  as A
    left outer join makt  as B on  A.matnr = B.matnr
                               and B.spras = $session.system_language
    inner join      t001l as C on  A.lgort = C.lgort
                               and A.werks = C.werks
{
  key A.vbeln, //판매오더 번호
  key A.posnr, //항번
      A.matnr, // 자재번호
      B.maktx, // 자재명
      A.netpr,  // 단가
      A.waerk,  // 통화
      A.kwmeng, // 수량
      A.meins,  // 수량 단위
      ( netpr * kwmeng ) as TOTAL, // 금액
      C.lgobe // 창고명
      
}
