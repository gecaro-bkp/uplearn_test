with 

renamed as (

    select
        "Subject_id" as subject_id,
        "Subject_name" as subject_name

    from {{ ref('raw_subjects') }}

)

select * from renamed