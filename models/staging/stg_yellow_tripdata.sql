-- select
--     -- identifiers (standardized naming for consistency across yellow/green)
--     cast(vendorid as integer) as vendor_id,
--     cast(ratecodeid as integer) as rate_code_id,
--     cast(pulocationid as integer) as pickup_location_id,
--     cast(dolocationid as integer) as dropoff_location_id,

--     -- timestamps (standardized naming)
--     cast(tpep_pickup_datetime as timestamp) as pickup_datetime,  -- tpep = Taxicab Passenger Enhancement Program (yellow taxis)
--     cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

--     -- trip info
--     store_and_fwd_flag,
--     cast(passenger_count as integer) as passenger_count,
--     cast(trip_distance as numeric) as trip_distance,

--     -- payment info
--     cast(fare_amount as numeric) as fare_amount,
--     cast(extra as numeric) as extra,
--     cast(mta_tax as numeric) as mta_tax,
--     cast(tip_amount as numeric) as tip_amount,
--     cast(tolls_amount as numeric) as tolls_amount,
--     cast(improvement_surcharge as numeric) as improvement_surcharge,
--     cast(total_amount as numeric) as total_amount,
--     cast(payment_type as integer) as payment_type

-- from {{ source('raw', 'yellow_tripdata') }}

-- -- Filter out records with null vendor_id (data quality requirement)
-- where vendorid is not null

-- -- Limit records for faster iteration and memory management
-- {% if target.name == 'dev' %}
-- limit {{ var('record_limit', 10000) }}
-- {% endif %}


{{
    config(
        materialized='view'
    )
}}

with trip_data as 
(
    select *,
        row_number() over (partition by vendorid, tpep_pickup_datetime )as row_number
    from
        {{ source('raw', 'yellow_tripdata') }}
    where vendorid is not null
)

select
    {{ dbt_utils.generate_surrogate_key(['vendorid', 'tpep_pickup_datetime' ])}} as trip_id,
    -- identifiers (standardized naming for consistency across yellow/green)
    cast(vendorid as integer) as vendor_id,
    cast(ratecodeid as integer) as rate_code_id,
    cast(pulocationid as integer) as pickup_location_id,
    cast(dolocationid as integer) as dropoff_location_id,

    -- timestamps (standardized naming)
    cast(tpep_pickup_datetime as timestamp) as pickup_datetime,  -- tpep = Taxicab Passenger Enhancement Program (yellow taxis)
    cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    store_and_fwd_flag,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(payment_type as integer) as payment_type,
    {{ get_payment_type_descr('payment_type')}} as patment_type_descr

from trip_data

-- Filter out records with null vendor_id (data quality requirement)
where row_number = 1

-- Limit records for faster iteration and memory management
-- {% if var('is_test_run', default=true) %}
-- limit {{ var('record_limit', 100) }}
-- {% endif %}
limit 100