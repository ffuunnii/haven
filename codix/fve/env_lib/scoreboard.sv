/******************************************************************************
 *     "Copyright (C) 2013, ApS s.r.o Brno, All Rights Reserved"             *
 ******************************************************************************/
/**
 *  \file
 *  \date   Mon Mar  4 13:49:04 2013, generated by Codasip HW generator v2.0.0.
 *  \brief  Definition of the scoreboard.
 */

// This class receives transactions from the driver and performs transformation of these transactions into the form of expected responses according to the specification. Afterwards, it receives transactions from the monitor and automatically compares these real responses with the expected ones.
class codix_ca_scoreboard extends ovm_scoreboard;

	// registration of component tools
	`ovm_component_utils( codix_ca_scoreboard )

	// queues to receive transaction from monitors and golden model
	tlm_analysis_fifo #(codix_ca_core_regs_transaction) m_dut_codix_ca_core_regs_fifo;
	tlm_analysis_fifo #(codix_ca_core_regs_transaction) m_golden_model_codix_ca_core_regs_fifo;

	tlm_analysis_fifo #(codix_ca_output_transaction) m_dut_codix_ca_output_fifo;
	tlm_analysis_fifo #(codix_ca_output_transaction) m_golden_model_codix_ca_output_fifo;

        tlm_analysis_fifo #(codix_ca_mem_transaction) m_dut_codix_ca_mem_fifo;
        //tlm_analysis_fifo #(codix_ca_mem_transaction) m_golden_model_codix_ca_mem_fifo;

	tlm_analysis_fifo #(codix_ca_input_transaction) m_dut_codix_ca_input_fifo;

	// local queues to store all transactions
	local codix_ca_core_regs_transaction m_dut_codix_ca_core_regs_fifo_all[$];
	local codix_ca_core_regs_transaction m_golden_model_codix_ca_core_regs_fifo_all[$];

	local codix_ca_output_transaction m_dut_codix_ca_output_fifo_all[$];
	local codix_ca_output_transaction m_golden_model_codix_ca_output_fifo_all[$];

        local codix_ca_mem_transaction m_dut_codix_ca_mem_fifo_all[$];

	local codix_ca_input_transaction m_dut_codix_ca_input_fifo_all[$];

	// store last transaction register file content
	local codix_ca_core_regs_transaction m_dut_codix_ca_core_regs_transaction;
	local codix_ca_core_regs_transaction m_golden_model_codix_ca_core_regs_transaction;

	// stores the final report message
	local string report_msg;
	// local comparator
	local ovm_comparer m_comparer;

	// Constructor - creates new instance of this class
	function new( string name, ovm_component parent );
		super.new( name, parent );
		m_comparer = new;
		m_comparer.show_max = 1;
		m_comparer.sev = OVM_ERROR;
	endfunction : new

	// Build - instantiates child components
	function void build();
		super.build();
		m_dut_codix_ca_core_regs_fifo = new( "m_dut_codix_ca_core_regs_fifo", this );
		m_golden_model_codix_ca_core_regs_fifo = new( "m_golden_model_codix_ca_core_regs_fifo", this );

		m_dut_codix_ca_output_fifo = new( "m_dut_codix_ca_output_fifo", this );
		m_golden_model_codix_ca_output_fifo = new( "m_golden_model_codix_ca_output_fifo", this );

                m_dut_codix_ca_mem_fifo = new( "m_dut_codix_ca_mem_fifo", this );

		m_dut_codix_ca_input_fifo = new( "m_dut_codix_ca_input_fifo", this );
	endfunction : build

	// move 'regs' transactions from TLM to local queue of the DUT
	task move_dut_codix_ca_core_regs_transaction();
		codix_ca_core_regs_transaction tr;
		forever begin
			m_dut_codix_ca_core_regs_fifo.get( tr );
			m_dut_codix_ca_core_regs_fifo_all.push_back( tr );
			// tr.print();
		end
	endtask : move_dut_codix_ca_core_regs_transaction

	// move 'regs' transactions from TLM to local queue of the golden model
	task move_golden_model_codix_ca_core_regs_transaction();
		codix_ca_core_regs_transaction tr;
		forever begin
			m_golden_model_codix_ca_core_regs_fifo.get( tr );
			m_golden_model_codix_ca_core_regs_fifo_all.push_back( tr );
			// tr.print();
		end
	endtask : move_golden_model_codix_ca_core_regs_transaction

	// move output transaction from TLM to local queue of the DUT
	task move_dut_codix_ca_output_transaction();
		codix_ca_output_transaction tr;
		forever begin
			m_dut_codix_ca_output_fifo.get( tr );
			m_dut_codix_ca_output_fifo_all.push_back( tr );
			// tr.print();
		end
	endtask : move_dut_codix_ca_output_transaction

	// move output transaction from TLM to local queue of the golden model
	task move_golden_model_codix_ca_output_transaction();
		codix_ca_output_transaction tr;
		forever begin
			m_golden_model_codix_ca_output_fifo.get( tr );
			m_golden_model_codix_ca_output_fifo_all.push_back( tr );
			// tr.print();
		end
	endtask : move_golden_model_codix_ca_output_transaction

	// move input transaction from TLM to local queue
	task move_dut_codix_ca_input_transaction();
		codix_ca_input_transaction tr;
		forever begin
			m_dut_codix_ca_input_fifo.get( tr );
			m_dut_codix_ca_input_fifo_all.push_back( tr );
			// tr.print();
		end
	endtask : move_dut_codix_ca_input_transaction

	// compare output transactions
	function void compare_outputs();
		// TODO insert your code here
	endfunction : compare_outputs

	// starts processing in scoreboard
	task run();
		fork
			move_dut_codix_ca_core_regs_transaction();
			move_dut_codix_ca_output_transaction();
			move_golden_model_codix_ca_output_transaction();
			move_dut_codix_ca_input_transaction();
		join
	endtask : run

	// compare DUTs and GMs memories and register files contents
	function void check();
		// pick up 'codix_ca_core_regs' content from DUT and GM
		assert( m_dut_codix_ca_core_regs_fifo.used() == 1 );
		assert( m_golden_model_codix_ca_core_regs_fifo.used() == 1 );
		assert( m_dut_codix_ca_core_regs_fifo.try_get(m_dut_codix_ca_core_regs_transaction) );
		assert( m_golden_model_codix_ca_core_regs_fifo.try_get(m_golden_model_codix_ca_core_regs_transaction) );
		assert( m_dut_codix_ca_core_regs_transaction );
		assert( m_golden_model_codix_ca_core_regs_transaction );
		m_dut_codix_ca_core_regs_fifo_all.push_back( m_dut_codix_ca_core_regs_transaction );
		m_golden_model_codix_ca_core_regs_fifo_all.push_back( m_golden_model_codix_ca_core_regs_transaction );

	endfunction: check

	// report comparison result of DUTs and GMs transactions
	function void report();
		automatic int fd = $fopen( "report.txt", "a" );

		m_comparer.show_max = 32;
		if ( !m_golden_model_codix_ca_core_regs_fifo_all[$].compare(
			m_dut_codix_ca_core_regs_fifo_all[$], m_comparer) )
		begin
			`ovm_error( get_name(), "'regs': The results do not correspond!\n" );
			report_msg = { report_msg, m_comparer.miscompares };
		end
		else begin
			`ovm_info( get_name(), "'regs': The result is OK!\n", OVM_MEDIUM );
		end
		// m_dut_codix_ca_core_regs_transaction.print();
		// m_golden_model_codix_ca_core_regs_transaction.print();
		// write final test status.
		if ( report_msg == "" )
			$fwrite( fd, "ok\n" );
		else begin
			$fwrite( fd, "fail\n" );
			$fwrite( fd, $psprintf("%s\n", report_msg) );
		end
		$fclose( fd );
	endfunction: report

endclass: codix_ca_scoreboard
