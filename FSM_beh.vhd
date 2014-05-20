-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;  
use IEEE.numeric_std.all;
----------------------------------------------------------------
entity FSM_beh is
port(
    Sclk : in  std_logic;
    Dclk : in std_logic;
    Frame : in std_logic;
	Input : in std_logic;
	Start : in std_logic;
	Reset_n : in std_logic;
	Rj_full : in std_logic;
	Coe_full : in std_logic;
	--out_finished : in std_logic;
	Load_out : out std_logic;
    int_reset_out : out std_logic;
    rst_out : out std_logic;
    input_enabled :  out std_logic;
    Read_Rj_out : out std_logic;
    Read_Coe_out : out std_logic;
	Read_data_out : out std_logic;
    InR_out : out std_logic;
    OutR_out : out std_logic;
    Work_out : out std_logic
    );
end FSM_beh;
--------------------------------------------------------------
architecture FSM_beh_arc of FSM_beh is

signal sleep_counter : integer range 0 to 12900; 
signal InR, OutR, int_reset : std_logic;
signal rst : std_logic;
signal Read_data, Read_Rj, Read_Coe : std_logic;
signal sleep, OutR2, OutR1, OutR3 : std_logic;
signal o_count : integer range 0 to 3;
signal Work : std_logic;
signal out_count : integer range 0 to 40;

constant sleep_count : integer := 12816; 

type st is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
signal state, next_state: st ; 

type ost is (os0, os1);
signal out_state, next_out_state : ost;
----------------------------------------------------------------
begin
 
int_reset <= Start;
 
in_rdy : process(Sclk)
begin
    if (Sclk'event and Sclk = '1') then
        if (Reset_n = '0') then
            InR <= '0';
        elsif (int_reset = '1') then
            InR <= '0';
        else
            InR <= '1';
        end if;
    end if;
end process;
 
flag_signals : process(rst, next_state)
begin
    if (rst = '1') then
        input_enabled <= '0';
    elsif (next_state = s1) then
        input_enabled <= '0';
    elsif (next_state = s10) then
        input_enabled <= '0';
    elsif (next_state = s0) then
        input_enabled <= '0';
    else 
        input_enabled <= '1';
    end if;
end process;
     
current_state : process(Sclk, Reset_n, int_reset)
begin
    if (Reset_n = '0') then
        state <= s7;
    elsif (int_reset = '1') then
        state <= s0;
	elsif (Sclk'event and Sclk = '1') then
        state <= next_state;
	end if;
end process; 

select_state: process(state, Frame, Rj_full, Coe_full, sleep, Reset_n)
begin
    case state is
        when s0 => 
            Read_Rj <= '0';
		    Read_Coe <= '0';
		    Read_data <= '0';
		    Work <= '0';
            next_state <= s1;
         
        when s1 => 
	        if (Frame ='1') then 
                next_state <= s2;
            else 
                next_state <= s1; 
            end if;
				
        when s2 =>  
            Read_Rj <= '1';	  
            if (Rj_full ='1')	then
			    next_state <= s3;	
		    else
			    next_state <= s2;		  
            end if; 
				
        when s3 =>
	        Read_Rj <= '0';
		    if (Frame ='1') then 
			    next_state <= s4;
		    else
			    next_state <= s3;      
            end if;

        when s4 =>
	        Read_Coe <= '1'; 
		    if (Coe_full ='1') then
			    next_state <= s5;
			else
			    next_state <= s4; 
		    end if;	

        when s5 => 
	   	    Read_Coe <= '0';
            if (Frame ='1') then 
                next_state <= s6;
            else
                next_state <= s5;
            end if;
 
        when s6 =>
	        Work <= '1';
            Read_data <= '1';	
            if (sleep ='1') then 
                next_state <= s8;
            else
                next_state <= s6;			
			end if;
					
		when s7 => 
		    Read_data <= '0';
		    Work <= '0';
			if (Reset_n = '0') then
                next_state <= s7;
            else
			     next_state <= s10;
			--  next_state <= s5;
            end if;
				
        when s8 =>
      	    Work <= '1';
 		    Read_data <= '1';
            if (sleep = '0') then
                next_state <= s9;
            else
                next_state <= s8;
            end if;
          
        when s9 =>
            if (Frame = '1') then
                next_state <= s6;
            else
                next_state <= s9;
            end if;
          
        when s10 =>
            if (Frame = '1') then    
             --   next_state <= s11;
                next_state <= s6;
            else
                next_state <= s10;
            end if;
            
--        when s11 =>
--            if (Frame = '1') then
--                next_state <= s6;
--            else 
--                next_state <= s11;
--            end if;            
            
        when others => null;
    end case;
end process;  

Out_P_to_S : process(Frame, OutR3, Work, rst)
begin
    if (rst = '1') then
	    OutR <= '0';
	elsif (Work = '1') then
	    if (OutR3 = '1') then
	        OutR <= Frame;
	    else
	        OutR <= '0';
	    end if;
	end if;
end process;

sleepcounter: process(Dclk, rst)
begin
    if (rst = '1') then 
	    sleep_counter <= 0;
    elsif (Dclk'event and Dclk = '1') then
        if (sleep_counter = sleep_count)then
		    sleep_counter <= 0;
        elsif (Work = '1' and sleep = '0') then
            if (Input = '0' ) then 
                sleep_counter <=  sleep_counter+1;
            else
                sleep_counter <= 0;
	        end if;
	    end if;
    end if; 
end process;

sleep_flag: process(Dclk, rst)
begin
    if (rst = '1') then 
	    sleep <= '0';
    elsif (Dclk'event and Dclk = '1')then
        if(sleep_counter = sleep_count) then
            sleep <= '1';
        elsif (sleep = '1') then
            if (Input = '1' ) then  
   	            sleep <= '0';
            end if;
        end if;
    end if; 
end process;

count_sclk : process(int_reset, Reset_n, Frame, o_count, OutR3, Work, sleep)
begin
	if (int_reset = '1') then
	    o_count <= 0;
	elsif (Reset_n = '0') then
	   o_count <= 0;
  elsif ((Work = '1') and (sleep = '0')) then
     -- elsif (Work = '1') then
        if (OutR3 = '0') then
            if (Frame'event and Frame = '1') then
                if (o_count = 2) then
                    o_count <= 0;
                else
                    o_count <= o_count + 1;
                end if;
            end if;
        end if;
    elsif (sleep = '1') then
        o_count <= 0; 
    end if;
end process;

Out_P_to_S3 : process(rst, o_count, Work, sleep)
begin
    if (rst = '1') then
	    OutR3 <= '0';
	elsif ((Work = '1') and (sleep = '0')) then
	--  elsif (Work = '1') then
	    if (o_count = 2) then
		    outR3 <= '1';
	    end if;
	else
	    outR3 <= '0';
	end if;
end process;

Out_P_to_S2 : process(rst, Work, sleep, OutR1)
begin
	if (rst = '1') then
	    OutR2 <= '0';
    elsif (sleep = '1') then
	   OutR2 <= '0';
    elsif ((Work = '1') and (sleep = '0')) then
     -- elsif (Work = '1') then
        OutR2 <= OutR1;
    end if;
end process;
	        
current_outstate : process(Sclk, rst)
begin
    if (rst = '1') then
        out_state <= os0;
	elsif (Sclk'event and Sclk = '1') then
	    out_state <= next_out_state;
	end if;
end process; 

select_outstate : process(OutR, out_state, out_count)
begin
    case out_state is
        when os0 =>
            OutR1 <= '0'; 
    		if (OutR = '1') then
                next_out_state <= os1;
            else
                next_out_state <= os0;
            end if;
         
        when os1 =>
            OutR1 <= '1';
	        if  (out_count = 39) then 
                next_out_state <= os0;
            else 
                next_out_state <= os1; 
            end if;            
            
        when others => null;
    end case;
end process;        	

out_counter : process(rst, Sclk)
begin
    if (rst = '1') then
        out_count <= 0;
    elsif (Sclk'event and Sclk = '1') then
        if (OutR1 = '1') then
            if (out_count = 39) then
                out_count <= 0;
            else
                out_count <= out_count + 1;
            end if;
        else
            out_count <= 0;
        end if;
    end if;
end process;
  
    rst_out <= (not Reset_n) or Start;
    rst <=   (not Reset_n) or Start;
    InR_out <= InR;
    Load_out <= OutR;
    OutR_out <= OutR2;
    int_reset_out <= int_reset;
    
    Read_Rj_out <= Read_Rj; 
    Read_Coe_out <= Read_Coe; 
    Read_data_out <= Read_data; 
    
    Work_out <= Work;

end FSM_beh_arc;