library IEEE;																												library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;  
use ieee.std_logic_unsigned.all;

entity recTestbenchCache is
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
	esperando_in 		:	in bit;
	endereco_in 		:	in std_logic_vector(tamanho_endereco-1 downto 0)
	);
end recTestbenchCache ;

architecture recTestbenchCache of recTestbenchCache is
signal indice					:	std_logic_vector(tamanho_cache_bits-1 downto 0):="10000000";
signal tag_cache				:	std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0);
signal valid_bit				:	bit;
signal endereco_bloco			:	std_logic_vector(palavras_bloco_bits-1 downto 0):="1100";
signal instructionControlCache	:	std_logic_vector(tamanho_instrucao-1 downto 0);
signal instructionCacheContol	:	std_logic_vector(tamanho_instrucao-1 downto 0);
signal esperando				:	bit:='1';
signal endereco					:	std_logic_vector(tamanho_endereco-1 downto 0):="0010000000110010";
signal readWriteCache			:	bit:='0';

component recCacheInstrucao
	port(
	indice					:	in std_logic_vector(tamanho_cache_bits-1 downto 0);
	tag_cache				:	out std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0);
	valid_bit				:	out bit;  
	esperando				:	in bit;
	endereco_bloco			:	in std_logic_vector(palavras_bloco_bits-1 downto 0);
	instructionControlCache	:	in std_logic_vector(tamanho_instrucao-1 downto 0);
	instructionCacheContol	:	out std_logic_vector(tamanho_instrucao-1 downto 0);
	readWriteCache			:	in bit
	);
end component;	

begin
	ligaCacheInstrucao: recCacheInstrucao port map ( 
	indice => indice, tag_cache => tag_cache, valid_bit => valid_bit, esperando => esperando, 
	endereco_bloco => endereco_bloco, instructionControlCache => instructionControlCache, 
	instructionCacheContol => instructionCacheContol, readWriteCache => readWriteCache
	); 
	
	process(endereco,esperando)
	begin
		esperando <= '0';
		endereco <= "0010000000110010";
		indice <= "10000000";
		readWriteCache <= '0';
	end process;
end recTestbenchCache;