<?xml version="1.0" encoding="UTF-8"?>
<Project>
    <Project_Created_Time>2018-12-03 19:58:32</Project_Created_Time>
    <TD_Version>4.2.511</TD_Version>
    <UCode>10011100</UCode>
    <Name>tang_picorv32</Name>
    <HardWare>
        <Family>EG4</Family>
        <Device>EG4S20BG256</Device>
    </HardWare>
    <Source_Files>
        <Verilog>
            <File>src/picosoc.v</File>
            <File>src/simpleuart.v</File>
            <File>src/spimemio.v</File>
            <File>src/tang_system.v</File>
            <File>al_ip/bram.v</File>
            <File>src/bram_wrapper.v</File>
            <File>al_ip/pll.v</File>
            <File>src/picorv32.v</File>
        </Verilog>
        <ADC_FILE>constraints/io_cst.adc</ADC_FILE>
        <SDC_FILE>constraints/tim_cst.sdc</SDC_FILE>
        <CWC_FILE/>
    </Source_Files>
    <TOP_MODULE>
        <LABEL/>
        <MODULE>tang_system</MODULE>
        <CREATEINDEX>user</CREATEINDEX>
    </TOP_MODULE>
    <Project_Settings>
        <Step_Last_Change>2018-12-05 01:04:27</Step_Last_Change>
        <Current_Step>60</Current_Step>
        <Step_Status>true</Step_Status>
    </Project_Settings>
</Project>
