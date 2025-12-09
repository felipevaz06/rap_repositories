@Metadata.allowExtensions: true
@EndUserText.label: '##GENERATED Travel App (###)'
@ObjectModel.semanticKey: ['TravelID'] //case-sensitive
@AccessControl.authorizationCheck: #MANDATORY
@Search.searchable: true
define root view entity ZC_TRAP100_FVF
  provider contract transactional_query
  as projection on ZR_TRAP100_FVF
  association [1..1] to ZR_TRAP100_FVF as _BaseEntity on $projection.TravelID = _BaseEntity.TravelID
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
      //Enable the full-text search with a specific fuzziness (error tolerance)
  key TravelID,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['AgencyName']
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency_StdVH',
                                                     element: 'AgencyID' }, useForValidation: true }]
      //Enable the full-text search, define a value help, and specified AgencyName as associated text.
      //The defined value help shall be automatically used for frontend validations in Fiori elements UI
      AgencyID,
      _Agency.Name              as AgencyName,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['CustomerName']
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer_StdVH',
                                                     element: 'CustomerID' }, useForValidation: true }]
      // Enable the full-text search, specify CustomerName as associated text,
      // and define a value help which will automatically be used for frontend validations in Fiori elements UIs
      CustomerID,
      _Customer.LastName        as CustomerName,
      BeginDate,
      EndDate,
      @Semantics: {
        amount.currencyCode: 'CurrencyCode'
      }
      BookingFee,
      @Semantics: {
        amount.currencyCode: 'CurrencyCode'
      }
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      Description,
      @ObjectModel.text.element: ['OverallStatusText']
      @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' }, useForValidation: true }]
      //Specify OverallStatusText as associated text and define a value help which will automatically be used for frontend validations in Fiori elements UIs.
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized,
      Attachment,
      MimeType,
      FileName,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LocalLastChangedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangedAt,
      _BaseEntity
}
