@AbapCatalog.sqlViewName: 'ZIVENDORSHV'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Search Help'
@Metadata.ignorePropagatedAnnotations: true
define view Z_I_VENDOR_SH
  as select from lfa1 as VendorData
{
      @UI.hidden: true
  key lifnr as Vendor,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      name1 as VendorName
}
