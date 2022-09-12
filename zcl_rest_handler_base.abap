CLASS zcl_rest_handler_base DEFINITION
  PUBLIC
  CREATE PUBLIC  ABSTRACT.

  PUBLIC SECTION.
    INTERFACES zif_rest_handler ALL METHODS ABSTRACT.
    ALIASES c_auth FOR zif_rest_handler~c_auth.
    ALIASES c_content_type FOR zif_rest_handler~c_content_type.
    ALIASES c_accept FOR zif_rest_handler~c_accept.
    ALIASES c_application_json FOR zif_rest_handler~c_application_json.
    ALIASES c_subscription_key FOR zif_rest_handler~c_subscription_key.

    METHODS constructor
      IMPORTING iv_subscription_id TYPE csequence
      RAISING
                zcx_rest_handler .
    METHODS init RAISING
                   zcx_rest_handler .
  PROTECTED SECTION.
    METHODS create_http_client ABSTRACT
      RAISING
        zcx_rest_handler .
    METHODS set_http_header_fields.
    METHODS create_by_destination
      IMPORTING rfc_destination TYPE c
      RAISING
                zcx_rest_handler.
    METHODS create_rest_client
      IMPORTING http_client TYPE REF TO if_http_client.

    METHODS get_subscription_key
      IMPORTING iv_id TYPE string.

    DATA mr_http_client TYPE REF TO if_http_client .
    DATA mr_rest_client TYPE REF TO cl_rest_http_client .
    DATA: mv_subscription_key TYPE string.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_REST_HANDLER_BASE IMPLEMENTATION.


  METHOD constructor.
** All the subclasses will automatically call here

**First get the subscription key
    get_subscription_key( iv_id = iv_subscription_id ).

  ENDMETHOD.


  METHOD init.
**Call the necessary steps for building the client
*Create HTTP Client object
*Create REST Client object

** Call to set the header fields
    TRY.
*Create HTTP Client object
        create_http_client( ).
        create_rest_client( http_client = me->mr_http_client ).
      CATCH cx_rest_client_exception INTO DATA(lr_rest_exception).
        RAISE EXCEPTION TYPE zcx_rest_handler
          EXPORTING
        textid = zcx_rest_handler=>http_client_creation_failed
      .
    ENDTRY.

  ENDMETHOD.





  METHOD get_subscription_key.

    me->mv_subscription_key  =  zcl_subscription_manager=>get_subscription_key( subscription_id = iv_id ).

  ENDMETHOD.


  METHOD create_by_destination.
    CALL METHOD cl_http_client=>create_by_destination
      EXPORTING
        destination              = rfc_destination
      IMPORTING
        client                   = me->mr_http_client
      EXCEPTIONS
        destination_not_found    = 1
        internal_error           = 2
        argument_not_found       = 3
        destination_no_authority = 4
        plugin_not_active        = 5
        OTHERS                   = 5.
    IF sy-subrc NE 0.
*      GET TIME STAMP FIELD lv_utc_timestamp. "if app log handle needed
*      es_return = me->get_bapiret2( ).
      RAISE EXCEPTION NEW zcx_rest_handler( textid = zcx_rest_handler=>http_client_creation_failed ).
    ENDIF.
  ENDMETHOD.


  METHOD set_http_header_fields.
*Set HTTP header fields
    me->mr_http_client->request->set_header_field(
      EXPORTING
        name  = c_accept
        value = c_application_json ).
    me->mr_http_client->request->set_header_field(
      EXPORTING
        name  = c_content_type
        value = c_application_json ).

*Set the subscription key here
    me->mr_http_client->request->set_header_field(
      EXPORTING
        name  = c_subscription_key
        value = mv_subscription_key ).

*  Set version
    me->mr_http_client->request->set_version(
      if_http_request=>co_protocol_version_1_1 ).
  ENDMETHOD.


  METHOD create_rest_client.
    IF http_client IS BOUND.
      CREATE OBJECT me->mr_rest_client
        EXPORTING
          io_http_client = http_client.
    ENDIF.
  ENDMETHOD.
ENDCLASS.