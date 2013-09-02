/******************************************************************************
 *         Hardware accelerated Functional Verification of Processor          *
 ******************************************************************************/
/**
 *  \file   sorter.sv
 *  \date   09-03-2013
 *  \brief  Sorter splits output signal from HW environment 
 */


// Sorter class 
class Sorter extends ovm_component;

    // registration of component tools
    `ovm_component_utils_begin( Sorter )
        // implements the data operations for an ovm_object based property
//        `ovm_field_object( OVM_DEFAULT | OVM_NOCOMPARE | OVM_NOPRINT | OVM_NORECORD | OVM_NOPACK )
    `ovm_component_utils_end

    // synchronization put port
    ovm_put_port#(syncT) syncport;

    // get port - data
    ovm_get_port#(NetCOPETransaction) gport;

    // analysis port for sending data to the connected scoreboard
    ovm_analysis_port #(codix_ca_core_regs_transaction) regs_export;
    ovm_analysis_port #(codix_ca_output_transaction) portout_export;
    ovm_analysis_port #(codix_ca_mem_transaction) mem_export;

    // Constructor - creates new instance of this class
    function new( string name, ovm_component parent );

        super.new( name, parent );

        syncport = new("syncport", this);
        gport    = new("gport", this);

        regs_export = new( "regs_export", this );
        portout_export = new( "portout_export", this );
        mem_export = new( "mem_export", this );

    endfunction : new

    // build - instantiates child components
    function void build;
        super.build();
    endfunction: build

    // Run Sorter - receives transactions from output mailbox and 
    // according to NetCOPE header sends them to proper port
    task run();

        int cntPM = 0;
        int cntRM = 0;
        int cntMM = 0;
        int monitorID;
        longint count;
        syncT str;
        NetCOPETransaction t;

        str = new();
//        t = new();
        str.flag  = 0;

        while(1) begin
            // transaction with number of packets
            syncport.put(str);
            gport.get(t);

            count = getCount(t);

            // transaction with monitor ID
            syncport.put(str);
            gport.get(t);

            monitorID =  t.data[0];

            priority case (monitorID)
            // portout monitor
            8'h01 : begin
			automatic codix_ca_output_transaction portout_tr = new( "dut_codix_ca_output_transaction" );
                        syncport.put(str);
                        gport.get(t);
                        // cast to codix_ca_output_transaction
                        //portout_tr.codix_ca_port_output = t.data; 
                        
                        // send transaction to scoreboard
                        //portout_export.write(portout_tr);

                        cntPM++;
                    end
            // register monitor
            8'h02 : begin
                      automatic codix_ca_core_regs_transaction regs_tr = new ( "dut_codix_ca_core_regs_transaction" );
                      for (int i=0 ; i < count ; i++) begin
                        syncport.put(str);
                        gport.get(t);
                        // cast to codix_ca_core_regs_transaction
                        //regs_tr.codix_ca_core_regs_D0 = t.data;

                        // send transaction to scoreboard
                        //regs_export.write(regs_tr);

                        cntRM++;
                      end
                    end
            // memory monitor
            8'h03 : begin
                      automatic codix_ca_mem_transaction mem_tr = new ( "dut_codix_ca_mem_transaction" );
                      for (int i=0 ; i < count ; i++) begin
                        syncport.put(str);
                        gport.get(t);
                        // cast to codix_ca_mem_transaction
                        //mem_tr.codix_ca_mem_D0 = t.data;

                        // send transaction to scoreboard
                        //mem_export.write(mem_tr);

                        cntMM++;
                      end

                      // finish output wrapper
                      str.flag = 1;
                      syncport.put(str);

                      `ovm_info( get_name(), $sformatf("\nportout monitor transactions: %d\n", cntPM), OVM_MEDIUM);
                      `ovm_info( get_name(), $sformatf("\nregister monitor transactions: %d\n", cntRM), OVM_MEDIUM);
                      `ovm_info( get_name(), $sformatf("\nmemory monitor transactions: %d\n", cntMM), OVM_MEDIUM);

                    end         
          // error
          default : begin
                      // finish output wrapper
                      str.flag = 1;
                      syncport.put(str);

                      `ovm_info( get_name(), $sformatf("\nportout monitor transactions: %d\n", cntPM), OVM_MEDIUM);
                      `ovm_info( get_name(), $sformatf("\nregister monitor transactions: %d\n", cntRM), OVM_MEDIUM);
                      `ovm_info( get_name(), $sformatf("\nmemory monitor transactions: %d\n", cntMM), OVM_MEDIUM);

                      `ovm_error( get_name(), "Unknown Monitor ID!\n" );
                    end
          endcase
      end

      `ovm_info( get_name(), $sformatf("\nportout monitor transactions: %d\n", cntPM), OVM_MEDIUM);
      `ovm_info( get_name(), $sformatf("\nregister monitor transactions: %d\n", cntRM), OVM_MEDIUM);
      `ovm_info( get_name(), $sformatf("\nmemory monitor transactions: %d\n", cntMM), OVM_MEDIUM);

    endtask : run

    function longint getCount(NetCOPETransaction n);
      return {n.data[0], n.data[1], n.data[2], n.data[3], n.data[4], n.data[5], n.data[6], n.data[7]};
    endfunction


endclass : Sorter
