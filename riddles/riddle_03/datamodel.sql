create table marias_games (game_id integer, p1_bid varchar2(20 char), p2_bid varchar2(20 char), p3_bid varchar2(20 char));
create table marias_bids (bid_ord_nr integer, bid_id varchar2(20 char), bid_name varchar2(50 char));
create table marias_game_bids (game_id integer, bids varchar2(32000 char));

insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (1, '7', '7', '7L');
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (2, '100', '7', '7L');
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (3, '100', '7L', '7');
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (4, null, null, '7');
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (5, '100', 'DURCH', '107L');
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (6, '2x7', 'DURCH', '2x7L');
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (7, null, 'DURCH', 'BETL');
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (8, null, '100', null);
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (9, null, null, null);
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (10, '107', '107', null);
insert into marias_games (game_id, p1_bid, p2_bid, p3_bid) values (11, null, '107', 'BETL');

insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (1, '7', 'sedma');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (2, '7L', 'lepší sedma');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (3, '100', 'stovka');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (4, '100L', 'lepší stovka');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (5, '107', 'stosedm');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (6, '107L', 'lepších stosedm');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (7, 'BETL', 'betl');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (8, 'DURCH', 'durch');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (9, '2x7', 'dvě sedmy');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (10, '2x7L', 'lepší dvě sedmy');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (11, '100+2x7', 'sto a dvě sedmy');
insert into marias_bids (bid_ord_nr, bid_id, bid_name) values (12, '100+2x7L', 'lepší sto a dvě sedmy');

insert into marias_game_bids (game_id, bids) values (1, 
'2: sedma
1: mám
2: mlčím
3: lepší sedma
1: mlčím');

insert into marias_game_bids (game_id, bids) values (2, 
'2: sedma
1: mám
2: mlčím
3: lepší sedma
1: mám
3: mlčím');

insert into marias_game_bids (game_id, bids) values (3, 
'2: sedma
1: mám
2: lepší sedma
1: mám
2: mlčím
3: mlčím');

insert into marias_game_bids (game_id, bids) values (4, 
'2: mlčím
3: sedma
1: mlčím');

insert into marias_game_bids (game_id, bids) values (5, 
'2: sedma
1: mám
2: lepší sedma
1: mám
2: stovka
1: mám
2: lepší stovka
1: mlčím
3: stosedm
2: mám
3: lepších stosedm
2: mám
3: mlčím');

insert into marias_game_bids (game_id, bids) values (6, 
'2: sedma
1: mám
2: lepší sedma
1: mám
2: stovka
1: mám
2: lepší stovka
1: mám
2: stosedm
1: mám
2: lepších stosedm
1: mám
2: betl
1: mám
2: durch
1: mám
2: mlčím
3: dvě sedmy
1: mám
3: lepší dvě sedmy
1: mlčím');

insert into marias_game_bids (game_id, bids) values (7, 
'2: sedma
1: mlčím
3: lepší sedma
2: mám
3: stovka
2: mám
3: lepší stovka
2: mám
3: stosedm
2: mám
3: lepších stosedm
2: mám
3: betl
2: mám
3: mlčím');

insert into marias_game_bids (game_id, bids) values (8, 
'2: sedma
1: mlčím
3: mlčím');

insert into marias_game_bids (game_id, bids) values (9, 
'2: mlčím
3: mlčím
1: mlčím');

insert into marias_game_bids (game_id, bids) values (10, 
'2: sedma
1: mám
2: lepší sedma
1: mám
2: stovka
1: mám
2: lepší stovka
1: mám
2: stosedm
1: mám
2: mlčím
3: mlčím');

insert into marias_game_bids (game_id, bids) values (11, 
'2: sedma
1: mlčím
3: lepší sedma
2: mám
3: stovka
2: mám
3: lepší stovka
2: mám
3: stosedm
2: mám
3: lepších stosedm
2: mlčím');

commit;
