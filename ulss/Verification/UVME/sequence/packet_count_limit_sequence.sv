

class packet_count_limit_sequence extends uvm_sequence#(ulss_tx);

  // Factory registration
  `uvm_object_utils(packet_count_limit_sequence)

  // Creating sequence item handle
  ulss_tx tx;

  // Configuration parameters
  int num_packets = 5;      // Increased number of packets to send
  int token_wait = 3;        // Default token wait value
  int tokens_per_packet = 1; // Default tokens per packet
  int delay_between_packets = 2; // Shorter delay between packets
  
  // Constructor
  function new(string name="packet_count_limit_sequence");
    super.new(name);
  endfunction

  task body();
    bit [15:0] empty_status;
    bit [15:0] all_empty;
    int i;
    
    `uvm_info(get_type_name(), "packet_count_limit_sequence: Starting test with a single stream mapping", UVM_LOW)
    
    // Create the transaction
    tx = ulss_tx::type_id::create("tx");
    
    // Assert reset
    `uvm_do_with(tx, {
      tx.rate_limiter_16to4_rstn == 1'b0;
      tx.sch_reg_wr_en == 1'b0;
    });
    
    // Allow cycles for reset
    repeat(5) #10;
    
    // Map only input stream 0 to output stream 0 (bit 0 set)
    `uvm_do_with(tx, { 
      tx.rate_limiter_16to4_rstn == 1'b1;
      tx.sch_reg_wr_en   == 1'b1;
      tx.sch_reg_wr_addr == 5'd0; // OUT_STREAM_0_REG
      tx.sch_reg_wr_data == 64'h0001; // Map input stream 0 to output stream 0
    });
    
    `uvm_info(get_type_name(), $sformatf("OUT_STREAM_0_REG configured with value 0x%0h", tx.sch_reg_wr_data), UVM_LOW);
    
    // Wait for register write to complete
    repeat(2) #10;
    
    // Configure IN_STREAM_0_REG with token parameters
    `uvm_do_with(tx, {
      tx.rate_limiter_16to4_rstn == 1'b1;
      tx.sch_reg_wr_en   == 1'b1;
      tx.sch_reg_wr_addr == 5'd4; // IN_STREAM_0_REG
      tx.sch_reg_wr_data[14:0]  == token_wait;  // tokens wait
      tx.sch_reg_wr_data[63:15] == tokens_per_packet;  // tokens per packet
    });
    
    `uvm_info(get_type_name(), $sformatf("IN_STREAM_0_REG configured with values: tokens=%0d, packets=%0d", 
                                         token_wait, tokens_per_packet), UVM_LOW);
    
    repeat(2) #10;
    
    empty_status = '1;        // Initialize all streams as empty
    empty_status[0] = 1'b0;   // Only stream 0 is not empty
    
    // Now send multiple packets on stream 0
    for (i = 0; i < num_packets; i++) begin
      // Send a packet on stream 0
      send_packet_on_stream0(empty_status,{ $urandom(),$urandom()} + i);  // Include packet number in data
      
      `uvm_info(get_type_name(), $sformatf("Sent packet %0d/%0d on stream 0", 
                                        i+1, num_packets), UVM_LOW);
      
      // Wait some time between packets
      repeat(delay_between_packets) #10;
    end
    
    // Set all streams back to empty when done
    all_empty = '1;  // All streams are empty
    set_all_streams_empty(all_empty);
    
    `uvm_info(get_type_name(), "packet_count_limit_sequence completed", UVM_LOW);
  endtask
  
  // Simplified task to send a packet only on stream 0
  task send_packet_on_stream0(bit [15:0] empty_status, bit [63:0] packet_data);
    tx = ulss_tx::type_id::create("tx");
    
    // Base configuration
    tx.rate_limiter_16to4_rstn = 1'b1;
    tx.sch_reg_wr_en = 1'b0;
    tx.sch_reg_wr_addr = 'd0;
    tx.sch_reg_wr_data = 'h0;
    
    // Set up empty status for all streams
    tx.pck_str_empty_0 = empty_status[0];
    tx.pck_str_empty_1 = empty_status[1];
    tx.pck_str_empty_2 = empty_status[2];
    tx.pck_str_empty_3 = empty_status[3];
    tx.pck_str_empty_4 = empty_status[4];
    tx.pck_str_empty_5 = empty_status[5];
    tx.pck_str_empty_6 = empty_status[6];
    tx.pck_str_empty_7 = empty_status[7];
    tx.pck_str_empty_8 = empty_status[8];
    tx.pck_str_empty_9 = empty_status[9];
    tx.pck_str_empty_10 = empty_status[10];
    tx.pck_str_empty_11 = empty_status[11];
    tx.pck_str_empty_12 = empty_status[12];
    tx.pck_str_empty_13 = empty_status[13];
    tx.pck_str_empty_14 = empty_status[14];
    tx.pck_str_empty_15 = empty_status[15];
    
    // Initialize all streams to default/idle
    tx.in_sop_0 = 1'b0; tx.in_stream_0 = 64'h0; tx.in_eop_0 = 1'b0;
    tx.in_sop_1 = 1'b0; tx.in_stream_1 = 64'h0; tx.in_eop_1 = 1'b0;
    tx.in_sop_2 = 1'b0; tx.in_stream_2 = 64'h0; tx.in_eop_2 = 1'b0;
    tx.in_sop_3 = 1'b0; tx.in_stream_3 = 64'h0; tx.in_eop_3 = 1'b0;
    tx.in_sop_4 = 1'b0; tx.in_stream_4 = 64'h0; tx.in_eop_4 = 1'b0;
    tx.in_sop_5 = 1'b0; tx.in_stream_5 = 64'h0; tx.in_eop_5 = 1'b0;
    tx.in_sop_6 = 1'b0; tx.in_stream_6 = 64'h0; tx.in_eop_6 = 1'b0;
    tx.in_sop_7 = 1'b0; tx.in_stream_7 = 64'h0; tx.in_eop_7 = 1'b0;
    tx.in_sop_8 = 1'b0; tx.in_stream_8 = 64'h0; tx.in_eop_8 = 1'b0;
    tx.in_sop_9 = 1'b0; tx.in_stream_9 = 64'h0; tx.in_eop_9 = 1'b0;
    tx.in_sop_10 = 1'b0; tx.in_stream_10 = 64'h0; tx.in_eop_10 = 1'b0;
    tx.in_sop_11 = 1'b0; tx.in_stream_11 = 64'h0; tx.in_eop_11 = 1'b0;
    tx.in_sop_12 = 1'b0; tx.in_stream_12 = 64'h0; tx.in_eop_12 = 1'b0;
    tx.in_sop_13 = 1'b0; tx.in_stream_13 = 64'h0; tx.in_eop_13 = 1'b0;
    tx.in_sop_14 = 1'b0; tx.in_stream_14 = 64'h0; tx.in_eop_14 = 1'b0;
    tx.in_sop_15 = 1'b0; tx.in_stream_15 = 64'h0; tx.in_eop_15 = 1'b0;
    
    // Set packet data only for stream 0
    tx.in_sop_0 = 1'b1;
    tx.in_stream_0 = packet_data;
    tx.in_eop_0 = 1'b1;
    
    // Start the transaction
    start_item(tx);
    finish_item(tx);
  endtask
  
  //  task to set all streams to empty
  task set_all_streams_empty(bit [15:0] empty_status);
    tx = ulss_tx::type_id::create("tx");
    
    tx.rate_limiter_16to4_rstn = 1'b1;
    tx.sch_reg_wr_en = 1'b0;
    tx.sch_reg_wr_addr = 'd0;
    tx.sch_reg_wr_data = 'h0;
    
    // Set all empty status bits
    tx.pck_str_empty_0 = empty_status[0];
    tx.pck_str_empty_1 = empty_status[1];
    tx.pck_str_empty_2 = empty_status[2];
    tx.pck_str_empty_3 = empty_status[3];
    tx.pck_str_empty_4 = empty_status[4];
    tx.pck_str_empty_5 = empty_status[5];
    tx.pck_str_empty_6 = empty_status[6];
    tx.pck_str_empty_7 = empty_status[7];
    tx.pck_str_empty_8 = empty_status[8];
    tx.pck_str_empty_9 = empty_status[9];
    tx.pck_str_empty_10 = empty_status[10];
    tx.pck_str_empty_11 = empty_status[11];
    tx.pck_str_empty_12 = empty_status[12];
    tx.pck_str_empty_13 = empty_status[13];
    tx.pck_str_empty_14 = empty_status[14];
    tx.pck_str_empty_15 = empty_status[15];
    
    // Initialize all streams to idle
    tx.in_sop_0 = 1'b0; tx.in_stream_0 = 64'h0; tx.in_eop_0 = 1'b0;
    tx.in_sop_1 = 1'b0; tx.in_stream_1 = 64'h0; tx.in_eop_1 = 1'b0;
    tx.in_sop_2 = 1'b0; tx.in_stream_2 = 64'h0; tx.in_eop_2 = 1'b0;
    tx.in_sop_3 = 1'b0; tx.in_stream_3 = 64'h0; tx.in_eop_3 = 1'b0;
    tx.in_sop_4 = 1'b0; tx.in_stream_4 = 64'h0; tx.in_eop_4 = 1'b0;
    tx.in_sop_5 = 1'b0; tx.in_stream_5 = 64'h0; tx.in_eop_5 = 1'b0;
    tx.in_sop_6 = 1'b0; tx.in_stream_6 = 64'h0; tx.in_eop_6 = 1'b0;
    tx.in_sop_7 = 1'b0; tx.in_stream_7 = 64'h0; tx.in_eop_7 = 1'b0;
    tx.in_sop_8 = 1'b0; tx.in_stream_8 = 64'h0; tx.in_eop_8 = 1'b0;
    tx.in_sop_9 = 1'b0; tx.in_stream_9 = 64'h0; tx.in_eop_9 = 1'b0;
    tx.in_sop_10 = 1'b0; tx.in_stream_10 = 64'h0; tx.in_eop_10 = 1'b0;
    tx.in_sop_11 = 1'b0; tx.in_stream_11 = 64'h0; tx.in_eop_11 = 1'b0;
    tx.in_sop_12 = 1'b0; tx.in_stream_12 = 64'h0; tx.in_eop_12 = 1'b0;
    tx.in_sop_13 = 1'b0; tx.in_stream_13 = 64'h0; tx.in_eop_13 = 1'b0;
    tx.in_sop_14 = 1'b0; tx.in_stream_14 = 64'h0; tx.in_eop_14 = 1'b0;
    tx.in_sop_15 = 1'b0; tx.in_stream_15 = 64'h0; tx.in_eop_15 = 1'b0;
    
    // Start the transaction
    start_item(tx);
    finish_item(tx);
  endtask
endclass
