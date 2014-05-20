-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.std_logic_unsigned.all;  
use IEEE.std_logic_arith.all;
----------------------------------------------------------------
entity coe_store_beh is
port(
   -- Dclk     : in  std_logic;
    Read_Coe : in std_logic;
    Coe_limit_in : in std_logic_vector(9 downto 0);
	int_reset  : in  std_logic;
	Pinput : in std_logic_vector(8 downto 0);
    Frame    : in  std_logic;
    m_c  : in std_logic_vector(9 downto 0);
    Coe_out : out std_logic_vector(8 downto 0);
    Coe_sign_out : out std_logic;
    Coe_full    : out  std_logic
    );
end coe_store_beh;
--------------------------------------------------------------
architecture coe_store_beh_arc of coe_store_beh is

constant Coe_uplimit : integer := 512 ;

signal Coe_limit : integer range 0 to 512 ;
signal Coe_f : std_logic;
signal coe_r : std_logic;
signal Coe_j : integer range 0 to 512;
signal inter_m_c : integer range 0 to 512;
signal inter_Coe : integer range 0 to 512;

type coe_array is array (Coe_uplimit downto 1) of integer range 0 to 512;
signal Coe_store : coe_array;	 

type coe_sign_array is array (Coe_uplimit downto 1) of std_logic;
signal Coe_sign_store : coe_sign_array;	
---------------------------------------------------------------------------------------
begin
  
Coe_limit <= conv_integer(unsigned(Coe_limit_in)); 
inter_m_c <= conv_integer(unsigned(m_c)); 
  
Coe_Storage: process(Read_Coe, int_reset, Frame, Coe_j, Pinput)
begin
	if (int_reset = '1') then
	    Coe_store <= (others => 0);
        Coe_sign_store <= (others => '0');
	elsif (Read_Coe = '1') then
	    if (Frame'event and Frame = '1') then
	        Coe_store(Coe_j) <= conv_integer(unsigned(Pinput(7 downto 0)));
	        Coe_sign_store(Coe_j) <= Pinput(8);
		end if;
	end if;
end process;

Coe_counter: process(Read_Coe, int_reset, Frame, Coe_j)
begin
	if (int_reset = '1') then
		Coe_j <= 1;
	elsif (Read_Coe = '1') then
	    if (Frame'event and Frame = '1') then
	        if (Coe_j = Coe_limit) then
	            Coe_j <= Coe_j;
	        elsif (Coe_j < Coe_limit) then
		        Coe_j <= Coe_j+1;
		    end if;
		end if;
	end if;
end process;

Coe_storage_full: process(Read_Coe, int_reset, Frame, Coe_j)
begin
	if (int_reset = '1') then
		Coe_f <= '0';
	elsif (Read_Coe = '1') then
	    if (Frame'event and Frame = '1') then
	        if (Coe_j = Coe_limit) then
	            Coe_f <= '1';
	        elsif (Coe_j < Coe_limit) then
		        Coe_f <= '0';
		    end if;
		end if;
    end if;
end process;

Coe_full <= Coe_f;

coe_read : process(int_reset, Read_coe, coe_r)
begin
   if (int_reset = '1') then
     coe_r <= '0';
   elsif (Read_coe = '1' and coe_r = '0') then
     coe_r <= '1';
   end if;
end process;
  
Coe_o : process(int_reset, coe_r, inter_m_c, Coe_store)
begin
   if (int_reset = '1') then
      inter_Coe <= 0;
   elsif (coe_r = '1') then  
      inter_Coe <= Coe_store(inter_m_c);
   end if;
end process;

Coe_out <=  conv_std_logic_vector(inter_Coe, 9);

Coe_sign_o : process(int_reset, coe_r, inter_m_c, Coe_sign_store)
begin
   if (int_reset = '1') then
      Coe_sign_out <= '0';
   elsif (coe_r = '1') then  
      Coe_sign_out <= Coe_sign_store(inter_m_c);
   end if;
end process;
 
end Coe_store_beh_arc;

