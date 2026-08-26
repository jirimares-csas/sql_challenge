create table noughts_and_crosses_boards (board_id integer, board_detail varchar2(1000));

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

commit;
