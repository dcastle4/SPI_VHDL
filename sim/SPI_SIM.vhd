library ieee;
use ieee.std_logic_1164.all;


entity SPI_SIM is
end SPI_SIM;

architecture RTL_SIM of SPI_SIM is
    signal internalClock: std_logic := '1';
    signal internalReset: std_logic := '0';
    signal internalEnable: std_logic;
    signal internalData: std_logic_vector(23 downto 0) := X"AAAAAA";
    signal internalSS: std_logic;
    signal internalSCK: std_logic;
    signal internalMOSI: std_logic;
    signal internalFinish: std_logic;
begin
    
    internalClock <= not internalClock after 6.25 ns; --for 80MHz -> divided to 40MHz for serial clock
    
    ENABLE_TEST: process is
    begin
        internalEnable <= '0'; -- start low to show that transaction won't start
        wait for 10 ns; -- wait at low for a bit
        internalEnable <= '1'; -- go high to start transaction
        wait until internalFinish = '1'; -- wait until finish signal while sending all data
        internalData <= X"FFFFFF"; -- change data
        wait until internalFinish = '1'; -- wait until finish signal while sending all data
        internalData <= X"FDFDFD"; -- change data
        wait until internalFinish = '1'; -- wait until finish signal while sending all data
        internalEnable <= '0'; -- stop transaction        
        wait for 10 ms; -- wait for a long time (10ms)
    end process ENABLE_TEST;
    
    
    MY_SPI_MASTER: entity work.SPI_MASTER port map 
    (
            clock => internalClock,
            reset => internalReset,
            txEnable =>  internalEnable,
            data => internalData,
            ss_out => internalSS,
            sck_out => internalSCK,
            MOSI => internalMOSI,
            wordFinished => internalFinish   
    );

end RTL_SIM;
