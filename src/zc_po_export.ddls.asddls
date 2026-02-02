@AbapCatalog.sqlViewName: 'ZCPOEXPORT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO txt 파일로 변경'
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true

@UI.headerInfo: {
    typeName: 'Purchase Order',
    typeNamePlural: 'Purchase Orders',
    title: {
        value: 'PurchaseOrder'
    }
}


define view ZC_PO_EXPORT as select from ekko as Header
inner join ekpo as Item on Header.ebeln = Item.ebeln
left outer join lfa1 as Vendor on Header.lifnr = Vendor.lifnr
{
    // @UI.lineItem: SmartTable에 컬럼으로 표시하라는 지시입니다.
      // - position: 컬럼의 순서를 지정합니다.
      // @UI.selectionField: SmartFilterBar에 필터 필드로 표시하라는 지시입니다.
      @UI.lineItem:       [{ position: 10 }]
      @EndUserText.label: 'Purchase Order'
  key Header.ebeln as PurchaseOrder,

      @UI.lineItem:       [{ position: 20 }]
      @EndUserText.label: 'Item'
  key Item.ebelp   as PurchaseOrderItem,

      @UI.lineItem:       [{ position: 30 }]
      @EndUserText.label: 'Vendor'
      Header.lifnr as Vendor,

      @UI.lineItem:       [{ position: 40 }]
      @EndUserText.label: 'Vendor Name'
      Vendor.name1 as VendorName,

      @UI.lineItem:       [{ position: 50 }]
      @EndUserText.label: 'Material'
      Item.matnr   as Material,

      // 이 필드가 SmartFilterBar의 기본 검색 필드가 됩니다.
      @UI.lineItem:       [{ position: 60 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Purchase Date'
      Header.bedat as PurchaseDate,

      @UI.lineItem:       [{ position: 70 }]
      @EndUserText.label: 'Quantity'
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Item.menge   as Quantity,

      @UI.hidden: true
      @Semantics.unitOfMeasure: true
      Item.meins   as Unit,

      @UI.lineItem:       [{ position: 90 }]
      @Semantics.amount.currencyCode: 'Currency'      
      @EndUserText.label: 'Net Price'
      Item.netpr   as NetPrice,

      @UI.lineItem:       [{ position: 100 }]
      @EndUserText.label: 'Net Amount'
      @Semantics.amount.currencyCode: 'Currency'
      Item.netwr   as NetAmount,

      @UI.hidden: true
      @Semantics.currencyCode: true
      Header.waers as Currency
}
