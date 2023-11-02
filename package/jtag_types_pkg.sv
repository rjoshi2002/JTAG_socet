/* 
    Copied from Fall 2019 - Spring 2020 JTAG team 
	https://github.com/Purdue-SoCET/JTAG/blob/master/package/jtag_types_pkg.sv 
    Code from Fred Owens, Xianmeng Zhang 
*/ 
`ifndef JTAG_TYPES_PKG_VH
`define JTAG_TYPES_PKG_VH
package jtag_types_pkg;

	typedef enum logic [3:0]
	{
		// Start
		TEST_LOGIC_RESET	= 4'b0000,
		RUN_TEST_IDLE		= 4'b0001,
		// Data Column
		SELECT_DR_SCAN		= 4'b0010,
		CAPTURE_DR			= 4'b0011,
		SHIFT_DR			= 4'b0100,
		EXIT1_DR			= 4'b0101,
		PAUSE_DR			= 4'b0110,
		EXIT2_DR			= 4'b0111,
		UPDATE_DR			= 4'b1000,
    	// Instruction Column
		SELECT_IR_SCAN		= 4'b1001,
		CAPTURE_IR			= 4'b1010,
		SHIFT_IR			= 4'b1011,
		EXIT1_IR			= 4'b1100,
		PAUSE_IR			= 4'b1101,
		EXIT2_IR			= 4'b1110,
		UPDATE_IR			= 4'b1111
	} state_t;


	typedef enum logic [4:0]
	{
		// Mandatory
		BYPASS					= 5'b00000,	// 6.2.1.1.d	BYPASS = '0 and '1
		SAMPLE					= 5'b00001,
		PRELOAD					= 5'b00010,
		EXTEST					= 5'b00011,
		// Extras
		IDCODE					= 5'b00100,
		CLAMP					= 5'b00101,
		HIGHZ					= 5'b00110,
		IC_RESET				= 5'b00111,
		CLAMP_HOLD				= 5'b01000,
		CLAMP_RELEASE			= 5'b01001,
		TMP_STATUS				= 5'b01010,
		// Extra Extra for Programmable
		INIT_SETUP				= 5'b01011,
		INIT_SETUP_CLAMP		= 5'b01100,
		INIT_RUN				= 5'b01101,
        // SCAN CHAIN STUFF
        AHB                     = 5'b01110,
        // Extra BYPASS
        BYPASS_2				= 5'b01111,
        AHB_ERROR       = 5'b10000
	} instruction_t;


	typedef enum logic [15:0]
	{
		// Mandatory
		BYPASS_de					= 16'b0000000000000001,	// 6.2.1.1.d	BYPASS and BYPASS_2
		SAMPLE_de					= 16'b0000000000000010,
		PRELOAD_de					= 16'b0000000000000100,
		EXTEST_de					= 16'b0000000000001000,
		// Extras
		IDCODE_de					= 16'b0000000000010000,
		CLAMP_de					= 16'b0000000000100000,
		HIGHZ_de					= 16'b0000000001000000,
		IC_RESET_de					= 16'b0000000010000000,
		CLAMP_HOLD_de				= 16'b0000000100000000,
		CLAMP_RELEASE_de			= 16'b0000001000000000,
		TMP_STATUS_de				= 16'b0000010000000000,
		// Extra Extra for Programmable
		INIT_SETUP_de				= 16'b0000100000000000,
		INIT_SETUP_CLAMP_de			= 16'b0001000000000000,
		INIT_RUN_de					= 16'b0010000000000000,
		// Special for SCAN CHAIN
        AHB_de						= 16'b0100000000000000,
        AHB_ERROR_de                = 16'b1000000000000000
    } instruction_decode_t;

	typedef enum logic
	{
		PERSISTENCE_OFF = 1'b0,
		PERSISTENCE_ON = 1'b1
	} tmp_state_t;

  typedef enum logic
  {
    ADDRESS = 1'b0,
    DATA = 1'b1
  } regselect_t;

  typedef enum logic [1:0]
  {
    WORD = 2'b10,
    HALFWORD = 2'b01,
    BYTE = 2'b00
  } hsize_t;
    
  typedef enum logic
  {
    WRITE = 1'b1,
    READ = 1'b0
  } r_w_t;
  typedef struct packed
  {
    logic [31:0] data;
    regselect_t regselect;
    hsize_t size;
    logic addrinc;
    r_w_t r_w;
  } ap_shift_t;

endpackage
`endif //JTAG_TYPES_PKG_VH