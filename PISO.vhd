-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
------------------------------------------------------------------
entity PISO is
	port(
	    Sclk : in STD_LOGIC;
	    Load : in std_logic;
	    Reset : in STD_LOGIC;
		Pinput : in std_logic_vector(0 to 39);
		Sout: out STD_LOGIC
	    );
end PISO;
------------------------------------------------------------------
architecture PISO_arc of PISO is

signal counter : integer range 0 to 39;
signal int_store, int_stores : std_logic_vector(39 downto 0);

type out_state is (initial, standby, loads, op);
signal op_state, next_op_state : out_state;

signal So : std_logic;
-------------------------------------------------------------------------
begin

output_counter : process(Reset, Sclk)
begin
    if (Reset = '1') then
        counter <= 39;
    elsif (Sclk'event and Sclk = '1') then
        if (op_state = initial) then
            counter <= 39;
        elsif (op_state = standby) then
            counter <= 39;
        else
            if (counter = 0) then
                counter <= 39;
            else
                counter <= counter - 1;
            end if;
        end if;
    end if;
end process;
      
select_op_state : process(Load, counter, op_state, Pinput)
begin
    case op_state is
        when initial =>
            int_store <= (OTHERS => '0');
           -- out_f <= '0';
            next_op_state <= standby;
        
        when  standby =>
            if (Load = '1') then
                int_store <= Pinput;
                next_op_state <= op;
            else
                next_op_state <= standby;
            end if;

        when op =>
            if (counter = 39) then
			  --  out_f <= '0';
			    next_op_state <= op;
			elsif (counter = 0) then
			 --   out_f <= '1'; 
			    next_op_state <= standby;
			else
			    next_op_state <= op; 
			end if;
			
   	    when others => null;
    end case;
end process;			

output_state: process(Reset, Sclk)
begin
    if (Reset = '1') then
        op_state <= initial;
    elsif (Sclk'event and Sclk = '1') then
        op_state <= next_op_state;
    end if;
end process;

s_output : process(Reset, Sclk)
begin
    if (Reset = '1') then
        So <= '0';
    elsif (Sclk'event and Sclk = '1') then
        if (next_op_state = op) then
            So <= int_store(counter-1);
        else
            So <= '0';
        end if;
    end if;
end process;    
    
Sout <= So;

end PISO_arc;

