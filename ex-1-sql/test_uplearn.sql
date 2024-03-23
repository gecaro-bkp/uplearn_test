-- Q1: Write a query that returns users' names, email addresses, states, and their
-- percentage of cancelled orders as a proportion of their overall orders.
-- questions: Is there any duplication in the orders table? No there is not
select
    users.email,
    users.state,
    sum(case when orders.status = 'Cancelled' then 1 else 0 end)
    / count(*) as orders_cancelled_over_total
from `bigquery-public-data.thelook_ecommerce.orders` as orders
inner join
    `bigquery-public-data.thelook_ecommerce.users` as users on users.id = orders.user_id
group by 1, 2

-- Q2: Write a query that returns our top 100 most popular products by number sold
-- (excluding cancelled and returned orders), along with how much money they made
-- (products.retail_price), how many unique users purchased that item, and of
-- those users who purchased that item what percentage were women.
with

    orders_women as (
        select
            order_items.product_id,
            count(distinct orders.user_id) as unique_number_of_women
        from `bigquery-public-data.thelook_ecommerce.order_items` as order_items
        inner join
            `bigquery-public-data.thelook_ecommerce.orders` as orders
            on order_items.order_id = orders.order_id
        where
            orders.gender = 'F' and order_items.status not in ('Cancelled', 'Returned')
        group by 1
    )

select
    order_items.product_id,
    count(*) as total_orders,
    count(distinct order_items.user_id) as unique_users,
    coalesce(max(orders_women.unique_number_of_women), 0)
    / count(distinct order_items.user_id) as women_ratio,
    sum(products.retail_price) - sum(products.cost) as net_profit
from `bigquery-public-data.thelook_ecommerce.order_items` as order_items
inner join
    `bigquery-public-data.thelook_ecommerce.products` as products
    on products.id = order_items.product_id
left join orders_women on orders_women.product_id = order_items.product_id
where status not in ('Cancelled', 'Returned')
group by 1
order by 2 desc
limit 100

-- Q3: The `events` table contains a record of a user's activity on our website. Let's
-- call a user's FIRST (chronologically by events.created_at) traffic source their
-- `acquisition_channel`.
-- Write a query that returns our acquisition_channels, how many users we have
-- acquired through that channel, how many orders have been made from users with that
-- acquisition channel, our overall revenue from users acquired by that channel, and
-- the percentage of overall revenue that channel has been responsible for.
-- For this question, we are only interested in users acquired in 2021.
with
    user_acquisition_channels_2021 as (
        select distinct
            user_id,
            first_value(traffic_source ignore nulls) over (
                partition by user_id
                order by created_at asc
                rows between unbounded preceding and current row
            ) as first_traffic_source,
        from `bigquery-public-data.thelook_ecommerce.events`
        where extract(year from created_at) = 2021
    ),

    order_items_2021_onwards as (
        select user_id, order_id, sale_price, created_at
        from `bigquery-public-data.thelook_ecommerce.order_items`
        where extract(year from created_at) >= 2021
    ),

    total_revenue as (
        select sum(sale_price) as total_revenue from order_items_2021_onwards
    )

select
    user_acquisition_channels_2021.first_traffic_source,
    count(distinct order_items.user_id) as users,
    count(distinct order_items.order_id) as orders,
    sum(order_items.sale_price) as channel_revenue,
    100
    * sum(order_items.sale_price)
    / max(total_revenue.total_revenue) as channel_revenue_share,
from user_acquisition_channels_2021
inner join
    order_items_2021_onwards as order_items
    on order_items.user_id = user_acquisition_channels_2021.user_id
inner join total_revenue on 1 = 1
group by 1
;
