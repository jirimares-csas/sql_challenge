create table playfair_ciphers (cipher_id integer, enc_message varchar2(1000), enc_password varchar2(50));
create table playfair_ciphers_solution (cipher_id integer, dec_message varchar2(1000));

insert into playfair_ciphers (cipher_id, enc_message, enc_password)
values
(1,
'KEABBVWVGERBLN',
'VERGILIUS');

insert into playfair_ciphers (cipher_id, enc_message, enc_password)
values
(2,
'MBSLESPTTOQTIHCUOKENPLNHLUQCBSLPIA',
'SENECA');

insert into playfair_ciphers_solution (cipher_id, dec_message)
values
(1,
'DISALITERVISUM');


insert into playfair_ciphers_solution (cipher_id, dec_message)
values
(2,
'IGNISAURUMPROBATMISERIAFORTESVIROS');

commit;
