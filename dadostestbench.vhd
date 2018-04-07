library IEEE;																											  library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity testbenchdados is
	generic(
	tamanho_instrucao	:	integer	:=32;
	tamanho_endereco	:	integer	:=16;
	tamanho_cache_bits	:	integer	:=7;
	palavras_bloco_bits	:	integer	:=4;
	bits_offset			:	integer	:=2;
	Tcache				:	time	:=5 ns;
	Tmem				:	time	:=100ns
	);
end testbenchdados;

architecture testbenchdados of testbenchdados is

signal leitura					: bit;
signal endereco					: std_logic_vector(tamanho_endereco-1 downto 0);
signal dado_in					: std_logic_vector(tamanho_instrucao-1 downto 0);
signal set						: bit;
signal hit_or_miss				: bit;
signal dado_out					: std_logic_vector(tamanho_instrucao-1 downto 0);
signal readWriteCache			: bit;
signal esperando				: bit;
signal indice				 	: std_logic_vector(tamanho_cache_bits-1 downto 0);
signal tag_in					: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
signal endereco_bloco			: std_logic_vector(palavras_bloco_bits-1 downto 0);
signal dadoCacheControl			: std_logic_vector(tamanho_instrucao-1 downto 0); 
signal dadoControlCache			: std_logic_vector(tamanho_instrucao-1 downto 0);
signal tag1, tag2				: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
signal valid_bit1, valid_bit2	: bit;
signal dirty_bit1, dirty_bit2	: bit;
signal LRU						: bit;
signal dadosBufferControl		: std_logic_vector(tamanho_instrucao-1 downto 0);
signal enderecoBufferControl	: std_logic_vector(tamanho_endereco-1 downto 0);
signal enderecoControlBuffer	: std_logic_vector(tamanho_endereco-1 downto 0);
signal dadosControlBuffer		: std_logic_vector(tamanho_instrucao-1 downto 0);
signal busy						: bit;
signal WB						: bit;
signal usando					: bit;
signal readWriteMem				: bit;
signal enderecoControlMem		: std_logic_vector(tamanho_endereco-1 downto 0);
signal dadosControlMem			: std_logic_vector(tamanho_instrucao-1 downto 0);
signal dadosMemControl			: std_logic_vector(tamanho_instrucao-1 downto 0);

component dadosControlador
	port(
	leitura					: in bit;
	endereco				: in std_logic_vector(tamanho_endereco-1 downto 0);
	dado_in					: in std_logic_vector(tamanho_instrucao-1 downto 0);
	set						: in bit;
	hit_or_miss				: out bit;
	dado_out				: out std_logic_vector(tamanho_instrucao-1 downto 0);
	readWriteCache			: out bit;
	esperando				: out bit;
	indice				 	: out std_logic_vector(tamanho_cache_bits-1 downto 0);
	tag_in					: out std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
	endereco_bloco			: out std_logic_vector(palavras_bloco_bits-1 downto 0);
	dadoCacheControl		: in std_logic_vector(tamanho_instrucao-1 downto 0); 
	dadoControlCache		: out std_logic_vector(tamanho_instrucao-1 downto 0);
	tag1, tag2				: in std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
	valid_bit1, valid_bit2	: in bit;
	dirty_bit1, dirty_bit2	: in bit;
	LRU						: in bit;
	dadosBufferControl		: in std_logic_vector(tamanho_instrucao-1 downto 0);
	enderecoBufferControl	: in std_logic_vector(tamanho_endereco-1 downto 0);
	enderecoControlBuffer	: out std_logic_vector(tamanho_endereco-1 downto 0);
	dadosControlBuffer		: out std_logic_vector(tamanho_instrucao-1 downto 0);
	busy					: in bit;
	WB						: out bit;
	usando					: out bit;
	readWriteMem			: out bit;
	enderecoControlMem		: out std_logic_vector(tamanho_endereco-1 downto 0);
	dadosControlMem			: out std_logic_vector(tamanho_instrucao-1 downto 0);
	dadosMemControl			: in std_logic_vector(tamanho_instrucao-1 downto 0)
	);
end component; 

component dadosMemPrincipal 
	port(
	usando				: in bit;
	readWriteMem		: in bit;
	enderecoControlMem	: in std_logic_vector(tamanho_endereco-1 downto 0);
	dadosControlMem		: in std_logic_vector(tamanho_instrucao-1 downto 0);
	dadosMemControl		: out std_logic_vector(tamanho_instrucao-1 downto 0)
	);
end component;

component dadosWriteBuffer
	port(
	dadosBufferControl		: out std_logic_vector(tamanho_instrucao-1 downto 0);
	enderecoBufferControl	: out std_logic_vector(tamanho_endereco-1 downto 0);
	enderecoControlBuffer	: in std_logic_vector(tamanho_endereco-1 downto 0);
	dadosControlBuffer		: in std_logic_vector(tamanho_instrucao-1 downto 0);
	busy					: out bit;
	WB						: in bit;
	set						: in bit
	);								
end component;

component dadosCache
	port(
	readWriteCache			: in bit;
	esperando				: in bit;
	indice				 	: in std_logic_vector(tamanho_cache_bits-1 downto 0);
	tag_in					: in std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
	endereco_bloco			: in std_logic_vector(palavras_bloco_bits-1 downto 0);
	dadoControlCache		: in std_logic_vector(tamanho_instrucao-1 downto 0);
	dadoCacheControl		: out std_logic_vector(tamanho_instrucao-1 downto 0);
	tag1, tag2				: out std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
	valid_bit1, valid_bit2	: out bit;
	dirty_bit1, dirty_bit2	: out bit;
	LRU						: out bit;
	set						: in bit
	);
end component;

begin
	ligaControlador: dadosControlador port map (leitura,endereco,dado_in,set,hit_or_miss,dado_out,readWriteCache,
	esperando,indice,tag_in,endereco_bloco,dadoCacheControl,dadoControlCache,tag1, tag2,valid_bit1, valid_bit2,
	dirty_bit1, dirty_bit2,LRU,dadosBufferControl,enderecoBufferControl,enderecoControlBuffer,dadosControlBuffer,
	busy,WB,usando,readWriteMem,enderecoControlMem,dadosControlMem,dadosMemControl);
	
	ligaMemoria: dadosMemPrincipal port map (usando,readWriteMem,enderecoControlMem,dadosControlMem,dadosMemControl); 
	
	ligaWriteBuffer: dadosWriteBuffer port map (dadosBufferControl,enderecoBufferControl,enderecoControlBuffer,
	dadosControlBuffer,busy,WB,set);
	
	ligaCache: dadosCache port map (readWriteCache,esperando,indice,tag_in,endereco_bloco,dadoControlCache,
	dadoCacheControl,tag1, tag2,valid_bit1, valid_bit2,dirty_bit1, dirty_bit2,LRU,set);	
	
	process (set)
	begin
	end process;
	
end testbenchdados;