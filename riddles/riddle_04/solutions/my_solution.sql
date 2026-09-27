with
  numbers
as
  (
    select 
      level as lvl
    from 
      dual
    connect by
      level <= (select max(greatest(greatest(length(enc_password), length(enc_message)),25)) from playfair_ciphers)
  ),
  password_length
as
  (
    select
      p.cipher_id,
      n.lvl as ord_num,
      replace(substr(p.enc_password, n.lvl, 1), 'J', 'I') as password_char
    from
      playfair_ciphers p,
      numbers n
    where
      length(p.enc_password) >= n.lvl
  ),
  alphabets
as
  (
    select
      cipher_id,
      enc_password || replace(translate('ABCDEFGHIKLMONPQRSTUVWXYZ', enc_password, lpad(' ', length(enc_password), ' ')), ' ', '') as enc_alphabet
    from
      (
        select
          cipher_id,
          listagg(password_char,'') within group (order by ord_num) as enc_password
        from
          (
            select
              cipher_id,
              ord_num,
              password_char,
              row_number() over (partition by cipher_id, password_char order by ord_num) as rn
            from
              password_length
          )
        where
          rn = 1
        group by
          cipher_id
      )
  ),
  enc_dec_table
as
  (
    select
      a.cipher_id,
      substr(a.enc_alphabet, n.lvl, 1) as dec_char,
      trunc((n.lvl - 1) / 5) + 1 as row_nr,
      decode(mod(n.lvl, 5), 0, 5, mod(n.lvl, 5)) as col_nr
    from
      alphabets a,
      numbers n
    where
      length(a.enc_alphabet) >= n.lvl
  ),
  couples
as
  (
    select
      c.cipher_id,
      n.lvl,
      substr(c.enc_message, 1 + 2 * (n.lvl - 1), 1) as first_letter,
      substr(c.enc_message, 2 * n.lvl, 1) as second_letter
    from
      playfair_ciphers c,
      numbers n
    where
      length(c.enc_message) / 2 >= n.lvl
  )
 select
  e.cipher_id,
  listagg(l1.dec_char || l2.dec_char, '') within group (order by e.lvl) as dec_message
from
  (
    select
      cipher_id,
      lvl,
      first_letter_row,
      first_letter_column,
      second_letter_row,
      second_letter_column,
      case 
        when 
          first_letter_column = second_letter_column
        then
          decode(first_letter_row, 1, 5, first_letter_row - 1)
        else
          first_letter_row
      end as new_first_letter_row,
      case 
        when 
          first_letter_row = second_letter_row
        then
          decode(first_letter_column, 1, 5, first_letter_column - 1)
        when 
          first_letter_column <> second_letter_column
        then
          second_letter_column
        else
          first_letter_column
      end as new_first_letter_column,
      case 
        when 
          first_letter_column = second_letter_column
        then
          decode(second_letter_row, 1, 5, second_letter_row - 1)
        else
          second_letter_row
      end as new_second_letter_row,
      case 
        when 
          first_letter_row = second_letter_row
        then
          decode(second_letter_column, 1, 5, second_letter_column - 1)
        when 
          first_letter_column <> second_letter_column
        then
          first_letter_column
        else
          second_letter_column
      end as new_second_letter_column
    from
      (
        select 
          c.cipher_id,
          c.lvl,
          c.first_letter,
          l1.row_nr as first_letter_row,
          l1.col_nr as first_letter_column,
          c.second_letter,
          l2.row_nr as second_letter_row,
          l2.col_nr as second_letter_column
        from
          couples c,
          enc_dec_table l1,
          enc_dec_table l2
        where
          c.first_letter = l1.dec_char and
          c.cipher_id = l1.cipher_id and
          c.second_letter = l2.dec_char and
          c.cipher_id = l2.cipher_id
      )
  ) e,
  enc_dec_table l1,
  enc_dec_table l2 
where
  e.cipher_id = l1.cipher_id and
  e.new_first_letter_row = l1.row_nr and
  e.new_first_letter_column = l1.col_nr and
  e.cipher_id = l2.cipher_id and
  e.new_second_letter_row = l2.row_nr and
  e.new_second_letter_column = l2.col_nr
group by
  e.cipher_id;
