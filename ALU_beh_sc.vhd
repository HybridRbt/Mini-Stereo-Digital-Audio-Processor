-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;  
use IEEE.std_logic_arith.all;
----------------------------------------------------------------
entity ALU_beh_sc is
port(
    Sclk  : in  std_logic;
    Frame : in std_logic;
	rst : in  std_logic;
	m_c_out : out std_logic_vector(9 downto 0);
    yOutput  : out std_logic_vector(39 downto 0);
    u_out : out std_logic_vector(3 downto 0);
    Rj_store_in: in std_logic_vector(8 downto 0);
    u_start_store_in : in std_logic_vector(8 downto 0);
    coe_store_sign_in : in std_logic;
    data_fifo_in : in std_logic_vector(39 downto 0);
    Work_in : in std_logic 
    );
end ALU_beh_sc;
--------------------------------------------------------------
architecture ALU_beh_sc_arc of ALU_beh_sc is

signal u : integer range 0 to 16;
signal y_store, y : signed(39 downto 0) ;
signal inter_Rj  : integer range 0 to 512;
signal u_end : integer range 0 to 512;
signal u_initial : std_logic;
signal m_c : integer range 0 to 512;
signal u_temp : signed(39 downto 0) ;
signal inter_u_start : integer range 0 to 512;
signal begin_calc : std_logic;
signal add_u : std_logic;
signal shift_u : std_logic;
signal write_y : std_logic;
signal Work : std_logic;
signal data_fifo : signed(39 downto 0);

type cst is (s600, s60, s61, s62, s63, s64, s65);
signal next_calc_state: cst ; 
---------------------------------------------------------------------
begin

inter_u_start <= conv_integer(unsigned(u_start_store_in));
Work <= Work_in;
u_out <= conv_std_logic_vector(u, 4);
inter_Rj <= conv_integer(unsigned(Rj_store_in));
data_fifo <= signed(data_fifo_in);

select_calc_state: process(Sclk,rst)
begin
    if (rst = '1') then
        u <= 0;
        m_c <= 1;
        next_calc_state <= s600;
	    u_end <= 2;
	    begin_calc <= '0';
	    add_u <= '0';
	    shift_u <= '0';
	    write_y <= '0';
	    u_initial <= '1';
    elsif (Sclk'event and Sclk = '1')then
        case next_calc_state is
            when s600 =>
          	    u <= 0;
                m_c <= 1;
				u_end <= 2;
                if (Frame = '1') then
                    next_calc_state <= s60;
                    u_initial <= '1';
                end if;
            
            when s60 =>
                if (Work = '1') then
			        u <=0;
			        if (Frame = '1') then
				        next_calc_state <= s61;
	        			u_initial <= '0';
	    			    begin_calc <= '1';
			        end if;
		 	    end if;
					
            when s61 =>
                if (Work ='1') then
                    m_c <= inter_u_start;
				    u_end <= inter_u_start + inter_Rj -1;
                    next_calc_state <= s62;
   		            begin_calc <= '0';
                    add_u <= '1';
           		end if;
				
            when s62 =>
                if (Work = '1') then
		            if (m_c = u_end) then
		                next_calc_state <= s63;
		                add_u <= '0';
		                shift_u <= '1';
		            elsif (m_c < u_end) then
		                m_c <= m_c + 1;
		                add_u <= '1';
		                shift_u <= '0';
		                next_calc_state <= s62;
		            end if;	
	            end if;	 
			
            when s63 =>
                if (Work = '1') then
                    if (u < 15) then
				        u <= u+1;
				        next_calc_state <= s61;
				        begin_calc <= '1';
			            shift_u <= '0';
		            elsif (u = 15) then
				        next_calc_state <= s64;
				        shift_u <= '0';
				        write_y <= '1';
		            end if;
		        end if;

	        when s64 =>
		        if (Work = '1') then
				    next_calc_state <= s60;
				    write_y <= '0';
				    u_initial <= '1';
		        end if;
		     
            when others => null;
        end case;
    end if;
end process; 

m_c_out <= conv_std_logic_vector(m_c, 10);

acc: process(Sclk, rst, u_initial)
begin
	if (rst = '1')then
	   	u_temp <= (others => '0');
	elsif (u_initial = '1') then
        u_temp <= (others => '0');
	elsif (Sclk'event and Sclk = '1') then
	    if (Work = '1') then
	        if (begin_calc = '1') then
		        u_temp <= y;
	        elsif (add_u = '1') then
	            if (Coe_store_sign_in = '0') then
	                u_temp <= u_temp + data_fifo;
	            elsif (Coe_store_sign_in = '1') then
		            u_temp <= u_temp - data_fifo;
	            end if;
            end if;
        end if;
	end if; 
end process;

shift : process(rst, shift_u, u_initial, u_temp)
begin
    if (rst = '1') then
        y <= "0000000000000000000000000000000000000000";
    elsif (u_initial = '1') then
        y <= (others => '0') ;
    elsif (shift_u = '1') then
        y(38 downto 0) <= u_temp(39 downto 1) ;
        y(39) <= u_temp(39);
    end if;
end process;

write : process(rst, write_y, y)
begin
    if (rst = '1') then
        y_store <= "0000000000000000000000000000000000000000";
    elsif (write_y = '1') then
        y_store <= y; 
    end if;
end process;
	
yOutput <= conv_std_logic_vector(y_store, 40);
   		
end  ALU_beh_sc_arc; 

