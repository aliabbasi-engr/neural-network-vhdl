library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

package NN_Package is
	constant bitCount : INTEGER := 8;
	type inputVectorlength is array (natural range <>) of signed (bitCount - 1 downto 0);
	type outputVectorlength is array (natural range <>) of signed (2 * bitCount-1 downto 0);
end NN_Package;
	