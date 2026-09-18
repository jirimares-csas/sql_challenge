with games as (
    select distinct game_id
    from marias_games
    order by game_id
),
game_bids as (
    select 
        g.game_id, 
        b.*
    from 
        games g
    cross join 
        marias_bids b
), 
bidding_21 as (
    select 
        g.game_id,
        g.p2_bid as p2_max_bid,
        g.p1_bid as p1_max_bid,
        g.p3_bid as p3_max_bid,
        nvl (b2.bid_ord_nr, 0) as p2_max_bid_ord_nr, 
        nvl (b1.bid_ord_nr, 0) as p1_max_bid_ord_nr 
    from 
        marias_games g,
        marias_bids b1,
        marias_bids b2
    where 
        g.p1_bid = b1.bid_id(+)
        and g.p2_bid = b2.bid_id(+)
),
p21_bid as (
    select 
        b21.*,
        case 
            when p2_max_bid_ord_nr <= p1_max_bid_ord_nr
            then '1'
            else '2'
        end as p21_id
    from bidding_21 b21
),
p21_bid_result as (
    select 
        p21_b.*,
        case 
            when p21_b.p21_id = '1' 
            then p1_max_bid_ord_nr 
            else p2_max_bid_ord_nr 
        end as p21_max_bid_ord_nr, 
        case 
            when p21_b.p21_id = '1' 
            then p2_max_bid_ord_nr 
            else p1_max_bid_ord_nr + 1 
        end as p21_curr_bid_ord_nr, 
        case 
            when p21_b.p21_id = '2' 
            then p1_max_bid_ord_nr + 1
            else p2_max_bid_ord_nr + 1 
        end as p2_last_bid_ord_nr, 
        case 
            when p21_b.p21_id = '2' 
            then 'm m'
            else 'ml  m' 
        end as p2_last_bid_flag, 
        case 
            when p21_b.p21_id = '1' 
            then p2_max_bid_ord_nr 
            else p1_max_bid_ord_nr + 1 
        end as p1_last_bid_ord_nr, 
        case 
            when p21_b.p21_id = '1' 
            then 'm m'
            else 'ml  m' 
        end as p1_last_bid_flag 
    from 
        p21_bid p21_b
),
player_bidding_21 as (
    select 
        b.game_id,
        '2' as player_id,
        p2_last_bid_ord_nr as last_bid_ord_nr,
        p2_last_bid_flag as last_bid_flag,
        p21_id,
        b.bid_ord_nr,
        b.bid_name
    from 
        p21_bid_result p21
    right outer join game_bids b
        on (p21.game_id = b.game_id)
    where
        p21.p2_last_bid_ord_nr >= b.bid_ord_nr  
    union all
    select 
        b.game_id,
        '1' as player_id,
        p1_last_bid_ord_nr as last_bid_ord_nr,
        p1_last_bid_flag as last_bid_flag,
        p21_id,
        b.bid_ord_nr,
        b.bid_name
    from 
        p21_bid_result p21
    right outer join game_bids b
        on (p21.game_id = b.game_id)
    where
        p21.p1_last_bid_ord_nr >= b.bid_ord_nr  
),
bidding_213 as (
    select 
        b21.game_id,
        p2_max_bid, 
        p1_max_bid, 
        p3_max_bid,
        b21.p21_id,
        p21_max_bid_ord_nr, 
        p21_curr_bid_ord_nr,
        nvl (b3.bid_ord_nr, 0) as p3_max_bid_ord_nr 
    from 
        p21_bid_result b21, 
        marias_bids b3
    where 
        b21.p3_max_bid = b3.bid_id(+)
),
p213_bid as (
    select 
        b213.*,
        case 
            when p3_max_bid_ord_nr <= p21_max_bid_ord_nr
            then '21'
            else '3'
        end as p213_id
    from bidding_213 b213
),
p213_bid_result as (
    select 
        p213_b.*,
        case 
            when p213_b.p213_id = '21' 
            then p21_max_bid_ord_nr 
            else p3_max_bid_ord_nr 
        end as p213_max_bid_ord_nr, 
        case 
            when p213_b.p213_id = '3' 
            then p21_max_bid_ord_nr + 1
            else greatest(p3_max_bid_ord_nr, p21_curr_bid_ord_nr) + 1 
        end as p3_last_bid_ord_nr, 
        case 
            when p213_b.p213_id = '3' 
            then 'm m'
            else 'ml  m' 
        end as p3_last_bid_flag, 
        case 
            when p213_b.p213_id = '21'  and p21_curr_bid_ord_nr > 0
            then p3_max_bid_ord_nr 
            else p21_max_bid_ord_nr + 1 
        end as p21_last_bid_ord_nr, 
        case 
            when p213_b.p213_id = '21' and p21_curr_bid_ord_nr > 0 
            then 'm m'
            else 'ml  m' 
        end as p21_last_bid_flag
    from 
        p213_bid p213_b
),
player_bidding_213 as (
    select 
        b.game_id,
        '3' as player_id,
        p3_last_bid_ord_nr as last_bid_ord_nr,
        p3_last_bid_flag as last_bid_flag,
        p213_id,
        p21_curr_bid_ord_nr,
        b.bid_ord_nr,
        b.bid_name
    from 
        p213_bid_result p213
    right outer join game_bids b
        on (p213.game_id = b.game_id)
    where
        p213.p3_last_bid_ord_nr >= b.bid_ord_nr  
        and p213.p21_curr_bid_ord_nr < b.bid_ord_nr
    union all
    select 
        b.game_id,
        p21_id as player_id,
        p21_last_bid_ord_nr as last_bid_ord_nr,
        p21_last_bid_flag as last_bid_flag,
        p213_id,
        p21_curr_bid_ord_nr,
        b.bid_ord_nr,
        b.bid_name
    from 
        p213_bid_result p213
    right outer join game_bids b
        on (p213.game_id = b.game_id)
    where
        p213.p21_last_bid_ord_nr >= b.bid_ord_nr  
        and p213.p21_curr_bid_ord_nr < b.bid_ord_nr
),
bidding as (
    select 
        rownum as rn,
        b.*
    from (
        select
            game_id,
            1 as bidding_ord_nr,
            bid_ord_nr,
            player_id,
            player_id || ': '||
            case 
                when bid_ord_nr < last_bid_ord_nr and player_id = '2' 
                then bid_name
                when bid_ord_nr < last_bid_ord_nr and player_id = '1' 
                then 'm m'
                when bid_ord_nr = last_bid_ord_nr and player_id = '2' and p21_id = '2'
                then bid_name
                when bid_ord_nr = last_bid_ord_nr and player_id = '2' and p21_id = '1'
                then last_bid_flag
                when bid_ord_nr = last_bid_ord_nr and player_id = '1' and p21_id = '2'
                then last_bid_flag
                when bid_ord_nr = last_bid_ord_nr and player_id = '1' and p21_id = '1'
                then last_bid_flag
            end as bid_text
        from 
            player_bidding_21 b21
        union all
        select
            game_id,
            2 as bidding_ord_nr,
            bid_ord_nr,
            player_id,
            player_id || ': '||
            case 
                when bid_ord_nr < last_bid_ord_nr and player_id = '3' 
                then bid_name
                when bid_ord_nr < last_bid_ord_nr and player_id != '3' 
                then 'm m'
                when bid_ord_nr = last_bid_ord_nr and player_id = '3' and p213_id = '3'
                then bid_name
                when bid_ord_nr = last_bid_ord_nr and player_id = '3' and p213_id = '21'
                then last_bid_flag
                when bid_ord_nr = last_bid_ord_nr and player_id != '3' and p213_id = '3'
                then last_bid_flag
                when bid_ord_nr = last_bid_ord_nr and player_id != '3' and p213_id = '21'
                then last_bid_flag
            end as bid_text
        from 
            player_bidding_213 b213
        order by
            game_id,
            bidding_ord_nr,
            bid_ord_nr,
            player_id desc
        ) b
),
result as (
    select game_id, listagg(bid_text, chr(10)) within group (order by rn) as bids
    from bidding
    group by game_id
)
--select game_id, bids
--from marias_game_bids
--minus
select game_id, bids
from result r
--minus
--select game_id, bids
--from marias_game_bids
order by game_id
;
