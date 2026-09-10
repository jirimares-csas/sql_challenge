with alphabet_letters as (
    select 
        letters.alphabet_letter_id,
        letters.alphabet_letter_char
    from (
        select 
            'ABCDEFGHIKLMNOPQRSTUVWXYZ' as alphabet_text
        from 
            dual
        ) l
    cross join lateral (
        select
            level as alphabet_letter_id,
            substr(l.alphabet_text, level, 1) as alphabet_letter_char
        from dual
        connect by level <= length(l.alphabet_text)
    ) letters
),
ciphers as (
    select 
        distinct cipher_id
    from 
        polybius_square_ciphers
),
password_letters as ( 
    select
        p.cipher_id,
        letters.password_letter_id,
        letters.password_letter_char
    from 
        polybius_square_ciphers p
    cross join lateral (
        select
            level as password_letter_id,
            substr(p.enc_password, level, 1) as password_letter_char
        from dual
        connect by level <= length(p.enc_password)
    ) letters
),
enc_message_cz_coordinates as (
    select
        m.cipher_id,
        coordinates.enc_message_cz_coordinate_id,
        to_number(substr(coordinates.enc_message_cz_coordinate, 1, 1)) as enc_message_cz_coordinate_row,
        to_number(substr(coordinates.enc_message_cz_coordinate, 2, 1)) as enc_message_cz_coordinate_column
    from 
        polybius_square_ciphers m
    cross join lateral (
        select
            level as enc_message_cz_coordinate_id,
            substr(m.enc_message_cz, level*2 - 1, 2) as enc_message_cz_coordinate
        from dual
        connect by level*2 <= length(m.enc_message_cz)
    ) coordinates
),
enc_message_en_coordinates as (
    select
        m.cipher_id,
        coordinates.enc_message_en_coordinate_id,
        to_number(substr(coordinates.enc_message_en_coordinate, 1, 1)) as enc_message_en_coordinate_row,
        to_number(substr(coordinates.enc_message_en_coordinate, 2, 1)) as enc_message_en_coordinate_column
    from 
        polybius_square_ciphers m
    cross join lateral (
        select
            level as enc_message_en_coordinate_id,
            substr(m.enc_message_en, level*2 - 1, 2) as enc_message_en_coordinate
        from dual
        connect by level*2 <= length(m.enc_message_en)
    ) coordinates
),
enc_aplhabet as (
    select
        cipher_id, 
        trunc((enc_alphabet_letter_id-1) / 5) + 1 as enc_alphabet_letter_coordinate_row,
        mod(enc_alphabet_letter_id-1, 5) + 1 as enc_alphabet_letter_coordinate_column,
        enc_alphabet_letter_char,
        enc_alphabet_letter_id,
        priority, 
        enc_alphabet_original_letter_id 
    from (
        select
            row_number() over (partition by cipher_id order by cipher_id, priority, enc_alphabet_original_letter_id) as enc_alphabet_letter_id,    
            cipher_id, priority, enc_alphabet_original_letter_id, enc_alphabet_letter_char
        from (
            select 
                cipher_id, 1 as priority, min(password_letter_id) as enc_alphabet_original_letter_id, password_letter_char as enc_alphabet_letter_char
            from 
                password_letters
            group by 
                cipher_id, password_letter_char
            union all
            select 
                c.cipher_id, 2 as priority, al.alphabet_letter_id as enc_alphabet_original_letter_id, al.alphabet_letter_char as enc_alphabet_letter_char
            from 
                alphabet_letters al
            cross join 
                ciphers c
            where (c.cipher_id, al.alphabet_letter_char) not in (
                select 
                    pl.cipher_id, pl.password_letter_char
                from 
                    password_letters pl
                )
            )
        )
)
select 
    c.cipher_id,
    dec_m_cz.dec_message_cz,
    dec_m_en.dec_message_en
from 
    polybius_square_ciphers c,
    (
    select 
        m_cz.cipher_id, listagg (ea_cz.enc_alphabet_letter_char) within group (order by m_cz.enc_message_cz_coordinate_id) as dec_message_cz
    from
        enc_message_cz_coordinates m_cz
        ,
        enc_aplhabet ea_cz
    where
        m_cz.cipher_id = ea_cz.cipher_id
        and m_cz.enc_message_cz_coordinate_row = ea_cz.enc_alphabet_letter_coordinate_row    
        and m_cz.enc_message_cz_coordinate_column = ea_cz.enc_alphabet_letter_coordinate_column
    group by
        m_cz.cipher_id
    ) dec_m_cz,
    (
    select 
        m_en.cipher_id, listagg (ea_en.enc_alphabet_letter_char) within group (order by m_en.enc_message_en_coordinate_id) as dec_message_en
    from
        enc_message_en_coordinates m_en
        ,
        enc_aplhabet ea_en
    where
        m_en.cipher_id = ea_en.cipher_id
        and m_en.enc_message_en_coordinate_row = ea_en.enc_alphabet_letter_coordinate_row    
        and m_en.enc_message_en_coordinate_column = ea_en.enc_alphabet_letter_coordinate_column
    group by
        m_en.cipher_id
    ) dec_m_en
where
    c.cipher_id = dec_m_cz.cipher_id    
    and c.cipher_id = dec_m_en.cipher_id
order by
    c.cipher_id;
