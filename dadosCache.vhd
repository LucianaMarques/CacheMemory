library IEEE;																											  library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity dadosCache is
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
end dadosCache;

architecture dadosCache of dadosCache is
type tag is array (2**tamanho_cache_bits-1 downto 0) of std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
signal tag1Array	: tag := (others => (others => '0'));
signal tag2Array : tag := (others => (others => '0'));

type valid_bit is array (2**tamanho_cache_bits-1 downto 0) of bit;
signal valid_bit1Array : valid_bit := (others => '0');
signal valid_bit2Array : valid_bit := (others => '0');

signal dirty_bit1Array : valid_bit := (others => '0');
signal dirty_bit2Array : valid_bit := (others => '0'); 
signal last_r_usedArray : valid_bit := (others => '0');

type tipo_memoria  is array (0 to 2**tamanho_cache_bits-1) of std_logic_vector((2**palavras_bloco_bits)*(2**tamanho_cache_bits)-1 downto 0);
signal bloco1: tipo_memoria := (others => (others => '0'));
signal bloco2: tipo_memoria := (others => (others => '0'));

begin
	process(readWriteCache, esperando, indice, tag_in, endereco_bloco) 
	begin
			tag1 <= tag1Array(to_integer(unsigned(indice))); 
			tag2 <= tag2Array(to_integer(unsigned(indice)));
			valid_bit1 <= valid_bit1Array(to_integer(unsigned(indice)));
			--valid_bit1 <='1';
			valid_bit2 <= valid_bit2Array(to_integer(unsigned(indice)));
			LRU <= last_r_usedArray(to_integer(unsigned(indice)));
			dirty_bit1 <= dirty_bit1Array(to_integer(unsigned(indice)));
			dirty_bit2 <= dirty_bit2Array(to_integer(unsigned(indice)));
			if (readWriteCache = '1') then
				if (last_r_usedArray(to_integer(unsigned(indice))) = '0') then
					bloco1(to_integer(unsigned(indice)))(tamanho_instrucao*to_integer(unsigned(endereco_bloco))+31 downto tamanho_instrucao*to_integer(unsigned(endereco_bloco))) <= dadoControlCache after Tcache;
					tag1Array(to_integer(unsigned(indice))) <= tag_in;
					last_r_usedArray(to_integer(unsigned(indice))) <= '1';
					if (valid_bit1Array(to_integer(unsigned(indice))) = '0') then
						valid_bit1Array(to_integer(unsigned(indice))) <= '1';
					end if;
					if (esperando = '1') then
						dirty_bit1Array(to_integer(unsigned(indice))) <= '1';
					else 
						dirty_bit1Array(to_integer(unsigned(indice))) <= '0';
					end if;
				else
					bloco2(to_integer(unsigned(indice)))(tamanho_instrucao*to_integer(unsigned(endereco_bloco))+31 downto tamanho_instrucao*to_integer(unsigned(endereco_bloco))) <= dadoControlCache after Tcache;
					tag1Array(to_integer(unsigned(indice))) <= tag_in;
					last_r_usedArray(to_integer(unsigned(indice))) <= '0';								
					if (valid_bit2Array(to_integer(unsigned(indice))) = '0') then
						valid_bit2Array(to_integer(unsigned(indice))) <= '1';
					end if;
					if (esperando = '1') then
						dirty_bit2Array(to_integer(unsigned(indice))) <= '1';
					else 
						dirty_bit2Array(to_integer(unsigned(indice))) <= '0';
					end if;
				end if;
			else
				if (esperando = '1') then
					tag1 <= tag1Array(to_integer(unsigned(indice))); 
					tag2 <= tag2Array(to_integer(unsigned(indice)));
					valid_bit1 <= valid_bit1Array(to_integer(unsigned(indice)));
					--valid_bit1 <='1';
					valid_bit2 <= valid_bit2Array(to_integer(unsigned(indice)));
					LRU <= last_r_usedArray(to_integer(unsigned(indice)));
					dirty_bit1 <= dirty_bit1Array(to_integer(unsigned(indice)));
					dirty_bit2 <= dirty_bit2Array(to_integer(unsigned(indice)));
				else
					if (last_r_usedArray(to_integer(unsigned(indice))) = '0') then
						dadoCacheControl <= bloco1(to_integer(unsigned(indice)))(tamanho_instrucao*to_integer(unsigned(endereco_bloco))+31 downto tamanho_instrucao*to_integer(unsigned(endereco_bloco))) after Tcache;
						last_r_usedArray(to_integer(unsigned(indice))) <= '1';
					else
						dadoCacheControl <= bloco2(to_integer(unsigned(indice)))(tamanho_instrucao*to_integer(unsigned(endereco_bloco))+31 downto tamanho_instrucao*to_integer(unsigned(endereco_bloco))) after Tcache;
						last_r_usedArray(to_integer(unsigned(indice))) <= '0';
					end if;
				end if;
			end if;
		
	end process;
				
end dadosCache;