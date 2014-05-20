-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.std_logic_unsigned.all;  
use IEEE.std_logic_arith.all;
----------------------------------------------------------------
entity Rj_store_beh is
port(
  --  Dclk     : in  std_logic;
    Read_Rj : in std_logic;
	int_reset  : in  std_logic;
	Pinput : in std_logic_vector(9 downto 0);
    Frame    : in  std_logic;
    u_in  : in  std_logic_vector(3 downto 0);
    u_start_store_out : out std_logic_vector(8 downto 0);
    Rj_out : out std_logic_vector(8 downto 0);
    Rj_full : out  std_logic;
    Coe_limit_out : out std_logic_vector(9 downto 0)
    );
end Rj_store_beh;
--------------------------------------------------------------
architecture Rj_store_beh_arc of Rj_store_beh is

signal u : integer range 0 to 16;
signal Rj_f : std_logic;
signal Rj_r : std_logic;
signal Rj_j : integer range 0 to 15;
signal inter_u_start_store : integer range 0 to 512;
signal Rj : integer range 0 to 512;
signal Coe_limit : integer range 0 to 512;

type Rj_array is array (15 downto 0) of integer range 0 to 512;
signal Rj_store : Rj_array;

type u_pointer is array (16 downto 1) of integer range 0 to 512;
signal u_start_store : u_pointer; 
------------------------------------------------------------------------------
begin

u <= conv_integer(u_in);
Coe_limit_out <= conv_std_logic_vector(Coe_limit, 10);

count_coe_limit : process(int_reset, Rj_f, Rj_store)
begin
    if (int_reset = '1') then
        Coe_limit <= 0;
    elsif (Rj_f = '1') then
        Coe_limit <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + Rj_store(9) + Rj_store(10) + Rj_store(11) + Rj_store(12) + Rj_store(13) + Rj_store(14) + Rj_store(15) ;
    end if;
end process;
  
Rj_Storage: process(Read_Rj, int_reset, Frame, Pinput, Rj_j)
begin
    if (int_reset = '1') then
        Rj_store <= (others => 0);	
    elsif (Read_Rj = '1') then
        if (Frame'event and Frame = '1') then
            Rj_store(Rj_j) <= conv_integer(unsigned(Pinput));
        end if;
    end if;
end process;

Rj_count: process(Read_Rj, int_reset, Frame, Rj_j)
begin
    if (int_reset = '1') then
        Rj_j <= 0;
    elsif (Read_Rj = '1') then
        if (Frame'event and Frame = '1') then
            if (Rj_j < 15) then
                Rj_j <= Rj_j+1;
            end if;
        end if;
    end if;
end process;

Rj_storage_full: process(Read_Rj, int_reset, Frame, Rj_j)
begin
    if (int_reset = '1') then
        Rj_f <= '0';	
    elsif (Read_Rj = '1') then
        if (Frame'event and Frame = '1') then
            if (Rj_j = 15) then
                Rj_f <= '1';
            elsif (Rj_j < 16) then
                Rj_f <= '0';
            end if;
        end if;
    end if;
end process;

Rj_full <= Rj_f ;

u_current_position: process(int_reset, Rj_f, Rj_store)
begin
	if (int_reset = '1') then
	    u_start_store <= (others => 0);    
	elsif (Rj_f = '1') then
		u_start_store(1) <= 1;
		u_start_store(2) <= Rj_store(0) + 1;
		u_start_store(3) <= Rj_store(0) + Rj_store(1) + 1;
		u_start_store(4) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + 1;
		u_start_store(5) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + 1; 
		u_start_store(6) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + 1;
		u_start_store(7) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + 1;
		u_start_store(8) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + 1;
		u_start_store(9) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + 1;
		u_start_store(10) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + 1;
		u_start_store(11) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + Rj_store(9) + 1;
		u_start_store(12) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + Rj_store(9) + Rj_store(10) + 1; 
		u_start_store(13) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + Rj_store(9) + Rj_store(10) + Rj_store(11) + 1; 
		u_start_store(14) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + Rj_store(9) + Rj_store(10) + Rj_store(11) + Rj_store(12) + 1;
		u_start_store(15) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + Rj_store(9) + Rj_store(10) + Rj_store(11) + Rj_store(12) + Rj_store(13) + 1; 
		u_start_store(16) <= Rj_store(0) + Rj_store(1) + Rj_store(2) + Rj_store(3) + Rj_store(4) + Rj_store(5) + Rj_store(6) + Rj_store(7) + Rj_store(8) + Rj_store(9) + Rj_store(10) + Rj_store(11) + Rj_store(12) + Rj_store(13) + Rj_store(14) + 1; 
	end if;
end process;

rj_read : process(int_reset, Frame)
begin
    if (int_reset = '1') then
        Rj_r <= '0';
    elsif (Frame'event and Frame = '1') then
        if (Rj_f = '1') then
            Rj_r <= '1';
        end if;
    end if;
end process;

Rj_o : process(int_reset, Rj_r, u, Rj_store )
begin
    if (int_reset = '1') then
        Rj <= 1;
    elsif (Rj_r = '1') then
        Rj <= Rj_store(u);
    end if;
end process;

Rj_out <= conv_std_logic_vector(Rj, 9);

ustart_o : process(int_reset, Rj_r, u, u_start_store )
begin
    if (int_reset = '1') then
        inter_u_start_store <= 1;
    elsif (Rj_r = '1') then
        inter_u_start_store <= u_start_store(u+1);
    end if;
end process;

u_start_store_out <= conv_std_logic_vector(inter_u_start_store, 9);

end Rj_store_beh_arc;