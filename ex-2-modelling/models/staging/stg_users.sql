with

renamed as (

    select
        "User_id" as user_id,
        "School_id" as school_id,
        "Name" as name,
        "Postcode" as postcode,
        "Introduction_source" as introduction_source,
        "School_year" as school_year,
        "Signed_up_at" as signed_up_at,
        "Last_logged_in_at" as last_logged_in_at
    from {{ ref('raw_users') }}

)

select * from renamed
