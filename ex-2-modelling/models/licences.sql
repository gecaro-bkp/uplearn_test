with

licences as (
    select
        licence_id,
        user_id,
        subject_id,
        licence_type,
        licence_tier,
        licence_started_at,
        licence_expires_at
    from {{ref('stg_licences')}}
)

select * from licences