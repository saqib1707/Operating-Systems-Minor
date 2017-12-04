library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.datapath_components.all;

entity datapath_fsm is
	port (
    clk,reset:in std_logic
	);
end entity;

architecture behave of datapath_fsm is
-- component declaration already done in work
constant zeros:std_logic_vector(15 downto 0):="0000000000000000";
constant ones:std_logic_vector(15 downto 0):="1111111111111111";

signal mux25_out,PC_out,adder1_out,Imem_data_out,addrin,PR1_IR_out,PR1_PC_out,mux0_out,PR2_IR_out,PR2_PC_out,xor_out: std_logic_vector(15 downto 0):=zeros;
signal mult_out,mux1_00_in,mux1_01_in,mux1_10_in,PR3_PC_out,mux16_out,mux20_out,alu_out,PR4_d1_out,PR4_d2_out,mux10_out : std_logic_vector(15 downto 0):=zeros;
signal mux1_out,sgn9_ones_out,d1_out,d2_out,mux5_out,mux8_out,mux3_out,mux14_out,PR4_res_out,PR5_res_out:std_logic_vector(15 downto 0):=zeros;
signal mux27_out,mux22_out,mux23_out,mux24_out,adder2_out,PR3_imm_out,mux6_out,mux7_out,mux9_out,Dmem_data_out:std_logic_vector(15 downto 0):=zeros;
signal PR3_d1_out,PR3_d2_out,PR4_PC_out:std_logic_vector(15 downto 0):=zeros;
signal r7_en,P,cin,PR1_en,PR2_IR_en,PR2_PC_en,mux0_sel,mux1_sel1,mux1_sel0,flag:std_logic:='0';
signal mux17_sel,mux18_sel,mux2_sel,mux4_sel,mux5_sel1,mux16_sel,mux20_sel,PR4_cout,PR4_zout,PR5_cout:std_logic:='0';
signal mux9_sel,PR5_en,c_en,z_en,PR4_opc_en,Dmem_rdbar,Dmem_wrbar,PR5_lmbit:std_logic:='0';
signal mux5_sel0,mux3_sel,mux14_sel,mux27_sel,mux22_sel,mux23_sel,mux24_sel,mux25_sel1,mux25_sel0,mux13_sel,PR4_truth_out:std_logic:='0';
signal PR5_truth_out,PR3_en,lmbit,PR3_lmbit,PR4_lmbit,mux6_sel,mux7_sel1,mux7_sel0,mux8_sel1,mux8_sel0,PR4_cin,PR4_zin:std_logic:='0';
signal mux13_out,PR5_zout,CF,ZF,PR4_en,mux10_sel,PC_en,mux34_sel:std_logic:='0';
signal mux2_out,mux4_out,PE_out,mux17_out,mux18_out,PR3_wb_addr_out,PR4_wb_addr_out,PR5_wb_addr_out,PR3_d1_addr_out,PR3_d2_addr_out:std_logic_vector(2 downto 0):="000";
signal PR3_opc_out,PR4_opc_out,PR5_opc_out,mux34_out,mux33_out: std_logic_vector(3 downto 0):="0000";
signal ZE_out:std_logic_vector(8 downto 0):="000000000";
signal PR3_2bits,PR4_2bits,PR5_2bits :std_logic_vector(1 downto 0):="00";
signal mux30_out,mux31_out,mux32_out,Imem_or_out,PR1_or_out,PR5_PC_out,PR3_temp_out:std_logic_vector(15 downto 0):=zeros;
signal mux30_sel,mux31_sel,mux32_sel,mux33_sel,eta,mux12_sel,mux12_out,mux50_out:std_logic:='0';

constant add:std_logic_vector(3 downto 0):="0000";
constant adc:std_logic_vector(3 downto 0):="0000";
constant adz:std_logic_vector(3 downto 0):="0000";
constant adi:std_logic_vector(3 downto 0):="0001";
constant ndu:std_logic_vector(3 downto 0):="0010";
constant ndz:std_logic_vector(3 downto 0):="0010";
constant ndc:std_logic_vector(3 downto 0):="0010";
constant lhi:std_logic_vector(3 downto 0):="0011";
constant lw:std_logic_vector(3 downto 0):="0100";
constant sw:std_logic_vector(3 downto 0):="0101";
constant lm:std_logic_vector(3 downto 0):="0110";
constant sm:std_logic_vector(3 downto 0):="0111";
constant beq:std_logic_vector(3 downto 0):="1100";
constant jal:std_logic_vector(3 downto 0):="1000";
constant jlr:std_logic_vector(3 downto 0):="1001";

begin
	mux25_sel1<='0';
	mux25_sel0<='0';
	mux33_sel<='0';
  main_control:process(PR2_IR_out,mult_out,PR3_opc_out,PR3_2bits,PR4_opc_out,PR4_wb_addr_out,PR3_d1_addr_out,PR3_d2_addr_out) is
    begin

      if(((PR3_opc_out=add or PR3_opc_out=ndu) and PR3_2bits="00") or ((PR3_opc_out=adc or PR3_opc_out = ndc) and PR3_2bits="10")
          or ((PR3_opc_out=adz or PR3_opc_out=ndz) and PR3_2bits="01") or (PR3_opc_out=sw) or (PR3_opc_out=beq) or (PR3_opc_out=sm)) then

          if(((PR4_opc_out = lw) or (PR4_opc_out = lm)) and ((PR4_wb_addr_out = PR3_d1_addr_out) or (PR4_wb_addr_out = PR3_d2_addr_out))) then
            PC_en<='0';
            PR1_en<='0';
            PR2_PC_en<='0';
            PR2_IR_en<='0';
            PR3_en<='0';
            PR4_en<='0';
            mux34_sel<='1';

          elsif((PR2_IR_out(15 downto 12)=lm or PR2_IR_out(15 downto 12)=sm) and (PR2_IR_out(7 downto 0)/="00000000") and (mult_out(7 downto 0)/="00000000")) then
          	PC_en<='0';
            PR1_en<='0';
		        PR2_PC_en<='0';
		        PR2_IR_en<='1';
            PR3_en<='1';
            PR4_en<='1';
            mux34_sel<='0';
          
          else
            PC_en<='1';
		        PR1_en<='1';
		        PR2_PC_en<='1';
		        PR2_IR_en<='1';
		        PR3_en<='1';
		        PR4_en<='1';
		        mux34_sel<='0';
          end if;

      elsif(PR3_opc_out = adi or PR3_opc_out = lw or PR3_opc_out = jlr or PR3_opc_out = lm) then

          if((PR4_opc_out = lw or PR4_opc_out = lm) and (PR4_wb_addr_out = PR3_d1_addr_out)) then
             PC_en<='0';
             PR1_en<='0';
             PR2_PC_en<='0';
             PR2_IR_en<='0';
             PR3_en<='0';
             PR4_en<='0';
             mux34_sel<='1';

          elsif ((PR2_IR_out(15 downto 12)=lm or PR2_IR_out(15 downto 12)=sm) and (PR2_IR_out(7 downto 0)/="00000000") and (mult_out(7 downto 0)/="00000000")) then
          	PC_en<='0';
            PR1_en<='0';
		        PR2_PC_en<='0';
		        PR2_IR_en<='1';
            PR3_en<='1';
            PR4_en<='1';
            mux34_sel<='0';

          else
          	PC_en<='1';
		        PR1_en<='1';
		        PR2_PC_en<='1';
		        PR2_IR_en<='1';
		        PR3_en<='1';
		        PR4_en<='1';
		        mux34_sel<='0';
          end if;

      else
      	if((PR2_IR_out(15 downto 12)=lm or PR2_IR_out(15 downto 12)=sm) and (PR2_IR_out(7 downto 0)/="00000000") and (mult_out(7 downto 0)/="00000000")) then
          PC_en<='0';
          PR1_en<='0';
		      PR2_PC_en<='0';
		      PR2_IR_en<='1';
          PR3_en<='1';
          PR4_en<='1';
          mux34_sel<='0';
        else
	        PC_en<='1';
	        PR1_en<='1';
	        PR2_PC_en<='1';
	        PR2_IR_en<='1';
	        PR3_en<='1';
	        PR4_en<='1';
	        mux34_sel<='0';
	      end if;
      end if;
  end process; 


  --flushing: process(PR3_opc_out,PR3_wb_addr_out,mux13_sel,PR3_2bits,PR4_opc_out,PR4_wb_addr_out,PR2_IR_out,mux4_out) is
  --	begin
  --		if ((PR4_opc_out=lw or PR4_opc_out=lm) and PR4_wb_addr_out="111") then
  --			mux25_sel1<='1';
  --			mux25_sel0<='0';
  --			mux31_sel<='1';
  --			mux32_sel<='1';
  --			mux33_sel<='1';
  --			mux34_sel<='1';

  --		elsif ((((PR3_opc_out=add or PR3_opc_out=ndu) and PR3_2bits="00") or (PR3_opc_out=adi) or (PR3_opc_out=lhi)) and PR3_wb_addr_out="111") then
  --			mux25_sel1<='0';
  --			mux25_sel0<='1';
  --			mux31_sel<='1';
  --			mux32_sel<='1';
  --			mux33_sel<='1';
  --			mux34_sel<='0';

  --		elsif ((((PR3_opc_out=adc or PR3_opc_out=ndc) and PR3_2bits="10") or ((PR3_opc_out=adz or PR3_opc_out=ndz) and PR3_2bits="01"))
  --						and PR3_wb_addr_out="111" and mux13_sel='1') then
  --			mux25_sel1<='0';
  --			mux25_sel0<='1';
  --			mux31_sel<='1';
  --			mux32_sel<='1';
  --			mux33_sel<='1';
  --			mux34_sel<='0';

  --		else
  --			mux25_sel1<='0';
  --			mux25_sel0<='0';
  --			mux31_sel<='0';
  --			mux32_sel<='0';
  --			mux33_sel<='0';
  --			mux34_sel<='0';

  --		end if;

  --		if(PR2_IR_out(15 downto 12)=jlr or PR2_IR_out(15 downto 12)=jal or (PR2_IR_out(15 downto 12)=beq and xor_out=zeros)) then
  --    	mux30_sel<='1';
  --    	mux31_sel<='1';
  --    	mux32_sel<='1';
  --    else
  --    	mux30_sel<='0';
  --    	mux31_sel<='0';
  --    	mux32_sel<='0';
  --    end if;

  --end process;
  
	-- Stage 1
  PC: dregister port map(din=>mux25_out, dout=>PC_out, wr_en=>PC_en, clk=>clk,reset=>reset);
  adder1 : sixteenbitadder port map(x=>PC_out,y=>"0000000000000001",z=>adder1_out);
  Imemory: asynch_mem port map(din=>zeros, dout=>Imem_data_out, rdbar=>'0', wrbar=>'1', addrin=>PC_out, reset=>reset, clk=>clk);

  -- Stage 2
  OR_block1: or16 port map(x=>Imem_data_out, y=>"1111000000000000", s=>Imem_or_out);
  mux31:  MUX21 port map(d1=>Imem_data_out, d2=>Imem_or_out, s=>mux31_sel, dout=>mux31_out);
  PR1_IR : dregister port map(din=>mux31_out, dout=>PR1_IR_out, wr_en=>PR1_en, clk=>clk,reset=>reset);
  PR1_PC : dregister port map(din=>adder1_out, dout=>PR1_PC_out, wr_en=>PR1_en, clk=>clk,reset=>reset);

  -- Stage 3
  OR_block2: or16 port map(x=>PR1_IR_out, y=>"1111000000000000", s=>PR1_or_out);
  mux32:  MUX21 port map(d1=>PR1_IR_out, d2=>PR1_or_out, s=>mux32_sel, dout=>mux32_out);
  mux0: MUX21 port map(d1=>mux32_out, d2=>mult_out, s=>mux0_sel, dout=>mux0_out);
  
  PR2_IR: dregister port map(din=>mux0_out, dout=>PR2_IR_out, wr_en=>PR2_IR_en, clk=>clk,reset=>reset);
  PR2_PC: dregister port map(din=>PR1_PC_out, dout=>PR2_PC_out, wr_en=>PR2_PC_en, clk=>clk,reset=>reset);

  process(PR2_IR_out,mult_out) is
    begin
      if ((PR2_IR_out(15 downto 12) = lm or PR2_IR_out(15 downto 12) = sm) and mult_out(7 downto 0)/="00000000") then
        mux0_sel <= '1';
      else
        mux0_sel <= '0';
      end if;
  end process;

  sgn6: sgn generic map(nbits=>6) port map(din=>PR2_IR_out(5 downto 0), dout=>mux1_10_in);
  sgn9: sgn generic map(nbits=>9) port map(din=>PR2_IR_out(8 downto 0), dout=>mux1_00_in);
  LS: leftshift port map(din=>PR2_IR_out(8 downto 0), dout=>mux1_01_in);          -- leftshift input is 9 bits
  mux1: MUX4X1 port map(d1=>mux1_00_in, d2=>mux1_01_in, d3=>mux1_10_in, d4=>zeros, s1=>mux1_sel1, s0=>mux1_sel0, dout=>mux1_out);
  
  process(PR2_IR_out) is
    begin
      if(PR2_IR_out(15 downto 12)=adi or PR2_IR_out(15 downto 12)=lw or PR2_IR_out(15 downto 12)=sw or PR2_IR_out(15 downto 12)=beq) then
        mux1_sel1<='1';
      else
        mux1_sel1<='0';
      end if;
      if(PR2_IR_out(15 downto 12)=lhi) then
        mux1_sel0<='1';
      else
        mux1_sel0<='0';
      end if;
  end process;
  
  PE : priority_encoder port map(din=>PR2_IR_out(7 downto 0), dout=>PE_out);
  ZE : zero_decoder port map(din=>PE_out, dout=>ZE_out);
  sgn9_ones: sgn generic map(flag=>1) port map(din=>ZE_out, dout=>sgn9_ones_out);
  scraper: and16 port map(x=>PR2_IR_out, y=>sgn9_ones_out, z=>mult_out);

  mux17: MUX21 generic map(nbits=>3) port map(d1=>PR2_IR_out(8 downto 6), d2=>PR2_IR_out(11 downto 9), s=>mux17_sel, dout=>mux17_out);
  mux18: MUX21 generic map(nbits=>3) port map(d1=>PR2_IR_out(5 downto 3), d2=>PR2_IR_out(11 downto 9), s=>mux18_sel, dout=>mux18_out);
  mux2: MUX21 generic map(nbits=>3) port map(d1=>mux18_out, d2=>PE_out, s=>mux2_sel, dout=>mux2_out);

  mux30: MUX21 port map(d1=>PR2_PC_out, d2=>mux5_out, s=>mux30_sel, dout=>mux30_out);

  process(PR2_IR_out,xor_out) is
    begin
      if(PR2_IR_out(15 downto 12)=sw or PR2_IR_out(15 downto 12)=lm or PR2_IR_out(15 downto 12)=beq or PR2_IR_out(15 downto 12)=lhi) then
        mux18_sel<='1';
      else
        mux18_sel<='0';
      end if;
      if(PR2_IR_out(15 downto 12)=sm) then
        mux2_sel<='1';
        mux17_sel<='1';
      else
        mux2_sel<='0';
        mux17_sel<='0';
      end if;
      if(PR2_IR_out(15 downto 12)=lm) then
        mux4_sel<='1';
        mux17_sel<='1';
      else
        mux4_sel<='0';
        mux17_sel<='0';
      end if;
      if(PR2_IR_out(15 downto 12)=jlr) then
        mux5_sel1<='1';
      else
        mux5_sel1<='0';
      end if;
      if(PR2_IR_out(15 downto 12)=jal) then
        mux5_sel0<='1';
      elsif((PR2_IR_out(15 downto 12)=beq) and( xor_out = zeros)) then
        mux5_sel0<='1';
      else
        mux5_sel0<='0';
      end if;

      if(PR2_IR_out(15 downto 12)=jlr or PR2_IR_out(15 downto 12)=jal or (PR2_IR_out(15 downto 12)=beq and xor_out=zeros)) then
      	mux30_sel<='1';
      	mux31_sel<='1';
      	mux32_sel<='1';
      else
      	mux30_sel<='0';
      	mux31_sel<='0';
      	mux32_sel<='0';
      end if;
  end process;

  regfile: register_file port map(a1=>mux17_out,a2=>mux2_out,a3=>PR5_wb_addr_out,a4=>"111",wr_en=>P,wr_en7=>r7_en,d1=>d1_out,d2=>d2_out,d3=>PR5_res_out,d4=>PR5_PC_out,clk=>clk,reset=>reset);
  mux4: MUX21 generic map(nbits=>3) port map(d1=>PR2_IR_out(11 downto 9), d2=>PE_out, s=>mux4_sel, dout=>mux4_out);   -- WB address selector

  -- forward logic at stage 3
  mux3: MUX21 port map(d1=>d1_out, d2=>mux8_out, s=>mux3_sel, dout=>mux3_out);
  mux14: MUX21 port map(d1=>d2_out, d2=>mux8_out, s=>mux14_sel, dout=>mux14_out);
  mux27: MUX21 port map(d1=>mux3_out, d2=>PR4_res_out, s=>mux27_sel, dout=>mux27_out);
  mux22: MUX21 port map(d1=>mux14_out, d2=>PR4_res_out, s=>mux22_sel, dout=>mux22_out);
  mux23: MUX21 port map(d1=>mux27_out, d2=>PR5_res_out, s=>mux23_sel, dout=>mux23_out);
  mux24: MUX21 port map(d1=>mux22_out, d2=>PR5_res_out, s=>mux24_sel, dout=>mux24_out);

  
  forward_from_mux8_out: process(PR3_opc_out,PR3_wb_addr_out,mux17_out,mux2_out,mux13_sel,PR3_2bits,PR2_IR_out,PR2_PC_out,PR3_PC_out) is
    
  	begin

      if(PR3_wb_addr_out=mux17_out or PR3_wb_addr_out=mux2_out) then

        if((PR3_opc_out=add and PR3_2bits="00") or PR3_opc_out=adi or (PR3_opc_out=ndu and PR3_2bits="00") or PR3_opc_out=lhi or PR3_opc_out=jal or PR3_opc_out=jlr) then

          --if((opc2=add and PR2_IR_out(1 downto 0)="00") or (opc2=adc and PR2_IR_out(1 downto 0)="10") or (opc2=adz and PR2_IR_out(1 downto 0)="01") or (opc2=ndu and PR2_IR_out(1 downto 0)="00") or (opc2=ndc and PR2_IR_out(1 downto 0)="10") or (opc2=ndz and PR2_IR_out(1 downto 0)="01") or opc2=beq or opc2=sw or opc2=adi or opc2=lw or opc2=jlr or opc2=jal or opc2=lhi or opc2=lm or opc2=sm) then     -- those instructions which read at least one regsiter                   

            if(PR3_wb_addr_out=mux17_out) then
              mux3_sel<='1';
              --d1_flag=1;
            else
              mux3_sel<='0';
            end if;

            if(PR3_wb_addr_out=mux2_out) then
              mux14_sel<='1';
              --d2_flag=1;
            else
              mux14_sel<='0';
            end if;

          --end if;

        elsif(((PR3_opc_out=adc or PR3_opc_out=ndc) and PR3_2bits="10") or ((PR3_opc_out=adz or PR3_opc_out=ndz) and PR3_2bits="01")) then

          -- for all instructions
          if(PR3_wb_addr_out=mux17_out and mux13_sel='1') then
            mux3_sel<='1';
            --d1_flag=1;
          else
            mux3_sel<='0';
          end if;
          if(PR3_wb_addr_out=mux2_out and mux13_sel='1') then
            mux14_sel<='1';
            --d2_flag=1;
          else
            mux14_sel<='0';
          end if;

        else
          mux3_sel<='0';
          mux14_sel<='0';

        end if;

      else
        mux3_sel<='0';
        mux14_sel<='0';
      end if;

      if (((PR3_opc_out=lm and PR2_IR_out(15 downto 12)=lm) or (PR3_opc_out=sm and PR2_IR_out(15 downto 12)=sm)) and PR2_PC_out=PR3_PC_out) then
  			mux3_sel<='1';
  		end if;
  end process;


  forward_from_PR4_out: process(PR3_opc_out,PR2_IR_out,PR2_PC_out,PR3_PC_out,PR4_opc_out,PR4_wb_addr_out,mux17_out,mux2_out,PR4_truth_out,PR4_2bits,mux3_sel,mux14_sel) is
      
      begin
      
      if(PR4_wb_addr_out=mux17_out or PR4_wb_addr_out=mux2_out) then

        if(((PR4_opc_out=add or PR4_opc_out=ndu) and PR4_2bits="00") or PR4_opc_out=adi or PR4_opc_out=lhi or PR4_opc_out=jal or PR4_opc_out=jlr) then

          if(PR4_wb_addr_out=mux17_out and mux3_sel='0') then
            mux27_sel<='1';
          else
            mux27_sel<='0';
          end if;

          if(PR4_wb_addr_out=mux2_out and mux14_sel='0') then
            mux22_sel<='1';
          else
            mux22_sel<='0';
          end if;

        elsif(((PR4_opc_out=adc or PR4_opc_out=ndc) and PR4_2bits="10") or ((PR4_opc_out=adz or PR4_opc_out=ndz) and PR4_2bits="01")) then

          if(PR4_wb_addr_out=mux17_out and mux3_sel='0' and PR4_truth_out='1') then
            mux27_sel<='1';
          else
            mux27_sel<='0';
          end if;

          if(PR4_wb_addr_out=mux2_out and mux14_sel='0' and PR4_truth_out='1') then
            mux22_sel<='1';
          else
            mux22_sel<='0';
          end if;

        else
          mux27_sel<='0';
          mux22_sel<='0';
        end if;

      else
        mux27_sel<='0';
        mux22_sel<='0';
      end if;

      if (((PR3_opc_out=lm and PR2_IR_out(15 downto 12)=lm) or (PR3_opc_out=sm and PR2_IR_out(15 downto 12)=sm)) and PR2_PC_out=PR3_PC_out) then
  			mux27_sel<='0';
  		end if;
  end process;

	forward_from_PR5_out: process(PR3_opc_out,PR2_IR_out,PR5_opc_out,PR2_PC_out,PR3_PC_out,PR5_wb_addr_out,mux17_out,mux2_out,PR5_truth_out,PR5_2bits,mux3_sel,mux14_sel,mux22_sel,mux27_sel) is  
      
			begin

      if(PR5_wb_addr_out=mux17_out or PR5_wb_addr_out=mux2_out) then

        if(((PR5_opc_out=add or PR5_opc_out=ndu) and PR5_2bits="00") or PR5_opc_out=adi or PR5_opc_out=lhi or PR5_opc_out=jal or PR5_opc_out=jlr) then

          if(PR5_wb_addr_out=mux17_out and mux3_sel='0' and mux27_sel='0') then
            mux23_sel<='1';
          else
            mux23_sel<='0';
          end if;

          if(PR5_wb_addr_out=mux2_out and mux14_sel='0' and mux22_sel='0') then
            mux24_sel<='1';
          else
            mux24_sel<='0';
          end if;

        elsif(((PR5_opc_out=adc or PR5_opc_out=ndc) and PR5_2bits="10") or ((PR5_opc_out=adz or PR5_opc_out=ndz) and PR5_2bits="01")) then

          if(PR5_wb_addr_out=mux17_out and mux3_sel='0' and mux27_sel='0' and PR5_truth_out='1') then
            mux23_sel<='1';
          else
            mux23_sel<='0';
          end if;

          if(PR5_wb_addr_out=mux2_out and mux14_sel='0' and mux22_sel='0' and PR5_truth_out='1') then
            mux24_sel<='1';
          else
            mux24_sel<='0';
          end if;

        else
          mux23_sel<='0';
          mux24_sel<='0';
        end if;

      else
        mux23_sel<='0';
        mux24_sel<='0';
      end if;

      if (((PR3_opc_out=lm and PR2_IR_out(15 downto 12)=lm) or (PR3_opc_out=sm and PR2_IR_out(15 downto 12)=sm)) and PR2_PC_out=PR3_PC_out) then
  			mux23_sel<='0';
  		end if;
  end process;

  beqchecker: xor16 port map(x=>mux23_out, y=>mux24_out, s=>xor_out);
  adder2: sixteenbitadder port map(x=>PR2_PC_out, y=>mux1_out,z=>adder2_out);
  mux5:  MUX4X1 port map(d1=>adder1_out, d2=>adder2_out, d3=>mux23_out, d4=>mux23_out, s1=>mux5_sel1, s0=>mux5_sel0, dout=>mux5_out);
  mux25: MUX4X1 port map(d1=>mux5_out, d2=>mux8_out, d3=>Dmem_data_out, d4=>PR3_temp_out, s1=>mux25_sel1, s0=>mux25_sel0, dout=>mux25_out);  -- if R7 changes then PC has to be updated
  lmbit <= (PR2_IR_out(7) or PR2_IR_out(6) or PR2_IR_out(5) or PR2_IR_out(4) or PR2_IR_out(3) or PR2_IR_out(2) or PR2_IR_out(1) or PR2_IR_out(0));
 
  -- PR3 registers
  PR3_temp_reg: dregister port map(din=>PR2_PC_out,dout=>PR3_temp_out,wr_en=>PR3_en,clk=>clk,reset=>reset);

  PR3_d1_addr: dregister generic map(nbits=>3) port map(din=>mux17_out, dout=>PR3_d1_addr_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  PR3_d2_addr: dregister generic map(nbits=>3) port map(din=>mux2_out, dout=>PR3_d2_addr_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  PR3_wb_addr: dregister generic map(nbits=>3) port map(din=>mux4_out, dout=>PR3_wb_addr_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  
  PR3_PC: dregister port map(din=>mux30_out, dout=>PR3_PC_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  PR3_d1_value : dregister port map(din=>mux23_out, dout=>PR3_d1_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  PR3_d2_value : dregister port map(din=>mux24_out, dout=>PR3_d2_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  PR3_Imm: dregister port map(din=>mux1_out, dout=>PR3_imm_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  PR3_opc: dregister generic map(nbits=>4) port map(din=>mux33_out, dout=>PR3_opc_out, wr_en=>PR3_en, clk=>clk,reset=>reset);
  PR3_lm: onedregister port map(din=>lmbit, dout=>PR3_lmbit, wr_en=>PR3_en, clk=>clk,reset=>reset);

  PR3_last2bits: dregister generic map(nbits=>2) port map(din=>PR2_IR_out(1 downto 0),dout=>PR3_2bits, wr_en=>PR3_en, clk=>clk,reset=>reset);

  -- Stage 4
  forward_stage4:process(PR3_opc_out,PR4_opc_out,PR3_PC_out,PR4_PC_out) is
  begin 
    --if(PR3_opc_out = adi or PR3_opc_out = lw or PR3_opc_out = sw) then
    --  mux6_sel<= '0';
    --else 
    --  mux6_sel<= '1';
    --end if;
    mux6_sel<='0';
    if(PR3_opc_out=lm or PR3_opc_out = sm) then
      if(PR3_PC_out/= PR4_PC_out) then
        mux7_sel1<= '1';
        mux7_sel0<= '1'; 
      elsif(PR4_opc_out = lm or PR4_opc_out = sm) then
        mux7_sel1<='0';
        mux7_sel0<='1';
      end if; 
    elsif(PR3_opc_out = adi or PR3_opc_out = lw or PR3_opc_out = sw) then
      mux7_sel1<= '1';
      mux7_sel0<= '0';
    else
      mux7_sel0<='0';
      mux7_sel1<='0';
    end if;

    if(PR3_opc_out=lhi) then
      mux8_sel1<='1';
    else
      mux8_sel1<='0';
    end if;

    if(PR3_opc_out=jal or PR3_opc_out=jlr) then
      mux8_sel0<='1';
    else
      mux8_sel0<='0';
    end if; 
  end process;

  mux16:MUX21 port map(d1=>PR3_d1_out, d2=>PR5_res_out, s=>mux16_sel, dout=>mux16_out);
  mux20:MUX21 port map(d1=>PR3_d2_out, d2=>PR5_res_out, s=>mux20_sel, dout=>mux20_out);
  mux6: MUX21 port map(d1=>mux16_out, d2=>PR3_d2_out, s=>'0', dout=>mux6_out);    ------i changed here if it doesn't work change it back
  mux7: MUX4X1 port map(d1=>mux20_out, d2=>"0000000000000001", d3=>PR3_imm_out, d4=>zeros, s1=>mux7_sel1, s0=>mux7_sel0, dout=>mux7_out);

  mux33: MUX21 generic map(nbits=>4) port map(d1=>PR2_IR_out(15 downto 12), d2=>"1111", s=>mux33_sel, dout=>mux33_out);
  mux34: MUX21 generic map(nbits=>4) port map(d1=>PR3_opc_out, d2=>"1111", s=>mux34_sel, dout=>mux34_out);

  ---------------PR5 to Alu_input forwarding and stalling logic for lw and for lm------------
process(PR3_d1_addr_out,PR3_d2_addr_out,PR4_wb_addr_out,PR5_wb_addr_out,PR3_opc_out,PR4_opc_out,PR5_opc_out,PR3_2bits) is
begin

if(((PR3_opc_out=add or PR3_opc_out=ndu) and PR3_2bits="00") or ((PR3_opc_out=adc or PR3_opc_out = ndc) and PR3_2bits="10")
     or ((PR3_opc_out=adz or PR3_opc_out=ndz) and PR3_2bits="01") or PR3_opc_out=sw or PR3_opc_out=beq or PR3_opc_out=sm) then

  if ((PR4_opc_out="1111") and (PR5_opc_out=lw or PR5_opc_out=lm) and (PR5_wb_addr_out = PR3_d1_addr_out or PR5_wb_addr_out = PR3_d2_addr_out)) then
    
    if(PR5_wb_addr_out = PR3_d1_addr_out) then
      mux16_sel <='1';
    else
      mux16_sel <='0';
    end if;
    if(PR5_wb_addr_out = PR3_d2_addr_out) then 
      mux20_sel <='1';
    else
      mux20_sel<='0';
    end if;
  
  elsif ((PR5_opc_out = lw or PR5_opc_out = lm) and (PR5_wb_addr_out = PR3_d1_addr_out or PR5_wb_addr_out = PR3_d2_addr_out)) then

    if(PR5_wb_addr_out = PR3_d1_addr_out) then
      mux16_sel <='1';
    else
      mux16_sel <='0';
    end if;
    if(PR5_wb_addr_out = PR3_d2_addr_out) then 
      mux20_sel <='1';
    else
      mux20_sel<='0';
    end if;
  
  else
    mux16_sel <='0';
    mux20_sel <='0';
  end if;
elsif(PR3_opc_out = adi or PR3_opc_out = lw or PR3_opc_out = jlr or PR3_opc_out = lm) then

  if ((PR4_opc_out="1111") and (PR5_opc_out=lw or PR5_opc_out=lm) and PR5_wb_addr_out = PR3_d1_addr_out) then
    
    mux20_sel <='0';
    mux16_sel <='1';

  elsif ((PR5_opc_out = lw or PR5_opc_out = lm) and (PR5_wb_addr_out = PR3_d1_addr_out)) then
    mux16_sel<='1';
    mux20_sel<='0';
  
  else 
    mux16_sel<='0';
    mux20_sel<='0';
  end if;
else 
  mux16_sel <='0';
  mux20_sel <='0';  
end if;  
end process;
---------------------------------------------------end----------------------------
  

  alu_inside:alu port map(X=>mux6_out, Y=>mux7_out, Z=>alu_out, OPC=>PR3_opc_out, CF=>PR4_cin, ZF=>PR4_zin);
  mux8: MUX4X1 port map(d1=>alu_out, d2=>PR3_temp_out, d3=>PR3_imm_out, d4=>zeros, s1=>mux8_sel1, s0=>mux8_sel0, dout=>mux8_out); 
  mux13: singlebitMUX port map(d1=>'0', d2=>'1', s=>mux13_sel, dout=>mux13_out);

  
  truth_register:process(PR3_opc_out,PR4_opc_out,PR5_opc_out,PR4_truth_out,PR5_truth_out,PR4_cout,PR4_zout,PR5_cout,PR5_zout,CF,ZF,
                        PR3_2bits,PR4_2bits,PR5_2bits,eta) is
    begin
      if(((PR3_opc_out=add or PR3_opc_out=ndu) and PR3_2bits="00") or PR3_opc_out=adi) then
        mux13_sel<='1';
      
      elsif((PR3_opc_out=adc or PR3_opc_out=ndc) and PR3_2bits="10") then
        
        if (((PR4_opc_out=add and PR4_2bits="00") or (PR4_opc_out=adc and PR4_2bits="10") or PR4_opc_out=adi or (PR4_opc_out=adz and PR4_2bits="01")) and PR4_truth_out='1') then
          if(PR4_cout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        
        elsif (((PR5_opc_out=add and PR5_2bits="00") or (PR5_opc_out=adc and PR5_2bits="10") or PR5_opc_out=adi or (PR5_opc_out=adz and PR5_2bits="01")) and PR5_truth_out='1') then
          if(PR5_cout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        
        else
          if(CF='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        end if;
      
      elsif ((PR3_opc_out=adz or PR3_opc_out=ndz) and PR3_2bits="01") then     -- assuming that load does not changes carry

        if ((((PR4_opc_out=add or PR4_opc_out=ndu) and PR4_2bits="00") or ((PR4_opc_out=adc or PR4_opc_out=ndc) and PR4_2bits="10") or ((PR4_opc_out=adz or PR4_opc_out=ndz) and PR4_2bits="01") or PR4_opc_out=adi) and PR4_truth_out='1') then
          if(PR4_zout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        
        elsif(PR4_opc_out=lw) then
        	if(eta='1') then
        		mux13_sel<='1';
        	else
        		mux13_sel<='0';
        	end if;

        elsif((((PR5_opc_out=add or PR5_opc_out=ndu) and PR5_2bits="00") or ((PR5_opc_out=adc or PR5_opc_out=ndc) and PR5_2bits="10") or ((PR5_opc_out=adz or PR5_opc_out=ndz) and PR5_2bits="01") or PR5_opc_out=adi) and PR5_truth_out='1')  then
          if(PR5_zout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        
        elsif (PR5_opc_out=lw) then
        	if(PR5_zout='1') then
        		mux13_sel<='1';
        	else
        		mux13_sel<='0';
        	end if;

        else
          if(ZF='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        end if;
      
      else
        mux13_sel<='0';

      end if;
  end process;

  -- PR4 registers 
  PR4_opc_en<=(PR4_en or mux34_sel);
  PR4_PC: dregister port map(din=>PR3_PC_out, dout=>PR4_PC_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  --PR4_d1 : dregister port map(din=>PR3_d1_out, dout=>PR4_d1_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  --PR4_d2 : dregister port map(din=>PR3_d2_out, dout=>PR4_d2_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_d1 : dregister port map(din=>mux16_out, dout=>PR4_d1_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_d2 : dregister port map(din=>mux20_out, dout=>PR4_d2_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_result: dregister port map(din=>mux8_out, dout=>PR4_res_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_opc: dregister generic map(nbits=>4) port map(din=>mux34_out, dout=>PR4_opc_out, wr_en=>PR4_opc_en, clk=>clk,reset=>reset);
  PR4_wb_addr: dregister generic map(nbits=>3) port map(din=>PR3_wb_addr_out, dout=>PR4_wb_addr_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_ct : onedregister port map(din=>PR4_cin, dout=>PR4_cout, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_zt : onedregister port map(din=>PR4_zin, dout=>PR4_zout, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_truth: onedregister port map(din=>mux13_out, dout=>PR4_truth_out, wr_en=>PR4_en, clk=>clk,reset=>reset);
  PR4_lm: onedregister port map(din=>PR3_lmbit, dout=>PR4_lmbit, wr_en=>PR4_en, clk=>clk,reset=>reset);

  PR4_last2bits: dregister generic map(nbits=>2) port map(din=>PR3_2bits, dout=>PR4_2bits, wr_en=>PR4_en, clk=>clk,reset=>reset);

  -- Stage 5
  mux9: MUX21 port map(d1=>PR4_d1_out, d2=>PR4_d2_out, s=>mux9_sel, dout=>mux9_out);

  Dmemory: asynch_mem port map(din=>mux9_out,dout=>Dmem_data_out,rdbar=>'0',wrbar=>Dmem_wrbar,addrin=>PR4_res_out,reset=>reset,clk=>clk);
  mux10: MUX21 port map(d1=>PR4_res_out, d2=>Dmem_data_out, s=>mux10_sel, dout=>mux10_out);

  process(PR4_opc_out,PR4_lmbit) is
    begin
      if(PR4_opc_out=sw or PR4_opc_out=sm) then
        mux9_sel<='1';
      else
        mux9_sel<='0';
      end if;
      if(PR4_opc_out=lw or PR4_opc_out=lm) then
        mux10_sel<='1';
        --Dmem_rdbar<='0';
      else
        mux10_sel<='0';
        --Dmem_rdbar<='1';
      end if;

      if((PR4_opc_out=sw) or ((PR4_opc_out=sm) and (PR4_lmbit='1'))) then
        Dmem_wrbar<='0';
      else
        Dmem_wrbar<='1';
      end if;
  end process;

  -- PR5 registers
  PR5_en<='1';
  PR5_PC: dregister port map(din=>PR4_PC_out, dout=>PR5_PC_out, wr_en=>PR5_en,clk=>clk,reset=>reset);
  PR5_result: dregister port map(din=>mux10_out, dout=>PR5_res_out, wr_en=>PR5_en, clk=>clk,reset=>reset);
  PR5_wb_addr: dregister generic map(nbits=>3) port map(din=>PR4_wb_addr_out, dout=>PR5_wb_addr_out, wr_en=>PR5_en, clk=>clk,reset=>reset);
  PR5_opc: dregister generic map(nbits=>4) port map(din=>PR4_opc_out, dout=>PR5_opc_out, wr_en=>PR5_en, clk=>clk,reset=>reset);

  PR5_ct : onedregister port map(din=>PR4_cout, dout=>PR5_cout, wr_en=>PR5_en, clk=>clk,reset=>reset);
  PR5_zt: onedregister port map(din=>mux12_out, dout=>PR5_zout, wr_en=>PR5_en, clk=>clk,reset=>reset);
  PR5_truth: onedregister port map(din=>mux50_out, dout=>PR5_truth_out, wr_en=>PR5_en, clk=>clk,reset=>reset);
  PR5_lm: onedregister port map(din=>PR4_lmbit, dout=>PR5_lmbit, wr_en=>PR5_en, clk=>clk,reset=>reset);

  PR5_last2bits: dregister generic map(nbits=>2) port map(din=>PR4_2bits, dout=>PR5_2bits, wr_en=>PR5_en, clk=>clk,reset=>reset);

  mux12: singlebitMUX port map(d1=>PR4_zout, d2=>eta, s=>mux12_sel, dout=>mux12_out);
  mux12_sel<= (not(PR4_opc_out(3)) and PR4_opc_out(2) and not(PR4_opc_out(1)) and not(PR4_opc_out(0)));

  mux50: singlebitMUX port map(d1=>PR4_truth_out, d2=>'1', s=>mux12_sel, dout=>mux50_out);

  eta<=not(Dmem_data_out(15) or Dmem_data_out(14) or Dmem_data_out(13) or Dmem_data_out(12) or Dmem_data_out(11) or Dmem_data_out(10) 
        or Dmem_data_out(9) or Dmem_data_out(8) or Dmem_data_out(7) or Dmem_data_out(6) or Dmem_data_out(5) or Dmem_data_out(4)
        or Dmem_data_out(3) or Dmem_data_out(2) or Dmem_data_out(1) or Dmem_data_out(0));

  carry_flag: onedregister port map(din=>PR5_cout, dout=>CF, wr_en=>c_en, clk=>clk,reset=>reset);
  zero_flag: onedregister port map(din=>PR5_zout, dout=>ZF, wr_en=>z_en, clk=>clk,reset=>reset);

  flag_enable:process(PR5_opc_out,PR5_truth_out,PR5_2bits) is
    begin
      if (((PR5_opc_out=add and PR5_2bits="00") or PR5_opc_out=adi or (PR5_opc_out=adc and PR5_2bits="10") or (PR5_opc_out=adz and PR5_2bits="01")) and PR5_truth_out='1') then
        c_en<='1';
      else
        c_en<='0';
      end if;

      if ((((PR5_opc_out=add or PR5_opc_out=ndu) and PR5_2bits="00") or PR5_opc_out=adi or ((PR5_opc_out=adc or PR5_opc_out=ndc) and PR5_2bits="10") or ((PR5_opc_out=adz or PR5_opc_out=ndz) and PR5_2bits="01")) and PR5_truth_out='1') then
        z_en<='1';

      elsif(PR5_opc_out=lw) then
      	z_en<='1';
      
      else
        z_en<='0';
      end if;
  end process;

  RF_wr_en:process(PR5_opc_out,PR5_2bits,PR5_truth_out,PR5_lmbit) is
  begin
    if (((PR5_opc_out=add or PR5_opc_out=ndu) and PR5_2bits="00") or PR5_opc_out=adi or PR5_opc_out=lhi or PR5_opc_out=lw or PR5_opc_out=jal or PR5_opc_out=jlr) then
      P <= '1';
    elsif ((((PR5_opc_out=adc or PR5_opc_out=ndc) and PR5_2bits="10") or ((PR5_opc_out=adz or PR5_opc_out=ndz) and PR5_2bits="01")) and PR5_truth_out='1') then
      P <= '1';
    elsif (PR5_opc_out=lm and PR5_lmbit='1') then
      P<='1';
    else
      P<='0';
    end if;
  end process;

  register7_enable:process(PR5_opc_out,PR4_PC_out,PR5_PC_out) is
  	begin
  		if(PR5_opc_out="1111" or ((PR5_opc_out=lm or PR5_opc_out=sm) and PR5_PC_out=PR4_PC_out)) then
  			r7_en<='0';
  		else
  			r7_en<='1';
  		end if;
  end process;

  --r7_en <= (((P) and (PR5_wb_addr_out(2)) and (PR5_wb_addr_out(1)) and (PR5_wb_addr_out(0))) or PC_en);
  --mux25_sel <= (PR5_wb_addr_out(2) and PR5_wb_addr_out(1) and PR5_wb_addr_out(0)) and P;
end behave;