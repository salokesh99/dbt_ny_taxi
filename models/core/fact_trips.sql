{{
    config(
        materialized='table'
    )
}}

with green_tripdata as (
    select *,
        'Green' as service_type 
    from {{ ref('stg_green_tripdata') }}
    limit 100
),
yellow_tripdata as (
    select *,
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
    limit 100
),
trips_union as (
    select 
        trip_id, 
        vendor_id, 
        service_type,
        rate_code_id, 
        pickup_location_id, 
        dropoff_location_id,
        pickup_datetime, 
        dropoff_datetime, 
        store_and_fwd_flag, 
        passenger_count, 
        trip_distance, 
        -- trip_type, 
        fare_amount, 
        extra, 
        mta_tax, 
        tip_amount, 
        tolls_amount, 
        -- ehail_fee, 
        improvement_surcharge, 
        total_amount, 
        payment_type, 
        patment_type_descr
    from green_tripdata
    union all
    select 
        trip_id, 
        vendor_id, 
        service_type,
        rate_code_id, 
        pickup_location_id, 
        dropoff_location_id,
        pickup_datetime, 
        dropoff_datetime, 
        store_and_fwd_flag, 
        passenger_count, 
        trip_distance, 
        -- trip_type, 
        fare_amount, 
        extra, 
        mta_tax, 
        tip_amount, 
        tolls_amount, 
        -- ehail_fee, 
        improvement_surcharge, 
        total_amount, 
        payment_type, 
        patment_type_descr
     from yellow_tripdata
     limit 100
),
dim_zones as (
    select * from {{ ref('taxi_zone_lookup') }} where borough != 'Unknown'
)

select     
    trips_unioned.trip_id, 
    trips_unioned.vendor_id, 
    trips_unioned.service_type,
    trips_unioned.rate_code_id, 
    trips_unioned.pickup_location_id, 
    pickup_zones.borough as pickup_borough, 
    pickup_zones.zone as pickup_zone, 
    trips_unioned.dropoff_location_id,
   --  dropoff_zones.borough as dropoff_borough, 
    -- dropoff_zones.zone as dropoff_zone,  
    trips_unioned.pickup_datetime, 
    trips_unioned.dropoff_datetime, 
    trips_unioned.store_and_fwd_flag, 
    trips_unioned.passenger_count, 
    trips_unioned.trip_distance, 
    -- trips_unioned.trip_type, 
    trips_unioned.fare_amount, 
    trips_unioned.extra, 
    trips_unioned.mta_tax, 
    trips_unioned.tip_amount, 
    trips_unioned.tolls_amount, 
    -- trips_unioned.ehail_fee, 
    trips_unioned.improvement_surcharge, 
    trips_unioned.total_amount, 
    trips_unioned.payment_type, 
    trips_unioned.patment_type_descr
from trips_union trips_unioned
inner join dim_zones as pickup_zones on trips_unioned.pickup_location_id = pickup_zones.locationid
-- inner join dim_zones as dropoff_zones on trips_unioned.pickup_location_id = dropoff_zones.locationid
limit 100