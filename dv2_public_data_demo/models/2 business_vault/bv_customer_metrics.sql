{#-
  bv_customer_metrics
  ===================
  Customer-level derived metrics from the raw vault: gross sales, returns,
  net spend, customer lifetime value (LTV), order/return counts.

  Why this lives in BV (not RV or IM):
    - The LTV *formula* is an analytical decision (gross vs net, lifetime
      vs trailing-12-months, etc.). Isolating it here means changing the
      definition doesn't trigger a raw-vault rebuild.
    - IM pulls from BV for BI consumption — public-facing dashboards
      should never join raw hubs directly.

  Source joins:
    - rv_h_customer (CUSTOMER_HK + C_CUSTOMER_ID for audit)
    - rv_nhl_sale_transaction (sale measures, payload-on-link)
    - rv_nhl_return_transaction (return measures, payload-on-link)

  Materialised as a table (from `2 business_vault/` folder config).
-#}

with customers as (
    select customer_hk, c_customer_id, load_datetime
    from {{ ref('rv_h_customer') }}
),

sales as (
    select
        customer_hk,
        ss_quantity,
        ss_sales_price,
        ss_ext_sales_price,
        ss_net_paid,
        ss_net_profit
    from {{ ref('rv_nhl_sale_transaction') }}
),

returns as (
    select
        customer_hk,
        sr_return_quantity,
        sr_return_amt,
        sr_net_loss
    from {{ ref('rv_nhl_return_transaction') }}
),

sales_rolled as (
    select
        customer_hk,
        count(*)                       as sale_line_count,
        sum(ss_quantity)               as units_sold,
        sum(ss_ext_sales_price)        as gross_sales,
        sum(ss_net_paid)               as net_paid,
        sum(ss_net_profit)             as gross_profit
    from sales
    group by 1
),

returns_rolled as (
    select
        customer_hk,
        count(*)                       as return_line_count,
        sum(sr_return_quantity)        as units_returned,
        sum(sr_return_amt)             as gross_returns,
        sum(sr_net_loss)               as net_loss
    from returns
    group by 1
),

joined as (
    select
        c.customer_hk,
        c.c_customer_id,
        coalesce(s.sale_line_count, 0)    as sale_line_count,
        coalesce(s.units_sold,      0)    as units_sold,
        coalesce(s.gross_sales,     0)    as gross_sales,
        coalesce(s.net_paid,        0)    as net_paid,
        coalesce(s.gross_profit,    0)    as gross_profit,
        coalesce(r.return_line_count, 0)  as return_line_count,
        coalesce(r.units_returned,    0)  as units_returned,
        coalesce(r.gross_returns,     0)  as gross_returns,
        coalesce(r.net_loss,          0)  as net_loss
    from customers c
    left join sales_rolled   s on c.customer_hk = s.customer_hk
    left join returns_rolled r on c.customer_hk = r.customer_hk
),

with_ltv as (
    select
        *,

        -- TODO(human): define customer_ltv below.
        --
        -- Multiple valid LTV definitions, all interview-defendable. The
        -- choice signals what business question you think LTV answers.
        --
        -- (A) Lifetime gross sales:
        --       gross_sales as customer_ltv
        --     Simplest. "Total value of everything they ever bought, ignoring returns."
        --
        -- (B) Lifetime net (sales minus returns):
        --       (gross_sales - gross_returns) as customer_ltv
        --     "Total value they actually kept." Common in retail.
        --
        -- (C) Net profit (sales minus returns minus cost):
        --       (gross_profit - net_loss) as customer_ltv
        --     "Total profit we made from them." Most aligned with shareholder
        --     value; less aligned with marketing's view of LTV.
        --
        -- (D) Net paid (already accounts for promotional discounts):
        --       net_paid as customer_ltv
        --     Cleanest "cash received from this customer" number.
        --
        -- You can also add derived ratios alongside LTV — e.g.,
        --   return_rate = units_returned / nullif(units_sold, 0)
        --   avg_order_value = gross_sales / nullif(sale_line_count, 0)
        --
        -- Write 5-10 lines that define customer_ltv and 1-2 derived ratios
        -- you think are worth surfacing. The IM layer (im_transactions)
        -- and downstream BI tools will consume what you expose here.

        -- BEGIN_TODO(human) ─────────────────────────────────────────────
        -- END_TODO(human) ───────────────────────────────────────────────

        current_timestamp() as last_refreshed_at
    from joined
)

select * from with_ltv
