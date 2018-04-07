library IEEE;																												library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity recTestbenchMemoria is
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
	set_test			:	in bit;
	endereco_test		: 	in std_logic_vector(tamanho_endereco-1 downto 0);
	hit_or_miss_test	:	out bit;
	instrucao_test		:	out std_logic_vector(tamanho_instrucao-1 downto 0);
	tag					:	out std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0)
	);	
end recTestbenchMemoria;

architecture recTestbenchMemoria of recTestbenchMemoria is	
signal 	set						: bit :=set_test;
signal	endereco				: std_logic_vector(tamanho_endereco-1 downto 0):=endereco_test;
signal	hit_or_miss				: bit;
signal 	instrucao				: std_logic_vector(tamanho_instrucao-1 downto 0); 
signal 	indice					: std_logic_vector(tamanho_cache_bits-1 downto 0);												
signal 	tag_cache_control		: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);	
signal 	tag_cache				: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
signal 	valid_bit				: bit;	 
signal 	esperando				: bit;
signal 	endereco_bloco			: std_logic_vector(palavras_bloco_bits-1 downto 0);
signal 	instructionCacheControl	: std_logic_vector(tamanho_instrucao-1 downto 0);
signal 	instructionControlCache	: std_logic_vector(tamanho_instrucao-1 downto 0);
signal 	readWriteCache			: bit;
signal 	readWriteMem			: bit;
signal 	enderecoMem				: std_logic_vector(tamanho_endereco-1 downto 0);
signal 	instructionMemControl	: std_logic_vector(tamanho_instrucao-1 downto 0);
signal  usando 					: bit;
signal 	tag_calculado 			: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);

component recControladorMemoria
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
	instructionCacheContol	:	out std_logic_vector(tamanho_instrucao-1 downto 0);
	readWriteCache			:	in bit
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
	ligaControlador: recControladorMemoria port map(
	set => set_test, endereco => endereco, hit_or_miss => hit_or_miss, instrucao => instrucao, 
	indice => indice, tag_cache	=> tag_cache_control, valid_bit => valid_bit, esperando => esperando,
	endereco_bloco => endereco_bloco, instructionCacheControl => instructionCacheControl, 
	instructionControlCache => instructionControlCache, readWriteCache => readWriteCache,
	readWriteMem => readWriteMem, enderecoMem => enderecoMem, instructionMemControl => instructionMemControl, 
	usando => usando, tag_calculado => tag_calculado
	); 
	
	ligaCacheInstrucao: recCacheInstrucao port map ( 
	indice => indice, tag_cache => tag_cache, valid_bit => valid_bit, esperando => esperando, 
	endereco_bloco => endereco_bloco, instructionControlCache => instructionControlCache, 
	instructionCacheContol => instructionCacheControl, readWriteCache => readWriteCache
	);
	
	ligaMemoriaPrincial: recMemoriaPrincipal port map (
	ReadWriteMem => ReadWriteMem, enderecoMem => enderecoMem, instructionMemControl => instructionMemControl, 
	usando => usando
	);	
	
	process(set)
	begin
		tag_cache_control <= tag_cache;
	end process;		
	
end recTestbenchMemoria;