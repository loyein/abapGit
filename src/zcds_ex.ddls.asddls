/** View Annotation 영역 */

@AbapCatalog.sqlViewName: 'ZCDSEX'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '해당 View에 대한 Description'
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true

@UI.headerInfo: {
    typeName: '항공편',
    typeNamePlural: '항공편 목록',
    title: { type: #STANDARD, value: 'AirlineId' },
    description: { value: 'AirlineName' }
}

/** CDS View 정의 */
define view ZCDS_EX
  as select from sflight
  association [1..1] to scarr as _Carrier    on  sflight.carrid = _Carrier.carrid
  association [1..1] to spfli as _Connection on  sflight.carrid = _Connection.carrid
                                             and sflight.connid = _Connection.connid

/** CDS View Field 정의 */
{
      /** Field(Element) Annotation */
      @UI.lineItem: [{ position: 10 }]          // 테이블 출력순서
      @UI.selectionField: [{position: 10}]      // 필터 출력순서
 //     @Consumption.filter.mandatory: true       // 필수입력
      @Consumption.filter.defaultValue: 'JL'    // 검색기본값
      @Consumption.valueHelp: '_Carrier'        // Value Help 기능
      @EndUserText.label: '항공사코드' // UI 명칭 적용
  key carrid                as AirlineId,

      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{position: 20}]
  key connid                as ConnectionId,

      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{position: 30}]
      @Consumption.filter.selectionType: #INTERVAL
  key fldate                as FlightDate,

      @EndUserText.label: '항공사명'
      @UI.lineItem: [{ position: 11 }]
      _Carrier.carrname     as AirlineName,

      @UI.lineItem: [{ position: 40 }]
      @Semantics.amount.currencyCode: 'Currency' // 통화코드를 적용
      price                 as PriceWithCurrency,

      @UI.lineItem: [{ position: 50 }]           // 통화코드를 미적용
      price                 as PriceWithoutCurrency,

      @Semantics.currencyCode: true              // 통화코드는 출력하지 않음
      currency              as Currency,

      @UI.lineItem: [{ position: 60 }]
      _Connection.countryfr as CountryFrom,

      /** Association */
      _Carrier,
      _Connection
}
