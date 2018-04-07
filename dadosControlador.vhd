library IEEE;																											  library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;

entity dadosControlador is
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
end dadosControlador;

architecture dadosControlador of dadosControlador is 
signal estado_usando		: bit := '0';
signal estado_esperando 	: bit := '0';
signal estado_WB	 		: bit := '0';
signal estado_usando1		: bit := '0';
signal estado_esperando1	: bit := '0';
signal estado_WB1 			: bit := '0';
signal tag_in2							: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
signal tag_recebido1, tag_recebido2		: std_logic_vector(tamanho_endereco-tamanho_cache_bits-palavras_bloco_bits-bits_offset-1 downto 0);
signal leituras				: bit := '0';
begin				 
	process(leitura, endereco, dado_in, set, dadoCacheControl, tag1, tag2, valid_bit1, valid_bit2, dirty_bit1, dirty_bit2,
	LRU, dadosBufferControl, enderecoBufferControl, busy, estado_usando, estado_esperando, estado_WB, estado_usando1, estado_esperando1, estado_WB1)
	begin
		if (set'event) then
			indice <= endereco(palavras_bloco_bits + bits_offset + tamanho_cache_bits-1 downto palavras_bloco_bits + bits_offset);	   
			tag_in <= endereco(tamanho_endereco-1 downto tamanho_cache_bits + palavras_bloco_bits + bits_offset); 				 
			tag_in2 <= endereco(tamanho_endereco-1 downto tamanho_cache_bits + palavras_bloco_bits + bits_offset);
			endereco_bloco <= endereco(palavras_bloco_bits+bits_offset-1 downto bits_offset);
			tag_recebido1  <= tag1;
			tag_recebido2  <= tag2;
			estado_esperando <= estado_esperando1;
			estado_usando <= estado_usando1;
			estado_WB <= estado_WB1;
			if (estado_esperando = '1' and estado_WB = '0' and estado_usando = '0') then
				readWriteCache <= '0';
				readWriteMem <= '0';
				if (leitura = '0') then
					if (LRU = '0') then
						if (dirty_bit1 = '0') then
							readWriteCache <= '1';
							dadoControlCache <= dado_in;
						end if;
					else
						if (dirty_bit2 = '0') then
							readWriteCache <= '1';
							dadoControlCache <= dado_in;
						end if;
					end if;
				else
					if (valid_bit1 = '1' and to_integer(unsigned(tag_in2)) = to_integer(unsigned(tag_recebido1))) then
						hit_or_miss <= '1';	-- deu hit
						readWriteCache <= '1';
						dado_out <= dadoCacheControl;
						estado_esperando1 <= '0';
						estado_usando1 <= '0';
						estado_WB <= '0';
					elsif (valid_bit2 = '1' and to_integer(unsigned(tag_in2)) = to_integer(unsigned(tag_recebido2))) then
						hit_or_miss <= '1';	-- deu hit													
						dado_out <= dadoCacheControl;
						readWriteCache <= '1';
						estado_esperando1 <= '0';
						estado_usando1 <= '0';
						estado_WB <= '0';
					else
						hit_or_miss <= '0';
						readWriteCache <= '0';
						readWriteMem <= '0';
						if (LRU = '0') then
							if (dirty_bit1 = '0') then
								estado_esperando1 <= '1';
								estado_WB1 <= '0';		 
								estado_usando1 <= '1';
							elsif (dirty_bit1= '1' and busy = '1') then
									estado_esperando1 <= '1';
									estado_usando1 <= '1';
									estado_WB1 <= '1'; 
			
							elsif (dirty_bit1 = '1' and busy = '0') then
									estado_esperando1 <= '1';
									estado_usando1 <= '1';
									estado_WB1 <= '0';
									enderecoControlBuffer(15 downto 13) <= tag_recebido1;
									enderecoControlBuffer(12 downto 6) <= endereco(palavras_bloco_bits + bits_offset + tamanho_cache_bits-1 downto palavras_bloco_bits + bits_offset);
									enderecoControlBuffer(5 downto 2) <= endereco(palavras_bloco_bits+bits_offset-1 downto bits_offset);
									enderecoControlBuffer(1 downto 0) <= "00";
							end if;
						else
							if (dirty_bit2 = '0') then
								hit_or_miss <= '0';
								readWriteCache <= '0';
								readWriteMem <= '0';
								estado_esperando1 <= '1';
								estado_WB1 <= '0';		 
								estado_usando1 <= '1';
							elsif (dirty_bit2 = '1' and busy = '1') then
									estado_esperando1 <= '1';
									estado_usando1 <= '1';
									estado_WB1 <= '1';
									enderecoControlMem <= enderecoBufferControl;
									dadosControlMem <= dadosBufferControl;
									readWriteMem <= '1';
							elsif (dirty_bit2 = '1' and busy = '0') then
									estado_esperando1 <= '1';
									estado_usando1 <= '1';
									estado_WB1 <= '0';
									enderecoControlBuffer(15 downto 13) <= tag_recebido2;
									enderecoControlBuffer(12 downto 6) <= endereco(palavras_bloco_bits + bits_offset + tamanho_cache_bits-1 downto palavras_bloco_bits + bits_offset);	   
									enderecoControlBuffer(5 downto 2) <= endereco(palavras_bloco_bits+bits_offset-1 downto bits_offset);
									enderecoControlBuffer(1 downto 0) <= "00";
							end if;
						end if;
					end if;
				end if;
			end if;			
			if (estado_esperando = '0' and estado_usando = '0' and estado_WB = '0') then
				if (leitura = '0') then
					readWriteCache <= '0';
					readWriteMem <= '0';
					estado_esperando1 <= '1';
					estado_usando1 <= '0';
					estado_WB1 <= '0';
				else
					readWriteCache <= '0';
					readWriteMem <= '0';
					estado_esperando1 <= '1';
					estado_usando1 <= '0';
					estado_WB1 <= '0';
					dado_out <= dadoCacheControl;
				end if;
			end if;	
			if (estado_esperando = '1' and estado_WB = '0' and estado_usando = '1') then
				enderecoControlMem <= endereco;
				dadoControlCache <= dadosMemControl;
				readWriteCache <= '1';
				estado_esperando1 <= '0';
				estado_WB1 <= '0';
				estado_usando1 <= '1';
			end if;	
			if (estado_esperando = '0' and estado_WB = '0' and estado_usando = '1') then
				estado_esperando1 <= '1';
				estado_usando1 <= '0';
				estado_WB1 <= '0';
			end if;
			if (estado_esperando = '1' and estado_usando = '1' and estado_WB = '1') then 
				estado_esperando1 <= '1';
				estado_usando1 <= '0';
				estado_WB1 <= '0';
			end if;
			if (estado_esperando = '1' and estado_usando = '1' and estado_WB = '0') then
				estado_esperando1 <= '1';
				estado_usando1 <= '0';
				estado_WB1 <= '1';
				dadosControlBuffer <= dadoCacheControl;
			end if;			
				
			esperando <= estado_esperando;
			usando <= estado_usando;
			WB <= estado_WB;
		end if;
	end process;	
end dadosControlador;
	