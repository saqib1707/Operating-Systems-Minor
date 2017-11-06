library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.datapath_components.all;

entity DUT is
	port (reset, clk: in std_logic);
end entity;

architecture behave of DUT is
	signal a,b,c,d,e,f,g,h,j,k,l,m,n,o,p,q,r,s,t,u,ir_en,c_en,z_en,zdash_en,rfa3,zero_temp: std_logic;
	signal opcode: std_logic_vector(3 downto 0);
	signal last2bits,cz: std_logic_vector(1 downto 0);
	-- component definition
	component datapath_fsm is
		port (
		  A,B,C,D,E,F,G,H,J,K,L,M,N,O,P,Q,R,S,T,U,IR_en,c_en,z_en,zdash_en:in std_logic;
		  clk,reset:in std_logic;
			RFA3,ZT: out std_logic;
		  cz_bits, LSB_IR_bits: out std_logic_vector(1 downto 0);
		  opcode:out std_logic_vector(3 downto 0)
		);
	end component;

	component control_path is
		port (
	    clk,reset:in std_logic;
      opcode_bits:in std_logic_vector(3 downto 0);
	  	RFA3,ZT: in std_logic;
      cz_bits,LSB_IR_bits: in std_logic_vector(1 downto 0);
      A,B,C,D,E,F,G,H,J,K,L,M,N,O,P,Q,R,S,T,U,IR_en,c_en,z_en,zdash_en:out std_logic
		);
	end component;

begin
	datapath_map: datapath_fsm port map(
		A=>a,B=>b,C=>c,D=>d,E=>e,F=>f,G=>g,H=>h,J=>j,K=>k,L=>l,M=>m,N=>n,O=>o,P=>p,Q=>q,R=>r,S=>s,T=>t,U=>u,clk=>clk,RFA3=>rfa3,opcode=>opcode,
		LSB_IR_bits=>last2bits,ZT=>zero_temp,cz_bits=>cz,reset=>reset,IR_en=>ir_en,c_en=>c_en,z_en=>z_en,zdash_en=>zdash_en
	);
	control_map:control_path port map(
		A=>a,B=>b,C=>c,D=>d,E=>e,F=>f,G=>g,H=>h,J=>j,K=>k,L=>l,M=>m,N=>n,O=>o,P=>p,Q=>q,R=>r,S=>s,T=>t,U=>u,clk=>clk,RFA3=>rfa3,reset=>reset,
		opcode_bits=>opcode,LSB_IR_bits=>last2bits,cz_bits=>cz,ZT=>zero_temp,IR_en=>ir_en,c_en=>c_en,z_en=>z_en,zdash_en=>zdash_en
	);
end behave;