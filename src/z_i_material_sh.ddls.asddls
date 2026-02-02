@AbapCatalog.sqlViewName: 'ZIMATERIALSHV'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 Search Help'
@Metadata.ignorePropagatedAnnotations: true
define view Z_I_MATERIAL_SH
  as select from makt
{
  key matnr,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      maktx
}
