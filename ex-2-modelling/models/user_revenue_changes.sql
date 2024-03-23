with 

windowed_weekly_revenue as (
    select
        date_week,
        user_id,
        wrr,
        is_active,
        first_active_week,
        last_active_week,
        is_first_week,
        is_last_week,
        coalesce(
            lag(is_active) over (partition by user_id order by date_week),
            false
        ) as previous_week_is_active,
        wrr - coalesce(
            lag(wrr) over (partition by user_id order by date_week),
            0
        ) as wrr_change
    from {{ref('user_revenue_by_week')}}
),

final as (
    select 
        date_week,
        user_id,
        wrr,
        wrr_change,
        is_active,
        case
            when is_first_week
                then 'new'
            when not(is_active) and previous_week_is_active
                then 'churn'
            when is_active and not(previous_week_is_active)
                then 'reactivation'
            when wrr_change > 0 then 'upgrade'
            when wrr_change < 0 then 'downgrade'
        end as change_category
    from windowed_weekly_revenue
)

select 
    date_week,
    user_id,
    wrr,
    wrr_change,
    is_active,
    change_category
from final
