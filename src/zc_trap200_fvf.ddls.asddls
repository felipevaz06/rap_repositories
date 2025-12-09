@EndUserText.label: 'Travel Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true

@Search.searchable: true
define root view entity ZC_TRAP200_FVF
  provider contract transactional_query
  as projection on ZR_TRAP200_FVF
  association [1..1] to ZR_TRAP200_FVF as _BaseEntity on $projection.TravelID = _BaseEntity.TravelID
{
  @Search.defaultSearchElement: true
  key TravelID,
  Descripion,
  
  @ObjectModel.text.element: ['StatusText'] 
  @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Travel_Status_VH_Text', element: 'TravelStatus' }, useForValidation: true}]
   TravelStatus,
  _TravelStatus._Text.Text as StatusText : localized, 
  
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
