create table marias_hands (game_id integer, p1_hand varchar2(100), p2_hand varchar2(100), p3_hand varchar2(100));
create table marias_hands_solution (game_id integer, p1_bid varchar2(100), p2_bid varchar2(100), p3_bid varchar2(100));

insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (1, '7♠Q♠K♠X♠A♠7♥Q♥K♥X♥A♥', '7♣Q♣K♣X♣A♣7♦Q♦K♦X♦A♦', '8♠9♠8♣9♣J♣8♥9♥8♦9♦J♦');
insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (2, '7♠8♠9♠J♠A♠7♥8♥J♥K♥A♥', '7♣8♣9♣X♣A♣7♦8♦9♦J♦A♦', 'Q♠K♠X♠J♣Q♣K♣Q♥Q♦K♦X♦');
insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (3, '7♠8♠9♠K♠A♠7♥8♥Q♥K♥X♥', '8♣9♣Q♣K♣A♣7♦J♦Q♦K♦A♦', 'J♠Q♠X♠J♣X♣J♥A♥8♦9♦X♦');
insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (4, '7♠8♠9♠X♠7♥8♥9♥J♥X♥A♥', '7♣8♣9♣7♦8♦9♦J♦Q♦X♦A♦', 'J♠Q♠K♠A♠J♣Q♣X♣Q♥K♥K♦');
insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (5, '7♠8♠9♠X♠A♠7♦8♦9♦J♦X♦', 'K♠7♣8♣9♣J♣Q♣K♣X♣A♣K♦', 'J♠Q♠7♥8♥9♥J♥Q♥K♥X♥A♥');
insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (6, '7♠8♠9♠8♥9♥J♥Q♥K♥X♥A♥', '7♣8♣9♣J♣Q♣K♣X♣A♣J♦Q♦', 'J♠Q♠K♠X♠A♠8♦9♦K♦X♦A♦');
insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (7, '7♣Q♣K♣A♣7♥8♥9♥J♥X♥A♦', '7♠8♠9♠J♠X♠Q♥K♥A♥J♦X♦', 'Q♠A♠8♣9♣X♣7♦8♦9♦Q♦K♦');
insert into marias_hands
   (game_id, p1_hand, p2_hand, p3_hand)
 values
   (8, 'X♠A♠X♣A♣Q♥K♥X♥A♥X♦A♦', '8♠J♠K♠9♣K♣8♥J♥7♦J♦K♦', '7♠9♠Q♠8♣J♣Q♣7♥9♥8♦Q♦');

insert into marias_hands_solution values (1,'100+2x7L','100+2x7',null);
insert into marias_hands_solution values (2,'2x7L','2x7',null);
insert into marias_hands_solution values (3,'7L','DURCH',null);
insert into marias_hands_solution values (4,'7L','BETL',null);
insert into marias_hands_solution values (5,'7','7','107L');
insert into marias_hands_solution values (6,'100L','107','100');
insert into marias_hands_solution values (7,'7L','7',null);
insert into marias_hands_solution values (8,'100L',null,null);

commit;  
