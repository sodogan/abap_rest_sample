CLASS zcx_rest_handler DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    DATA parameter TYPE string .
    DATA sm59_dest TYPE rfcdest .

     CONSTANTS:
      BEGIN OF failed_to_get_subscriptionkey,
        msgid TYPE symsgid VALUE 'ZREST_HANDLER',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'PARAMETER',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF failed_to_get_subscriptionkey .

    CONSTANTS:
      BEGIN OF unauthorized,
        msgid TYPE symsgid VALUE 'ZREST_HANDLER',
        msgno TYPE symsgno VALUE '401',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF unauthorized .
    CONSTANTS:
      BEGIN OF not_found,
        msgid TYPE symsgid VALUE 'ZREST_HANDLER',
        msgno TYPE symsgno VALUE '404',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_found .
    CONSTANTS:
      BEGIN OF bad_request,
        msgid TYPE symsgid VALUE 'ZREST_HANDLER',
        msgno TYPE symsgno VALUE '400',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF bad_request .
    CONSTANTS:
      BEGIN OF internal_server_error,
        msgid TYPE symsgid VALUE 'ZREST_HANDLER',
        msgno TYPE symsgno VALUE '500',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF internal_server_error .
    CONSTANTS:
      BEGIN OF http_client_creation_failed,
        msgid type symsgid value '/UI2/CORE_FES',
        msgno type symsgno value '007',
        attr1 type scx_attrname value 'SM59_DEST',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_creation_failed .
    CONSTANTS:
      BEGIN OF http_client_comm_failure,
        msgid TYPE symsgid VALUE 'REST_CORE_TEXTS',
        msgno TYPE symsgno VALUE '021',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_comm_failure .
    CONSTANTS:
      BEGIN OF http_client_invalid_entity,
        msgid TYPE symsgid VALUE 'REST_CORE_TEXTS',
        msgno TYPE symsgno VALUE '022',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_invalid_entity .
    CONSTANTS:
      BEGIN OF http_client_invalid_timeout,
        msgid TYPE symsgid VALUE 'REST_CORE_TEXTS',
        msgno TYPE symsgno VALUE '023',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_invalid_timeout .
    CONSTANTS:
      BEGIN OF http_client_processing_failed,
        msgid TYPE symsgid VALUE 'REST_CORE_TEXTS',
        msgno TYPE symsgno VALUE '024',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_processing_failed .
    CONSTANTS:
      BEGIN OF http_client_invalid_state,
        msgid TYPE symsgid VALUE 'REST_CORE_TEXTS',
        msgno TYPE symsgno VALUE '025',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_invalid_state .
    CONSTANTS:
      BEGIN OF http_client_initial,
        msgid TYPE symsgid VALUE 'REST_CORE_TEXTS',
        msgno TYPE symsgno VALUE '026',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF http_client_initial .
    CONSTANTS:
      BEGIN OF error_code_enum,
        bad_request           TYPE char3 VALUE '400',
        unauthorized          TYPE char3 VALUE '401',
        not_found             TYPE char3 VALUE '404',
        internal_server_error TYPE char3 VALUE '500',
      END OF error_code_enum .

    METHODS constructor
      IMPORTING
        !textid    LIKE if_t100_message=>t100key OPTIONAL
        !previous  LIKE previous OPTIONAL
        !sm59_dest TYPE rfcdest OPTIONAL
        !parameter TYPE csequence OPTIONAL.

   CLASS-METHODS raise_subscriptionkey_notfound
      IMPORTING
        !parameter      TYPE csequence
      RAISING
        zcx_rest_handler .
    CLASS-METHODS raise_http_client_creation
      IMPORTING
        !textid         LIKE if_t100_message=>t100key OPTIONAL
        !previous       LIKE previous OPTIONAL
        !sm59_dest TYPE rfcdest OPTIONAL
      RAISING
        zcx_rest_handler .
      CLASS-METHODS raise_exc_from_status_code
      IMPORTING
        !iv_status_code TYPE string
      RAISING
        zcx_rest_handler .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_rest_handler IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->sm59_dest = sm59_dest.
    me->parameter = parameter.
  ENDMETHOD.
  METHOD raise_http_client_creation.
    RAISE EXCEPTION TYPE zcx_rest_handler
      EXPORTING
        textid = zcx_rest_handler=>http_client_creation_failed
        sm59_dest = sm59_dest
      .
  ENDMETHOD.

  METHOD raise_exc_from_status_code.
    CASE iv_status_code.
      WHEN '400'.
        RAISE EXCEPTION NEW zcx_rest_handler( textid = zcx_rest_handler=>bad_request ).
      WHEN '401'.
        RAISE EXCEPTION NEW zcx_rest_handler( textid = zcx_rest_handler=>unauthorized ).
      WHEN '404'.
        RAISE EXCEPTION NEW zcx_rest_handler( textid = zcx_rest_handler=>not_found ).
      WHEN '500'.
        RAISE EXCEPTION NEW zcx_rest_handler( textid = zcx_rest_handler=>internal_server_error ).
    ENDCASE.

  ENDMETHOD.

  METHOD raise_subscriptionkey_notfound.
     raise EXCEPTION TYPE zcx_rest_handler
       EXPORTING
          textid    = zcx_rest_handler=>failed_to_get_subscriptionkey
         parameter = parameter
     .
  ENDMETHOD.

ENDCLASS.