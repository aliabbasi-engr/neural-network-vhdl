library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

use work.NN_Package.ALL;

entity NN_Layer is
	
	generic (
		neuron_count : integer := 8; -- Neurons count in the layer
		neuron_input_count : integer := 4; -- Inputs count for each neuron
		neuron_input_length : integer := 8; -- Neurons input length
		neuron_weight_length : integer := 8); -- Neurons weight length
	
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_weight : in signed (neuron_input_length-1 downto 0);
		i_we : in std_logic; -- Write enable for weights serial input
		i_layer_data : in inputVectorlength (0 to neuron_count * neuron_input_count - 1);
		o_layerResult : out outputVectorlength (0 to neuron_count - 1));

end NN_Layer;

Architecture behavioral of NN_Layer is
	 
	type t_buffered_weights is array (0 to neuron_count * neuron_input_count - 1) of signed(neuron_weight_length - 1 downto 0);
	signal r_buffered_weights : t_buffered_weights := (others => (others => '0'));
	signal r_neuron_pointer : integer range 0 to neuron_count * neuron_input_count - 1 := 0;
	
begin
	
	------------------------------------------
	---- Buffering weights into registers ----
	------------------------------------------
	p_buffering : process (i_clk)
	begin
	
		if (falling_edge(i_clk)) then

			if (i_rst = '1') then

				r_buffered_weights <= (others => (others => '0'));
				r_neuron_pointer <= 0;

			elsif (i_we = '1') then

				r_buffered_weights(r_neuron_pointer) <= signed(i_weight);
				
				if (r_neuron_pointer < neuron_count * neuron_input_count - 1) then
					r_neuron_pointer <= r_neuron_pointer + 1;
				else
					r_neuron_pointer <= 0;
				end if;
			
			end if;
			
		end if;
	end process p_buffering;
	
	----------------------
	---- Main process ----
	----------------------
	p_mult : process (i_clk, i_layer_data, i_weight)
	
		variable r_product : signed (neuron_input_length + neuron_weight_length - 1 downto 0);
		variable r_accumulator : signed (neuron_input_length + neuron_weight_length - 1 downto 0);
		variable r_sign : std_logic;
		
	begin

		r_accumulator := (others => '0');

		L0: for i in 0 to neuron_count - 1 loop -- 0 to 2

			L1: for j in 0 to neuron_input_count - 1 loop -- 0 to 1
			
				r_product := i_layer_data(i * neuron_input_count + j) * r_buffered_weights(i * neuron_input_count + j);
				r_sign := r_accumulator(r_accumulator'left);
				r_accumulator := r_accumulator + r_product;
				
				-- Check Overflow --
				if (r_sign = r_product(r_product'left) and r_accumulator(r_accumulator'left) /= r_sign) then  
					r_accumulator := (r_accumulator'left => r_sign, others => not r_sign);
				end if;
			
			end loop L1;
			
			o_layerResult(i) <= r_accumulator;
			r_accumulator := (others => '0');
		
		end loop L0;

	end process p_mult;
	
end behavioral;