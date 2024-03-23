with

renamed as (

    select
        "Licence_id" as licence_id,
        "User_id" as user_id,
        "Subject_id" as subject_id,
        "Licence_type" as licence_type,
        "Licence_tier" as licence_tier,
        "Licence_started_at" as licence_started_at,
        "Licence_expires_at" as licence_expires_at

    from {{ ref('raw_licences') }}

)

select 
    licence_id,
    user_id,
    subject_id,
    licence_type,
    licence_tier,
    licence_started_at,
    licence_expires_at
from renamed
