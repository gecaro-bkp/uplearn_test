with

renamed as (

    select
        "School_id" as school_id,
        "School_name" as school_name,
        "School_postcode" as school_postcode,
        "Number_of_pupils" as number_of_pupils

    from {{ ref('raw_schools') }}

)

select * from renamed