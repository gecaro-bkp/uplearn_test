with

renamed as (

    select
        "Trial_id" as trial_id,
        "User_id" as user_id,
        "Subject_id" as subject_id,
        "Trial_started_at" as trial_started_at,
        "Trial_expired_at" as trial_expired_at

    from {{ ref('raw_trials') }}

)

select * from renamed