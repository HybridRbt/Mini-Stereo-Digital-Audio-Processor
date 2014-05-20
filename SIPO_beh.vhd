-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all; 
----------------------------------------------------------------
entity SIPO_beh is
port(
    Dclk     : in  std_logic;
    rst, input_enabled   : in  std_logic;
    SInput   : in  std_logic;
    POutput  : out std_logic_vector(15 downto 0)
    );
end SIPO_beh;
--------------------------------------------------------------
architecture SIPO_beh_str of SIPO_beh is

signal temp : std_logic_vector(15 downto 0);
signal S_i : integer range 0 to 15;
signal pout : std_logic;
------------------------------------------------------------
begin
	
counter : process(Dclk, rst)
begin
	if (rst = '1') then
		S_i <= 15;
   	elsif (Dclk'event and Dclk='1') then
  		if (input_enabled = '1') then
			if (S_i = 0) then
				S_i <= 15;    
			else
                S_i <= S_i - 1;
			end if;
		end if;
	end if;
end process;
	
out_flag : process(rst, S_i)
begin
    if (rst = '1') then
	   	pout <= '0';
	elsif (S_i = 0) then
	    pout <= '1';
	else
	    pout <= '0';
	end if;
end process;
	
Parallel_Out: process(rst, pout, temp)
begin
    if (rst= '1') then
	    POutput <=  "0000000000000000";
	elsif (pout = '1') then
	    POutput <=  temp;
	end if;
end process;  

Serial_Read: process(rst, Dclk)
begin
    if rst = '1' then
        temp <= "0000000000000000";
    elsif (Dclk'event and Dclk = '1') then
        temp(15 downto 1) <= temp(14 downto 0);
        temp(0) <= SInput;
    end if; 
end process; 
	
end SIPO_beh_str;
	
