library IEEE;																											  library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity dadosWriteBuffer is
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
	dadosBufferControl		: out std_logic_vector(tamanho_instrucao-1 downto 0);
	enderecoBufferControl	: out std_logic_vector(tamanho_endereco-1 downto 0);
	enderecoControlBuffer	: in std_logic_vector(tamanho_endereco-1 downto 0);
	dadosControlBuffer		: in std_logic_vector(tamanho_instrucao-1 downto 0);
	busy					: out bit;
	WB						: in bit;
	set						: in bit
	);								
end dadosWriteBuffer;

architecture dadosWriteBuffer of dadosWriteBuffer is
signal endereco_buffer	: std_logic_vector(tamanho_endereco-1 downto 0)	:= (others => '0');
signal Buf				: std_logic_vector(tamanho_instrucao-1 downto 0):= (others => '0');
signal bufBusy			: bit :='0';
begin
	process(WB, enderecoControlBuffer,dadosControlBuffer, set, WB)
	begin
		if (set'event and WB = '1') then
			if (bufBusy = '1') then
				dadosBufferControl <= Buf;
				enderecoBufferControl <= endereco_buffer;
				bufBusy <= '0';
				busy <= '0';
			else
				endereco_buffer <= enderecoControlBuffer;
				Buf <= dadosControlBuffer;
				bufBusy <= '1';
				busy <= '1';
			end if;
		end if;
	end process;
end dadosWriteBuffer;                                                                                                                                                                                                                                                                                                                                                                                                                                                          
			