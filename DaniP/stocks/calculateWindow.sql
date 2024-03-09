-- find the earliest and latest price for each symbol in window
with window_values as (
    select 
        $Symbol as symbol,
        min($Price) as earliest_price, 
        max($Price) as latest_price
    -- filter for the last 1 hour
    where strftime('%s', $Timestamp) >= strftime('%s', $Timestamp) - 3600
    group by $Symbol
)

-- select the percentage difference and window duration
select symbol, earliest_price, latest_price,
    (latest_price - earliest_price) / earliest_price * 100 as percentage_difference
from window_values
where percentage_difference > 0;
