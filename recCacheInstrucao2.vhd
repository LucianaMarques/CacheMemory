library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity recCacheInstrucao2 is
	generic(
	tamanho_instrucao	:	integer	:=32;
	tamanho_endereco	:	integer	:=16;
	tamanho_cache_bits	:	integer	:=8;
	palavras_bloco_bits	:	integer	:=4;
	bits_offset			:	integer	:=2;
	Tcache				:	time	:=5 ns;
	Tmem				:	time	:=100ns
	);
	port(
	indice					:	in std_logic_vector(tamanho_cache_bits-1 downto 0);
	tag_cache				:	out std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0);
	valid_bit				:	out bit;  
	esperando				:	in bit;
	endereco_bloco			:	in std_logic_vector(palavras_bloco_bits-1 downto 0);
	instructionControlCache	:	in std_logic_vector(tamanho_instrucao-1 downto 0);
	instructionCacheContol	:	out std_logic_vector(tamanho_instrucao-1 downto 0);
	readWriteCache			:	in bit;
	tag_endereco			:	in std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0)
	);
end recCacheInstrucao2;

architecture recCacheInstrucao2 of recCacheInstrucao2 is	 
type tipo_memoria  is array (0 to 2**tamanho_cache_bits-1) of std_logic_vector((2**palavras_bloco_bits)*(2**tamanho_cache_bits)-1 downto 0);
signal cacheInst: tipo_memoria := (others => (others => '0')); 	

type tipo_tag is array (0 to 2**tamanho_cache_bits-1) of std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0);
signal TagArray: tipo_tag	:=	(others => (others => '0')); 

type tipo_valid_bit is array (0 to 2**tamanho_cache_bits-1) of bit;
signal ValidBitArray : tipo_valid_bit :=  (others => '0');	

signal instructionCacheContol2	:	std_logic_vector(tamanho_instrucao-1 downto 0);

begin
	process (readWriteCache, tag_endereco)
	begin
		if (readWriteCache = '0') then
			if (esperando = '1') then
				tag_cache <= TagArray(to_integer(unsigned(indice)));
				--valid_bit <= ValidBitArray(to_integer(unsigned(indice)));
				valid_bit <= '1';
			else
				instructionCacheContol <= cacheInst(to_integer(unsigned(indice)))(tamanho_instrucao*to_integer(unsigned(endereco_bloco))+31 downto tamanho_instrucao*to_integer(unsigned(endereco_bloco))) after Tcache;
				
			end if;
		else -- escreve no cache
			if (ValidBitArray(to_integer(unsigned(indice))) = '0') then
				ValidBitArray(to_integer(unsigned(indice))) <= '1';
			end if;						 
			TagArray(to_integer(unsigned(indice))) <= tag_endereco;
			cacheInst(to_integer(unsigned(indice)))(tamanho_instrucao*to_integer(unsigned(endereco_bloco))+31 downto tamanho_instrucao*to_integer(unsigned(endereco_bloco))) <= instructionControlCache after Tcache;			
		end if;
	end process;
end recCacheInstrucao2;