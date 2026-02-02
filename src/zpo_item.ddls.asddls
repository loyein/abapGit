@AbapCatalog.sqlViewName: 'ZPOITEM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 아이템 조회'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
  transactionalProcessingEnabled: true,
  createEnabled: true,
  updateEnabled: true,
  deleteEnabled: true
}
define view zpo_item
  as select from ekpo as Item
  
  association [1..1] to ekko as _Header on  $projection.PurchaseOrder = _Header.ebeln
  association [0..1] to makt as _makt   on  $projection.Material = _makt.matnr
                                        and _makt.spras          = $session.system_language
{
  key Item.ebeln                      as PurchaseOrder,

      @UI.lineItem: [{ position: 1 }]
      @EndUserText.label: '품목번호'
  key Item.ebelp                      as PurchaseOrderItem, // 품목번호
      // UI.lineItem: Fiori 화면 테이블에 보여줄 컬럼과 순서 정의
      @UI.lineItem: [{ position: 10 }]
      @EndUserText.label: '자재'
      Item.matnr                      as Material, // 자재

      @UI.lineItem: [{ position: 11 }]
      @EndUserText.label: '자재명'
      _makt.maktx                     as MaterialText, // 자재 텍스트
      
      Item.werks                      as Plant,

      @UI.lineItem: [{ position: 20, type: #STANDARD, label: '수량'  }]
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Item.menge                      as Quantity, // 수량
      
      //      @UI.lineItem: [{ position: 30 }]
      //      @EndUserText.label: '단위'
      Item.meins                      as Unit,      // 단위

      @UI.lineItem: [{ position: 40, type: #STANDARD, label: '단가' }]
      @Semantics.amount.currencyCode: 'Currency'
      Item.netpr                      as NetPrice,  // 단가

      @UI.lineItem: [{ position: 50, type: #STANDARD, label: '총 금액' }]
      @Semantics.amount.currencyCode: 'Currency'
      Item.netwr                      as NetAmount, // 금액

      // ## Association을 통해 EKKO에서 WAERS를 가져옴 ##
      @Semantics.currencyCode: true
      _Header.waers                   as Currency, // 통화

      Item.loekz

}
// 삭제되지 않은 아이템만 조회
where
  Item.loekz = ''
