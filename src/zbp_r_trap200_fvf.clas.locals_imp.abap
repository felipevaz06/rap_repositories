
CLASS lsc_saver DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_saver IMPLEMENTATION.

  METHOD save_modified.

  DATA : ls_travel TYPE STRUCTURE FOR CREATE ZR_TRAP200_FVF,
         lt_travel TYPE STANDARD TABLE OF ZTRAP200_FVF,
         LT_TRAVEL_UPD TYPE STANDARD TABLE OF ZTRAP200_FVF.




    IF create IS NOT INITIAL.

      lt_travel = CORRESPONDING #( create-travel MAPPING FROM ENTITY ).

      "Insert record into DB
      INSERT ZTRAP200_FVF FROM TABLE @lt_travel .

    ENDIF.

    IF update IS NOT INITIAL.

    lt_travel = CORRESPONDING #( update-travel MAPPING FROM ENTITY ).
    IF lt_travel IS NOT INITIAL.
    lt_travel_upd = CORRESPONDING #( update-travel MAPPING FROM ENTITY ).


        SELECT * FROM ZTRAP200_FVF FOR ALL ENTRIES IN @lt_travel
               WHERE travel_id = @lt_travel-travel_id
               INTO TABLE @DATA(lt_travel_old).

        lt_travel = VALUE #( FOR x = 1 WHILE x <= lines( lt_travel_upd )
                             LET ls_unmanaged_travel = VALUE #( update-travel[ x ] OPTIONAL )
                                 ls_travel_upd = VALUE #( lt_travel_upd[ x ] OPTIONAL )
                                 ls_travel_old = VALUE #( lt_travel_old[
                                      travel_id             = ls_travel_upd-travel_id
                                                            ] OPTIONAL )
                             IN (
                                        travel_id   = ls_travel_old-travel_id
                                        created_by  = ls_travel_old-created_by
                                        created_at  = ls_travel_old-created_at

                                        descripion  = COND #( WHEN ls_unmanaged_travel-%control-Descripion = if_abap_behv=>mk-on
                                                                THEN ls_travel_upd-descripion
                                                                ELSE ls_travel_old-descripion  )
                                        travel_status  = COND #( WHEN ls_unmanaged_travel-%control-TravelStatus = if_abap_behv=>mk-on
                                                                THEN ls_travel_upd-travel_status
                                                                ELSE ls_travel_old-travel_status )
                                        last_changed_at  = COND #( WHEN ls_unmanaged_travel-%control-LastChangedAt = if_abap_behv=>mk-on
                                                                THEN ls_travel_upd-last_changed_at
                                                                ELSE ls_travel_old-last_changed_at )
                                        local_last_changed_by  = COND #( WHEN ls_unmanaged_travel-%control-LocalLastChangedBy = if_abap_behv=>mk-on
                                                                THEN ls_travel_upd-local_last_changed_by
                                                                ELSE ls_travel_old-local_last_changed_by )
                              )
         ).

     MODIFY ztrap200_fvf FROM TABLE @lt_travel.
    ENDIF.



    ENDIF.

    IF delete IS NOT INITIAL.
        lt_travel = CORRESPONDING #( delete-travel MAPPING FROM ENTITY ).

        DELETE ztrap200_fvf FROM TABLE @lt_travel.
    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS LHC_ZR_TRAP200_FVF DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
  CONSTANTS:
      BEGIN OF travel_status,
        new      TYPE c LENGTH 1 VALUE 'N', "New
        booked   TYPE c LENGTH 1 VALUE 'B', "Booked
        planned  TYPE c LENGTH 1 VALUE 'P', "Planned
        canceled TYPE c LENGTH 1 VALUE 'X', "Cancelled
      END OF travel_status.


    METHODS:

      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR travel
        RESULT result,
      earlynumbering_create FOR NUMBERING
            IMPORTING entities FOR CREATE Travel,
      setStatusToNew FOR DETERMINE ON MODIFY
            IMPORTING keys FOR Travel~setStatusToNew.

ENDCLASS.

CLASS LHC_ZR_TRAP200_FVF IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.




  METHOD earlynumbering_create.
  DATA:
      entity           TYPE STRUCTURE FOR CREATE zr_trap200_fvf,
      travel_id_max    TYPE /dmo/travel_id,
      " change to abap_false if you get the ABAP Runtime error 'BEHAVIOR_ILLEGAL_STATEMENT'
      use_number_range TYPE abap_bool VALUE abap_true.

    "Ensure Travel ID is not set yet (idempotent)- must be checked when BO is draft-enabled
    LOOP AT entities INTO entity WHERE TravelID IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.

    DATA(entities_wo_travelid) = entities.
    "Remove the entries with an existing Travel ID
    DELETE entities_wo_travelid WHERE TravelID IS NOT INITIAL.

    IF use_number_range = abap_true.
      "Get numbers
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = '/DMO/TRV_M'
              quantity          = CONV #( lines( entities_wo_travelid ) )
            IMPORTING
              number            = DATA(number_range_key)
              returncode        = DATA(number_range_return_code)
              returned_quantity = DATA(number_range_returned_quantity)
          ).
        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          LOOP AT entities_wo_travelid INTO entity.
            APPEND VALUE #(  %cid      = entity-%cid
                             %key      = entity-%key
                             %is_draft = entity-%is_draft
                             %msg      = lx_number_ranges
                          ) TO reported-travel.
            APPEND VALUE #(  %cid      = entity-%cid
                             %key      = entity-%key
                             %is_draft = entity-%is_draft
                          ) TO failed-travel.
          ENDLOOP.
          EXIT.
      ENDTRY.

      "determine the first free travel ID from the number range
      travel_id_max = number_range_key - number_range_returned_quantity.
    ELSE.
      "determine the first free travel ID without number range
      "Get max travel ID from active table
      SELECT SINGLE FROM ztrap200_fvf FIELDS MAX( travel_id ) AS travelID INTO @travel_id_max.
      "Get max travel ID from draft table
      SELECT SINGLE FROM ztrap200_fvf_d FIELDS MAX( travelid ) INTO @DATA(max_travelid_draft).
      IF max_travelid_draft > travel_id_max.
        travel_id_max = max_travelid_draft.
      ENDIF.
    ENDIF.

    "Set Travel ID for new instances w/o ID
    LOOP AT entities_wo_travelid INTO entity.
      travel_id_max += 1.
      entity-TravelID = travel_id_max.

      APPEND VALUE #( %cid      = entity-%cid
                      %key      = entity-%key
                      %is_draft = entity-%is_draft
                    ) TO mapped-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD setStatusToNew.
  READ ENTITIES OF zr_trap200_fvf IN LOCAL MODE
     ENTITY travel
       FIELDS ( TravelStatus )
       WITH CORRESPONDING #( keys )
     RESULT DATA(travels)
     FAILED DATA(read_failed).

    "If overall travel status is already set, do nothing, i.e. remove such instances
    DELETE travels WHERE TravelStatus IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    "else set overall travel status to open ('O')
    MODIFY ENTITIES OF zr_trap200_fvf IN LOCAL MODE
      ENTITY travel
        UPDATE FIELDS ( TravelStatus )
        WITH VALUE #( FOR travel IN travels ( %tky          = travel-%tky
                                              TravelStatus = travel_status-new ) )
    REPORTED DATA(update_reported).

    "Set the changing parameter
    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

ENDCLASS.
