--*********************************************************************
--*
--* Name: SPI_MASTER
--* Designer: Daniel Castle (with guidance and help from Prof. Tippens)

--* Description: This SPI Master module sends out 24 bits of data 
--*              through the MOSI line. It utilizes three states:
--*                 - IDLE: slave select is high, no data is sent 
--*                     until enable signal
--*                 - DATA_SETUP: slave select is low, data is 
--*                     indexed through and sent decrementally
--*                 - DATA_VALID: slave select is low, check count
--*                     and enable signal to see if the 
--*                     transaction continues
--*                     [TODO: implement MISO sampling in DATA_VALID]
--*
--*********************************************************************


library ieee;
use ieee.std_logic_1164.all;

entity SPI_MASTER is
    generic(clk_div: integer := 1);
    port(   clock: in std_logic;
            reset: in std_logic;
            txEnable: in std_logic;
            data: in std_logic_vector(23 downto 0);
            
            ss_out: out std_logic;
            sck_out: out std_logic;
            MOSI: out std_logic;
            
            wordFinished: out std_logic
            
            );
end SPI_MASTER;


architecture RTL of SPI_MASTER is

    ----active/idle high/low declarations---------------------CONSTANTS
    constant ACTIVE_HIGH, IDLE_HIGH: std_logic := '1';
    constant ACTIVE_LOW, IDLE_LOW: std_logic := '0';
    
    ----state machine declarations----------------------------CONSTANTS
    type states is (IDLE, DATA_VALID, DATA_SETUP);
    signal currentState: states := IDLE;
    
    ----intermediate signals-----------------------------------SIGNALS
    signal ss_reg: std_logic := IDLE_HIGH;
    signal sck_reg: std_logic := IDLE_LOW;
    signal wordFinished_reg: std_logic := IDLE_LOW;

    ----internal enable signal---------------------------------SIGNALS
    signal decrementEnable: std_logic;

   
begin

    
    --============================================================================
    --  Direct Signal Assignment
    --============================================================================
    ss_out <= ss_reg;
    sck_out <= sck_reg;
    wordFinished <= wordFinished_reg;

   
    --============================================================================
    --  Main State Machine Process
    --============================================================================
    STATE_MACHINE: process(reset, clock) is
    variable count: integer range 24 downto 0;
    begin 
        if(reset = ACTIVE_HIGH) then
            ss_reg <= IDLE_HIGH;
            decrementEnable <= IDLE_LOW;
            currentState <= IDLE;
            MOSI <= 'Z'; -- high impedence
            count := 24;
        
        elsif(rising_edge(clock)) then
            case currentState is
                when IDLE =>
                    count := 24;
                    ss_reg <= IDLE_HIGH;
                    MOSI <= 'Z';
                    if(txEnable = ACTIVE_HIGH) then
                        ss_reg <= ACTIVE_LOW;
                        decrementEnable <= ACTIVE_HIGH;
                        currentState <= DATA_SETUP;
                        count := count - 1;
                        MOSI <= data(count);
                    end if;
                    
                when DATA_SETUP =>
                    if(txEnable = ACTIVE_HIGH) then
                            if(ss_reg = ACTIVE_LOW and sck_reg = ACTIVE_HIGH) then
                                if(decrementEnable = ACTIVE_HIGH) then
                                    count := count - 1;
                                    MOSI <= data(count);
                                    decrementEnable <= IDLE_LOW;
                                    currentState <= DATA_VALID;
                                end if;
                            end if;
                     else
                        MOSI <= 'Z';
                     end if;
                when DATA_VALID =>
                    if(ss_reg = ACTIVE_LOW and sck_reg = IDLE_LOW) then
                        if(count = 0) then
                            wordFinished_reg <= ACTIVE_HIGH;
                            if(txEnable = ACTIVE_HIGH) then
                                currentState <= DATA_SETUP;
                                decrementEnable <= ACTIVE_HIGH;
                                count := 24;
                            else
                                currentState <= IDLE;
                                decrementEnable <= IDLE_LOW;
                            end if;
                        else
                            currentState <= DATA_SETUP;
                            decrementEnable <= ACTIVE_HIGH;
                            wordFinished_reg <= IDLE_LOW;
                        end if;
                    end if;
            end case;
        end if;   
    end process STATE_MACHINE;


    --============================================================================
    --  Serial Clock Generator
    --============================================================================
    GENERATE_SCK: process(reset, clock, ss_reg) is
    variable count: integer range 0 to clk_div;
    begin
        if(reset = ACTIVE_HIGH) then
            sck_reg <= IDLE_LOW;
            count := 0;
        elsif(rising_edge(clock)) then
            if(txEnable = ACTIVE_HIGH) then  
                if(ss_reg = ACTIVE_LOW) then
                    count := count + 1;
                    if(count = clk_div) then
                        count := 0;
                        sck_reg <= not sck_reg;
                    end if;
                end if;
            else
                sck_reg <= IDLE_LOW;
            end if;
            
        end if;
    end process GENERATE_SCK;


end RTL;
