with
  rounds
as
  (
    select
      level as rnd
    from
      dual
    connect by
      level <= (select max(bid_ord_nr) from marias_bids)
  ),
  games
as
  (
    select
      game_id,
      player_id,
      bid,
      win_flag,
      round_from,
      round_to,
      answer_from
    from
      (
        select
          game_id,
          p1_bid,
          p2_bid,
          p3_bid,
          case when p1_bid >= p2_bid and p1_bid >= p3_bid and p1_bid > 0 then 1 else 0 end as p1_win_flag,
          case when p2_bid > p1_bid and p2_bid >= p3_bid then 1 else 0 end as p2_win_flag,
          case when p3_bid > p1_bid and p3_bid > p2_bid then 1 else 0 end as p3_win_flag,
          1 as p1_round_from,
          greatest(least(p1_bid, greatest(p2_bid, p3_bid)) + (case when greatest(p2_bid, p3_bid) > p1_bid then 1 else 0 end), 1) as p1_round_to,
          1 as p2_round_from,
          least(p2_bid, greatest(p1_bid, p3_bid)) + (case when p1_bid < p2_bid and p2_bid >= p3_bid and greatest(p1_bid, p3_bid) > 0 then 0 else 1 end) as p2_round_to,
          least(p1_bid, p2_bid) + (case when p1_bid < p2_bid then 2 else 1 end) as p3_round_from,
          greatest(greatest(least(greatest(p1_bid, p2_bid), p3_bid) + 1, least(p1_bid, p2_bid) + 1), least(p1_bid, p2_bid) + (case when p1_bid < p2_bid then 2 else 1 end)) as p3_round_to,
          1 as p1_answer_from,
          (case when p1_bid + 1 < p2_bid and p1_bid + 1 < p3_bid then p1_bid + 2 else 99 end) as p2_answer_from,
          99 as p3_answer_from
        from
          (
            select
              g.game_id,
              nvl(b1.bid_ord_nr, 0) as p1_bid,
              nvl(b2.bid_ord_nr, 0) as p2_bid,
              nvl(b3.bid_ord_nr, 0) as p3_bid
            from
              marias_games g,
              marias_bids b1,
              marias_bids b2,
              marias_bids b3
            where
              g.p1_bid = b1.bid_id(+) and
              g.p2_bid = b2.bid_id(+) and
              g.p3_bid = b3.bid_id(+)
          )
      )
    unpivot
      (
        (bid, win_flag, round_from, round_to, answer_from) for player_id in 
          (
            (p1_bid, p1_win_flag, p1_round_from, p1_round_to, p1_answer_from) as 1,
            (p2_bid, p2_win_flag, p2_round_from, p2_round_to, p2_answer_from) as 2,
            (p3_bid, p3_win_flag, p3_round_from, p3_round_to, p3_answer_from) as 3
          )
      )
  )
select
  game_id,
  listagg(
           to_char(player_id) || ': ' ||
           case 
             when 
               rnd = round_to and win_flag = 0
             then
               'mlčím'
             when
               answer_flag = 0 
             then
               bid_name
             else
               'mám'
           end,
           chr(10) 
           ) within group (order by rnd, answer_flag, decode(player_id, 1, 99, player_id)) as bids
from
  (
    select
      g.game_id,
      g.player_id,
      g.bid,
      g.win_flag,
      g.round_from,
      g.round_to,
      g.answer_from,
      r.rnd,
      case when r.rnd >= g.answer_from then 1 else 0 end as answer_flag,
      b.bid_name
    from
      games g,
      rounds r,
      marias_bids b
    where
      r.rnd between g.round_from and g.round_to and
      r.rnd = b.bid_ord_nr
  )
group by 
  game_id;
