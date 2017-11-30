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
	 --ALU_OUTPUT:out std_logic_vector(15 downto 0)
	);
end entity;

architecture behave of datapath_fsm is
-- component declaration already done in work
signal mux5_out,PC_out,adder1_out,Imem_data_out,PR1_IR_out,PR1_PC_out:std_logic_vector(15 downto 0);
signal PC_en,adder1_carry, : std_logic;

signal zeros:std_logic_vector(15 downto 0):="0000000000000000";
signal ones:std_logic_vector(15 downto 0):="1111111111111111";
signal add,adc,adz,adi,ndu,ndz,ndc,lhi,lw,lm,jal,jlr:std_logic_vector(3 downto 0);

variable d1_flag,d2_flag:integer;

begin
  --JLR <= IR_out(15) and (not(IR_out(14))) and (not(IR_out(13))) and IR_out(12);
  --BEQ <= IR_out(15) and IR_out(14) and (not(IR_out(13))) and (not(IR_out(12))); 
  --LHI <= (not(IR_out(15))) and (not(IR_out(14))) and IR_out(13) and IR_out(12);
  --LW_SW <= ((not(IR_out(15))) and IR_out(14) and (not(IR_out(13))) and (not(IR_out(12)))) or ((not(IR_out(15))) and IR_out(14) and (not(IR_out(13))) and IR_out(12));
  --LW_SW_ADI <= (LW_SW or (not(IR_out(15)) and not(IR_out(14)) and not(IR_out(13)) and IR_out(12)));
  
  --BEQ_SW <= (IR_out(15) and IR_out(14) and (not(IR_out(13))) and (not(IR_out(12)))) or ((not(IR_out(15))) and IR_out(14) and (not(IR_out(13))) and IR_out(12));
  --SM <= (not(IR_out(15))) and IR_out(14) and IR_out(13) and IR_out(12);
  --LM <= (not(IR_out(15)))  and IR_out(14) and IR_out(13) and (not(IR_out(12)));
  
  add <= "0000";
  adi <= "0001";
  ndu <= "0010"
  lhi <= "0011";
  lw <= "0100";
  sw <= "0101";
  lm <= "0110";
  sm <= "0111";
  jal <= "1000";
  jlr <= "1001";
  beq <= "1100";


  PR2_I6 <= (LW_SW_ADI or BEQ);
  PR2_LM <= (not(PR2_IR_out(15)) and PR2_IR_out(14) and PR2_IR_out(13) and not(PR2_IR_out(12)));
  PR2_SM <= (not(PR2_IR_out(15)) and PR2_IR_out(14) and PR2_IR_out(13) and PR2_IR_out(12));
  PR2_LM_SM <= PR2_LM or PR2_SM;
  PR2_JAL <= PR2_IR_out(15) and not(PR2_IR_out(14)) and not(PR2_IR_out(13)) and not(PR2_IR_out(12));
  PR2_JLR <= PR2_IR_out(15) and (not(PR2_IR_out(14))) and (not(PR2_IR_out(13))) and PR2_IR_out(12);

  -- Stage 1
  PC: dregister port map(din=>mux5_out, dout=>PC_out, wr_en=>PC_en, clk=>clk);
  adder1 : sixteenbitadder port map(x=>PC_out, y=>'1', cin=>'0', z=>adder1_out, cout=>adder1_carry);
  Imemory: asynch_mem port map(din=>zeros, dout=>Imem_data_out, rdbar=>'0', wrbar=>'1', addrin=>PC_out, reset=>reset);

  PR1_IR : dregister port map(din=>Imem_data_out, dout=>PR1_IR_out, wr_en=>PR1_en, clk=>clk);
  PR1_PC : dregister port map(din=>adder1_out, dout=>PR1_PC_out, wr_en=>PR1_en, clk=>clk);

  -- Stage 2
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

  -- Stage 3
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
      else
        mux5_sel0<=xor_out;
      end if;
  end process;

  process(PR5_opc,last2bits,PR5_wr_en) is
  begin
    if (PR5_opc = adi or PR5_opc = lhi or PR5_opc = lw or PR5_opc = lm or PR5_opc = jal or PR5_opc = jlr) then
      P <= '1';
    elsif (PR5_opc = "0000" or PR5_opc = "0010") then
      if(last2bits = "00") then
        P<='1';
      elsif(last2bits = "01" or last2bits = "10") then
        P <= PR5_wr_en;
      else
        P <= '0';
      end if;
    else
      P <= '0';
    end if;
  end process;

  r7_en <= (P or PC_en);
  regfile: register_file port map(a1=>mux17_out,a2=>mux2_out, a3=>PR5_wb_addr_out, a4=>"111", d3=>PR5_res_out, wr_en=>P, wr_en7=>r7_en, d1=>d1_out, d2=>d2_out, clk=>clk,reset=>reset);
  mux4: MUX21 generic map(nbits=>3) port map(d1=>PR2_IR_out(11 downto 9), d2=>PE_out, s=>mux4_sel, dout=>mux4_out);

  -- forward logic at stage 3
  mux3: MUX21 port map(d1=>d1_out, d2=>mux8_out, s=>mux3_sel, dout=>mux3_out);
  mux14: MUX21 port map(d1=>d2_out, d2=>mux8_out, s=>mux14_sel, dout=>mux14_out);
  mux21: MUX21 port map(d1=>mux3_out, d2=>PR4_res_out, s=>mux21_sel, dout=>mux21_out);
  mux22: MUX21 port map(d1=>mux14_out, d2=>PR4_res_out, s=>mux22_sel, dout=>mux22_out);
  mux23: MUX21 port map(d1=>mux21_out, d2=>PR5_res_out, s=>mux23_sel, dout=>mux23_out);
  mux24: MUX21 port map(d1=>mux22_out, d2=>PR5_res_out, s=>mux24_sel, dout=>mux24_out);

  
  forward: process(PR2_IR_out,PR3_opc_out,PR4_opc_out,PR5_opc_out,PR3_wb_addr_out,PR4_wb_addr_out,PR5_wb_addr_out,
                  mux17_out,mux2_out,mux13_sel,PR4_truth_out,PR5_truth_out) is
    begin
      opc2<=PR2_IR_out(15 downto 12);
      opc3<=PR3_opc_out;
      opc4<=PR4_opc_out;
      opc5<=PR5_opc_out;

      if(PR3_wb_addr_out=mux17_out or PR3_wb_addr_out=mux2_out) then

        if(opc3=add or opc3=adi or opc3=ndu or opc3=lhi or opc3=jal or opc3=jlr) then

          if(opc2=add or opc2=adc or opc2=adz or opc2=ndu or opc2=ndc or opc2=ndz or opc2=beq or opc2=sw or opc2=adi or opc2=lw or opc2=jlr or opc2=jal or opc2=lhi or opc2=lm or opc2=sm) then     -- those instructions which read at least one regsiter                   

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

          end if;

        elsif(opc3=adc or opc3=adz or opc3=ndc or opc3=ndz) then

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

        if(opc4=add or opc4=adi or opc4=ndu or opc4=lhi or opc4=jal or opc4=jlr) then

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

        elsif(opc4=adc or opc4=adz or opc4=ndc or opc4=ndz) then

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

        if(opc5=add or opc5=adi or opc5=ndu or opc5=lhi or opc5=jal or opc5=jlr) then

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

        elsif(opc5=adc or opc5=adz or opc5=ndc or opc5=ndz) then

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

  -- PR3 registers
  PR3_d1_addr: dregister generic map(nbits=>3) port map(din=>mux17_out, dout=>PR3_d1_addr_out, wr_en=>PR3_en, clk=>clk);
  PR3_d2_addr: dregister generic map(nbits=>3) port map(din=>mux2_out, dout=>PR3_d2_addr_out, wr_en=>PR3_en, clk=>clk);
  PR3_PC: dregister port map(din=>PR2_PC_out, dout=>PR3_PC_out, wr_en=>PR3_en, clk=>clk);
  PR3_d1_value : dregsiter port map(din=>mux3_out, dout=>PR3_d1_out, wr_en=>PR3_en, clk=>clk);
  PR3_d2_value : dregsiter port map(din=>mux14_out, dout=>PR3_d2_out, wr_en=>PR3_en, clk=>clk);
  PR3_wb_addr: dregsiter generic map(nbits=>3) port map(din=>mux4_out, dout=>PR3_wb_addr_out, wr_en=>PR3_en, clk=>clk);
  PR3_Imm: dregsiter port map(din=>mux1_out, dout=>PR3_imm_out, wr_en=>PR3_en, clk=>clk);
  PR3_opc: dregsiter generic map(nbits=>4) port map(din=>PR2_IR_out(15 downto 12), dout=>PR3_opc_out, wr_en=>PR3_en, clk=>clk);

  -- Stage 4

  --PR3_LW <= not(PR3_opc_out(3)) and PR3_opc_out(2) and not(PR3_opc_out(1)) and not(PR3_opc_out(0));
  --PR3_SW <= not(PR3_opc_out(3)) and PR3_opc_out(2) and not(PR3_opc_out(1)) and PR3_opc_out(0);
  --PR3_ADI <= not(PR3_opc_out(3)) and not(PR3_opc_out(2)) and not(PR3_opc_out(1)) and PR3_opc_out(0);
  --PR3_LHI <= not(PR3_opc_out(3)) and not(PR3_opc_out(2)) and PR3_opc_out(1) and PR3_opc_out(0);
  --PR3_JLR <= PR3_opc_out(3) and not(PR3_opc_out(2)) and not(PR3_opc_out(1)) and PR3_opc_out(0);
  --PR3_JAL <= PR3_opc_out(3) and not(PR3_opc_out(2)) and not(PR3_opc_out(1)) and not(PR3_opc_out(0));
  --gamma <= PR3_JLR or PR3_JAL;
  process(PR3_opc_out,PR4_opc_out) is
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
if(PR3_opc_out = add or PR3_opc_out = adc or PR3_opc_out = adz or PR3_opc_out = ndu or PR3_opc_out = ndc or PR3_opc_out = ndz, PR3_opc_out = sw or PR3_opc_out = beq or PR3_opc_out = sm) then
  if((PR4_opc_out = lw or PR4_opc_out = lm) and (PR4_wb_addr_out = PR3_d1_addr_out or PR4_wb_addr_out = PR3_d2_addr_out)) then 
     introduce stalling:
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
    introduce stalling:
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

      if(opc3=add or opc3=ndu or opc3=adi) then
        mux13_sel<='1';
      elsif(opc3=adc or opc3=ndc) then
        if((opc4=add or opc4=adc or opc4=adi or opc4=adz) and PR4_truth_out='1') then
          if(PR4_cout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        elsif((opc5=add or opc5=adc or opc5=adi or opc5=adz) and PR5_truth_out='1') then
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
      elsif(opc3=adz or opc3=ndz) then     -- assuming that load does not changes carry
        if((opc4=add or opc4=adc or opc4=adz or opc4=adi or opc4=ndu or opc4=ndc or opc4=ndz) and PR4_truth='1') then
          if(PR4_zout='1') then
            mux13_sel<='1';
          else
            mux13_sel<='0';
          end if;
        elsif((opc5=add or opc5=adc or opc5=adz or opc5=adi or opc5=ndu or opc5=ndc or opc5=ndz) and PR5_truth='1') then
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
  PR5_result: dregsiter port map(din=>mux10_out, dout=>PR5_res_out, wr_en=>PR5_en, clk=>clk);
  PR5_opc: dregsiter generic map(nbits=>4) port map(din=>PR4_opc_out, dout=>PR5_opc_out, wr_en=>PR5_en, clk=>clk);

  PR5_ct : onedregister port map(din=>PR4_cout, dout=>PR5_cout, wr_en=>'1', clk=>clk);

  eta<=not(Dmem_data_out(15) or Dmem_data_out(14) or Dmem_data_out(13) or Dmem_data_out(12) or Dmem_data_out(11) or Dmem_data_out(10) 
        or Dmem_data_out(9) or Dmem_data_out(8) or Dmem_data_out(7) or Dmem_data_out(6) or Dmem_data_out(5) or Dmem_data_out(4)
        or Dmem_data_out(3) or Dmem_data_out(2) or Dmem_data_out(1) or Dmem_data_out(0));
  mux12: MUX21 generic map(nbits=>1) port map(d1=>PR4_zout, d2=>eta, s=>mux12_sel, dout=>mux12_out);
  PR5_zt: onedregister port map(din=>mux12_out, dout=>PR5_zout, wr_en=>'1', clk=>clk);

  carry_flag: onedregister port map(din=>PR5_cout, dout=>CF, wr_en=>c_en, clk=>clk);
  zero_flag: onedregister port map(din=>PR5_zout, dout=>ZF, wr_en=>z_en, clk=>clk);




  process() is
  begin
    if(PR3_opc = adc) then
      if(PR4_opc=add or PR4_opc=adc or PR4_opc=adz or PR4_opc = adi) then
        if(PR4_truth='1') then
          if(PR4_cout='1') then

  end process; 
































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
  mem: asynch_mem port map(din=>t2_out, dout=>mem_data_out, rdbar=>D, wrbar=>E, addrin=>mem_addr, reset=>reset);
  -- PC section
  gamma <= (B and (zd or JLR));
  mux1: MUX21 port map(d1=>alu_out, d2=>rf_d3, s=>U, dout=>mux_U);
  mux2: MUX4X1 port map(d1=>mux_U, d2=>t3_out, d3=>mux_U, d4=>t1_out, s1=>JLR, s0=>gamma, dout=>mux2_out);
  mux3: MUX21 port map(d1=>mux2_out,d2=>"0000000000000000",s=>reset,dout=>pc_in);
	alpha <= (rf_a3(0) and rf_a3(1) and rf_a3(2));
	
	badass <= ((A and (not JLR)) or ((B or (not D)) and JLR));
  
  pc_en <= ((((zd and BEQ) and S) or badass) or (U and alpha)) or reset;
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
  --ALU_OUTPUT<= alu_out;
  
  process(S,IR_out) is
  begin
    if(S = '0') then
      alu_opc <= "1111";      -- simple addition
    else
      alu_opc <= IR_out(15 downto 12);  -- based on opcode
    end if;
  end process;
end behave;