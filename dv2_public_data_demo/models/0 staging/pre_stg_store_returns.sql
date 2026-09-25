{#-
  pre_stg_store_returns
  =====================
  Pre-staging view: STORE_RETURNS enriched with natural BKs from CUSTOMER,
  ITEM, and STORE.

  Same shape as pre_stg_store_sales — STORE_RETURNS carries surrogate FKs
  (sr_customer_sk, sr_item_sk, sr_store_sk) which must be translated to
  natural BKs (c_customer_id, i_item_id, s_store_id) so v_stg_store_returns
  can call automate_dv.stage() against a single ref().

  Materialised as a view. Schema: staging.

  Null-FK policy: NULL surrogates filtered out (DV2 hubs require non-null
  BKs). In TPC-DS, returns reference an original sale via
  (sr_ticket_number, sr_item_sk); rows with null FKs would be orphan
  returns and are out of scope for v1.

  Dev sampling: LIMIT 50000 (smaller than sales because returns are a
  sparser table; this preserves a representative customer/item overlap
  with the 100k-row sales sample for downstream link joins).
-#}

with store_returns as (
    select * from {{ source('SNOWFLAKE_SAMPLE_DATA', 'STORE_RETURNS') }}
    where sr_customer_sk is not null
      and sr_item_sk     is not null
      and sr_store_sk    is not null
    limit 50000
),

customer as (
    select c_customer_sk, c_customer_id
    from {{ source('SNOWFLAKE_SAMPLE_DATA', 'CUSTOMER') }}
),

item as (
    select i_item_sk, i_item_id
    from {{ source('SNOWFLAKE_SAMPLE_DATA', 'ITEM') }}
),

store as (
    select s_store_sk, s_store_id
    from {{ source('SNOWFLAKE_SAMPLE_DATA', 'STORE') }}
)

select
    sr.*,
    c.c_customer_id,
    i.i_item_id,
    s.s_store_id
from store_returns sr
left join customer c on sr.sr_customer_sk = c.c_customer_sk
left join item     i on sr.sr_item_sk     = i.i_item_sk
left join store    s on sr.sr_store_sk    = s.s_store_sk
