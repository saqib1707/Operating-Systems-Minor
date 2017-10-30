library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

package datapath_Components is
  component INVERTER is
  port (a: in std_logic; b : out std_logic);
   end component;
   component AND21 is
  port (a, b: in std_logic; c : out std_logic);
   end component;
   component NAND21 is
  port (a, b: in std_logic; c : out std_logic);
   end component;
   component OR21 is
  port (a, b: in std_logic; c : out std_logic);
   end component;
   component NOR21 is
  port (a, b: in std_logic; c : out std_logic);
   end component;
   component positive_d_latch is
  port (d, clk: in std_logic; q : out std_logic);
   end component;
   component negative_d_latch is
  port (d, clk: in std_logic; q : out std_logic);
   end component;
   component DFF is
  port (d, clk: in std_logic; q : out std_logic);
   end component;
  component alu is
    port(X,Y : in std_logic_vector(15 downto 0);
        OPC : in std_logic_vector(3 downto 0);
        Z : out std_logic_vector(15 downto 0);
        CF, ZF: out std_logic
    );
  end component;
  component leftshift_1 is
    port (din: in std_logic_vector(15 downto 0);
      dout:out std_logic_vector(15 downto 0)
    );
  end component;
  component leftshift_7 is
    port (din: in std_logic_vector(15 downto 0);
      dout:out std_logic_vector(15 downto 0)
    );
  end component;
  component sgn6 is
    port (
      din : in STD_LOGIC_VECTOR(5 downto 0);
      dout : out STD_LOGIC_VECTOR(15 downto 0)
    );
  end component;
  component sgn9 is
    port (
      din : in STD_LOGIC_VECTOR(8 downto 0);
      dout : out STD_LOGIC_VECTOR(15 downto 0)
    );
  end component;
  component priority_encoder is
    port (
      din : in STD_LOGIC_VECTOR(7 downto 0);
      dout : out STD_LOGIC_VECTOR(2 downto 0)
      );
  end component;
  component zero_decoder is
    port (
      din : in STD_LOGIC_VECTOR(2 downto 0);
      dout : out STD_LOGIC_VECTOR(8 downto 0)
    );
  end component;
  component MUX21 is
    port (d1, d2: in std_logic_vector(15 downto 0);
      s: in std_ulogic;
      dout: out std_logic_vector(15 downto 0)
    );
  end component;
  component MUX41 is
    port (d1, d2, d3, d4: in std_logic_vector(15 downto 0);
        s: in std_logic_vector(1 downto 0);
        dout: out std_logic_vector(15 downto 0));
  end component;
  component register_file is
    port (
      a1, a2, a3: in std_logic_vector(2 downto 0);
      d3: in std_logic_vector(15 downto 0);
      write_enable: in std_logic;
      d1, d2: out std_logic_vector(15 downto 0);
      clk: in std_logic
    );
  end component;
end datapath_Components;

library ieee;
use ieee.std_logic_1164.all;
entity INVERTER is
  port (a: in std_ulogic;
         b: out std_ulogic);
end entity INVERTER;
architecture Behave of INVERTER is
begin
  b <= not a;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity AND21 is
  port (a, b: in std_ulogic;
         c: out std_ulogic);
end entity AND21;
architecture Behave of AND21 is
begin
  c <= a and b;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity NAND21 is
  port (a, b: in std_ulogic;
         c: out std_ulogic);
end entity NAND21;
architecture Behave of NAND21 is
begin
  c <= not(a and b);
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity OR21 is
  port (a, b: in std_ulogic;
         c: out std_ulogic);
end entity OR21;
architecture Behave of OR21 is
begin
  c <= a or b;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity NOR21 is
  port (a, b: in std_ulogic;
         c: out std_ulogic);
end entity NOR21;
architecture Behave of NOR21 is
begin
  c <= not (a or b);
end Behave;

------------------------------ALU------------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity alu is
  port(X,Y : in std_logic_vector(15 downto 0);
        OPC : in std_logic_vector(3 downto 0);
        Z : out std_logic_vector(15 downto 0);
        CF, ZF: out std_logic
  );
end entity;

architecture behave of alu is 
  signal sig1,sig2,sig3,sig4 : std_logic_vector(15 downto 0);
  signal carry, zero: std_logic;
  constant zeros: std_logic_vector(15 downto 0) := (others => '0');

  component sixteenbitadder is
    port(x,y:in std_logic_vector(15 downto 0); z:out std_logic_vector(15 downto 0); carry_flag: out std_logic);
  end component;

  component sixteenbitsubtractor is 
    port(x,y:in std_logic_vector(15 downto 0); z:out std_logic_vector(15 downto 0));
  end component;

  component and16 is
    port(x, y:in std_logic_vector(15 downto 0); z:out std_logic_vector(15 downto 0));
  end component;

  component nand16 is
    port(x, y:in std_logic_vector(15 downto 0); z:out std_logic_vector(15 downto 0));
  end component;   

  begin 
  a: sixteenbitadder       port map(x => X, y => Y, z => sig1, carry_flag=>carry);
  b: sixteenbitsubtractor  port map(x => X, y => Y, z => sig2);
  c: and16       port map(x => X, y => Y, z => sig3);
  d: nand16      port map(x => X, y => Y, z => sig4);

  process(OPC, sig1, sig2, sig3, sig4)
    begin
      if (OPC = "0000") or (OPC = "0001") then
        Z <= sig1;
        CF <= carry;
        if(sig1 = zeros) then
          ZF <= '1';
        else
          ZF <= '0';
        end if;
      elsif (OPC = "1111") then
        Z <= sig1;
      elsif (OPC = "0010") then
        Z <= sig4;
        if (sig4 = zeros) then
          ZF <= '1';
        else
          ZF <= '0';
        end if;
      elsif (OPC = "1100") then
        Z <= sig2;
      elsif (OPC = "0110" or OPC = "0111") then
        Z <= sig3;
      else
        Z <= sig1;
      end if;
  end process;
end behave;

-------------------nand16----------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity nand16 is 
port (x, y: in std_logic_vector(15 downto 0);
      z:out std_logic_vector(15 downto 0));
end entity;

architecture behave of nand16 is
begin
  label: process(x, y) is
  begin
    for i in 0 to 15 loop
      z(i) <= (x(i) nand y(i));
    end loop;
  end process label;
end behave;

-------------------and16----------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity and16 is 
port (x, y: in std_logic_vector(15 downto 0);
      z:out std_logic_vector(15 downto 0));
end entity;

architecture behave of and16 is
begin
  label: process(x, y) is
  begin
    for i in 0 to 15 loop
      z(i) <= x(i) and y(i);
    end loop;
  end process label;
end behave;

-----------------Sixteen Bit Adder------------------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity sixteenbitadder is 
port (x,y: in std_logic_vector(15 downto 0);
      z:out std_logic_vector(15 downto 0);
      carry_flag: out std_logic
);
end entity;

architecture behave of sixteenbitadder is
  component onebitadder is
    port(x,y,cin : in std_logic;
        z,cout : out std_logic);
  end component;
  signal c:std_logic_vector(15 downto 0);
begin
 adder0:onebitadder port map(x=>x(0),y=>y(0),cin=>'0',z=>z(0),cout=>c(0));
 adder1:onebitadder port map(x=>x(1),y=>y(1),cin=>c(0),z=>z(1),cout=>c(1));
 adder2:onebitadder port map(x=>x(2),y=>y(2),cin=>c(1),z=>z(2),cout=>c(2));
 adder3:onebitadder port map(x=>x(3),y=>y(3),cin=>c(2),z=>z(3),cout=>c(3));
 adder4:onebitadder port map(x=>x(4),y=>y(4),cin=>c(3),z=>z(4),cout=>c(4));
 adder5:onebitadder port map(x=>x(5),y=>y(5),cin=>c(4),z=>z(5),cout=>c(5));
 adder6:onebitadder port map(x=>x(6),y=>y(6),cin=>c(5),z=>z(6),cout=>c(6));
 adder7:onebitadder port map(x=>x(7),y=>y(7),cin=>c(6),z=>z(7),cout=>c(7));
 adder8:onebitadder port map(x=>x(8),y=>y(8),cin=>c(7),z=>z(8),cout=>c(8));
 adder9:onebitadder port map(x=>x(9),y=>y(9),cin=>c(8),z=>z(9),cout=>c(9));
 adder10:onebitadder port map(x=>x(10),y=>y(10),cin=>c(9),z=>z(10),cout=>c(10));
 adder11:onebitadder port map(x=>x(11),y=>y(11),cin=>c(10),z=>z(11),cout=>c(11));
 adder12:onebitadder port map(x=>x(12),y=>y(12),cin=>c(11),z=>z(12),cout=>c(12));
 adder13:onebitadder port map(x=>x(13),y=>y(13),cin=>c(12),z=>z(13),cout=>c(13));
 adder14:onebitadder port map(x=>x(14),y=>y(14),cin=>c(13),z=>z(14),cout=>c(14));
 adder15:onebitadder port map(x=>x(15),y=>y(15),cin=>c(14),z=>z(15),cout=>carry_flag);
end behave;

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity onebitadder is
port (x,y,cin: in std_logic;
    z,cout:out std_logic
);
end entity;
architecture behave of onebitadder is
begin
  z <= (cin xor (x xor y));
  cout <= ((cin and (x xor y)) or (x and y));
end behave;

----------------------------Sixteen Bit Subtractor---------------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity sixteenbitsubtractor is 
port (x,y: in std_logic_vector(15 downto 0);
      z:out std_logic_vector(15 downto 0)
);
end entity;

architecture behave of sixteenbitsubtractor is
  component onebitsubtractor is
    port(x,y,bin : in std_logic;
          z,bout : out std_logic
    );
  end component;
  signal c:std_logic_vector(15 downto 0);
begin
 subtractor0:onebitsubtractor port map(x=>x(0),y=>y(0),bin=>'0',z=>z(0),bout=>c(0));
 subtractor1:onebitsubtractor port map(x=>x(1),y=>y(1),bin=>c(0),z=>z(1),bout=>c(1));
 subtractor2:onebitsubtractor port map(x=>x(2),y=>y(2),bin=>c(1),z=>z(2),bout=>c(2));
 subtractor3:onebitsubtractor port map(x=>x(3),y=>y(3),bin=>c(2),z=>z(3),bout=>c(3));
 subtractor4:onebitsubtractor port map(x=>x(4),y=>y(4),bin=>c(3),z=>z(4),bout=>c(4));
 subtractor5:onebitsubtractor port map(x=>x(5),y=>y(5),bin=>c(4),z=>z(5),bout=>c(5));
 subtractor6:onebitsubtractor port map(x=>x(6),y=>y(6),bin=>c(5),z=>z(6),bout=>c(6));
 subtractor7:onebitsubtractor port map(x=>x(7),y=>y(7),bin=>c(6),z=>z(7),bout=>c(7));
 subtractor8:onebitsubtractor port map(x=>x(8),y=>y(8),bin=>c(7),z=>z(8),bout=>c(8));
 subtractor9:onebitsubtractor port map(x=>x(9),y=>y(9),bin=>c(8),z=>z(9),bout=>c(9));
 subtractor10:onebitsubtractor port map(x=>x(10),y=>y(10),bin=>c(9),z=>z(10),bout=>c(10));
 subtractor11:onebitsubtractor port map(x=>x(11),y=>y(11),bin=>c(10),z=>z(11),bout=>c(11));
 subtractor12:onebitsubtractor port map(x=>x(12),y=>y(12),bin=>c(11),z=>z(12),bout=>c(12));
 subtractor13:onebitsubtractor port map(x=>x(13),y=>y(13),bin=>c(12),z=>z(13),bout=>c(13));
 subtractor14:onebitsubtractor port map(x=>x(14),y=>y(14),bin=>c(13),z=>z(14),bout=>c(14));
 subtractor15:onebitsubtractor port map(x=>x(15),y=>y(15),bin=>c(14),z=>z(15),bout=>c(15));
end behave;

library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity onebitsubtractor is
port (x,y,bin: in std_logic;
      z,bout:out std_logic);
end entity;
architecture behave of onebitsubtractor is
begin
  z <= (bin xor (x xor y));
  bout <= ((not x) and y) or ((not (x xor y)) and bin);
end behave;

---------------------------------Left Shifter 1(Not required now)--------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity leftshift_1 is
port 
  (din: in std_logic_vector(15 downto 0);
    dout:out std_logic_vector(15 downto 0)
  );
end entity;
architecture behave of leftshift_1 is
begin
  ls_1:process(din) is
  begin
    for i in 15 to 1 loop
      dout(i) <= din(i-1);
    end loop;
    dout(0) <= '0';
  end process ls_1;
end behave;

---------------------------------Left Shifter 7--------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
entity leftshift_7 is
port 
  (din: in std_logic_vector(15 downto 0);
    dout:out std_logic_vector(15 downto 0)
  );
end entity;
architecture behave of leftshift_7 is
begin
  ls_7:process(din) is
  begin
    for i in 15 to 7 loop
      dout(i) <= din(i-7);
    end loop;
    for j in 6 to 0 loop
      dout(j) <= '0';
    end loop;
  end process ls_7;
end behave;

-------------------------sgn6-----------------------
library ieee;
use ieee.std_logic_1164.all;
entity sgn6 is
  port (
    din : in STD_LOGIC_VECTOR(5 downto 0);
    dout : out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity sgn6;
architecture behave of sgn6 is
begin
  extender6: process(din) is
  begin
    for i in 5 to 0 loop
      dout(i) <= din(i);
    end loop;
    for j in 15 to 6 loop
      dout(j) <= '0';
    end loop;
  end process extender6;
end behave;

-------------------------sgn9------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity sgn9 is
  port (
  din : in STD_LOGIC_VECTOR(8 downto 0);
    dout : out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity sgn9;
architecture behave of sgn9 is
begin
  extender9: process(din) is
  begin
    for i in 8 to 0 loop
      dout(i) <= din(i);
    end loop;
    for j in 15 to 9 loop
      dout(j) <= '0';
    end loop;
  end process extender9;
end behave;

-----------------------Priority Encoder--------------------
library ieee;
use ieee.std_logic_1164.all;
entity priority_encoder is
  port (
  din : in STD_LOGIC_VECTOR(7 downto 0);
    dout : out STD_LOGIC_VECTOR(2 downto 0)
    );
end entity priority_encoder;
architecture behave of priority_encoder is
begin
  pri_enc : process (din) is
    begin
        if (din(7)='1') then
            dout <= "111";
        elsif (din(6)='1') then
            dout <= "110";
        elsif (din(5)='1') then
            dout <= "101";
        elsif (din(4)='1') then
            dout <= "100";
        elsif (din(3)='1') then
            dout <= "011";
        elsif (din(2)='1') then
            dout <= "010";
        elsif (din(1)='1') then
            dout <= "001";
        elsif (din(0)='1') then
            dout <= "000";
        else
          dout <= "000";
        end if;
    end process pri_enc;
end behave;

-----------------------Zero Decoder--------------------
library ieee;
use ieee.std_logic_1164.all;
entity zero_decoder is
  port (
  din : in STD_LOGIC_VECTOR(2 downto 0);
    dout : out STD_LOGIC_VECTOR(8 downto 0)
    );
end entity zero_decoder;
architecture behave of zero_decoder is
begin
  zero_dec : process (din) is
    begin
        if (din = "111") then
            dout <= "101111111";
        elsif (din = "110") then
            dout <= "110111111";
        elsif (din = "101") then
            dout <= "111011111";
        elsif (din = "100") then
            dout <= "111101111";
        elsif (din = "011") then
            dout <= "111110111";
        elsif (din = "010") then
            dout <= "111111011";
        elsif (din = "001") then
            dout <= "111111101";
        elsif (din = "000") then
            dout <= "111111110";
        end if;
    end process zero_dec;
end behave;

-----------------------2x1 MUX--------------------------
library ieee;
use ieee.std_logic_1164.all;
entity MUX21 is
  port (d1, d2: in std_logic_vector(15 downto 0);
      s: in std_ulogic;
      dout: out std_logic_vector(15 downto 0)
  );
end entity MUX21;
architecture behave of MUX21 is
begin
  logic_mux21: process(d1, d2, s) is
  begin
    if(s = '0') then
      dout <= d1;
    elsif(s = '1') then
      dout <= d2;
    end if;
  end process logic_mux21;
end behave;

----------------------- 4x1 MUX--------------------------
library ieee;
use ieee.std_logic_1164.all;
entity MUX41 is
  port (d1, d2, d3, d4: in std_logic_vector(15 downto 0);
      s: in std_logic_vector(1 downto 0);
      dout: out std_logic_vector(15 downto 0));
end entity MUX41;
architecture behave of MUX41 is
begin
  logic_mux41:process(d1, d2, d3, d4) is
  begin
    if(s = "00") then
      dout <= d1;
    elsif(s = "01") then
      dout <= d2;
    elsif(s = "10") then
      dout <= d3;
    elsif(s = "11") then
      dout <= d4;
    end if;
  end process logic_mux41;
end behave;

-----------------------Register File--------------------------
library ieee;
use ieee.std_logic_1164.all;
entity register_file is
  port (
    a1, a2, a3: in std_logic_vector(2 downto 0);
    d3: in std_logic_vector(15 downto 0);
    write_enable: in std_logic;
    d1, d2: out std_logic_vector(15 downto 0);
    clk: in std_logic
  );
end entity register_file;
architecture behave of register_file is
  type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
  signal registers : registerFile;
begin
  regFile : process (clk) is
  begin
    if rising_edge(clk) then
      -- Read A and B before bypass
      d1 <= registers(to_integer(unsigned(a1)));
      d2 <= registers(to_integer(unsigned(a2)));
      -- Write and bypass
      if write_enable = '1' then
        registers(to_integer(unsigned(a3))) <= d3;  -- Write
        if a1 = a3 then  -- Bypass for read A
          d1 <= d3;
        end if;
        if a2 = a3 then  -- Bypass for read B
          d2 <= d3;
        end if;
      end if;
    end if;
  end process;
end behave;

----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.datapath_Components.all; 
entity positive_d_latch is
  port (d, clk: in std_ulogic; q: out std_ulogic);
end entity positive_d_latch;
architecture Equations of positive_d_latch is
   signal qsig: std_logic;
begin
   -- q cannot be read.
   qsig    <= (d and clk) or (qsig and (not clk));
   q <= qsig;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
use work.datapath_Components.all; 
entity negative_d_latch is
  port (d, clk: in std_ulogic; q: out std_ulogic);
end entity negative_d_latch;
architecture Equations of negative_d_latch is
   signal qsig: std_logic;
begin
   qsig    <= (d and (not clk)) or (qsig and clk);
   q <= qsig;
end Equations;

library ieee;
use ieee.std_logic_1164.all;
use work.datapath_Components.all; 
entity DFF is
  port (d, clk: in std_ulogic; q: out std_ulogic);
end entity DFF;
architecture Struct of DFF is
   signal U: std_logic;
begin
   master: negative_d_latch
            port map (d => d, clk => clk, q => U);
   slave: positive_d_latch
            port map (d => U, clk => clk, q => q);
end Struct;
