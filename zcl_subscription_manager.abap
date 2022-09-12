CLASS zcl_subscription_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC ABSTRACT .

  PUBLIC SECTION.
    CLASS-METHODS get_subscription_key
      IMPORTING
                subscription_id         TYPE string
      RETURNING VALUE(subscription_key) TYPE string
      RAISING   zcx_rest_handler.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_subscription_manager IMPLEMENTATION.



  METHOD get_subscription_key.
    DATA: lv_subscription_id TYPE string.

    lv_subscription_id = subscription_id.
**Might need to get the data based on the client
** We will append WSD, WSQ, WSP at the end of id
*    CASE sy-sysid.
*      WHEN 'WSD'.
*        lv_subscription_id = lv_subscription_id && |_WSD|.
*      WHEN 'WSQ' OR 'WSX'.
*        lv_subscription_id = lv_subscription_id && |_WSQ|.
*      WHEN 'WSP'.
*        lv_subscription_id = lv_subscription_id && |_WSP|.
*    ENDCASE.

    SELECT SINGLE par_value
      FROM zpar
      INTO subscription_key
      WHERE par_id LIKE lv_subscription_id.

    IF sy-subrc NE 0.
*Throw exception here!
      zcx_rest_handler=>raise_subscriptionkey_notfound(
        EXPORTING
          parameter = lv_subscription_id
      ).


    ENDIF.

  ENDMETHOD.

ENDCLASS.