-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;  
use IEEE.std_logic_arith.all; 
----------------------------------------------------------------
entity single_MSDAP_str is
port(
    Sclk     : in  std_logic;
    Dclk     : in  std_logic;
    Start    : in  std_logic;
	Reset_n  : in  std_logic;
    Frame    : in  std_logic;
    Input    : in  std_logic;
    InReady  : out std_logic;
    OutReady : out std_logic;
    Output  : out std_logic
    );
end single_MSDAP_str;
--------------------------------------------------------------
architecture single_msdap_str_arc of single_MSDAP_str is

component SIPO_beh
port(
    Dclk     : in  std_logic;
	rst, input_enabled : in  std_logic;
    SInput   : in  std_logic;
    POutput  : out std_logic_vector(15 downto 0)
    );
end component SIPO_beh;	  

component PISO is
port(
	Sclk : in STD_LOGIC; 
	Load : in std_logic;
	Reset : in STD_LOGIC;
	Pinput : in STD_LOGIC_VECTOR(0 to 39);
	Sout: out STD_LOGIC
	);
end component PISO;

component Rj_store_beh is
port(
   -- Dclk     : in  std_logic;
    Read_Rj : in std_logic;
    int_reset  : in  std_logic;
	Pinput : in std_logic_vector(9 downto 0);
    Frame    : in  std_logic;
    u_in  : in  std_logic_vector(3 downto 0);
	Rj_full    : out  std_logic;
    u_start_store_out : out std_logic_vector(8 downto 0);
    Rj_out : out std_logic_vector(8 downto 0);
    Coe_limit_out : out std_logic_vector(9 downto 0)
    );
end component Rj_store_beh;

component coe_store_beh is
port(
 --   Dclk     : in  std_logic;
    Read_Coe : in std_logic;
    Coe_limit_in : in std_logic_vector(9 downto 0);
	int_reset  : in  std_logic;
	Pinput : in std_logic_vector(8 downto 0);
    Frame    : in  std_logic;
    m_c  : in  std_logic_vector(9 downto 0);
	Coe_full    : out  std_logic;
    Coe_out : out std_logic_vector(8 downto 0);
    Coe_sign_out : out std_logic    
    );
end component coe_store_beh;

component data_fifo_beh is
port(
    Read_data : in std_logic;
	rst  : in  std_logic;
	Pinput : in std_logic_vector(15 downto 0);
    Frame    : in  std_logic;
    coe_store_in  : in  std_logic_vector(8 downto 0);
    data_fifo_out : out std_logic_vector(39 downto 0)
    );
end component data_fifo_beh;

component ALU_beh_sc is
port(
    Sclk     : in  std_logic;
	Frame : in std_logic;
	rst : in  std_logic;
    Rj_store_in: in std_logic_vector(8 downto 0);
    u_start_store_in : in std_logic_vector(8 downto 0);
    coe_store_sign_in : in std_logic;
    data_fifo_in : in std_logic_vector(39 downto 0);
    Work_in : in std_logic;
	m_c_out : out std_logic_vector(9 downto 0);
    yOutput  : out std_logic_vector(39 downto 0);
    u_out : out std_logic_vector(3 downto 0)	
    );
end component ALU_beh_sc;

component FSM_beh is
port(
    Sclk     : in  std_logic;
    Dclk : in std_logic;
	Frame : in std_logic;
	Input : in std_logic;
	Start : in std_logic;
	Reset_n : in std_logic;
	Rj_full : in std_logic;
	Coe_full : in std_logic;
    --out_finished : in std_logic;
    Load_out : out std_logic;
    int_reset_out :out std_logic;
    rst_out : out std_logic;
    input_enabled :  out std_logic;
    Read_Rj_out : out std_logic;
    Read_Coe_out : out std_logic;
	Read_data_out : out std_logic;
    InR_out : out std_logic;
    OutR_out : out std_logic;
    Work_out : out std_logic
    );
end component FSM_beh;

----------------------------------------------------------------------------
signal m_c : std_logic_vector(9 downto 0);
------------------Output y---------------------
signal yOutput : std_logic_vector(39 downto 0);
--------------------All kinds of Flags and pointers-----------------------------------------------
signal Rj_full, Coe_full : std_logic;
signal Pinput : std_logic_vector(15 downto 0);
signal Coe_limit : std_logic_vector(9 downto 0);
-----------------FSM-------------------------------------------------------
signal input_enabled : std_logic;
signal Read_data, Read_Rj, Read_Coe : std_logic;
signal InR, OutR, rst, int_reset : std_logic;
signal u : std_logic_vector(3 downto 0);
signal out_finished : std_logic;
signal u_start_store_in : std_logic_vector(8 downto 0);
signal Rj_store_in : std_logic_vector(8 downto 0);
signal Coe_store_sign_in : std_logic;
signal Coe_store_in : std_logic_vector(8 downto 0); 
signal data_fifo_in : std_logic_vector(39 downto 0) ;
signal Load : std_logic;
signal Work : std_logic;

---=====================------------------  
begin
	SIPO : SIPO_beh
	port map(
	        Dclk    => Dclk,
		    rst     => rst,
		    input_enabled  => input_enabled,
            SInput   => Input,
            POutput  => Pinput
		    );
		
	PS: PISO
	port map(
	        Sclk => Sclk,
	        Load => Load,
		    Reset => rst,
		    Pinput => yOutput,
		    Sout => Output
		   -- out_f =>out_finished
	        );

    Rj_store : Rj_store_beh
    port map(
         --   Dclk   => Dclk,
            Read_Rj => Read_Rj,
            Rj_full =>Rj_full,
	        int_reset => int_reset,
	        Pinput => Pinput(9 downto 0),
            Frame => Frame,
            u_in  => u,
            u_start_store_out => u_start_store_in,
            Rj_out => Rj_store_in,
            Coe_limit_out => Coe_limit
            );

    Coe_store : coe_store_beh
    port map(
        --    Dclk   => Dclk,
            Read_Coe => Read_Coe,
            Coe_full   => Coe_full,
	        int_reset  => int_reset,
	        Pinput => Pinput(8 downto 0),
            Frame   => Frame,
            m_c  => m_c,
            Coe_out => Coe_store_in,
            Coe_sign_out => Coe_store_sign_in,
            Coe_limit_in => Coe_limit
            );
   
    data_store : data_fifo_beh 
    port map(
            Read_data => Read_data,
	        rst => rst,
	        Pinput => Pinput,
            Frame    => Frame,
            coe_store_in  => coe_store_in,
            data_fifo_out => data_fifo_in
            );

    ALU_sc : ALU_beh_sc
    port map(
            Sclk   => Sclk,
		    Frame => Frame,
		    rst => rst,
		    m_c_out => m_c,
		    u_out => u,
            yOutput  => yOutput,
            Rj_store_in => Rj_store_in,
            u_start_store_in => u_start_store_in,
            coe_store_sign_in =>  coe_store_sign_in,
            data_fifo_in => data_fifo_in,
            Work_in => Work 
            );

    FSM : FSM_beh
    port map(
            Sclk   => Sclk,
            Dclk => Dclk,
		    Frame => Frame,
		    Input => Input,
		    Start => Start,
		    Reset_n => Reset_n,
		    Rj_full => Rj_full,
		    Coe_full => Coe_full,
		    --out_finished => out_finished,
		    Load_out => Load,
            int_reset_out => int_reset,
            rst_out => rst, 
            input_enabled => input_enabled, 
            Read_Rj_out => Read_Rj,
            Read_Coe_out => Read_Coe,
		    Read_data_out => Read_data,
            InR_out => InR,
            OutR_out => OutR,
            Work_out => Work
            );
  
InReady <= InR;
OutReady <= OutR;
    
--==========================--
--==========================--
end  single_MSDAP_str_arc; 
		
		


