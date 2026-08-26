create table noughts_and_crosses_boards (board_id integer, board_detail varchar2(1000));
create table noughts_and_crosses_solution (board_id integer, crosses_move varchar2(1000), noughts_move varchar2(1000));

insert into noughts_and_crosses_boards (board_id, board_detail) values (1,
'          
   O      
   XO  O  
   XXXO   
   X O    
   XO     
          
          
          
          '
);

insert into noughts_and_crosses_boards (board_id, board_detail) values (2,
'          
          
 XX  X    
 OOOOX    
  OOX     
  O OX    
 X   X    
          
          
          '
);

insert into noughts_and_crosses_boards (board_id, board_detail) values (3,
'        
     X  
    O   
  XO O  
   X    
        
        
        '
);

insert into noughts_and_crosses_boards (board_id, board_detail) values (4,
'        
        
  OX  X 
 OOOOX  
   XXX  
   O    
        
        '
);

insert into noughts_and_crosses_boards (board_id, board_detail) values (5,
'XXXX    XXXX
            
   OOOO     
   OOOO     
   OOO      
   OOOO     
      O     
            
            
            
            
XXXX    XXXX'
);

insert into noughts_and_crosses_boards (board_id, board_detail) values (6,
'           X
 OOOO OOOO  
         X  
        X   
       X    
            
     X      
    X       
   X        
            
 X          
            '
);

insert into noughts_and_crosses_boards (board_id, board_detail) values (7,
'   XX   
        
  OOOO  
        
        
        
        
   XX   '
);

insert into etl_owner.noughts_and_crosses_solution
   (board_id, crosses_move, noughts_move)
 values
   (1, 'G4', 'B9, G4');
   
insert into etl_owner.noughts_and_crosses_solution
   (board_id, crosses_move, noughts_move)
 values
   (2, 'E6', 'D1');
   
insert into etl_owner.noughts_and_crosses_solution
   (board_id, crosses_move, noughts_move)
 values
   (3, '?', '?');
   
insert into etl_owner.noughts_and_crosses_solution
   (board_id, crosses_move, noughts_move)
 values
   (4, 'D1', 'D1');
   
insert into etl_owner.noughts_and_crosses_solution
   (board_id, crosses_move, noughts_move)
 values
   (5, 'A5, A8, L5, L8', 'B3, B4, B5, B6, B8, C3, C8, D3, D8, E7, F3, F8, G3, G4, G5, G6, G8, H8');
   
insert into etl_owner.noughts_and_crosses_solution
   (board_id, crosses_move, noughts_move)
 values
   (6, 'B11, F7, J3', 'B1, B6, B11');
   
insert into etl_owner.noughts_and_crosses_solution
   (board_id, crosses_move, noughts_move)
 values
   (7, '!', 'C2, C7');

commit;
