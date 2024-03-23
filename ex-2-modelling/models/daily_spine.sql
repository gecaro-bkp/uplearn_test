with

days as (
    {{ 
        dbt_utils.date_spine(
            datepart="day",
            start_date="'2018-01-01'::date",
            end_date="current_date + interval '1 month'"
        )
    }}
)

select date_day from days