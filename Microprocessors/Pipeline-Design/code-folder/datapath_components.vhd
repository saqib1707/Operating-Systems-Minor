library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;

package datapath_components is
  component positive_d_latch is
  	port (d, clk: in std_logic; q : out std_logic);
  end component;
  component negative_d_latch is
  	port (d, clk: in std_logic; q : out std_logic);
  end component;
  component dflipflop is
  	port (d, clk: in std_logic; q : out std_logic);
  end component;
  component alu is
    port(X,Y : in std_logic_vector(15 downto 0);
        OPC : in std_logic_vector(3 downto 0);
        Z : out std_logic_vector(15 downto 0);
        --ZERO_TEMP: out std_logic;
        CF, ZF: out std_logic
    );
  end component;
  component leftshift is
    port (din: in std_logic_vector(15 downto 0);
      dout:out std_logic_vector(15 downto 0)
    );
  end component;
  component sgn is
    generic (nbits:integer:=9);
  	port (
	  	din : in STD_LOGIC_VECTOR(nbits-1 downto 0);
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
    generic (nbits: integer:= 16);
	  port (d1, d2: in std_logic_vector(nbits-1 downto 0);
	      s: in std_logic;
	      dout: out std_logic_vector(nbits-1 downto 0)
	  );
  end component;
  component MUX4X1 is
    generic (nbits:integer:=16);
	  port (d1, d2, d3, d4: in std_logic_vector(nbits-1 downto 0);
	      s1, s0: in std_logic;
	      dout: out std_logic_vector(nbits-1 downto 0)
	  );
  end component;
  component register_file is
    port (
	    a1, a2, a3: in std_logic_vector(2 downto 0);
	    d3: in std_logic_vector(15 downto 0);
	    wr_en: in std_logic;
	    d1, d2: out std_logic_vector(15 downto 0);
	    clk,reset: in std_logic
  	);
  end component;
  component asynch_mem is
  	generic (data_width: integer:= 16; addr_width: integer := 16);
	  port(din: in std_logic_vector(data_width-1 downto 0);
	        dout: out std_logic_vector(data_width-1 downto 0);
	        rdbar: in std_logic;
	        wrbar: in std_logic;
			    reset: in std_logic;
	        addrin: in std_logic_vector(addr_width-1 downto 0)
	  );
	end component;
	component dregister is
		generic (nbits : integer := 16);                    -- no. of bits
	  port (
	    din  : in  std_logic_vector(nbits-1 downto 0);
	    dout : out std_logic_vector(nbits-1 downto 0);
	    wr_en: in std_logic;
	    clk     : in std_logic
	  );
	end component;
  component onedregister is
    port (
    din  : in  std_logic;
    dout : out std_logic;
    wr_en: in std_logic;
    clk     : in std_logic);
  end component;
  component xor16 is
    generic (nbits:integer:=16);
    port (x, y: in std_logic_vector(nbits-1 downto 0);
          z:out std_logic);
  end component;
  component sixteenbitadder is
    port (x,y: in std_logic_vector(15 downto 0);
          z:out std_logic_vector(15 downto 0);
          carry_flag: out std_logic
    );
  end component;
  component sixteenbitsubtractor is
    port (x,y: in std_logic_vector(15 downto 0);
          z:out std_logic_vector(15 downto 0)
    );
  end component;
  component and16 is
    generic (nbits: integer:= 16);
    port (x, y: in std_logic_vector(nbits-1 downto 0);
          z:out std_logic_vector(nbits-1 downto 0)
    );
  end component;
end datapath_components;

------------------------------alu------------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity alu is
  port(X,Y : in std_logic_vector(15 downto 0);
        OPC : in std_logic_vector(3 downto 0);
        Z : out std_logic_vector(15 downto 0);
        --ZERO_TEMP:out std_logic;
        CF,ZF: out std_logic
  );
end entity;

architecture behave of alu is 
  signal sig1,sig2,sig3,sig4,sig5 : std_logic_vector(15 downto 0);
  signal carry: std_logic;
  constant zeros: std_logic_vector(15 downto 0) := "0000000000000000";

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

  process(OPC, sig1, sig4, carry) is
    begin
      --if (OPC = "1111" or OPC = "0100" or OPC = "0101") then     -- add without changing CF,ZF
      --  Z <= sig1;
      --  sig5 <= sig1;
      --  CF<='0';
      --  ZF <='0';

      --elsif ((OPC = "0000") or (OPC = "0001")) then  -- adz,adc,add,adi
      --  Z <= sig1;
      --  sig5 <= sig1;
      --  CF <= carry;
      --  if(sig1 = zeros) then
      --    ZF <= '1';
      --  else
      --    ZF <= '0';
      --  end if;

      if (OPC = "0010") then      -- ndz,ndu,ndc
        Z <= sig4;
        sig5 <= sig4;
        CF <='0';
        if (sig4 = zeros) then
          ZF <= '1';
        else
          ZF <= '0';
        end if;

      --elsif (OPC = "1100") then       -- not required for pipeline
      --  Z <= sig2;
      --  sig5 <= sig2;
      --  CF <='0';
      --  ZF <='0';

      --elsif (OPC = "0110" or OPC = "0111") then   -- and16
      --  Z <= sig3;
      --  sig5 <= sig3;
      --  ZF <='0';
      --  CF <='0';
      else 
        Z <= sig1;
        sig5 <= sig1;
        CF <= carry;
        if(sig1 = zeros) then
          ZF <= '1';
        else
          ZF <= '0';
        end if;
      end if;

  end process;
  --ZERO_TEMP<= not (sig5(15) or sig5(14) or sig5(13) or sig5(12) or sig5(11) or sig5(10) or sig5(9) or sig5(8) or sig5(7) or sig5(6)
  --           or sig5(5) or sig5(4) or sig5(3) or sig5(2) or sig5(1) or sig5(0));
end behave;


--------------------xor16---------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity xor16 is
generic (nbits:integer:=16);
port (x, y: in std_logic_vector(nbits-1 downto 0);
      z:out std_logic;
end entity;

architecture behave of nand16 is
  signal s:std_logic_vector(nbits-1 downto 0);
begin
  compute_xor: process(x, y) is
  begin
    for i in nbits-1 downto 0 loop
      s(i) <= (x(i) xor y(i));
    end loop;
    z <= not (s(15) or s(14) or s(13) or s(12) or s(11) or s(10) or s(9) or s(8) or s(7) or s(6) or s(5) or s(4) or s(3) or s(2) or s(1) or s(0));
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
  compute_nand: process(x, y) is
  begin
    for i in 15 downto 0 loop
      z(i) <= (x(i) nand y(i));
    end loop;
  end process;
end behave;

-------------------and16----------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity and16 is
generic (nbits: integer:= 16);
port (x, y: in std_logic_vector(nbits-1 downto 0);
      z:out std_logic_vector(nbits-1 downto 0));
end entity;

architecture behave of and16 is
begin
  compute_and: process(x, y) is
  begin
    for i in nbits-1 downto 0 loop
      z(i) <= (x(i) and y(i));
    end loop;
  end process;
end behave;

-----------------sixteenbitadder------------------------------------
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

-----------------------------onebitadder---------------------------
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

----------------------------sixteenbitsubtractor--------------------------------
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

-----------------------------onebitsubtractor--------------------------------
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

---------------------------------leftshift--------------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity leftshift is
port 
  (din: in std_logic_vector(15 downto 0);
    dout:out std_logic_vector(15 downto 0)
  );
end entity;
architecture behave of leftshift is
begin
  ls:process(din) is
  begin
    for i in 15 downto 7 loop
      dout(i) <= din(i-7);
    end loop;
    for j in 6 downto 0 loop
      dout(j) <= '0';
    end loop;
  end process;
end behave;

-------------------------sgn------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity sgn is
	generic (nbits:integer:=9;flag:integer:=0);   -- flag = 0 => bit extend with zeros and flag = 1 => bit extend with ones
  port (
  	din : in STD_LOGIC_VECTOR(nbits-1 downto 0);
    dout : out STD_LOGIC_VECTOR(15 downto 0)
  );
end entity sgn;
architecture behave of sgn is
begin
  extender: process(din) is
  begin
    for i in (nbits-1) downto 0 loop
      dout(i) <= din(i);
    end loop;
    if flag = '0' then
      for j in 15 downto nbits loop
        dout(j) <= '0';
      end loop;
    else
      for j in 15 downto nbits loop
        dout(j) <= '1';
      end loop;
    end if;
  end process;
end behave;

-----------------------priority_encoder--------------------
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
        if (din(0)='1') then
            dout <= "000";
        elsif (din(1)='1') then
            dout <= "001";
        elsif (din(2)='1') then
            dout <= "010";
        elsif (din(3)='1') then
            dout <= "011";
        elsif (din(4)='1') then
            dout <= "100";
        elsif (din(5)='1') then
            dout <= "101";
        elsif (din(6)='1') then
            dout <= "110";
        elsif (din(7)='1') then
            dout <= "111";
        else
            dout <= "000";
        end if;
    end process;
end behave;

-----------------------zero_decoder--------------------
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
		    else
				    dout <= "000000000";
        end if;
    end process;
end behave;

-----------------------MUX21--------------------------
library ieee;
use ieee.std_logic_1164.all;

entity MUX21 is
	generic (nbits: integer:= 16);
  port (d1, d2: in std_logic_vector(nbits-1 downto 0);
      s: in std_logic;
      dout: out std_logic_vector(nbits-1 downto 0)
  );
end entity MUX21;
architecture behave of MUX21 is
begin
  logic_mux21: process(d1, d2, s) is
  begin
    if(s = '0') then
      dout <= d1;
    else
      dout <= d2;
    end if;
  end process;
end behave;

----------------------- MUX4X1--------------------------
library ieee;
use ieee.std_logic_1164.all;

entity MUX4X1 is
	generic (nbits:integer:=16);
  port (d1, d2, d3, d4: in std_logic_vector(nbits-1 downto 0);
      s1, s0: in std_logic;
      dout: out std_logic_vector(nbits-1 downto 0));
end entity MUX4X1;
architecture behave of MUX4X1 is
begin
  logic_MUX4X1:process(d1, d2, d3, d4, s1, s0) is
  begin
    if(s1 = '0' and s0='0') then
      dout <= d1;
    elsif(s1 = '0' and s0='1') then
      dout <= d2;
    elsif(s1 = '1' and s0='0') then
      dout <= d3;
    else
      dout <= d4;
    end if;
  end process;
end behave;

-----------------------register_file--------------------------
library std;
use std.standard.all;
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity register_file is
  port (
    a1, a2, a3: in std_logic_vector(2 downto 0);
    d3, d4: in std_logic_vector(15 downto 0);
    wr_en, wr_en7: in std_logic;
    d1, d2: out std_logic_vector(15 downto 0);
    clk,reset: in std_logic
  );
end entity register_file;
architecture behave of register_file is
  type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
  signal registers : registerFile;
  function to_integer(x: std_logic_vector) return integer is
      variable xu: unsigned(x'range);
   begin
      for I in x'range loop
         xu(I) := x(I);
      end loop;
      return(To_Integer(xu));
   end to_integer;
	
begin
  regFile : process (clk,reset,wr_en,wr_en7,d3,d4,a1,a2,a3) is
  begin
    if(reset = '1') then
      for i in 7 downto 0 loop
        registers(i)<="0000000000000000";
      end loop;
    elsif (clk'event and clk = '1') then
      -- Write and bypass
      if To_Integer(unsigned(a3)) /= 7 then
        if wr_en = '1' then
          registers(To_Integer(unsigned(a3))) <= d3;  -- Write
        end if;
        if wr_en7 = '1' then
          registers(7) <= d4;    -- d4 is PC+1
        end if;
      else
        if wr_en = '1' and wr_en7 = '1' then
          registers(7) <= d3;
        elsif wr_en = '0' and wr_en7 = '1' then
          registers(7) <= d4;
        elsif wr_en = '1' and wr_en7 = '0' then
          registers(7) <= d3;
        end if;
      end if;
    
      -- Read A and B before bypass
      d1 <= registers(To_Integer(unsigned(a1)));
      d2 <= registers(To_Integer(unsigned(a2)));
    end if;
  end process;
end behave;

-------------------------------asynch_mem--------------------------
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity asynch_mem is
   generic (data_width: integer:= 16; addr_width: integer := 16);
   port(din: in std_logic_vector(data_width-1 downto 0);
        dout: out std_logic_vector(data_width-1 downto 0);
        rdbar: in std_logic;
        wrbar: in std_logic;
		  reset :in std_logic;
        addrin: in std_logic_vector(addr_width-1 downto 0)
  );
end entity;
architecture behave of asynch_mem is
   type MemArray is array(natural range <>) of std_logic_vector(data_width-1 downto 0);
   signal marray: MemArray(0 to ((2**(addr_width-12))-1));--:=(0=>"0001100000000100",1=>"0001011000000101",2=>"0001010000000011",others=>"0000000000000000");

   function To_Integer(x: std_logic_vector) return integer is
      variable xu: unsigned(x'range);
   begin
      for I in x'range loop
         xu(I) := x(I);
      end loop;
      return(To_Integer(xu));
   end To_Integer;
begin
   -- there is only one state..
   process(rdbar, wrbar, din, addrin,reset) is
      --variable addr_var: integer range 0 to ((2**(addr_width-12))-1);
   begin
		if (reset = '1') then
			marray<= (0=>"0001100000000011",1=>"0001011000000101",2=>"0001010000000011",3=>"0000101101011000",4=>"0001001001000001",5=>"1100010001000111",6=>"1001110100000000",7=>"0101101000000000",others=>"0000000000000000");
		end if;
      --addr_var := To_Integer(addrin);
      if(rdbar = '0') then
        dout <= marray(To_Integer(addrin));
      end if;
      if(wrbar = '0') then
        marray(To_Integer(addrin)) <= din;
      end if;     
   end process;
end behave;

-------------------dregister---------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity dregister is
  generic (
    nbits : integer := 16);                    -- no. of bits
  port (
    din  : in  std_logic_vector(nbits-1 downto 0);
    dout : out std_logic_vector(nbits-1 downto 0);
    wr_en: in std_logic;
    clk     : in std_logic);
end dregister;

architecture behave of dregister is
begin
process(clk,din,wr_en)
begin 
  if(clk'event and clk = '1') then
    if wr_en = '1' then
      dout <= din;
    end if;
  end if;
end process;
end behave;

-------------------onedregister---------------------
library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;

entity onedregister is
  port (
    din  : in  std_logic;
    dout : out std_logic;
    wr_en: in std_logic;
    clk     : in std_logic);
end onedregister;

architecture behave of onedregister is
begin
process(clk,din,wr_en)
begin 
  if(clk'event and clk = '1') then
    if wr_en = '1' then
      dout <= din;
    end if;
  end if;
end process;
end behave;

-------------------------positive_d_latch--------------------------
library ieee;
use ieee.std_logic_1164.all;
 
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

---------------------------negative_d_latch---------------------
library ieee;
use ieee.std_logic_1164.all;
 
entity negative_d_latch is
  port (d, clk: in std_ulogic; q: out std_ulogic);
end entity negative_d_latch;
architecture Equations of negative_d_latch is
   signal qsig: std_logic;
begin
   qsig    <= (d and (not clk)) or (qsig and clk);
   q <= qsig;
end Equations;

---------------------------dflipflop----------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity dflipflop is
  port (d, clk: in std_ulogic; q: out std_ulogic);
end entity dflipflop;
architecture Struct of dflipflop is
   signal U: std_logic;
	component positive_d_latch is
		 port (d, clk: in std_ulogic; q: out std_ulogic);
	end component;
	component negative_d_latch is
		port (d, clk: in std_ulogic; q: out std_ulogic);
	end component;
begin
   master: negative_d_latch
            port map (d => d, clk => clk, q => U);
   slave: positive_d_latch
            port map (d => U, clk => clk, q => q);
end Struct;