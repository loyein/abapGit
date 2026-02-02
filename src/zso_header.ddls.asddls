@AbapCatalog.sqlViewName: 'ZSOHEADER'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header'
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true

@UI.headerInfo: {
    typeName: 'Sales Order',
    typeNamePlural: 'Sales Orders',
    title: { value: 'vbeln' },
    description: { value: 'name1' }
}

define view zso_header as select from vbak as a
inner join vbkd as b on a.vbeln = b.vbeln
inner join kna1 as c on a.kunnr = c.kunnr
// --- [수정] TVKO 테이블을 조인하여 회사 코드를 가져옵니다 ---
inner join tvko as d on a.vkorg = d.vkorg 

association [0..*] to ZSO_ITEM as _Item
  on $projection.vbeln = _Item.vbeln
{
    @UI.selectionField: [ { position: 20, importance: #HIGH } ]
    @Consumption.filter: { mandatory: true, selectionType: #SINGLE, multipleSelections: false }
    @UI.lineItem: [ { position: 10, importance: #HIGH } ]
    key a.vbeln,   // 판매오더
    
    // --- [수정] 회사 코드를 'd' (TVKO) 테이블에서 가져옵니다 ---
    @UI.selectionField: [ { position: 10, importance: #HIGH } ]
    @Consumption.filter: { mandatory: true, selectionType: #SINGLE, multipleSelections: false, defaultValue: '4000' }
    @UI.lineItem: [ { position: 20, importance: #HIGH } ]
    d.bukrs,   // 회사 코드
    // ---------------------------------------------------

    @UI.lineItem: [ { position: 30, importance: #HIGH } ]
    a.kunnr,   // 고객번호
    @UI.lineItem: [ { position: 40, importance: #MEDIUM } ]
    c.name1,   // 고객이름
    a.bstnk,   // 참조번호
    @UI.lineItem: [ { position: 50, importance: #MEDIUM } ]
    a.netwr,   // 총액
    a.waerk,   // 통화
    a.vdatu,   // 배송요청일
    b.zterm,   // 지급조건
    b.inco1,   // 인도조건
    
    _Item // 아이템 연결
}
