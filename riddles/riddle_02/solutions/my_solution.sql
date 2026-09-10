with
  numbers
as
  (
    select 
      level as lvl
    from 
      dual
    connect by
      level <= (select max(greatest(greatest(greatest(length(enc_password), length(enc_message_cz)),length(enc_message_en)),25)) from polybius_square_ciphers)
  ),
  password_length
as
  (
    select
      p.cipher_id,
      n.lvl as ord_num,
      replace(substr(p.enc_password, n.lvl, 1), 'J', 'I') as password_char
    from
      polybius_square_ciphers p,
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
      to_char(trunc((n.lvl - 1) / 5) + 1) || to_char(decode(mod(n.lvl, 5), 0, 5, mod(n.lvl, 5))) as enc_char,
      substr(a.enc_alphabet, n.lvl, 1) as dec_char
    from
      alphabets a,
      numbers n
    where
      length(a.enc_alphabet) >= n.lvl
  ),
  enc_messages
as
  (
    select 
      p.cipher_id,
      p.lang,
      n.lvl,
      substr(p.enc_message, (n.lvl-1) * 2 + 1, 2) as bigram
    from
      (
        select
          p.cipher_id,
          decode(n.lvl, 1, 'CZ', 'EN') as lang,
          decode(n.lvl, 1, p.enc_message_cz, p.enc_message_en) as enc_message
        from
          polybius_square_ciphers p,
          numbers n
        where
          n.lvl <= 2
      )  
       p,
      numbers n
    where
      length(p.enc_message) / 2 >= n.lvl
  )
select
  cipher_id,
  cz_dec_message as dec_message_cz,
  en_dec_message as dec_message_en
from
  (
    select 
      e.cipher_id,
      e.lang,
      listagg(t.dec_char, '') within group (order by e.lvl) as msg
    from 
      enc_messages e,
      enc_dec_table t
    where
      e.cipher_id = t.cipher_id and
      e.bigram = t.enc_char
    group by
      e.cipher_id,
      e.lang
  )
pivot
  (
    max(msg) as dec_message for lang in ('CZ' as cz, 'EN' as en)
  );
