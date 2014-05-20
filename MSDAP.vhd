--------------------------------------------------------------------------
--
-- dual channel MSDAP
---------------------------------------------------------------
-------------------- Library Declarations ---------------------
library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_textio.all;   
use IEEE.std_logic_unsigned.all;  
use IEEE.numeric_std.all;
use std.textio.all;  
----------------------------------------------------------------
entity strMSDAP is
port(
        Sclk     : in  std_logic;
        Dclk     : in  std_logic;
        Start    : in  std_logic;
		  Reset_n  : in  std_logic;
        Frame    : in  std_logic;
        InputL   : in  std_logic;
        InputR   : in  std_logic;
        InReady  : out std_logic;
        OutReady : out std_logic;
        OutputL  : out std_logic;
        OutputR  : out std_logic
    );
end strMSDAP;

architecture strmsdap_arc of strMSDAP is	
signal BothInReady, BothOutReady : std_logic;
signal InReadyL, InReadyR, OutReadyL, OutReadyR : std_logic;
signal output_counter : integer range 0 to 9999;
signal BOR : std_logic;

component single_MSDAP_str
port(
        Sclk     : in  std_logic;
        Dclk     : in  std_logic;
        Start    : in  std_logic;
		    Reset_n  : in  std_logic;
        Frame    : in  std_logic;
        Input   : in  std_logic;
        InReady  : out std_logic;
        OutReady : out std_logic;
        Output  : out std_logic
    );
end component single_MSDAP_str;

begin
	Left_channel: single_MSDAP_str
	        port map(
                  Sclk     => Sclk,
                  Dclk     => Dclk,
                  Start    => Start,
                  Reset_n  => Reset_n,
                  Frame    => Frame,
                  Input   => InputL,
                  InReady  => InReadyL,
                  OutReady => OutReadyL,
                  Output  => OutputL
                 ); 

	Right_channel: single_MSDAP_str
	        port map(
                  Sclk     => Sclk,
                  Dclk     => Dclk,
                  Start    => Start,
                  Reset_n  => Reset_n,
                  Frame    => Frame,
                  Input   => InputR,
                  InReady  => InReadyR,
                  OutReady => OutReadyR,
                  Output  => OutputR
                 ); 
				 
	BOR  <= OutReadyR or OutReadyL;
	BothInReady <= InReadyL or InReadyR;
	BothOutReady <= BOR;
	
	InReady <= BothInReady;
	OutReady <= BothOutReady;
	 			 
out_counter : process(Start, BOR)
begin
  if (Start = '1') then
    output_counter <= 0;
  elsif (BOR'event and BOR = '1') then
    output_counter <= output_counter + 1;
  end if;
end process;

	end  strMSDAP_arc; 
		
		
