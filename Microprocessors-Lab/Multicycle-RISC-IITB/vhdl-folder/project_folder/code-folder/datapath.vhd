library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.datapath_components.all;

entity datapath_fsm is
	port (
    A,B,C,D,E,F,G,H,J,K,L,M,N,O,P,Q,R,S,T,U,IR_en,c_en,z_en,t1_en:in std_logic;
    clk,reset:in std_logic;
	  RFA3,z_dash: out std_logic;
    cz_bits, LSB_IR_bits: out std_logic_vector(1 downto 0);
    T4_output: out std_logic_vector(15 downto 0);
    opcode:out std_logic_vector(3 downto 0)
	);
end entity;

architecture behave of datapath_fsm is
-- component declaration already done in work
signal pc_in,pc_out,mux_U,rf_d1,rf_d2,rf_d3,mem_data_out,mem_addr,alu1_in,alu2_in,mux2_out:std_logic_vector(15 downto 0);
signal t1_in,t1_out,t2_in,t2_out,t3_in,t3_out,IR_out,mux_t4_in1,t4_in,t4_out,d1_out,d2_out:std_logic_vector(15 downto 0);
signal mux_alu2_11,mux_alu2_10,mux_alu2_01,shift7_in,shift7_out,alu_out: std_logic_vector(15 downto 0);
signal pc_en,alpha,gamma,JLR,BEQ,LHI,LW_SW,LM_SM,BEQ_SW,SM,LM,LW_SW_ADI,zd: std_logic;
signal rf_a1,rf_a2,rf_a3,PE_out: std_logic_vector(2 downto 0);
signal alu_opc:std_logic_vector(3 downto 0);
signal temp_cz:std_logic_vector(1 downto 0);
signal ZE_out,mux_H_out:std_logic_vector(8 downto 0);

begin
  JLR <= IR_out(15) and (not(IR_out(14))) and (not(IR_out(13))) and IR_out(12);
  BEQ <= IR_out(15) and IR_out(14) and (not(IR_out(13))) and (not(IR_out(12))); 
  LHI <= (not(IR_out(15))) and (not(IR_out(14))) and IR_out(13) and IR_out(12);
  LW_SW <= ((not(IR_out(15))) and IR_out(14) and (not(IR_out(13))) and (not(IR_out(12)))) or ((not(IR_out(15))) and IR_out(14) and (not(IR_out(13))) and IR_out(12));
  LW_SW_ADI <= (LW_SW or (not(IR_out(15)) and not(IR_out(14)) and not(IR_out(13)) and IR_out(12)));
  LM_SM <= ((not(IR_out(15))) and IR_out(14) and IR_out(13) and (not(IR_out(12)))) or ((not(IR_out(15))) and IR_out(14) and IR_out(13) and IR_out(12)); 
  BEQ_SW <= (IR_out(15) and IR_out(14) and (not(IR_out(13))) and (not(IR_out(12)))) or ((not(IR_out(15))) and IR_out(14) and (not(IR_out(13))) and IR_out(12));
  SM <= (not(IR_out(15))) and IR_out(14) and IR_out(13) and IR_out(12);
  LM <= (not(IR_out(15)))  and IR_out(14) and IR_out(13) and (not(IR_out(12)));               
  
  IR : dregister port map(din=>mem_data_out, dout=>IR_out, wr_en=>IR_en, clk=>clk);

  -- RF section
  mux_d1_t1: MUX21 port map(d1=>d1_out, d2=>alu_out, s=>J, dout=>t1_in);
  mux_d3: MUX4X1 port map(d1=>pc_out, d2=>t3_out, d3=>pc_out, d4=>shift7_out, s1=>LHI, s0=>R, dout=>rf_d3);
  mux_a1: MUX21 generic map(nbits=>3) port map(d1=>IR_out(8 downto 6), d2=>IR_out(11 downto 9), s=>LM_SM, dout=>rf_a1);
  mux_a2: MUX4X1 generic map(nbits=>3) port map(d1=>IR_out(5 downto 3), d2=>PE_out, d3=> IR_out(11 downto 9), d4=>PE_out, s1=>BEQ_SW, s0=>SM, dout=>rf_a2);
  mux_a3: MUX4X1 generic map(nbits=>3) port map(d1=>"111", d2=>IR_out(11 downto 9), d3=>"111", d4=>PE_out, s1=>LM, s0=>Q, dout=>rf_a3);
  RF : register_file port map(a1=>rf_a1, a2=>rf_a2, a3=>rf_a3, d3=>rf_d3, wr_en=>P, d1=>d1_out, d2=>t2_in, clk=>clk,reset=>reset);

  sgn_LHI: sgn generic map(nbits=>9) port map(din=>IR_out(8 downto 0), dout=>shift7_in);
  LS_7: leftshift_7 port map(din=>shift7_in, dout=>shift7_out);

  T1: dregister port map(din=>t1_in, dout=>t1_out, wr_en=>t1_en, clk=>clk);
  T2 : dregister port map(din=>t2_in, dout=>t2_out, wr_en=>'1', clk=>clk);
  -- T3
  mux_t3: MUX21 port map(d1=>mem_data_out, d2=>alu_out, s=>M, dout=>t3_in);
  T3: dregister port map(din=>t3_in, dout=>t3_out, wr_en=>T, clk=>clk);
  -- T4
  sgn9_t4: sgn port map(din=>IR_out(8 downto 0), dout=>mux_t4_in1);
  mux_t4: MUX21 port map(d1=>alu_out, d2=>mux_t4_in1, s=>N, dout=>t4_in);
  T4: dregister port map(din=>t4_in, dout=>t4_out, wr_en=>O, clk=>clk);
  -- asynch mem
  mux_mem: MUX4X1 port map(d1=>t1_out, d2=>pc_out, d3=>t3_out, d4=>pc_out, s1=>LW_SW, s0=>C, dout=>mem_addr);
  mem: asynch_mem port map(din=>t2_out, dout=>mem_data_out, rdbar=>D, wrbar=>E, addrin=>mem_addr);
  -- PC section
  gamma <= (B and (zd or JLR));
  mux1: MUX21 port map(d1=>alu_out, d2=>rf_d3, s=>U, dout=>mux_U);
  mux2: MUX4X1 port map(d1=>mux_U, d2=>t3_out, d3=>mux_U, d4=>t1_out, s1=>JLR, s0=>gamma, dout=>mux2_out);
  mux3: MUX21 port map(d1=>mux2_out,d2=>"0000000000000000",s=>reset,dout=>pc_in);
	alpha <= (rf_a3(0) and rf_a3(1) and rf_a3(2));
  pc_en <= ((zd and BEQ) or A) or (U and alpha);
  PC : dregister port map(din=>pc_in,dout=>pc_out,wr_en=>pc_en,clk=>clk);

  PE : priority_encoder port map(din=>t4_out(7 downto 0),dout=>PE_out);                
  ZE : zero_decoder port map(din=>PE_out, dout=>ZE_out);              
  
 	-- ALU input section
  mux_alu1: MUX4X1 port map(d1=>"1111111111111111", d2=>t4_out, d3=>t1_out, d4=>pc_out, s1=>F, s0=>G, dout=>alu1_in);
  sgn6: sgn generic map(nbits=>6) port map(din=>IR_out(5 downto 0), dout=>mux_alu2_11);
  mux_H: MUX21 generic map(nbits=>9) port map(d1=>IR_out(8 downto 0), d2=>ZE_out, s=>H, dout=>mux_H_out);
  sgn9: sgn generic map(nbits=>9) port map(din=>mux_H_out, dout=>mux_alu2_01);
  alu2_mux_10: MUX21 port map(d1=>t2_out, d2=>mux_alu2_11, s=>LW_SW_ADI, dout=>mux_alu2_10);
  mux_alu2: MUX4X1 generic map(nbits=>16) port map(d1=>"0000000000000001", d2=>mux_alu2_01, d3=>mux_alu2_10, d4=>mux_alu2_11, s1=>K,s0=>L,dout=>alu2_in);
  -- ALU inside section
  carry_flag:onedregister port map(din=>temp_cz(1),dout=>cz_bits(1),wr_en=>c_en,clk=>clk);
  zero_flag:onedregister port map(din=>temp_cz(0),dout=>cz_bits(0),wr_en=>z_en,clk=>clk);
  --zdash:onedregister port map(din=>zd,dout=>ZT,wr_en=>zdash_en,clk=>clk);
  alu_inside:alu port map(X=>alu1_in,Y=>alu2_in,Z=>alu_out,OPC=>alu_opc,CF=>temp_cz(1),ZF=>temp_cz(0),ZERO_TEMP=>zd);
  z_dash<=zd;
  T4_output<=t4_out;
  RFA3 <= alpha;
  opcode <= IR_out(15 downto 12);
  LSB_IR_bits <= IR_out(1 downto 0);
  process(S,IR_out) is
  begin
    if(S = '0') then
      alu_opc <= "1111";      -- simple addition
    else
      alu_opc <= IR_out(15 downto 12);  -- based on opcode
    end if;
  end process;
end behave;