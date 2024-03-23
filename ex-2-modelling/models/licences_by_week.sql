with

stg_transactions_licences as (
    select
        stg_licences.licence_id,
        stg_licences.user_id,
        stg_transactions.amount / case
            when licence_type = 'Weekly'
            then 1
            when licence_type = 'Monthly'
            then (4 + 1/3) -- weeks in a month
            when licence_type = 'Quarterly'
            then 13 -- weeks in a quarter
            when licence_type = 'Yearly'
            then 52.17 -- weeks in a year
        end as revenue_amount, -- calculate the corresponding weekly amount
        stg_transactions.transaction_occured_at,
        stg_transactions.transaction_occured_at + case
            when licence_type = 'Weekly'
            then interval '1 week'
            when licence_type = 'Monthly'
            then interval '1 month'
            when licence_type = 'Quarterly'
            then interval '3 month'
            when licence_type = 'Yearly'
            then interval '1 year'
            else interval '0 day'
        end as next_transaction_expected_at
    from {{ ref("stg_transactions") }}
    inner join {{ ref("stg_licences") }} using (licence_id)
),

weeks as (
    select date_week
    from {{ref('weekly_spine')}}
),

final as (
    select
        licence_id,
        user_id,
        revenue_amount as weekly_revenue,
        date_week
    from stg_transactions_licences
    left join weeks on stg_transactions_licences.transaction_occured_at <= weeks.date_week
        -- end date is after the date we want in out model, or there is no end date
        and (stg_transactions_licences.next_transaction_expected_at > weeks.date_week
               or stg_transactions_licences.next_transaction_expected_at is null)
)

select
    licence_id,
    user_id,
    weekly_revenue,
    date_week
from final