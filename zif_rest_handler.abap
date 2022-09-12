INTERFACE zif_rest_handler
  PUBLIC .
  CONSTANTS c_auth TYPE string VALUE 'Authorization' ##NO_TEXT.
  CONSTANTS c_content_type TYPE string VALUE 'content-type'.
  CONSTANTS c_accept TYPE string VALUE 'ACCEPT' ##NO_TEXT.
  CONSTANTS c_application_json TYPE string VALUE 'application/json'.
  CONSTANTS c_subscription_Key TYPE string VALUE 'Ocp-Apim-Subscription-Key'.

  CONSTANTS: gc_e TYPE dd26e-enqmode VALUE 'E'.


ENDINTERFACE.