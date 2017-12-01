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


begin
  add <= "0000";
  add2bits <= "00";
  adz <= "0000";
  adz2bits<= "01";
  adc <= "0000";
  adc2bits <= "10";
  adi <= "0001";
  ndu <= "0010";
  ndu2bits<="00";
  ndc <= "0010";
  ndc2bits <= "10";
  ndz <= "0010";
  ndz2bits <= "01";
  lhi <= "0011";
  lw <= "0100";
  sw <= "0101";
  lm <= "0110";
  sm <= "0111";
  jal <= "1000";
  jlr <= "1001";
  beq <= "1100";

  -- Stage 1
  PC: dregister port map(din=>mux25_out, dout=>PC_out, wr_en=>PC_en, clk=>clk);
  adder1 : sixteenbitadder port map(x=>PC_out, y=>"0000000000000001", cin=>'0', z=>adder1_out, cout=>adder1_carry);
  Imemory: asynch_mem port map(din=>zeros, dout=>Imem_data_out, rdbar=>'0', wrbar=>'1', addrin=>PC_out, reset=>reset);

  -- Stage 2
  PR1_IR : dregister port map(din=>Imem_data_out, dout=>PR1_IR_out, wr_en=>PR1_en, clk=>clk);
  PR1_PC : dregister port map(din=>adder1_out, dout=>PR1_PC_out, wr_en=>PR1_en, clk=>clk);

  -- Stage 3
  PR2_IR_en <= (PR2_en or PR2_lm_sm);
  PR2_IR: dregister port map(din=>mux0_out, dout=>PR2_IR_out, wr_en=>PR2_IR_en, clk=>clk);
  PR2_PC: dregister port map(din=>PR1_PC_out, dout=>PR2_PC_out, wr_en=>PR2_en, clk=>clk);
  mux0: MUX21 port map(d1=>PR1_IR_out, d2=>mult_out, s=>mux0_sel, dout=>mux0_out);
  
  process(PR2_IR_out,mult_out) is
    begin
      if (PR2_IR_out(15 downto 12) = lm or PR2_IR_out(15 downto 12) = sm)
        PR2_lm_sm <= '1';
        if (mult_out(7 downto 0)="00000000") then
          mux0_sel <= '0';
          PC_en <= '1';
          PR1_en <= '1';
          PR2_en <= '1';
        else
          mux0_sel <= '1';
          PC_en <= '0';
          PR1_en <= '0';
          PR2_en <= '0';
        end if;
      else
        PR2_lm_sm <= '0';
        mux0_sel <= '0';
      end if;
  end process;

  sgn6: sgn port map(din=>PR2_IR_out(5 downto 0), dout=>mux1_10_in);
  sgn9: sgn port map(din=>PR2_IR_out(8 downto 0), dout=>mux1_00_in);
  leftshift: leftshift port map(din=>PR2_IR_out(8 downto 0), dout=>mux1_01_in);
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
      elsif(PR2_IR_out(15 downto 12)=beq)
        mux5_sel0<=xor_out;
      else
        mux5_sel0<='0';
      end if;
  end process;

  regfile: register_file port map(a1=>mux17_out,a2=>mux2_out,a3=>PR5_wb_addr_out,a4=>"111",wr_en=>P,wr_en7=>r7_en,d1=>d1_out,d2=>d2_out,d3=>PR5_res_out,d4=>mux5_out,clk=>clk,reset=>reset);
  mux4: MUX21 generic map(nbits=>3) port map(d1=>PR2_IR_out(11 downto 9), d2=>PE_out, s=>mux4_sel, dout=>mux4_out);

  -- forward logic at stage 3
  mux3: MUX21 port map(d1=>d1_out, d2=>mux8_out, s=>mux3_sel, dout=>mux3_out);
  mux14: MUX21 port map(d1=>d2_out, d2=>mux8_out, s=>mux14_sel, dout=>mux14_out);
  mux21: MUX21 port map(d1=>mux3_out, d2=>PR4_res_out, s=>mux21_sel, dout=>mux21_out);
  mux22: MUX21 port map(d1=>mux14_out, d2=>PR4_res_out, s=>mux22_sel, dout=>mux22_out);
  mux23: MUX21 port map(d1=>mux21_out, d2=>PR5_res_out, s=>mux23_sel, dout=>mux23_out);
  mux24: MUX21 port map(d1=>mux22_out, d2=>PR5_res_out, s=>mux24_sel, dout=>mux24_out);

  
  forward_stage3: process(PR2_IR_out,PR3_opc_out,PR4_opc_out,PR5_opc_out,PR3_wb_addr_out,PR4_wb_addr_out,PR5_wb_addr_out,
                  mux17_out,mux2_out,mux13_sel,PR4_truth_out,PR5_truth_out) is
    begin
      opc2<=PR2_IR_out(15 downto 12);
      opc3<=PR3_opc_out;
      opc4<=PR4_opc_out;
      opc5<=PR5_opc_out;

      if(PR3_wb_addr_out=mux17_out or PR3_wb_addr_out=mux2_out) then

        if((opc3=add and PR3_2bits="00") or opc3=adi or (opc3=ndu and PR3_2bits="00") or opc3=lhi or opc3=jal or opc3=jlr) then

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

        elsif(((opc3=adc or opc3=ndc) and PR3_2bits="10") or ((opc3=adz or opc3=ndz) and PR3_2bits="01")) then

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

      if(PR4_wb_addr_out=mux17_out or PR4_wb_addr_out=mux2_out) then

        if((opc4=add or opc4=ndu) and PR4_2bits="00") or opc4=adi or opc4=lhi or opc4=jal or opc4=jlr) then

          if(PR4_wb_addr_out=mux17_out and mux3_sel='0') then
            mux21_sel<='1';
          else
            mux21_sel<='0';
          end if;

          if(PR4_wb_addr_out=mux2_out and mux14_sel='0') then
            mux22_sel<='1';
          else
            mux22_sel<='0';
          end if;

        elsif(((opc4=adc or opc4=ndc) and PR4_2bits="10") or ((opc4=adz or opc4=ndz) and PR4_2bits="01")) then

          if(PR4_wb_addr_out=mux17_out and mux3_sel='0' and PR4_truth_out='1') then
            mux21_sel<='1';
          else
            mux21_sel<='0';
          end if;

          if(PR4_wb_addr_out=mux2_out and mux14_sel='0' and PR4_truth_out='1') then
            mux22_sel<='1';
          else
            mux22_sel<='0';
          end if;

        else
          mux21_sel<='0';
          mux22_sel<='0';
        end if;

      else
        mux21_sel<='0';
        mux22_sel<='0';
      end if;

      if(PR5_wb_addr_out=mux17_out or PR5_wb_addr_out=mux2_out) then

        if((opc5=add or opc5=ndu) and PR5_2bits="00") or opc5=adi or opc5=lhi or opc5=jal or opc5=jlr) then

          if(PR5_wb_addr_out=mux17_out and mux3_sel='0' and mux21_sel='0') then
            mux23_sel<='1';
          else
            mux23_sel<='0';
          end if;

          if(PR5_wb_addr_out=mux2_out and mux14_sel='0' and mux22_sel='0') then
            mux24_sel<='1';
          else
            mux24_sel<='0';
          end if;

        elsif(((opc5=adc or opc5=ndc) and PR5_2bits="10") or ((opc5=adz or opc5=ndz) and PR5_2bits="01")) then

          if(PR5_wb_addr_out=mux17_out and mux3_sel='0' and mux21_sel='0' and PR5_truth_out='1') then
            mux23_sel<='1';
          else
            mux23_sel<='0';
          end if;

          if(PR4_wb_addr_out=mux2_out and mux14_sel='0' and mux22_sel='0' and PR5_truth_out='1') then
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

  end process;
        


  --  begin
  --    opc2<=PR2_IR_out(15 downto 12);
  --    opc3<=PR3_opc_out;

  --    if(opc2=add or opc2=adc or opc2=adz or opc2=ndu or opc2=ndc or opc2=ndz) then     -- those instructions which read two regsiters
  --      if(opc3=add or opc3=adi or opc3=ndu or opc3=lhi or opc3=jal or opc3=jlr) then   -- those instructions which write to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(8 downto 6)) then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        if(PR3_wb_addr_out=PR2_IR_out(5 downto 3)) then
  --          mux14_sel<='1';
  --        else
  --          mux14_sel<='0';
  --        end if;
  --      elsif(opc3=adc or opc3=adz or opc3=ndc or opc3=ndz) then          -- those instructions which write(conditional) to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(8 downto 6) and mux13_sel='1') then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        if(PR3_wb_addr_out=PR2_IR_out(5 downto 3) and mux13_sel='1') then
  --          mux14_sel<='1';
  --        else
  --          mux14_sel<='0';
  --        end if;
  --      elsif(opc3=lw or opc3=lm) then   -- those instructions which write to regsiters (Awanish handling these)

  --      else                               -- those instructions which do not write to registers (beq,sw,sm)
  --        mux3_sel<='0';
  --        mux14_sel<='0';
      
  --    elsif(opc2=adi or opc2=lw or opc2=jlr) then   -- those instructions which read only one regsiter (8-6)
  --      if(opc3=add or opc3=adi or opc3=ndu or opc3=lhi or opc3=jal or opc3=jlr) then   -- those instructions which write to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(8 downto 6)) then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        --if(PR3_wb_addr_out=PR2_IR_out(5 downto 3)) then
  --        --  mux14_sel<='1';
  --        --else
  --        --  mux14_sel<='0';
  --        --end if;
  --      elsif(opc3=adc or opc3=adz or opc3=ndc or opc3=ndz) then          -- those instructions which write(conditional) to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(8 downto 6) and mux13_sel='1') then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        --if(PR3_wb_addr_out=PR2_IR_out(5 downto 3) and mux13_sel='1') then
  --        --  mux14_sel<='1';
  --        --else
  --        --  mux14_sel<='0';
  --        --end if;
  --      elsif(opc3=lw or opc3=lm) then   -- those instructions which write to regsiters (Awanish handling these)

  --      else                               -- those instructions which do not write to registers (beq,sw,sm)
  --        mux3_sel<='0';
  --        mux14_sel<='0';

  --    elsif(opc2=beq or opc2=sw) then      -- those instructions which read two regsiters (11-9) and (8-6)
  --      if(opc3=add or opc3=adi or opc3=ndu or opc3=lhi or opc3=jal or opc3=jlr) then   -- those instructions which write to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(8 downto 6)) then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        if(PR3_wb_addr_out=PR2_IR_out(11 downto 9)) then
  --          mux14_sel<='1';
  --        else
  --          mux14_sel<='0';
  --        end if;
  --      elsif(opc3=adc or opc3=adz or opc3=ndc or opc3=ndz) then          -- those instructions which write(conditional) to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(8 downto 6) and mux13_sel='1') then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        if(PR3_wb_addr_out=PR2_IR_out(11 downto 9) and mux13_sel='1') then
  --          mux14_sel<='1';
  --        else
  --          mux14_sel<='0';
  --        end if;
  --      elsif(opc3=lw or opc3=lm) then   -- those instructions which write to regsiters (Awanish handling these)

  --      else                               -- those instructions which do not write to registers (beq,sw,sm)
  --        mux3_sel<='0';
  --        mux14_sel<='0';

  --    elsif(opc2=jal or opc2=lhi) then    -- these instructions do not read regsiters hence default case
  --      mux3_sel<='0';
  --      mux14_sel<='0';

  --    elsif(opc2=lm) then      -- those instructions which read only one register(11-9)
  --      if(opc3=add or opc3=adi or opc3=ndu or opc3=lhi or opc3=jal or opc3=jlr) then   -- those instructions which write to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(11 downto 9)) then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        --if(PR3_wb_addr_out=PR2_IR_out(5 downto 3)) then
  --        --  mux14_sel<='1';
  --        --else
  --        --  mux14_sel<='0';
  --        --end if;
  --      elsif(opc3=adc or opc3=adz or opc3=ndc or opc3=ndz) then          -- those instructions which write(conditional) to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(11 downto 9) and mux13_sel='1') then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        --if(PR3_wb_addr_out=PR2_IR_out(5 downto 3) and mux13_sel='1') then
  --        --  mux14_sel<='1';
  --        --else
  --        --  mux14_sel<='0';
  --        --end if;
  --      elsif(opc3=lw or opc3=lm) then   -- those instructions which write to regsiters (Awanish handling these)

  --      else                               -- those instructions which do not write to registers (beq,sw,sm)
  --        mux3_sel<='0';
  --        mux14_sel<='0';

  --    elsif (opc2=sm) then
  --      if(opc3=add or opc3=adi or opc3=ndu or opc3=lhi or opc3=jal or opc3=jlr) then   -- those instructions which write to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(11 downto 9)) then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        if(PR3_wb_addr_out=PE_out) then
  --          mux14_sel<='1';
  --        else
  --          mux14_sel<='0';
  --        end if;
  --      elsif(opc3=adc or opc3=adz or opc3=ndc or opc3=ndz) then          -- those instructions which write(conditional) to regsiters
  --        if(PR3_wb_addr_out=PR2_IR_out(11 downto 9) and mux13_sel='1') then
  --          mux3_sel<='1';
  --        else
  --          mux3_sel<='0';
  --        end if;
  --        if(PR3_wb_addr_out=PE_out and mux13_sel='1') then
  --          mux14_sel<='1';
  --        else
  --          mux14_sel<='0';
  --        end if;
  --      elsif(opc3=lw or opc3=lm) then   -- those instructions which write to regsiters (Awanish handling these)

  --      else                               -- those instructions which do not write to registers (beq,sw,sm)
  --        mux3_sel<='0';
  --        mux14_sel<='0';
      
  --    else
  --      mux3_sel<='0';
  --      mux14_sel<='0';
  --    end if;

  --end process;

  beqchecker: xor16 port map(x=>mux3_out, y=>mux14_out, z=>xor_out);
  adder2: sixteenbitadder port map(x=>PR2_PC_out, y=>mux1_out, cin=>'0', z=>adder2_out, cout=>adder2_carry);
  mux5:  MUX4X1 port map(d1=>PR2_PC_out, d2=>adder2_out, d3=>mux14_out, d4=>mux14_out, s1=>mux5_sel1, s0=>mux5_sel0, dout=>mux5_out);
  mux25: MUX21 port map(d1=>mux5_out, d2=>PR5_res_out, s=>mux25_sel, dout=>mux25_out);  -- if R7 changes then PC has to be updated
  lmbit <= (PR2_IR_out(7) or PR2_IR_out(6) or PR2_IR_out(5) or PR2_IR_out(4) or PR2_IR_out(3) or PR2_IR_out(2) or PR2_IR_out(1) or PR2_IR_out(0));
 
  -- PR3 registers
  PR3_d1_addr: dregister generic map(nbits=>3) port map(din=>mux17_out, dout=>PR3_d1_addr_out, wr_en=>PR3_en, clk=>clk);
  PR3_d2_addr: dregister generic map(nbits=>3) port map(din=>mux2_out, dout=>PR3_d2_addr_out, wr_en=>PR3_en, clk=>clk);
  PR3_PC: dregister port map(din=>PR2_PC_out, dout=>PR3_PC_out, wr_en=>PR3_en, clk=>clk);
  PR3_d1_value : dregsiter port map(din=>mux3_out, dout=>PR3_d1_out, wr_en=>PR3_en, clk=>clk);
  PR3_d2_value : dregsiter port map(din=>mux14_out, dout=>PR3_d2_out, wr_en=>PR3_en, clk=>clk);
  PR3_wb_addr: dregsiter generic map(nbits=>3) port map(din=>mux4_out, dout=>PR3_wb_addr_out, wr_en=>PR3_en, clk=>clk);
  PR3_Imm: dregsiter port map(din=>mux1_out, dout=>PR3_imm_out, wr_en=>PR3_en, clk=>clk);
  PR3_opc: dregsiter generic map(nbits=>4) port map(din=>PR2_IR_out(15 downto 12), dout=>PR3_opc_out, wr_en=>PR3_en, clk=>clk);
  PR3_lm: onedregister port map(din=>lmbit, dout=>PR3_lmbit, wr_en=>PR3_en, clk=>clk);

  -- Stage 4
  forward_stage4:process(PR3_opc_out,PR4_opc_out) is
  begin 
    if(PR3_opc_out = adi or PR3_opc_out = lw or PR3_opc_out = sw) then
      mux6_sel<= '1';
    else 
      mux6_sel<= '0';
    end if;
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
  mux6: MUX21 port map(d1=>mux16_out, d2=>PR3_d2_out, s=>mux6_sel, dout=>mux6_out);
  mux7: MUX4X1 port map(d1=>mux20_out, d2=>ones, d3=>PR3_imm_out, d4=>zeros, s1=>mux7_sel1, s0=>mux7_sel0, dout=>mux7_out);

  ---------------PR5 to Alu_input forwarding and stalling logic for lw and for lm------------
process(PR3_d1_addr_out, PR3_d2_addr_out, PR4_wb_addr_out, PR5_wb_addr_out, PR3_opc_out, PR4_opc_out, PR5_opc_out) is
begin

if(((PR3_opc_out=add or PR3_opc_out=ndu) and PR3_2bits="00") or ((PR3_opc_out=adc or PR3_opc_out = ndc) and PR3_2bits="10") or ((PR3_opc_out=adz or PR3_opc_out=ndz) and PR3_2bits="01") or PR3_opc_out=sw or PR3_opc_out=beq or PR3_opc_out=sm) then
  if((PR4_opc_out = lw or PR4_opc_out = lm) and (PR4_wb_addr_out = PR3_d1_addr_out or PR4_wb_addr_out = PR3_d2_addr_out)) then 
     --introduce stalling:
    if(PR4_wb_addr_out = PR3_d1_addr_out) then
       mux16_sel <='1';
    end if;
    if(PR4_wb_addr_out = PR3_d2_addr_out) then 
      mux20_sel <='1';
    end if;
  elsif(PR5_opc_out = lw or PR5_opc_out = lm) then
    if(PR5_wb_addr_out = PR3_d1_addr_out) then
      mux16_sel <='1';
    end if;
    if(PR5_wb_addr_out = PR3_d2_addr_out) then
      mux20_sel <='1';
    end if;
  else
    mux16_sel <='0';
    mux20_sel <='0';
  end if;
elsif(PR3_opc_out = adi or PR3_opc_out = lw or PR3_opc_out = jlr or PR3_opc_out = lm) then
  if(PR4_opc_out = lw or PR4_opc_out = lm) and (PR4_wb_addr_out = PR3_d1_addr_out)) then
    --introduce stalling:
    mux16_sel <='1';
  elsif(PR5_opc_out = lw or PR5_opc_out = lm) and (PR5_wb_addr_out = PR3_d1_addr_out)) then
    mux16_sel<='1';
  else 
    mux16_sel<='0';
    mux20_sel<='0';
  end if;
else 
  mux16_sel <='0';
  mux20_sel <='0';  
end if;  
end process
---------------------------------------------------end----------------------------
  alu_inside:alu port map(X=>mux6_out, Y=>mux7_out, Z=>alu_out, OPC=>PR3_opc_out, CF=>PR4_cin, ZF=>PR4_zin);
  mux8: MUX4X1 port map(d1=>alu_out, d2=>PR3_PC_out, d3=>PR3_imm_out, d4=>zeros, s1=>mux8_sel1, s0=>mux8_sel0, dout=>mux8_out); 

  mux13: MUX21 port map(d1=>'0', d2=>'1', s=>mux13_sel, dout=>mux13_out);

  truth_register:process(PR3_opc_out,PR4_opc_out,PR5_opc_out,PR4_truth_out,PR5_truth_out,PR4_cout,PR4_zout,PR5_cout,PR5_zout,CF,ZF) is
    begin
      opc3<=PR3_opc_out;
      opc4<=PR4_opc_out;
      opc5<=PR5_opc_out;

      if(((opc3=add or opc3=ndu) and PR3_2bits="00") or opc3=adi) then
        mux13_sel<='1';
      
      elsif((opc3=adc or opc3=ndc) and PR3_2bits="10") then
        
        if (((opc4=add and PR4_2bits="00") or (opc4=adc and PR4_2bits="10") or opc4=adi or (opc4=adz and PR4_2bits="01")) and PR4_truth_out='1') then
          if(PR4_cout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        
        elsif (((opc5=add and PR5_2bits="00") or (opc5=adc and PR5_2bits="10") or opc5=adi or (opc5=adz and PR5_2bits="01")) and PR5_truth_out='1') then
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
      
      elsif ((opc3=adz or opc3=ndz) and PR3_2bits="01") then     -- assuming that load does not changes carry

        if ((((opc4=add or opc4=ndu) and PR4_2bits="00") or ((opc4=adc or opc4=ndc) and PR4_2bits="10") or ((opc4=adz opc4=ndz) and PR4_2bits="01") or opc4=adi) and PR4_truth_out='1') then
          if(PR4_zout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        elsif((((opc5=add or opc5=ndu) and PR5_2bits="00") or ((opc5=adc or opc5=ndc) and PR5_2bits="10") or ((opc5=adz or opc5=ndz) and PR5_2bits="01") or opc5=adi) and PR5_truth_out='1')  then
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
  PR4_d1 : dregsiter port map(din=>PR3_d1_out, dout=>PR4_d1_out, wr_en=>PR4_en, clk=>clk);
  PR4_d2 : dregsiter port map(din=>PR3_d2_out, dout=>PR4_d2_out, wr_en=>PR4_en, clk=>clk);
  PR4_result: dregsiter port map(din=>mux8_out, dout=>PR4_res_out, wr_en=>PR4_en, clk=>clk);
  PR4_opc: dregsiter generic map(nbits=>4) port map(din=>PR3_opc_out, dout=>PR4_opc_out, wr_en=>PR4_en, clk=>clk);
  PR4_wb_addr: dregsiter generic map(nbits=>3) port map(din=>PR3_wb_addr_out, dout=>PR4_wb_addr_out, wr_en=>PR4_en, clk=>clk);
  PR4_zt: onedregister port map(din=>PR4_cin, dout=>PR4_cout, wr_en=>'1', clk=>clk);
  PR4_ct : onedregister port map(din=>PR4_zin, dout=>PR4_zout, wr_en=>'1', clk=>clk);
  PR4_truth: onedregsiter port map(din=>mux13_out, dout=>PR4_truth_out, wr_en=>PR4_en, clk=>clk);
  PR4_lm: onedregister port map(din=>PR3_lmbit, dout=>PR4_lmbit, wr_en=>PR4_en, clk=>clk);

  -- Stage 5
  mux9: MUX21 port map(d1=>PR4_d2_out, d2=>PR4_d1_out, s=>mux9_sel, dout=>mux9_out);

  Dmemory: asynch_mem port map(din=>mux9_out, dout=>Dmem_data_out, rdbar=>c1, wrbar=>c2, addrin=>PR4_res_out, reset=>reset);
  mux10: MUX21 port map(d1=>PR4_res_out, d2=>Dmem_data_out, s=>mux10_sel, dout=>mux10_out);

  process(PR4_opc_out) is
    begin
      if(PR4_opc_out=sw) then
        mux9_sel<='1';
      else
        mux9_sel<='0';
      end if;
      if(PR4_opc_out=lw or PR4_opc_out=lm) then
        mux10_sel<='1';
      else
        mux10_sel<='0';
      end if;
  end process;

  -- PR5 regsiters
  PR5_wb_addr: dregsiter generic map(nbits=>3) port map(din=>PR4_wb_addr_out, dout=>PR5_wb_addr_out, wr_en=>PR5_en, clk=>clk);
  PR5_opc: dregsiter generic map(nbits=>4) port map(din=>PR4_opc_out, dout=>PR5_opc_out, wr_en=>PR5_en, clk=>clk);
  PR5_result: dregsiter port map(din=>mux10_out, dout=>PR5_res_out, wr_en=>PR5_en, clk=>clk);

  PR5_ct : onedregister port map(din=>PR4_cout, dout=>PR5_cout, wr_en=>PR5_en, clk=>clk);
  PR5_zt: onedregister port map(din=>PR4_zout, dout=>PR5_zout, wr_en=>PR5_en, clk=>clk);
  PR5_truth: onedregister port map(din=>PR4_truth_out, dout=>PR5_truth_out, wr_en=>PR5_en, clk=>clk);
  PR5_lm: onedregister port map(din=>PR4_lmbit, dout=>PR5_lmbit, wr_en=>PR5_en, clk=>clk);

  --mux12: MUX21 generic map(nbits=>1) port map(d1=>PR4_zout, d2=>eta, s=>mux12_sel, dout=>mux12_out);

  --eta<=not(Dmem_data_out(15) or Dmem_data_out(14) or Dmem_data_out(13) or Dmem_data_out(12) or Dmem_data_out(11) or Dmem_data_out(10) 
  --      or Dmem_data_out(9) or Dmem_data_out(8) or Dmem_data_out(7) or Dmem_data_out(6) or Dmem_data_out(5) or Dmem_data_out(4)
  --      or Dmem_data_out(3) or Dmem_data_out(2) or Dmem_data_out(1) or Dmem_data_out(0));

  carry_flag: onedregister port map(din=>PR5_cout, dout=>CF, wr_en=>c_en, clk=>clk);
  zero_flag: onedregister port map(din=>PR5_zout, dout=>ZF, wr_en=>z_en, clk=>clk);

  flag_enable:process(PR5_opc_out,PR5_truth_out) is
    begin
      opc5<=PR5_opc_out;
      if (((opc5=add and PR5_2bits="00") or opc5=adi or (opc5=adc and PR5_2bits="10") or (opc5=adz and PR5_2bits="01")) and PR5_truth_out='1') then
        c_en<='1';
      else
        c_en<='0';
      end if;

      if ((((opc5=add or opc5=ndu) and PR5_2bits="00") or opc5=adi or ((opc5=adc or opc5=ndc) and PR5_2bits="10") or ((opc5=adz or opc5=ndz) and PR5_2bits="01")) and PR5_truth_out='1') then
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

    r7_en <= (P or PC_en);
    mux25_sel <= (PR5_wb_addr_out(2) and PR5_wb_addr_out(1) and PR5_wb_addr_out(0)) and P;
  end process;
end behave;