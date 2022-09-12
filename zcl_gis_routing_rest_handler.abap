***********************************************************************
* Class           : ZCL_GRAPHHOPPER_REST_HANDLER                      *
* Package         : ZML_SHARED                                        *
*                                                                     *
* Author          : Michal Brulinski, Tieto                           *
*                                                                     *
* Description     : Initialize instance of HTTP Client                *
*                   and set its header fields                         *
*                   Uses REST client to retrieve the data.            *
*                                                                     *
* Change history:                                                     *
* Date       // Author                    // Description              *
* ------------------------------------------------------------------- *
* 27.08.2022 // Michal Brulinski, Tieto   // First version created    *
*                                                                     *
**********************************************************************
CLASS zcl_gis_routing_rest_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC INHERITING FROM zcl_rest_handler_base.

  PUBLIC SECTION.
     CONSTANTS c_subscription_id TYPE string VALUE 'APIM_GIS_ROUTING'.
     CONSTANTS c_rfc_dest TYPE rfcdest VALUE 'APIM_GIS_ROUTING'.

    TYPES:
      BEGIN OF ty_calculate_route_dist_resp,
        time     TYPE string,
        distance TYPE string,
      END OF ty_calculate_route_dist_resp .


    METHODS constructor
      RAISING
                zcx_rest_handler .
    METHODS calculate_route_distance
      IMPORTING
        !iv_start_point TYPE string
        !iv_end_point   TYPE string
      CHANGING
        !ev_distance    TYPE int4
        !ev_time        TYPE int4
      RAISING
        zcx_unexpected_exception
        zcx_rest_handler .


  PROTECTED SECTION.
    METHODS create_http_client REDEFINITION .
    METHODS set_http_header_fields REDEFINITION.
    METHODS create_by_destination REDEFINITION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_gis_routing_rest_handler IMPLEMENTATION.


  METHOD calculate_route_distance.
***********************************************************************
* Class           : ZCL_GRAPHHOPPER_REST_HANDLER                      *
* Package         : ZML_SHARED                                        *
*                                                                     *
* Author          : Michal Brulinski, Tieto                           *
*                                                                     *
* Description     : Implementation of GET method for                  *
*                   Calculate Route Distance in Azure GIS Routing Service
*                   https://confluence.shared.tds.metsagroup.com/display/MFORIS/Azure+GIS+Routing+Services
*                   Build REST call to outside API                    *
*                   Uses REST client to retrieve the data.            *
*                                                                     *
* Change history:                                                     *
* Date       // Author                    // Description              *
* ------------------------------------------------------------------- *
* 17.08.2022 // Michal Brulinski, Tieto   // First version created    *
*                                                                     *
***********************************************************************
    DATA: lr_json   TYPE REF TO /ui2/cl_json,
          lr_entity TYPE REF TO if_rest_entity.

    DATA: lv_return        TYPE bapiret2,
          lv_errortxt      TYPE string,
          lv_uri           TYPE string,
          lv_start_point_x TYPE string,
          lv_start_point_y TYPE string,
          lv_end_point_x   TYPE string,
          lv_end_point_y   TYPE string,

          ls_response_data TYPE ty_calculate_route_dist_resp.

    CHECK me->mr_http_client IS BOUND.
    CHECK me->mr_rest_client IS BOUND.

    " Extract coordinates from startpoint and endpoint strings
    SPLIT iv_start_point AT ' ' INTO lv_start_point_x lv_start_point_y.
    SPLIT iv_end_point AT ' ' INTO lv_end_point_x lv_end_point_y.

    "Start point or endpoint can not be empty otherwise raise an exception
    IF lv_start_point_x IS INITIAL OR
       lv_start_point_y IS INITIAL OR
       lv_end_point_x IS INITIAL OR
       lv_end_point_y IS INITIAL.
      RAISE EXCEPTION TYPE zcx_unexpected_exception MESSAGE e005(zml_gis_amdp).
    ENDIF.
    " Insert decimal point after 2 leading characters
    CONCATENATE lv_start_point_x(2) '.' lv_start_point_x+2 INTO lv_start_point_x.
    CONCATENATE lv_start_point_y(2) '.' lv_start_point_y+2 INTO lv_start_point_y.
    CONCATENATE lv_end_point_x(2) '.' lv_end_point_x+2 INTO lv_end_point_x.
    CONCATENATE lv_end_point_y(2) '.' lv_end_point_y+2 INTO lv_end_point_y.

* Build URI
*    lv_uri = '/new_mapservertest/services/routing/route?point=START_POINT_Y%2CSTART_POINT_X&point=END_POINT_Y%2CEND_POINT_X&type=json&locale=en-GB&vehicle=car&weighting=fastest&elevation=false&key=&points_encoded=false&instructions=false'.
    lv_uri = 'mfo/gis/routing/route?point=START_POINT_X%2CSTART_POINT_Y&point=END_POINT_X%2CEND_POINT_Y&profile=car_fastest&calc_points=false'.

    REPLACE 'START_POINT_Y' WITH lv_start_point_y INTO lv_uri.
    REPLACE 'START_POINT_X' WITH lv_start_point_x INTO lv_uri.
    REPLACE 'END_POINT_X' WITH lv_end_point_x INTO lv_uri.
    REPLACE 'END_POINT_Y' WITH lv_end_point_y INTO lv_uri.

    cl_http_utility=>set_request_uri(
      EXPORTING
        request = me->mr_http_client->request
        uri     = lv_uri ).


* Call Request
*    TRY.
        " GET request
        me->mr_rest_client->if_rest_client~get( ).
        " Collect response
        DATA(lo_response) = me->mr_rest_client->if_rest_client~get_response_entity( ).

        DATA(lt_response_headers) = me->mr_rest_client->if_rest_client~get_response_headers( ).
        DATA(lv_http_status) = lo_response->get_header_field( '~status_code' ).

        "Receive the response data in JSON.
        DATA(lv_string_data) = lo_response->get_string_data( ).

        "request failed -> STOP Processing
        IF lv_http_status NE 200.
          zcx_rest_handler=>raise_exc_from_status_code( lv_http_status ).
        ENDIF.

        " Parse the response into structure
        IF lv_string_data IS NOT INITIAL.
          /ui2/cl_json=>deserialize(
            EXPORTING
              json = lv_string_data    " JSON string
            CHANGING
              data = ls_response_data       " Data to serialize
          ).
          ev_distance = ls_response_data-distance.
          ev_time = ls_response_data-time.
        ENDIF.
*Close the connection
        mr_rest_client->if_rest_client~close( ).
        "exception handling
*      CATCH cx_rest_client_exception INTO DATA(lo_rest_client_excp).
*        RAISE EXCEPTION NEW zcx_rest_handler( previous = lo_rest_client_excp ).
*    ENDTRY.

  ENDMETHOD.


  METHOD constructor.
    super->constructor( iv_subscription_id  = c_subscription_id ).
** Call the init
    init(  ).
  ENDMETHOD.


  METHOD create_http_client.
    create_by_destination( rfc_destination = c_rfc_dest ).
    set_http_header_fields( ).

  ENDMETHOD.


  METHOD set_http_header_fields.
    super->set_http_header_fields( ).
  ENDMETHOD.


  METHOD create_by_destination.
    super->create_by_destination( rfc_destination = rfc_destination ).
  ENDMETHOD.

ENDCLASS.