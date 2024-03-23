with

trials as (
    select
        trial_id,
        user_id,
        subject_id,
        trial_started_at,
        trial_expired_at
    from {{ref('stg_trials')}}
),

days as (
    select date_day
    from {{ref('daily_spine')}}
),

final as (
    select
        trial_id,
        user_id,
        subject_id,
        date_day
    from trials
    left join days on trials.trial_started_at <= days.date_day
        -- end date is after the date we want in out model, or there is no end date
        and (trials.trial_expired_at > days.date_day
               or trials.trial_expired_at is null)
)

select
    trial_id,
    user_id,
    subject_id,
    date_day
from final