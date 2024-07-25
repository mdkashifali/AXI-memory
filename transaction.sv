class transaction;
  
  rand bit [3:0] id;
  
  rand bit awvalid;
  bit awready;
  bit [3:0] awid;
  rand bit [3:0] awlen;
  rand bit [2:0] awsize; //4byte =010
  rand bit [31:0] awaddr;
  rand bit [1:0] awburst;
  
  bit wvalid;
  bit wready;
  bit [3:0] wid;
  rand bit [31:0] wdata;
  rand bit [3:0] wstrb;
  bit wlast;
  
  bit bready;
  bit bvalid;
  bit [3:0] bid;
  bit [1:0] bresp;
  
  
  rand bit arvalid;  /// master is sending new address  
  bit arready;  /// slave is ready to accept request
  bit [3:0] arid; ////// unique ID for each transaction
  rand bit [3:0] arlen; ////// burst length AXI3 : 1 to 16, AXI4 : 1 to 256
  bit [2:0] arsize; ////unique transaction size : 1,2,4,8,16 ...128 bytes
  rand bit [31:0] araddr; ////write adress of transaction
  rand bit [1:0] arburst; ////burst type : fixed , INCR , WRAP
  
  /////////// read data channel (r)
  
  bit rvalid; //// master is sending new data
  bit rready; //// slave is ready to accept new data 
  bit [3:0] rid; /// unique id for transaction
  bit [31:0] rdata; //// data 
  bit [3:0] rstrb; //// lane having valid data
  bit rlast; //// last transfer in write burst
  bit [1:0] rresp; ///status of read transfer
 
 /* 
  constraint adr_c {
   awvalid == 0;
   arvalid == 1; 
  
  }
  */
  
  constraint valid_c {
   arvalid != awvalid;
  }
  
  constraint addr_c {
   awaddr == 5;
  //awaddr > 0; awaddr < 15;
   
  }
  
  constraint awsize_c {
  
  awsize >= 0; awsize < 3;
  }
  
  constraint awburst_c {
   awburst == 2;
  //awburst >= 0; awburst < 3; 
  }
  
  
  constraint arlen_c {
    arlen > 0; arlen <= 7;
  }
  
  
  constraint araddr_c {
    araddr == 5;
   // araddr > 0; araddr <= 7;
  }
  
  constraint arburst_c {
  arburst == 2;
  //arburst >= 0; arburst < 3; 
  }
  
endclass
