{#-
  rv_s_customer_core
  ==================
  Core descriptive satellite for hub_customer.
  Captures customer attributes that change slowly: name, salutation, email,
  birth year, preferred-customer flag.

  Parent: rv_h_customer (CUSTOMER_HK)
  Change detection: CUSTOMER_HASHDIFF (computed upstream in v_stg_customer
  across the same payload columns)
  SCD2 via append-only: each detected change inserts a new row keyed on
  (CUSTOMER_HK, LOAD_DATETIME); latest LOAD_DATETIME wins for current state.

  Not included here (deliberate scope cut for v1):
    - Address attributes → roadmap: rv_s_customer_address (separate sat,
      changes more frequently than core demographics)
    - Demographics (marital, education, income band) → roadmap:
      rv_s_customer_demographics (churnier; isolating keeps core stable)
    - Effective-from / effective-to → roadmap: effectivity sat. LOAD_DATETIME
      currently serves as the effectivity marker.
-#}

{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "CUSTOMER_HK" -%}
{%- set src_hashdiff = "CUSTOMER_HASHDIFF" -%}
{%- set src_payload = ["C_FIRST_NAME",
                       "C_LAST_NAME",
                       "C_SALUTATION",
                       "C_EMAIL_ADDRESS",
                       "C_BIRTH_YEAR",
                       "C_PREFERRED_CUST_FLAG"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk,
                   src_hashdiff=src_hashdiff,
                   src_payload=src_payload,
                   src_ldts=src_ldts,
                   src_source=src_source,
                   source_model=source_model) }}
