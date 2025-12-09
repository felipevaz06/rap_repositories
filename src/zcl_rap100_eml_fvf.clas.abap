CLASS zcl_rap100_eml_fvf DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      is_draft  TYPE if_abap_behv=>t_xflag VALUE if_abap_behv=>mk-on,  "draft: '01'
      is_active TYPE if_abap_behv=>t_xflag VALUE if_abap_behv=>mk-off. "active: '00'

    CLASS-DATA:
      travel_id      TYPE /dmo/travel_id,        "travel id
      instance_state TYPE if_abap_behv=>t_xflag, "instance state (draft or active)
      console_output TYPE REF TO if_oo_adt_classrun_out.

    METHODS:
      read_travel,
      update_travel,
      create_travel,
      delete_travel,
      activate_travel_draft,
      discard_travel_draft.
ENDCLASS.



CLASS ZCL_RAP100_EML_FVF IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " [Legende for operation execution]
    "  READ: 1 | UPDATE: 2 | CREATE: 3 | DELETE: 4 |
    "  ACTIVATE draft: 5 | DISCARD draft: 6 | ALL: 55
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "set console output instance
    console_output = out.

    "specify the operation to be executed
    DATA(execute) = 1.

    "READ a Travel BO entity instance
    IF execute = 1 OR execute = 55.
      travel_id      = '00000005'.
      instance_state = is_active.
      read_travel( ).
    ENDIF.

    "UPDATE a Travel BO entity instance
    IF execute = 2 OR execute = 55.
      travel_id      = '00000005'.
      instance_state = is_active.
      update_travel( ).
    ENDIF.

    "CREATE a Travel BO entity instance
    IF execute = 3 OR execute = 55.
      instance_state = is_active.
      create_travel( ).
    ENDIF.

    "DELETE a Travel BO entity instance
    IF execute = 4 OR execute = 55.
      travel_id      = '00000000'.
      instance_state = is_active.
      delete_travel( ).
    ENDIF.

    "ACTIVATE a draft Travel BO entity instance
    IF execute = 5 OR execute = 55.
      travel_id      = '00000005'.
      activate_travel_draft( ).
    ENDIF.

    "DISCARD a draft Travel BO entity instance
    IF execute = 6 OR execute = 55.
      travel_id      = '00000195'.
      discard_travel_draft( ).
    ENDIF.
  ENDMETHOD.


  METHOD activate_travel_draft.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Exercise 9.6: Activate a draft travel BO entity instance
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    "activate travel instance in the transactional buffer
    MODIFY ENTITIES OF zr_trap100_fvf
      ENTITY ZrTrap100Fvf
        EXECUTE Activate FROM
        VALUE #( ( %cid = 'activate_draft_travel'  %key-TravelID = travel_id ) )
     MAPPED DATA(mapped)
     FAILED DATA(failed)
     REPORTED DATA(reported).

    "persist changes
    COMMIT ENTITIES
      RESPONSE OF zr_trap100_fvf
      FAILED DATA(failed_commit)
      REPORTED DATA(reported_commit).

    IF sy-subrc = 0.

      "Exercise 9.6: ACTIVATE a draft Travel BO entity instance
      console_output->write( |{ TEXT-009 } | ).
      "- TravelID =
      console_output->write( | { TEXT-001 } { travel_id }  | ).
      IF failed IS NOT INITIAL.
      "- Cause for failed activate:
        console_output->write( |{ TEXT-003 } { failed-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ELSEIF failed_commit IS NOT INITIAL.
      "- Cause for failed commit:
        console_output->write( |{ TEXT-002 } { failed_commit-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ENDIF.
      console_output->write( |--------------------------------------------- | ).

    ENDIF.



  ENDMETHOD.


  METHOD create_travel.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Exercise 9.4: Create a travel BO entity instance
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "create in the transactional buffer
    MODIFY ENTITIES OF zr_trap100_fvf
      ENTITY ZrTrap100Fvf
        CREATE FIELDS ( CustomerID AgencyID BeginDate EndDate Description )
          WITH VALUE #( ( %cid        = 'create_travel'
                          %is_draft   = instance_state
                          CustomerID  = '15'
                          AgencyID    = '070042'
                          BeginDate   = cl_abap_context_info=>get_system_date( )
                          EndDate     = cl_abap_context_info=>get_system_date( ) + 10
                          Description = |{ TEXT-015 } { cl_abap_context_info=>get_system_time(  ) } |
                      ) )

*      "execute action `rejectTravel`
*        ENTITY travel
*        EXECUTE rejectTravel
*        FROM VALUE #( ( %cid_ref = 'create_travel' %is_draft = instance_state ) )

      MAPPED DATA(mapped)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    "persist changes
    COMMIT ENTITIES
      RESPONSE OF zr_trap100_fvf
      FAILED DATA(failed_commit)
      REPORTED DATA(reported_commit).

    IF sy-subrc = 0.

      "Exercise 9.4: CREATE a new Travel BO entity instance
      console_output->write( |{ TEXT-010 } | ).
      console_output->write( mapped-ZrTrap100Fvf ).
      IF failed IS NOT INITIAL.
      "- Cause for failed create:
        console_output->write( |{ TEXT-004 }  { failed-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ELSEIF failed_commit IS NOT INITIAL.
      "- Cause for failed commit:
        console_output->write( |{ text-002 } { failed_commit-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ENDIF.
      console_output->write( |--------------------------------------------- | ).
    ENDIF.
  ENDMETHOD.


  METHOD delete_travel.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Exercise 9.5: Delete a travel BO entity instance
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "delete in the transactional buffer
    MODIFY ENTITIES OF zr_trap100_fvf
      ENTITY ZrTrap100Fvf
        DELETE FROM
          VALUE
             #( ( TravelID = travel_id  %is_draft   = instance_state ) )
     FAILED DATA(failed)
     REPORTED DATA(reported).

    "persist changes
    COMMIT ENTITIES
      RESPONSE OF zr_trap100_fvf
      FAILED     DATA(failed_commit)
      REPORTED   DATA(reported_commit).

    IF sy-subrc = 0.
      "Exercise 9.5: DELETE a Travel BO entity instance
      console_output->write( |{ TEXT-011 } | ).
      "- TravelID =
      console_output->write( | { text-001 } { travel_id } | ).
      IF failed IS NOT INITIAL.
      "- Cause for failed delete:
        console_output->write( |{ TEXT-005 } { failed-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ELSEIF failed_commit IS NOT INITIAL.
      "- Cause for failed commit:
        console_output->write( |{ text-002 } { failed_commit-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ENDIF.
      console_output->write( |--------------------------------------------- | ).
    ENDIF.
  ENDMETHOD.


  METHOD discard_travel_draft.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Exercise 9.7: Discard a draft travel BO entity instance
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "activate travel instance in the transactional buffer
    MODIFY ENTITIES OF zr_trap100_fvf
      ENTITY ZrTrap100Fvf
        EXECUTE Discard FROM
        VALUE #( ( %key-TravelID = travel_id ) )
     MAPPED DATA(mapped)
     FAILED DATA(failed)
     REPORTED DATA(reported).

      "persist changes
      COMMIT ENTITIES
        RESPONSE OF zr_trap100_fvf
        FAILED DATA(failed_commit)
        REPORTED DATA(reported_commit).
    IF sy-subrc = 0.
      "Exercise 9.7: DISCARD a draft Travel BO entity instance
      console_output->write( |{ TEXT-012 }| ).
      "- TravelID =
      console_output->write( | { text-001 } { travel_id } | ).
      IF failed IS NOT INITIAL.
      "- Cause for failed discard:
        console_output->write( |{ TEXT-006 } { failed-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ELSEIF failed_commit IS NOT INITIAL.
      "- Cause for failed commit:
        console_output->write( |{ text-002 } { failed_commit-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
      ENDIF.
      console_output->write( |--------------------------------------------- | ).
    ENDIF.
  ENDMETHOD.


  METHOD read_travel.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Exercise 9.2: Read a travel BO entity instance
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "declare internal table using derived type
    DATA travels TYPE TABLE FOR READ IMPORT zr_trap100_fvf.

    "fill in data for READ request
    travels = VALUE #( ( TravelID = travel_id  %is_draft = instance_state ) ).

    "read from transactional buffer
    READ ENTITIES OF zr_trap100_fvf
      ENTITY ZrTrap100Fvf
        ALL FIELDS
*        FIELDS ( AgencyID CustomerID BeginDate Description )
        WITH travels
    RESULT DATA(lt_travels_read)
    FAILED DATA(failed)
    REPORTED DATA(reported).

    "Exercise 9.2: READ a Travel BO entity instance
    console_output->write( |{ TEXT-013 } | ).
    console_output->write( lt_travels_read ).
    IF failed IS NOT INITIAL.
    "- Cause for failed read =
      console_output->write( |{ TEXT-007 } { failed-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
    ENDIF.
    console_output->write( |--------------------------------------------- | ).

  ENDMETHOD.


  METHOD update_travel.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Exercise 9.3: Update a travel BO entity instance
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "update the transactional buffer
    MODIFY ENTITIES OF zr_trap100_fvf
      ENTITY ZrTrap100Fvf
        UPDATE FIELDS ( Description )
          WITH VALUE #( ( %is_draft   = instance_state
                          TravelID    = travel_id
                          Description = |{ TEXT-016 } { cl_abap_context_info=>get_system_time( ) } |
                      ) )
      FAILED DATA(failed)
      REPORTED DATA(reported).

    "persist the transactional buffer
*    COMMIT ENTITIES
*      RESPONSE OF ZRAP100_R_TravelTP_###
*      FAILED DATA(failed_commit)
*      REPORTED DATA(reported_commit).

    "Exercise 9.3: UPDATE a Travel BO entity instance
    console_output->write( |{ TEXT-014 } | ).
    "- TravelID =
    console_output->write( | { text-001 } { travel_id } / Description was updated | ).
    IF failed IS NOT INITIAL.
    "- Cause for failed update =
      console_output->write( |{ TEXT-008 } { failed-ZrTrap100Fvf[ 1 ]-%fail-cause } | ).
*    ELSEIF failed_commit IS NOT INITIAL.
*      console_output->write( |- Cause for failed commit = { failed_commit-travel[ 1 ]-%fail-cause } | ).
    ENDIF.
    console_output->write( |--------------------------------------------- | ).

  ENDMETHOD.
ENDCLASS.
