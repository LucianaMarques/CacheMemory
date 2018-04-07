library IEEE;																												library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;  
use ieee.std_logic_unsigned.all;

entity recTestbenchCacheControl is
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
end recTestbenchCacheControl ;

architecture recTestbenchCacheControl of recTestbenchCacheControl is

-- sinais de conexao

signal 	indice_cache					:	std_logic_vector(tamanho_cache_bits-1 downto 0);
signal	tag_cache_cache					:	std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0);
signal  valid_bit_cache					:	bit;  
signal 	esperando_cache					:	bit;
signal	endereco_bloco_cache			:	std_logic_vector(palavras_bloco_bits-1 downto 0);
signal 	instructionControlCache_cache	:	std_logic_vector(tamanho_instrucao-1 downto 0);
--signal 	instructionCacheControl			:	std_logic_vector(tamanho_instrucao-1 downto 0);
signal	readWriteCache_cache			:	bit;
 
signal  set						: 	bit;
signal	endereco				:	std_logic_vector(tamanho_endereco-1 downto 0):="0010000000110010";
signal	hit_or_miss				:	bit;
signal	instrucao				:	std_logic_vector(tamanho_instrucao-1 downto 0);
signal	indice					:	std_logic_vector(tamanho_cache_bits-1 downto 0);
signal	tag_cache				:	std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
signal	valid_bit				:	bit;
signal	esperando				:	bit;
signal	endereco_bloco			:	std_logic_vector(palavras_bloco_bits-1 downto 0);
signal	instructionCacheControl	:	std_logic_vector(tamanho_instrucao-1 downto 0);
signal	instructionControlCache	:	std_logic_vector(tamanho_instrucao-1 downto 0);
signal	readWriteCache			:	bit;
signal	readWriteMem			:	bit;
signal	enderecoMem				:	std_logic_vector(tamanho_endereco-1 downto 0);
signal	instructionMemControl	:	std_logic_vector(tamanho_instrucao-1 downto 0);
signal	usando 					:	bit;	
signal	tag_calculado 			: 	std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
		

component recControladorMemoria2
	port(						
	set						: 	in bit;
	endereco				:	in std_logic_vector(tamanho_endereco-1 downto 0);
	hit_or_miss				:	out bit;
	instrucao				:	out std_logic_vector(tamanho_instrucao-1 downto 0);
	indice					:	out std_logic_vector(tamanho_cache_bits-1 downto 0);
	tag_cache				:	in std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
	valid_bit				:	in bit;
	esperando				:	out bit;
	endereco_bloco			:	out std_logic_vector(palavras_bloco_bits-1 downto 0);
	instructionCacheControl	:	in std_logic_vector(tamanho_instrucao-1 downto 0);
	instructionControlCache	:	out std_logic_vector(tamanho_instrucao-1 downto 0);
	readWriteCache			:	out bit;
	readWriteMem			:	out bit;
	enderecoMem				:	out std_logic_vector(tamanho_endereco-1 downto 0);
	instructionMemControl	:	in std_logic_vector(tamanho_instrucao-1 downto 0);
	usando 					:	out bit;	
	tag_calculado 			: 	out std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0)
	);
end component; 

component recCacheInstrucao
	port(
	indice					:	in std_logic_vector(tamanho_cache_bits-1 downto 0);
	tag_cache				:	out std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0);
	valid_bit				:	out bit;  
	esperando				:	in bit;
	endereco_bloco			:	in std_logic_vector(palavras_bloco_bits-1 downto 0);
	instructionControlCache	:	in std_logic_vector(tamanho_instrucao-1 downto 0);
	instructionCacheControl	:	out std_logic_vector(tamanho_instrucao-1 downto 0);
	readWriteCache			:	in bit;
	tag_endereco			:	in std_logic_vector(tamanho_endereco - tamanho_cache_bits - palavras_bloco_bits - bits_offset - 1 downto 0)

	);
end component;

component recMemoriaPrincipal
	port(
	ReadWriteMem			: in 	bit; 
	usando 					: in	bit;
	enderecoMem				: in 	std_logic_vector(tamanho_endereco-1 downto 0);
	instructionMemControl	: out	std_logic_vector(tamanho_instrucao-1 downto 0)
	);
end component;

begin
	
	ligaControlador:  recControladorMemoria2 port map (set, endereco, hit_or_miss, instrucao, indice, tag_cache, valid_bit, esperando, 
	endereco_bloco, instructionCacheControl, instructionControlCache, readWriteCache, readWriteMem, enderecoMem, instructionMemControl,
	usando, tag_calculado	
	); 
	
	ligaCache: recCacheInstrucao port map (
	indice, tag_cache, valid_bit, esperando, endereco_bloco, instructionControlCache, instructionCacheControl, readWriteCache, tag_calculado);
	
	ligaMemoriaPrincial: recMemoriaPrincipal port map (
	readWriteMem, usando, enderecoMem, instructionMemControl
	);
	
	process(endereco,esperando)
	begin
		
	end process;
end recTestbenchCacheControl;