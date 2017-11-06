library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.datapath_components.all;

entity control_path is
	port (
      clk,reset:in std_logic;
      opcode_bits:in std_logic_vector(3 downto 0);
	  RFA3,ZT: in std_logic;
	  cz_bits,LSB_IR_bits:in std_logic_vector(1 downto 0);
      A,B,C,D,E,F,G,H,J,K,L,M,N,O,P,Q,R,S,T,U,IR_en,c_en,z_en,zdash_en:out std_logic
	);
end entity;

architecture behave of control_path is

type MyState is (S1, S0, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);
type opcode_store is (ADD, ADZ, ADC, ADI, NDU, NDC, NDZ, LHI, LW, SW, LM, SM, BEQ, JAL, JLR);
signal present_state, next_state : MyState;
signal opcode : opcode_store;

begin
opcode_assign: process (opcode_bits,LSB_IR_bits) is
begin
  if(opcode_bits = "0000" and LSB_IR_bits ="00") then 
  	opcode <= add;
  elsif(opcode_bits = "0000" and LSB_IR_bits ="10") then
  	opcode <= adc;
  elsif(opcode_bits = "0000" and LSB_IR_bits="01") then
  	opcode <= adz;
  elsif(opcode_bits = "0010" and LSB_IR_bits="00") then
  	opcode <= ndu;
  elsif(opcode_bits = "0010" and LSB_IR_bits="10") then
  	opcode <= ndc;
  elsif(opcode_bits = "0010" and LSB_IR_bits="01") then
  	opcode <= ndz;
  elsif(opcode_bits = "0001") then
  	opcode <= adi;
  elsif(opcode_bits = "0011") then
  	opcode <= lhi;
  elsif(opcode_bits = "0100") then
  	opcode <= lw;
  elsif(opcode_bits = "0101") then
  	opcode <= sw;
  elsif(opcode_bits = "0110") then
  	opcode <= lm;
  elsif(opcode_bits = "0111") then
  	opcode <= sm;
  elsif(opcode_bits = "1100") then
  	opcode <= beq;
  elsif(opcode_bits = "1000") then
  	opcode <= jal;
  elsif(opcode_bits = "1001") then
  	opcode <= jlr;
  else
  	opcode <= add;       -- just to avoid latch
end if;
end process opcode_assign;

next_state_logic: process (present_state,reset,opcode,ZT,RFA3,cz_bits) is
begin
  	if(reset = '1') then
    	next_state <= S1;
  	elsif(present_state = S1) then
  		next_state <= S0;
  	elsif(present_state = S0) then
	  	if(opcode=adc or opcode=ndc) then
	  		if(cz_bits(1)='1') then
	  			next_state<=S2;
		  	else
		  		next_state<=S15;
		  	end if;
		elsif(opcode=adz or opcode=ndz) then
			if(cz_bits(0)='1') then
				next_state<=S2;
			else
				next_state<=S15;
			end if;
		elsif(opcode=lm or opcode=sm) then
			next_state<=S10;
		elsif(opcode=jal or opcode=jlr) then
			next_state<=S8;
		elsif(opcode=lhi) then
			next_state<=S4;
		else
			next_state<=S2;
		end if;
	elsif(present_state = S2) then
		if(opcode=beq) then
			next_state<=S7;
		else
			next_state<=S3;
		end if;
	elsif(present_state = S3) then
		if(opcode = lw) then
			next_state<=S5;
		elsif(opcode = sw) then
			next_state<=S6;
		else
			next_state<=S4;
		end if;
	elsif(present_state = S4) then
		if(RFA3 ='1') then
			next_state <= S1;
		else
			next_state <= S15;
		end if;
	elsif(present_state=S6 or present_state=S7 or present_state=S9) then
		next_state<=S15;
	elsif(present_state = S5) then
		if(opcode=lm) then
			next_state<= S11;
		else
			next_state<= S4;
		end if;
	elsif(present_state=S8) then
		if(opcode = jlr) then
			next_state<=S9;
		else
			next_state<=S15;
		end if;
	elsif(present_state = S10) then
		if(opcode=lm) then
			if(ZT='1') then
				next_state<=S15;
			else
				next_state<=S5;
			end if;
		elsif(opcode=sm) then
			if(ZT='1') then
				next_state<=S15;
			else
				next_state<=S13;
			end if;
		end if;
	elsif(present_state = S11) then
		if(RFA3 = '1') then
			next_state <= S1;
		elsif(ZT = '0') then
			next_state <= S12;
		else                         -- (ZT = '0')
			next_state <= S15;
		end if;
	elsif(present_state = S12) then
		if(opcode = lm) then
			next_state <= S5;
		else
			next_state <= S13;
		end if;
	elsif(present_state = S13) then
		next_state <= S14;
	elsif(present_state = S14) then
		if(ZT = '0') then
			next_state<=S12;
		else
			next_state<=S15;
		end if;
	elsif(present_state = S15) then
		next_state <= S1;
	else 
		next_state <= S1;
	end if;
end process next_state_logic;

state_latch: process(next_state, clk) is
begin
	if rising_edge(clk) then
		present_state <= next_state;
	end if;
end process;

--A <= S1+S8+S9;
--B <= S7+S9;
--C <= S1;
--D <= not (S1+S5);
--E <= not (S6+S14);
--F <= S1+S2+S3+S7+S8+S12;
--G <= S1+S2+S8+S11+S13;
--H <= S11+S13;
--J <= S13;
--K <= S2+S3+S7;
--L <= S2+S8+S10+S11+S13;
--M <= S2+S3+S7;
--N <= S10;
--O <= S10+S11+S13;
--P <= S4+S8+S11+S15;
--Q <= S4+S8+S11;
--R <= S4+S11;
--T <= S2+S3+S5;
--U <= S4+S11;

next_state_output: process(present_state) is
begin
if(present_state = S1) then
A<='1';B<='0';C<='1';D<='0';E<='1';F<='1';G<='1';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='1';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S0) then
A<='0';B<='0';C<='1';D<='1';E<='1';F<='1';G<='1';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';

elsif(present_state = S2) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='1';G<='1';H<='0';J<='0';K<='1';L<='1';M<='1';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='1';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S3) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='1';G<='0';H<='0';J<='0';K<='1';L<='0';M<='1';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='1';T<='1';U<='0';IR_en<='0';zdash_en<='1';
	if(opcode=lw or opcode=sw) then
		c_en<='0';z_en<='0';
	else
		c_en<='1';z_en<='1';
	end if;
elsif(present_state = S4) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='0';G<='0';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='1';Q<='1';R<='1';S<='0';T<='0';U<='1';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';

elsif(present_state = S5) then
A<='0';B<='0';C<='0';D<='0';E<='1';F<='0';G<='0';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='1';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';

elsif(present_state = S6) then
A<='0';B<='0';C<='0';D<='1';E<='0';F<='0';G<='0';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';

elsif(present_state = S7) then
A<='0';B<='1';C<='0';D<='1';E<='1';F<='1';G<='0';H<='0';J<='0';K<='1';L<='0';M<='1';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='1';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S8) then
A<='1';B<='0';C<='0';D<='1';E<='1';F<='1';G<='1';H<='0';J<='0';K<='0';L<='1';M<='0';N<='0';O<='0';P<='1';Q<='1';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S9) then
A<='1';B<='1';C<='0';D<='1';E<='1';F<='0';G<='0';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';

elsif(present_state = S10) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='0';G<='0';H<='0';J<='0';K<='0';L<='1';M<='0';N<='1';O<='1';P<='0';Q<='0';R<='0';S<='1';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S11) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='0';G<='1';H<='1';J<='0';K<='0';L<='1';M<='0';N<='0';O<='1';P<='1';Q<='1';R<='1';S<='1';T<='0';U<='1';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S12) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='1';G<='0';H<='0';J<='1';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S13) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='0';G<='1';H<='1';J<='0';K<='0';L<='1';M<='0';N<='0';O<='1';P<='0';Q<='0';R<='0';S<='1';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='1';

elsif(present_state = S14) then
A<='0';B<='0';C<='0';D<='1';E<='0';F<='0';G<='0';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';

elsif(present_state = S15) then
A<='0';B<='0';C<='0';D<='1';E<='1';F<='0';G<='0';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='1';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';

else
A<='0';B<='0';C<='1';D<='1';E<='1';F<='1';G<='1';H<='0';J<='0';K<='0';L<='0';M<='0';N<='0';O<='0';P<='0';Q<='0';R<='0';S<='0';T<='0';U<='0';IR_en<='0';c_en<='0';z_en<='0';zdash_en<='0';
end if;


end process;

end behave;