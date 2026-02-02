@AbapCatalog.sqlViewName: 'ZS4H084I01V'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO 조회'
@OData.publish: true

//@Search.searchable: true
// ## UI 관련 어노테이션 추가 ##
@UI.headerInfo: {
    typeName: 'Purchase Order',
    typeNamePlural: 'Purchase Orders',
    title: {
        type: #STANDARD,
        label:'구매오더 번호 : ',
        value: 'PurchaseOrder'
    }
}
define view ZS4H084_I01
  as select from ekko as Header

  // inner join 대신 association 사용을 권장합니다.
  association [1..*] to zpo_item as _Item   on $projection.PurchaseOrder = _Item.PurchaseOrder
  //  association [1..*] to ekpo as _Item   on  $projection.PurchaseOrder = _Item.ebeln
  //                                                 and _Item.loekz               = ''
  //                                        and Header.loekz              = ''
  association [0..1] to lfa1     as _Vendor on $projection.Vendor = _Vendor.lifnr
  //  composition [0..*] of zpo_item as _Item
  //  association [0..1] to Z_I_VENDOR_SH as _Vendor on  $projection.Vendor = _Vendor.Vendor


{


      // ## Flexible Column2 상세 화면(Object Page) 레이아웃 정의 ##
      @UI.facet: [
      // Facet 1: 헤더 정보 폼
      {
        id: 'HeaderGeneralInfo',
        purpose: #STANDARD,
        type: #FIELDGROUP_REFERENCE,
        label: '구매 오더 헤더 정보', // 폼 섹션의 제목
        targetQualifier: 'HeaderData', // 1단계에서 지정한 Field Group의 qualifier 이름
        position: 10
      },
      // Facet 2: 아이템 목록 테이블
          {
              id: 'PurchaseOrderItems',
              purpose: #STANDARD,
              type: #LINEITEM_REFERENCE,
              label: '구매 오더 아이템 정보', // 상세화면에서 보일 테이블의 제목
              targetElement: '_Item',     // 아래 association의 이름과 일치
              position: 20
          }
      ]
      // key 키워드는 필드명 바로 앞에 위치해야 합니다.


      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 1, type: #STANDARD }]
      @UI.fieldGroup: [{ qualifier: 'HeaderData', position: 10 }]
      @EndUserText.label: '구매 오더 번호'
  key Header.ebeln                                      as PurchaseOrder, // 구매오더 번호



      // --- 신규 검색 조건 추가 ---
      @UI.selectionField: [{ position: 10 }]
      @UI.fieldGroup: [{ qualifier: 'HeaderData', position: 20 }]
      @EndUserText.label: '구매 조직'
      Header.ekorg                                      as PurchasingOrg,

      @UI.selectionField: [{ position: 20 }]
      @UI.fieldGroup: [{ qualifier: 'HeaderData', position: 30 }]
      @EndUserText.label: '구매 그룹'
      Header.ekgrp                                      as PurchasingGroup,

      @UI.lineItem: [{ position: 30, type: #STANDARD }]
      @UI.fieldGroup: [{ qualifier: 'HeaderData', position: 40 }]
      @UI.selectionField: [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'Z_I_VENDOR_SH', element: 'Vendor' },
        additionalBinding: [{ localElement: 'VendorName', element: 'VendorName' }]
      }]

      @EndUserText.label: '공급 업체'
      Header.lifnr                                      as Vendor,        // 공급 업체

      @UI.lineItem: [{ position: 20, type: #STANDARD }]
      @UI.fieldGroup: [{ qualifier: 'HeaderData', position: 50 }]
      @UI.selectionField: [{ position: 40 }]
      @Consumption.filter: { selectionType: #RANGE, multipleSelections: false }
      @EndUserText.label: '생성일'
      Header.bedat                                      as PurchaseDate,  // 구매 날짜

      @UI.lineItem: [{ position: 40, type: #STANDARD }]
      @UI.fieldGroup: [{ qualifier: 'HeaderData', position: 60 }]
      @EndUserText.label: '공급 업체명'
      _Vendor.name1                                     as VendorName,    // 공급 업체명

      @UI.lineItem: [{ position: 50, type: #STANDARD }]
      @EndUserText.label: '생성자'
      Header.ernam                                      as CreatedByUser, // 생성자

      // 집계 함수 사용
      @UI.lineItem: [{ position: 60, type: #STANDARD }]
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: '구매 총액'
      @ObjectModel.readOnly: true
      //      _Item.NetAmount as TotalNetAmount,
      cast( sum( _Item.NetAmount ) as abap.dec(23, 2) ) as TotalNetAmount, // 구매 총액

      //      @UI.lineItem: [{ position: 70, type: #STANDARD }]
      //      @EndUserText.label: '통화'
      Header.waers                                      as Currency, // 단위

      Header.zterm                                      as zterm,
      
      Header.bukrs  as Bukrs,

      _Item
}

group by
  Header.ebeln,
  Header.ekorg,
  Header.ekgrp,
  Header.bedat,
  Header.lifnr,
  _Vendor.name1,
  Header.ernam,
  Header.waers,
  Header.zterm,
  Header.bukrs 
