with

user_licences_aggregations as (
    select
        user_id,
        min(licence_started_at) as first_licence_started_at,
        max(licence_expires_at) as last_licence_expires_at
    from {{ref('stg_licences')}}
    group by 1
),

user_week as (
    select
        user_id,
        date_week
    from user_licences_aggregations
    inner join {{ref('weekly_spine')}}
    on  weekly_spine.date_week >= user_licences_aggregations.first_licence_started_at
    and weekly_spine.date_week <= user_licences_aggregations.last_licence_expires_at
),

weekly_user_licences as (
    select
        user_id,
        date_week,
        coalesce(sum(weekly_revenue),0) as wrr -- users can have more than one subscription at a time
    from {{ref('licences_by_week')}}
    right join user_week using(user_id, date_week)
    group by 1,2
),

final as (
    select
        date_week,
        user_id,
        wrr,
        wrr > 0 as is_active,
        -- calculate first and last weeks
        min(case when wrr > 0 then date_week end) over (
            partition by user_id
        ) as first_active_week,
        max(case when wrr > 0 then date_week end) over (
            partition by user_id
        ) as last_active_week
    from weekly_user_licences
)

select 
    date_week,
    user_id,
    wrr,
    is_active,
    first_active_week,
    last_active_week,
    -- calculate if this record is the first or last week
    first_active_week = date_week as is_first_week,
    last_active_week = date_week as is_last_week
from final
