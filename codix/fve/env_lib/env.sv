/******************************************************************************
 *     "Copyright (C) 2013, ApS s.r.o Brno, All Rights Reserved"             *
 ******************************************************************************/
/**
 *  \file
 *  \date   Mon Mar  4 13:49:04 2013, generated by Codasip HW generator v2.0.0.
 *  \brief  Definition of the OVM environment.
 */

// This class represents the main parts of the verification environment.
class codix_ca_env extends ovm_env;

	// registration of component tools
	`ovm_component_utils( codix_ca_env )

	// declarations of main components
	// used to collect register file coverage (how extensive was the RF used).
	local codix_ca_core_regs_monitor m_codix_ca_core_regs_monitor;
	local codix_ca_core_regs_subscriber m_codix_ca_core_regs_subscriber;
	// used to collect instruction coverage
	local codix_ca_core_main_instr_hw_instr_hw_monitor m_codix_ca_core_main_instr_hw_instr_hw_monitor;
	local codix_ca_core_main_instr_hw_instr_hw_subscriber m_codix_ca_core_main_instr_hw_instr_hw_subscriber;
	// used to collect memory coverage (how extensive was the memory used).
	local codix_ca_mem_monitor m_codix_ca_mem_monitor;
	local codix_ca_mem_subscriber m_codix_ca_mem_subscriber;
	// used to drive input interface
	local codix_ca_input_driver m_codix_ca_input_driver;
	local codix_ca_input_sequencer m_codix_ca_input_sequencer;
	// used to collect input interface coverage
	local codix_ca_input_monitor m_codix_ca_input_monitor;
	local codix_ca_input_subscriber m_codix_ca_input_subscriber;
	// used to collect output interface coverage
	local codix_ca_output_monitor m_codix_ca_output_monitor;
	local codix_ca_output_subscriber m_codix_ca_output_subscriber;
	// used for scoardboarding
	local codix_ca_scoreboard m_codix_ca_scoreboard;
	local codix_ca_gm m_codix_ca_gm;

	// Constructor - creates new instance of this class
	function new( string name, ovm_component parent );
		super.new( name, parent );
	endfunction : new

	// Build - instantiates child components
	function void build;
		super.build();
            
		m_codix_ca_core_regs_monitor = new( "m_codix_ca_core_regs_monitor", this );
		m_codix_ca_core_regs_subscriber = new( "m_codix_ca_core_regs_subscriber", this );
		m_codix_ca_core_main_instr_hw_instr_hw_monitor = new( "m_codix_ca_core_main_instr_hw_instr_hw_monitor", this );
		m_codix_ca_core_main_instr_hw_instr_hw_subscriber = new( "m_codix_ca_core_main_instr_hw_instr_hw_subscriber", this );
		m_codix_ca_mem_monitor = new( "m_codix_ca_mem_monitor", this );
		m_codix_ca_mem_subscriber = new( "m_codix_ca_mem_subscriber", this );
		m_codix_ca_input_driver = new( "m_codix_ca_input_driver", this );
		m_codix_ca_input_sequencer = new( "m_codix_ca_input_sequencer", this );
		m_codix_ca_input_monitor = new( "m_codix_ca_input_monitor", this );
		m_codix_ca_input_subscriber = new( "m_codix_ca_input_subscriber", this );
		m_codix_ca_output_monitor = new( "m_codix_ca_output_monitor", this );
		m_codix_ca_output_subscriber = new( "m_codix_ca_output_subscriber", this );
		m_codix_ca_scoreboard = new( "m_codix_ca_scoreboard", this );
		m_codix_ca_gm = new( "m_codix_ca_gm", this );

	endfunction: build

	// Connect - connects ports of the child components so they can communicate
	function void connect();
		super.connect();

		// monitor => subscriber
		m_codix_ca_core_regs_monitor.analysis_export.connect( m_codix_ca_core_regs_subscriber.analysis_export );
		// monitor => scoreboard
		m_codix_ca_core_regs_monitor.analysis_export.connect( m_codix_ca_scoreboard.m_dut_codix_ca_core_regs_fifo.analysis_export );
		// golden model => scoreboard
		m_codix_ca_gm.aport_icodix_ca_core_regs_if.connect( m_codix_ca_scoreboard.m_golden_model_codix_ca_core_regs_fifo.analysis_export );
		// monitor => subscriber
		m_codix_ca_core_main_instr_hw_instr_hw_monitor.analysis_export.connect( m_codix_ca_core_main_instr_hw_instr_hw_subscriber.analysis_export );
		// monitor => subscriber
		m_codix_ca_mem_monitor.analysis_export.connect( m_codix_ca_mem_subscriber.analysis_export );
		// driver => sequencer
		m_codix_ca_input_driver.seq_item_port.connect( m_codix_ca_input_sequencer.seq_item_export );
		// input monitor => subscriber
		m_codix_ca_input_monitor.analysis_export.connect( m_codix_ca_input_subscriber.analysis_export );
		// input monitor => golden model
		m_codix_ca_input_monitor.analysis_export.connect( m_codix_ca_gm.m_golden_model_codix_ca_input_fifo.analysis_export );
		// input monitor => scoreboard
		m_codix_ca_input_monitor.analysis_export.connect( m_codix_ca_scoreboard.m_dut_codix_ca_input_fifo.analysis_export );
		// output monitor => scoreboard
		m_codix_ca_output_monitor.analysis_export.connect( m_codix_ca_scoreboard.m_dut_codix_ca_output_fifo.analysis_export );
		// output monitor => subscriber
		m_codix_ca_output_monitor.analysis_export.connect( m_codix_ca_output_subscriber.analysis_export );
		// golden model => scoreboard
		m_codix_ca_gm.analysis_export.connect( m_codix_ca_scoreboard.m_golden_model_codix_ca_output_fifo.analysis_export );

	endfunction: connect

endclass: codix_ca_env

// This class represents the main parts of the verification environment.
// environment in SW & HW
class codix_sw_hw extends ovm_env;

    // registration of component tools
    `ovm_component_utils( codix_sw_hw )

    // sender handle
    local Sender sender_h;
    //local Sorter sorter_h;

    // input & output wrapper
    local InputWrapper input_wrapper_h;
    local OutputWrapper output_wrapper_h;

    // connection between sender and input wrapper
    tlm_fifo #(NetCOPETransaction) input_fifo_h;

    // Constructor - creates new instance of this class
    function new( string name, ovm_component parent );
        super.new( name, parent );
    endfunction : new

    // Build - instantiates child components
    function void build;
        super.build();

        sender_h = new("sender_h", this);
        input_wrapper_h = new("input_wrapper_h", this);
        output_wrapper_h = new("output_wrapper_h", this);
        input_fifo_h = new("input_fifo_h", this);
        //sorter_h = new("sorter_h", this);

    endfunction: build

    // Connect - connects ports of the child components so they can communicate
    function void connect();
        super.connect();
        // sender takes input data from xexes directory
        // sender.putport => tlm_fifo => input_wrapper.getport
        sender_h.pport.connect( input_fifo_h.blocking_put_export );
        input_wrapper_h.gport.connect( input_fifo_h.blocking_get_export );

        // output wrapper => sorter
        //output_wrapper_h.seq_item_port.connect( sorter_h.seq_item_export );

        // sorter => scoreboard
        //sorter_h.seq_item_port.connect( );

    endfunction: connect

endclass: codix_sw_hw

