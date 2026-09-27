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
        playfair_ciphers
),
password_letters as ( 
    select
        p.cipher_id,
        letters.password_letter_id,
        letters.password_letter_char
    from 
        playfair_ciphers p
    cross join lateral (
        select
            level as password_letter_id,
            substr(p.enc_password, level, 1) as password_letter_char
        from dual
        connect by level <= length(p.enc_password)
    ) letters
),
enc_message_bigrams as (
    select
        m.cipher_id,
        bigrams.enc_message_bigram_id,
        bigrams.enc_message_bigram_text,
        substr(bigrams.enc_message_bigram_text, 1, 1) as enc_message_bigram_letter_1,
        substr(bigrams.enc_message_bigram_text, 2, 1) as enc_message_bigram_letter_2
    from 
        playfair_ciphers m
    cross join lateral (
        select
            level as enc_message_bigram_id,
            substr(m.enc_message, level*2 - 1, 2) as enc_message_bigram_text
        from dual
        connect by level*2 <= length(m.enc_message)
    ) bigrams
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
),
dec_bigrams_wave_1 as (
    select 
        mb.cipher_id,
        mb.enc_message_bigram_id,
        mb.enc_message_bigram_text,
        mb.enc_message_bigram_letter_1,
        al1.enc_alphabet_letter_coordinate_row as enc_letter_1_row,
        al1.enc_alphabet_letter_coordinate_column as enc_letter_1_column,
        mb.enc_message_bigram_letter_2,
        al2.enc_alphabet_letter_coordinate_row as enc_letter_2_row,
        al2.enc_alphabet_letter_coordinate_column as enc_letter_2_column
    from
        enc_message_bigrams mb,
        enc_aplhabet al1,
        enc_aplhabet al2
    where
        mb.cipher_id = al1.cipher_id
        and mb.enc_message_bigram_letter_1 = al1.enc_alphabet_letter_char    
        and mb.cipher_id = al2.cipher_id
        and mb.enc_message_bigram_letter_2 = al2.enc_alphabet_letter_char
),
dec_bigrams_wave_2 as (
    select 
        bw1.cipher_id,
        bw1.enc_message_bigram_id,
        bw1.enc_message_bigram_text,
        bw1.enc_message_bigram_letter_1,
        bw1.enc_letter_1_row,
        bw1.enc_letter_1_column,
        r1l1.enc_alphabet_letter_char as enc_alphabet_rule_1_letter_1_char,
        r1l1.enc_alphabet_letter_coordinate_row as enc_alphabet_rule_1_letter_1_coordinate_row,
        r1l1.enc_alphabet_letter_coordinate_column as enc_alphabet_rule_1_letter_1_coordinate_column,
        r2l1.enc_alphabet_letter_char as enc_alphabet_rule_2_letter_1_char,
        r2l1.enc_alphabet_letter_coordinate_row as enc_alphabet_rule_2_letter_1_coordinate_row,
        r2l1.enc_alphabet_letter_coordinate_column as enc_alphabet_rule_2_letter_1_coordinate_column,
        r3l1.enc_alphabet_letter_char as enc_alphabet_rule_3_letter_1_char,
        r3l1.enc_alphabet_letter_coordinate_row as enc_alphabet_rule_3_letter_1_coordinate_row,
        r3l1.enc_alphabet_letter_coordinate_column as enc_alphabet_rule_3_letter_1_coordinate_column,
        bw1.enc_message_bigram_letter_2,
        bw1.enc_letter_2_row,
        bw1.enc_letter_2_column,
        r1l2.enc_alphabet_letter_char as enc_alphabet_rule_1_letter_2_char,
        r1l2.enc_alphabet_letter_coordinate_row as enc_alphabet_rule_1_letter_2_coordinate_row,
        r1l2.enc_alphabet_letter_coordinate_column as enc_alphabet_rule_1_letter_2_coordinate_column,
        r2l2.enc_alphabet_letter_char as enc_alphabet_rule_2_letter_2_char,
        r2l2.enc_alphabet_letter_coordinate_row as enc_alphabet_rule_2_letter_2_coordinate_row,
        r2l2.enc_alphabet_letter_coordinate_column as enc_alphabet_rule_2_letter_2_coordinate_column,
        r3l2.enc_alphabet_letter_char as enc_alphabet_rule_3_letter_2_char,
        r3l2.enc_alphabet_letter_coordinate_row as enc_alphabet_rule_3_letter_2_coordinate_row,
        r3l2.enc_alphabet_letter_coordinate_column as enc_alphabet_rule_3_letter_2_coordinate_column
    from 
        dec_bigrams_wave_1 bw1,
        enc_aplhabet r1l1,
        enc_aplhabet r1l2,
        enc_aplhabet r2l1,
        enc_aplhabet r2l2,
        enc_aplhabet r3l1,
        enc_aplhabet r3l2
    where
        bw1.cipher_id = r1l1.cipher_id
        and bw1.enc_letter_1_row = r1l1.enc_alphabet_letter_coordinate_row
        and mod (bw1.enc_letter_1_column + 5 - 2, 5) + 1 = r1l1.enc_alphabet_letter_coordinate_column 
        and bw1.cipher_id = r1l2.cipher_id
        and bw1.enc_letter_2_row = r1l2.enc_alphabet_letter_coordinate_row
        and mod (bw1.enc_letter_2_column + 5 - 2, 5) + 1 = r1l2.enc_alphabet_letter_coordinate_column 
        and bw1.cipher_id = r2l1.cipher_id
        and mod (bw1.enc_letter_1_row + 5 - 2, 5) + 1 = r2l1.enc_alphabet_letter_coordinate_row
        and bw1.enc_letter_1_column = r2l1.enc_alphabet_letter_coordinate_column
        and bw1.cipher_id = r2l2.cipher_id
        and mod (bw1.enc_letter_2_row + 5 - 2, 5) + 1 = r2l2.enc_alphabet_letter_coordinate_row
        and bw1.enc_letter_2_column = r2l2.enc_alphabet_letter_coordinate_column 
        and bw1.cipher_id = r3l1.cipher_id
        and bw1.enc_letter_1_row = r3l1.enc_alphabet_letter_coordinate_row
        and bw1.enc_letter_1_column = r3l2.enc_alphabet_letter_coordinate_column 
        and bw1.cipher_id = r3l2.cipher_id
        and bw1.enc_letter_2_row = r3l2.enc_alphabet_letter_coordinate_row
        and bw1.enc_letter_2_column = r3l1.enc_alphabet_letter_coordinate_column 
),
result as (
    select
        cipher_id,
        listagg (dec_bigram_text) within group (order by enc_message_bigram_id) as dec_message
    from (
        select 
            cipher_id,
            enc_message_bigram_id,
            case
                when enc_letter_1_row = enc_letter_2_row
                    then enc_alphabet_rule_1_letter_1_char || enc_alphabet_rule_1_letter_2_char
                when enc_letter_1_column = enc_letter_2_column
                    then enc_alphabet_rule_2_letter_1_char || enc_alphabet_rule_2_letter_2_char
                else 
                    enc_alphabet_rule_3_letter_1_char || enc_alphabet_rule_3_letter_2_char
            end as dec_bigram_text
        from 
            dec_bigrams_wave_2 d
        )
    group by
        cipher_id
    order by 
        cipher_id
)
--select cipher_id, dec_message from result minus 
select 
    cipher_id, dec_message
from 
    playfair_ciphers_solution
--minus select cipher_id, dec_message from result
order by
    cipher_id
