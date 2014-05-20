 -------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;  
use IEEE.std_logic_arith.all; 

----------------------------------------------------------------
entity data_fifo_beh is
port(
    Read_data : in std_logic;
	rst  : in  std_logic;
	Pinput : in std_logic_vector(15 downto 0);
    Frame    : in  std_logic;
    coe_store_in  : in  std_logic_vector(8 downto 0);
    data_fifo_out : out std_logic_vector(39 downto 0)
    );
end data_fifo_beh;
--------------------------------------------------------------

architecture data_fifo_beh_arc of data_fifo_beh is

constant data_limit : integer :=512 ;


signal coe_store : integer range 0 to 512;
signal data_fifo_out_16 : std_logic_vector(15 downto 0);

type data_array is array ((data_limit-1) downto 0) of signed(15 downto 0);
signal data_fifo : data_array; 

begin

coe_store <= conv_integer(coe_store_in);

Data_storage : process(Frame, rst, Read_data, Pinput, data_fifo)
--Data_storage : process(Frame, Read_data, Pinput, data_fifo)
begin
	if (rst = '1') then
		data_fifo <= (others => (others =>'0'));
		--if (Read_data = '1') then
   elsif (Read_data = '1') then
		if (Frame'event and Frame = '1') then
		    data_fifo((data_limit-1) downto 1) <= data_fifo((data_limit-2) downto 0);
			data_fifo(0) <= signed(Pinput);
		end if;
	end if;
end process;

data_out: process(rst, coe_store, data_fifo, Read_data) 
begin
   	if (rst = '1') then
        data_fifo_out_16 <= (others => '0');
    elsif (Read_data = '1') then
        data_fifo_out_16 <= conv_std_logic_vector(data_fifo(coe_store), 16);
    end if;
end process;

data_fifo_out(15 downto 0) <= (others => '0');
data_fifo_out(31 downto 16) <= data_fifo_out_16;
data_fifo_out(39 downto 32) <= (others => data_fifo_out_16(15));

end data_fifo_beh_arc;
