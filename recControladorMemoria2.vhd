library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity recControladorMemoria2 is
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
end recControladorMemoria2;

architecture recControladorMemoria2 of recControladorMemoria2 is
signal tag_calculado2 	: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0); 
signal tag_recebido		: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);		
signal instrucao_mem	: std_logic_vector(tamanho_instrucao-1 downto 0); 
signal estado_esperando : bit:='0';
signal estado_usando	: bit:='0';
signal estado_esperando1 : bit:='0';
signal estado_usando1	: bit:='0';
signal valid_bit_s		: bit;
begin
	process(set, tag_cache, instructionMemControl)
	begin
		if (set'event) then
			indice <= endereco(palavras_bloco_bits + bits_offset + tamanho_cache_bits-1 downto palavras_bloco_bits + bits_offset);	   
			tag_calculado <= endereco(tamanho_endereco-1 downto tamanho_cache_bits + palavras_bloco_bits + bits_offset); 				 
			tag_calculado2 <= endereco(tamanho_endereco-1 downto tamanho_cache_bits + palavras_bloco_bits + bits_offset);
			endereco_bloco <= endereco(palavras_bloco_bits+bits_offset-1 downto bits_offset);
			tag_recebido  <= tag_cache;
			estado_esperando <= estado_esperando1;
			estado_usando <= estado_usando1;
			if (estado_esperando = '1' and estado_usando = '0') then
				if (valid_bit = '1' and to_integer(unsigned(tag_calculado2)) = to_integer(unsigned(tag_recebido))) then
					hit_or_miss <= '1';	-- deu hit													
					instrucao <= instructionCacheControl;
				else
					hit_or_miss <= '0';	-- deu miss
					estado_usando1 <= '1';
					usando <= '1'; 
				end if;						 
			end if;							 
			if (estado_esperando = '0' and estado_usando = '1') then
				estado_esperando1 <= '1';
				estado_usando1 <= '0';
				readWriteCache <= '0';
			end if;
			if (estado_esperando = '1' and estado_usando = '1') then
				enderecoMem <= endereco;
				instructionControlCache <= instructionMemControl;
				readWriteCache <= '1';
				estado_esperando1 <= '0';
				estado_usando1 <= '1';						 
			end if;
			if (estado_esperando = '0' and estado_usando = '0') then
				readWriteCache <= '0';
				readWriteMem <= '0';
				estado_esperando1 <= '1';
				estado_usando1 <= '0';
			end if;	  
			esperando <= estado_esperando;
			usando <= estado_usando;
		end if;
	end process;
end recControladorMemoria2;