create table polybius_square_ciphers (cipher_id integer, enc_message_cz varchar2(1000), enc_message_en varchar2(1000), enc_password varchar2(50));
create table polybius_square_cipher_solutions (cipher_id integer, dec_message_cz varchar2(1000), dec_message_en varchar2(1000));

insert into polybius_square_ciphers (cipher_id, enc_message_cz, enc_message_en, enc_password)
values
(1,
'554143215121',
'34121313213112',
'HESLO');

insert into polybius_square_ciphers (cipher_id, enc_message_cz, enc_message_en, enc_password)
values
(2,
'2413433122125225432225552413251125',
'52212431123513125245123131252312',
'VERYVERYLONGPASSWORD');

insert into polybius_square_cipher_solutions (cipher_id, dec_message_cz, dec_message_en)
values
(1,
'ZPRAVA',
'MESSAGE');

insert into polybius_square_cipher_solutions (cipher_id, dec_message_cz, dec_message_en)
values
(2,
'PRISNETAINAZPRAVA',
'TOPSECRETMESSAGE');

commit;
