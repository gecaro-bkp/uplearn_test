with

schools as(
    select
        school_id,
        school_name,
        school_postcode,
        number_of_pupils
    from {{ref('stg_schools')}}
),

school_licences as (
    select
        stg_users.school_id,
        count(stg_licences.licence_id) as licences
    from {{ref('stg_users')}}
    inner join {{ref('stg_licences')}} using(user_id)
    group by 1
),

final as (
    select
        schools.school_id,
        schools.school_name,
        schools.school_postcode,
        schools.number_of_pupils,
        school_licences.licences
    from schools
    left join school_licences using(school_id)
)

select
    school_id,
    school_name,
    school_postcode,
    number_of_pupils,
    licences
from final
