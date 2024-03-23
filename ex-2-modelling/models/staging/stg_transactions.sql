with 

renamed as (

    select
        "Transaction_id" as transaction_id,
        "Licence_id" as licence_id,
        "Type" as type,
        "Amount" as amount,
        "Transaction_occured_at" as transaction_occured_at

    from {{ ref('raw_transactions') }}

)

select * from renamed
