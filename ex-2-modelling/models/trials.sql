with

trials as (
    select
        trial_id,
        user_id,
        subject_id,
        trial_started_at,
        trial_expired_at
    from {{ref('stg_trials')}}
)

select * from trials