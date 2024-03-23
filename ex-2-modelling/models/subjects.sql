with
    
subjects as (
    select
        subject_id,
        subject_name
    from {{ref('stg_subjects')}}
)

-- here we could add aggregations such as number of users per subject... 
-- or add some logic. This will eventually be joined in the transaction table
-- or other dimension tables

select
    subject_id,
    subject_name
from subjects