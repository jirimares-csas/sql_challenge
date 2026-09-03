with board_cells as (
    select /*+ NO_PARALLEL */ 
        t.board_id,
        lines.line_id,
        line_cells.column_id,
        line_cells.cell_char
    from noughts_and_crosses_boards t
    cross join lateral (
        select
            level as line_id,
            regexp_substr(t.board_detail, '[^' || chr(10) || ']+', 1, level) as line_text
        from dual
        connect by level <= regexp_count(t.board_detail, '[^' || chr(10) || ']+')
    ) lines
    cross join lateral (
        select
            level as column_id,
            substr(lines.line_text, level, 1) as cell_char
        from dual
        connect by level <= length(lines.line_text)
    ) line_cells
),
empty_board_cells as (
    select *
    from board_cells
    where cell_char = ' '
),
nonempty_board_cells as (
    select *
    from board_cells
    where cell_char != ' '
),
empty_candidates as (
    select /*+ MATERIALIZE */ 
        distinct c1.board_id, c1.line_id, c1.column_id, c1.cell_char
    from 
        empty_board_cells c1, 
        nonempty_board_cells c2 
    where 
        c1.board_id = c2.board_id
    and (
        (c1.line_id = c2.line_id and c1.column_id = c2.column_id - 1)
        or
        (c1.line_id = c2.line_id and c1.column_id = c2.column_id + 1)
        or
        (c1.line_id = c2.line_id - 1 and c1.column_id = c2.column_id)
        or
        (c1.line_id = c2.line_id + 1 and c1.column_id = c2.column_id)
        or
        (c1.line_id = c2.line_id - 1 and c1.column_id = c2.column_id - 1)
        or
        (c1.line_id = c2.line_id + 1 and c1.column_id = c2.column_id - 1)
        or
        (c1.line_id = c2.line_id - 1 and c1.column_id = c2.column_id + 1)
        or
        (c1.line_id = c2.line_id + 1 and c1.column_id = c2.column_id + 1)
    )
),
cell_runs as ( 
    select 
        'E-W' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) and c1.column_id = c2.column_id(+) - 1) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) and c2.column_id = c3.column_id(+) - 1) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) and c3.column_id = c4.column_id(+) - 1) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) and c4.column_id = c5.column_id(+) - 1) and c4.cell_char = c5.cell_char(+)
    union all
    select 
        'E-W' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) and c1.column_id = c2.column_id(+) + 1) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) and c2.column_id = c3.column_id(+) + 1) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) and c3.column_id = c4.column_id(+) + 1) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) and c4.column_id = c5.column_id(+) + 1) and c4.cell_char = c5.cell_char(+)
    union all
    select 
        'N-S' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) - 1 and c1.column_id = c2.column_id(+)) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) - 1 and c2.column_id = c3.column_id(+)) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) - 1 and c3.column_id = c4.column_id(+)) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) - 1 and c4.column_id = c5.column_id(+)) and c4.cell_char = c5.cell_char(+)
    union all
    select 
        'N-S' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) + 1 and c1.column_id = c2.column_id(+)) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) + 1 and c2.column_id = c3.column_id(+)) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) + 1 and c3.column_id = c4.column_id(+)) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) + 1 and c4.column_id = c5.column_id(+)) and c4.cell_char = c5.cell_char(+)
    union all
    select 
        'NW-SE' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) - 1 and c1.column_id = c2.column_id(+) - 1) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) - 1 and c2.column_id = c3.column_id(+) - 1) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) - 1 and c3.column_id = c4.column_id(+) - 1) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) - 1 and c4.column_id = c5.column_id(+) - 1) and c4.cell_char = c5.cell_char(+)
    union all
    select 
        'NE-SW' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) + 1 and c1.column_id = c2.column_id(+) - 1) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) + 1 and c2.column_id = c3.column_id(+) - 1) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) + 1 and c3.column_id = c4.column_id(+) - 1) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) + 1 and c4.column_id = c5.column_id(+) - 1) and c4.cell_char = c5.cell_char(+)
    union all
    select 
        'NE-SW' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) - 1 and c1.column_id = c2.column_id(+) + 1) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) - 1 and c2.column_id = c3.column_id(+) + 1) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) - 1 and c3.column_id = c4.column_id(+) + 1) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) - 1 and c4.column_id = c5.column_id(+) + 1) and c4.cell_char = c5.cell_char(+)
    union all
    select 
        'NW-SE' as direction,
        c1.board_id as board_id_c1, c1.line_id as line_id_c1, c1.column_id as column_id_c1, c1.cell_char as cell_char_c1,
        c2.board_id as board_id_c2, c2.line_id as line_id_c2, c2.column_id as column_id_c2, c2.cell_char as cell_char_c2,
        c3.board_id as board_id_c3, c3.line_id as line_id_c3, c3.column_id as column_id_c3, c3.cell_char as cell_char_c3,
        c4.board_id as board_id_c4, c4.line_id as line_id_c4, c4.column_id as column_id_c4, c4.cell_char as cell_char_c4,
        c5.board_id as board_id_c5, c5.line_id as line_id_c5, c5.column_id as column_id_c5, c5.cell_char as cell_char_c5
    from 
        empty_candidates c1,
        nonempty_board_cells c2,
        nonempty_board_cells c3,
        nonempty_board_cells c4,
        nonempty_board_cells c5
    where c1.board_id = c2.board_id(+) and (c1.line_id = c2.line_id(+) + 1 and c1.column_id = c2.column_id(+) + 1) 
        and c2.board_id = c3.board_id(+) and (c2.line_id = c3.line_id(+) + 1 and c2.column_id = c3.column_id(+) + 1) and c2.cell_char = c3.cell_char(+)
        and c3.board_id = c4.board_id(+) and (c3.line_id = c4.line_id(+) + 1 and c3.column_id = c4.column_id(+) + 1) and c3.cell_char = c4.cell_char(+)
        and c4.board_id = c5.board_id(+) and (c4.line_id = c5.line_id(+) + 1 and c4.column_id = c5.column_id(+) + 1) and c4.cell_char = c5.cell_char(+)
),
aggr_cell_runs as (
    select 
        direction, board_id_c1, line_id_c1, column_id_c1, cell_char_c2,
        listagg(cell_char_c2||cell_char_c3||cell_char_c4||cell_char_c5, ' ') as cell_run
    from cell_runs
    group by direction, board_id_c1, line_id_c1, column_id_c1, cell_char_c2
    having length(listagg(cell_char_c2||cell_char_c3||cell_char_c4||cell_char_c5, ' ')) >= 4
),
run_lists as (
    select
        board_id, run_char,
        listagg(distinct cell_id, ', ') within group (order by line_id, column_id) as run_list,
        count(*) as run_list_count
    from (    
        select 
            board_id_c1 as board_id, 
            line_id_c1 as line_id, 
            column_id_c1 as column_id,
            CHR(line_id_c1 - 1 + ASCII('A')) || column_id_c1 as cell_id,
            cell_char_c2 as run_char
        from 
            aggr_cell_runs
        )
    group by
        board_id, run_char
)
select 
    b.board_id,
    case 
        when rl_c.run_list is not null then rl_c.run_list
        when rl_c.run_list is null and rl_n.run_list is not null and rl_n.run_list_count = 1 then rl_n.run_list
        when rl_c.run_list is null and rl_n.run_list is not null and rl_n.run_list_count > 1 then '!'
        else '?'
    end as crosses_move,
    case 
        when rl_n.run_list is not null then rl_n.run_list
        when rl_n.run_list is null and rl_c.run_list is not null and rl_c.run_list_count = 1 then rl_c.run_list
        when rl_n.run_list is null and rl_c.run_list is not null and rl_c.run_list_count > 1 then '!'
        else '?'
    end as noughts_move
from 
    (select distinct board_id from noughts_and_crosses_boards) b,
    run_lists rl_n,
    run_lists rl_c
where
    b.board_id = rl_n.board_id(+)
    and rl_n.run_char(+) = 'O' 
    and b.board_id = rl_c.board_id(+)
    and rl_c.run_char(+) = 'X' 
order by b.board_id
          
