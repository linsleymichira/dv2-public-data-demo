{#-
  pre_stg_store_sales
  ===================
  Pre-staging view: STORE_SALES enriched with natural BKs from CUSTOMER,
  ITEM, and STORE.

  Purpose: AutomateDV's automate_dv.stage() macro accepts ONE source and
  does not perform joins. STORE_SALES carries surrogate FKs (ss_customer_sk,
  ss_item_sk, ss_store_sk) but our hubs hash *natural* BKs (c_customer_id,
  i_item_id, s_store_id) to stay consistent with v_stg_customer / v_stg_store.
  This view translates surrogates → natural BKs so v_stg_store_sales can
  call stage() against a single ref() and produce matching hash keys.

  Materialised as a view (inherited from `0 staging/` folder config).
  Schema: staging.

  Null-FK policy: anonymous walk-in sales (NULL surrogates, ~3-5% of rows)
  are filtered. DV2 hubs require non-null BKs; ghost-record pattern is v1.1.

  Dev sampling: LIMIT 100000 keeps SF10-scale iteration fast.
-#}

with store_sales as (
    select * from {{ source('SNOWFLAKE_SAMPLE_DATA', 'STORE_SALES') }}
    where ss_customer_sk is not null
      and ss_item_sk     is not null
      and ss_store_sk    is not null
    limit 100000
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
    ss.*,
    c.c_customer_id,
    i.i_item_id,
    s.s_store_id
from store_sales ss
left join customer c on ss.ss_customer_sk = c.c_customer_sk
left join item     i on ss.ss_item_sk     = i.i_item_sk
left join store    s on ss.ss_store_sk    = s.s_store_sk
