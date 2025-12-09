@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel view - CDS data model'
define root view entity ZR_TRAP200_FVF 
  as select from ztrap200_fvf
  association [1..1] to /DMO/I_Travel_Status_VH as _TravelStatus on $projection.TravelStatus = _TravelStatus.TravelStatus
{
  key travel_id as TravelID,
  descripion as Descripion,
  travel_status as TravelStatus,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  
   _TravelStatus 
}
