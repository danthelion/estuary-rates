-- calculate percentage difference of earliest and last price in trades table
with deduped_trades as (
    select
        symbol,
        ts,
        price,
        ROW_NUMBER() OVER (PARTITION BY symbol, ts ORDER BY price) as row_num
    from trades
)

, window_ts as (
    select
        symbol,
        MIN(ts) AS window_start,
        MAX(ts) AS window_end
    from deduped_trades
    where row_num = 1
    group by symbol
)

-- find the earliest and latest price for each symbol in window
, window_values as (
    select
        t.symbol as symbol,
        w.window_start as window_start,
        w.window_end as window_end,
        MIN(t.price) AS earliest_price,
        MAX(t.price) AS latest_price
    from trades t
    join window_ts w
    on t.symbol = w.symbol
    and t.ts >= w.window_start
    and t.ts <= w.window_end
    group by t.symbol, w.window_start, w.window_end
)

-- select the percentage difference and window duration
select symbol, window_start, window_end, earliest_price, latest_price,
    (latest_price - earliest_price) / earliest_price * 100 as percentage_difference,
    strftime('%s', window_end) -  strftime('%s', window_start) as window_duration
from window_values;

-- clear trades table (aka empty the state of the trades table for the next window of time)
DELETE FROM trades WHERE 1=1;
