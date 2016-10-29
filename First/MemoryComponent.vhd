library std;
library ieee;
use ieee.std_logic_1164.all;
package MemoryComponent is

type MemArray is array(0 to 127) of std_logic_vector(7 downto 0);

constant INIT_MEMORY : MemArray := (
  0 => "00011110",
  1 => "00010010",
  2 => "00111110",
  3 => "01100000",
  4 => "11101000",
  5 => "00001000",
  6 => "01000010",
  7 => "00000010",
  8 => "10100000",
  9 => "00000110",
  10 => "01011000",
  11 => "00000100",
  12 => "00111110",
  13 => "01110000",
  14 => "11000000",
  15 => "00011101",
  16 => "10011101",
  17 => "01000001",
  18 => "00001000",
  19 => "00000000",
  20 => "10001010",
  21 => "00001101",
  22 => "00001001",
  23 => "00000000",
  24 => "00001010",
  25 => "00100000",
  26 => "10001000",
  27 => "00001101",
  28 => "00001001",
  29 => "00100000",
  30 => "11111111",
  31 => "00110000",
  32 => "10011110",
  33 => "01010001",
  34 => "10001000",
  35 => "00001101",
  36 => "10000010",
  37 => "11000011",
  38 => "00001000",
  39 => "00001011",
  40 => "00000010",
  41 => "10000000",
  42 => "00001000",
  43 => "00001011",
  44 => "10000000",
  45 => "10010001",
  46 => "00000000",
  47 => "00000000",
  48 => "00000000",
  49 => "00000000",
  50 => "00000000",
  51 => "00000000",
  52 => "00000000",
  53 => "00000000",
  54 => "00000000",
  55 => "00000000",
  56 => "00000000",
  57 => "00000000",
  58 => "00000000",
  59 => "00000000",
  60 => "00000000",
  61 => "00000000",
  62 => "00000000",
  63 => "00000000",
  64 => "00000000",
  65 => "00000000",
  66 => "00000000",
  67 => "00000000",
  68 => "00000000",
  69 => "00000000",
  70 => "00000000",
  71 => "00000000",
  72 => "00000000",
  73 => "00000000",
  74 => "00000000",
  75 => "00000000",
  76 => "00000000",
  77 => "00000000",
  78 => "00000000",
  79 => "00000000",
  80 => "00000000",
  81 => "00000000",
  82 => "00000000",
  83 => "00000000",
  84 => "00000000",
  85 => "00000000",
  86 => "00000000",
  87 => "00000000",
  88 => "00000000",
  89 => "00000000",
  90 => "00000000",
  91 => "00000000",
  92 => "00000000",
  93 => "00000000",
  94 => "00000000",
  95 => "00000000",
  96 => "00000000",
  97 => "00000000",
  98 => "00000000",
  99 => "00000000",
  100 => "00000000",
  101 => "00000000",
  102 => "00000000",
  103 => "00000000",
  104 => "00000000",
  105 => "00000000",
  106 => "00000000",
  107 => "00000000",
  108 => "00000000",
  109 => "00000000",
  110 => "00000000",
  111 => "00000000",
  112 => "00000000",
  113 => "00000000",
  114 => "00000000",
  115 => "00000000",
  116 => "00000000",
  117 => "00000000",
  118 => "00000000",
  119 => "00000000",
  120 => "00000000",
  121 => "00000000",
  122 => "00000000",
  123 => "00000000",
  124 => "00000000",
  125 => "00000000",
  126 => "00000000",
  127 => "00000000"
);

end MemoryComponent;
