library IEEE;																											  library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity dadosMemPrincipal is
	generic(
	tamanho_instrucao	:	integer	:=32;
	tamanho_endereco	:	integer	:=16;
	tamanho_cache_bits	:	integer	:=7;
	palavras_bloco_bits	:	integer	:=4;
	bits_offset			:	integer	:=2;
	Tcache				:	time	:=5 ns;
	Tmem				:	time	:=100ns
	);
	port(
	usando				: in bit;
	readWriteMem		: in bit;
	enderecoControlMem	: in std_logic_vector(tamanho_endereco-1 downto 0);
	dadosControlMem		: in std_logic_vector(tamanho_instrucao-1 downto 0);
	dadosMemControl		: out std_logic_vector(tamanho_instrucao-1 downto 0)
	);
end dadosMemPrincipal;

architecture dadosMemPrincipal of dadosMemPrincipal is
type tipo_memoria_principal is array (0 to (2**tamanho_endereco-2)-1) of std_logic_vector(tamanho_instrucao-1 downto 0);
signal MemoriaPrincipal : tipo_memoria_principal :=  (8242 => "00110011001100110011001100110011", others => (others => '0'));
begin
	process (usando, readWriteMem, enderecoControlMem, dadosControlMem) 
	begin
		if (usando = '1') then
			if (readWriteMem = '0') then -- leitura
				dadosMemControl <= MemoriaPrincipal(to_integer(unsigned(enderecoControlMem))) after Tmem;
			else
				MemoriaPrincipal(to_integer(unsigned(enderecoControlMem))) <= dadosControlMem after Tmem;
			end if;
		end if;
	end process;
end dadosMemPrincipal;
	