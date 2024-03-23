with

user_licence_aggregations as (
    select
        user_id,
        count(licence_id) as licences,
        min(licence_started_at) as first_licence_started_at,
        max(licence_started_at) as last_licence_started_at,
        max(licence_expires_at) as last_licence_expires_at
    from {{ref('stg_licences')}}
    group by 1
),

is_customer as (
    select
        user_id,
        max(last_active_week) is null or max(last_active_week) > current_date as is_active_customer
    from {{ref('user_revenue_by_week')}}
    group by 1
),

-- here we do no aggregations since we assume only 1 trial per user
user_trials as (
    select
        user_id,
        trial_started_at,
        trial_expired_at is null as is_active_trial
    from {{ref('stg_trials')}}
),


users as (
    select
        user_id,
        school_id,
        name,
        postcode,
        introduction_source,
        school_year,
        signed_up_at,
        last_logged_in_at
    from {{ref('stg_users')}}
),

final as (
    select
        users.user_id,
        users.school_id,
        users.name,
        users.postcode,
        users.introduction_source,
        users.school_year,
        users.signed_up_at,
        users.last_logged_in_at,
        user_licence_aggregations.licences,
        user_licence_aggregations.first_licence_started_at,
        user_licence_aggregations.last_licence_started_at,
        user_licence_aggregations.last_licence_expires_at,
        user_trials.trial_started_at,
        user_trials.is_active_trial,
        coalesce(is_customer.is_active_customer, false) as is_active_customer
    from users
    left join user_licence_aggregations using(user_id)
    left join user_trials using(user_id)
    left join is_customer using(user_id)
)

select
    user_id,
    school_id,
    name,
    postcode,
    introduction_source,
    school_year,
    signed_up_at,
    last_logged_in_at,
    licences,
    first_licence_started_at,
    last_licence_started_at,
    last_licence_expires_at,
    trial_started_at,
    is_active_trial,
    is_active_customer
from final