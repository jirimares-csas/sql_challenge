with
  matrix_max_dimension
as
  (      
    select
      max(regexp_count(board_detail,chr(10)) + 1) as max_dimens
    from
      noughts_and_crosses_boards
  ),
  max_dimension
as
  (
    select
      level as ord_num
    from
      dual
    connect by
      level <= (select max_dimens from matrix_max_dimension)
  ),
  board_rows
as
  (
    select
      m.ord_num as row_num,
      b.board_id,
      b.dimens,
      replace(regexp_substr(board_detail || chr(10), '[^'||chr(10)||']{'||b.dimens||'}'|| chr(10), 1, m.ord_num), chr(10), '') as row_text
    from
      (
        select
          board_id,
          board_detail,
          regexp_count(board_detail,chr(10)) + 1 as dimens
        from
          noughts_and_crosses_boards
      ) b,
      max_dimension m
    where
      m.ord_num <= b.dimens  
  ),
  board_chars
as
  (
    select
      b.row_num,
      m.ord_num as col_num,
      b.board_id,
      b.dimens,
      substr(b.row_text, m.ord_num, 1) as board_char
    from
      board_rows b,
      max_dimension m
    where
      m.ord_num <= b.dimens
  ),
  directions
as
  (
    select
      decode(level, 1, 'S', 2, 'E', 3, 'SE', 'SW') as direction,
      decode(level, 1, 0, 4, -1, 1) as col_move,
      decode(level, 2, 0, 1) as row_move
    from
      dual
    connect by
      level <= 4
  ),
  players
as
  (
    select
      level as id,
      decode(level, 1, 'X', 'O') as symbol
    from
      dual
    connect by
      level <= 2
  ),
  patterns
as
  (
    select
      level as pattern_id,
      regexp_replace('#####', '#', ' ', 1, level) as pattern_text
    from
      dual
    connect by
      level <= 5
  ),
  player_patterns
as
  (
    select
      p.id as player_id,
      p.symbol,
      pt.pattern_id,
      replace(pt.pattern_text, '#', p.symbol) as player_pattern
    from
      players p,
      patterns pt
  ),
  board_compass
as
  (
    select
      b.row_num,
      b.col_num,
      b.board_id,
      b.dimens,
      b.board_char,
      d.direction,
      d.row_move,
      d.col_move   
    from
      board_chars b,
      directions d
  ),
  board_words (board_id, row_begin, col_begin, direction, row_move, col_move, word, len)
as
  (
    select
      board_id,
      row_num as row_begin,
      col_num as col_begin,
      direction,
      row_move,
      col_move,
      board_char as word,
      1 as len
    from
      board_compass
    union all
    select
      prev.board_id,
      prev.row_begin,
      prev.col_begin,
      prev.direction,
      prev.row_move,
      prev.col_move,
      prev.word || act.board_char as word,
      prev.len + 1 as len
    from
      board_words prev,
      board_compass act
    where
      prev.board_id = act.board_id and
      prev.direction = act.direction and
      prev.row_begin + (act.row_move * prev.len) = act.row_num and
      prev.col_begin + (act.col_move * prev.len) = act.col_num
  ),
  board_valid_words
as
  (
    select
      board_id,
      row_begin,
      col_begin,
      row_move,
      col_move,
      word
    from
      board_words 
    where 
      len = 5
  ),
  player_valid_words
as
  (
    select
      board_id,
      player_id,
      listagg(chr(64 + final_row) || final_col, ', ') within group (order by final_row, final_col) as moves,
      count(1) as move_count
    from
      (
        select 
          distinct
            w.board_id,
            pp.player_id,
            w.row_begin + (pp.pattern_id - 1) * w.row_move as final_row,
            w.col_begin + (pp.pattern_id - 1) * w.col_move as final_col
        from 
          board_valid_words w,
          player_patterns pp
        where
          w.word = pp.player_pattern
      )
    group by
      board_id,
      player_id
  )
select 
  b.board_id,
  nvl(player_x.moves, case when player_o.move_count is null then '?' when player_o.move_count = 1 then player_o.moves else '!' end) as crosses_move,
  nvl(player_o.moves, case when player_x.move_count is null then '?' when player_x.move_count = 1 then player_x.moves else '!' end) as noughts_move
from 
  noughts_and_crosses_boards b,
  (
    select
      board_id,
      moves,
      move_count
    from
      player_valid_words
    where
      player_id = 1
  ) player_x,
  (
    select
      board_id,
      moves,
      move_count
    from
      player_valid_words
    where
      player_id = 2
  ) player_o 
where
  b.board_id = player_x.board_id(+) and
  b.board_id = player_o.board_id(+);
