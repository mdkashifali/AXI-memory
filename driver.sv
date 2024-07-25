class driver;
  
  virtual axi_if vif;
  
  transaction tr;
  
  event drvnext;
  event monnext;
  
  mailbox #(transaction) mbxgd;
 
  
  function new( mailbox #(transaction) mbxgd );
    this.mbxgd = mbxgd; 
  endfunction
  
  //////////////////Resetting System
  task reset();
    
     vif.resetn <= 1'b0;
      
     vif.awvalid <= 1'b0;
     vif.awid <= 0;
     vif.awlen <= 0;
     vif.awsize <= 0;
     vif.awaddr <= 0;
     vif.awburst <= 0;
     
     vif.wvalid <= 0;
     vif.wid <= 0;
     vif.wdata <= 0;
     vif.wstrb <= 0;
     vif.wlast <= 0;
    
     vif.bready <= 0;
 
    
     vif.arvalid <= 1'b0;
     vif.arid <= 0;
     vif.arlen <= 0;
     vif.arsize <= 0;
     vif.araddr <= 0;
     vif.arburst <= 0;
    
    repeat(5) @(posedge vif.clk);
    vif.resetn <= 1'b1;
    $display("[DRV] : RESET DONE"); 
  endtask
  
  
  ///////////////////////////////write data in Fixed Mode 
  task fixed_write(input transaction tr);
      int len = 0;
      len = tr.awlen + 1;  //8
      $display("[DRV] : FIXED MODE -> DATA WRITE DONE");
      @(posedge vif.clk);     
      vif.resetn <= 1'b1;
      vif.awvalid <= 1'b1;
      vif.arvalid <= 1'b0;  ////disable read
      vif.awid    <= tr.id;
      vif.awlen   <= tr.awlen;
      vif.awsize  <= 3'b010;   ///4 byte 
      vif.awburst <= 2'b00;   //00
      vif.wvalid <= 1'b1;
      vif.wid    <= tr.id; 
      vif.wstrb  <= 4'b1111;
      vif.bready <= 1'b1;
      vif.awaddr  <= tr.awaddr;
      vif.wdata  <= $urandom_range(1,100);
      
      @(posedge vif.wready);
      @(posedge vif.clk);
    
    
    for(int i = 1; i< len ; i++) begin /// 1 2 3 4 5 6 7
      vif.awaddr  <= tr.awaddr;
      vif.wdata  <= $urandom_range(1,100);
      @(posedge vif.wready);
      @(posedge vif.clk);
      end
      
      vif.wlast  <= 1'b1;
      vif.awvalid <= 1'b0;
      vif.arvalid <= 1'b0;
      vif.wvalid   <= 1'b0;
      @(posedge vif.clk);
      vif.wlast  <= 1'b0;
      @(negedge vif.bvalid);
      ->drvnext;
     endtask
  
  ///////////////////////////Write data in Incr Mode //////
   
  task incr_write(input transaction tr);
      int len = 0;
      len = tr.awlen + 1;  //8
       $display("[DRV] : INCR MODE -> DATA WRITE DONE");
      @(posedge vif.clk);
      vif.resetn <= 1'b1;
      vif.arvalid <= 1'b0; ////disable read 
      vif.awvalid <= 1'b1;
      vif.awid    <= tr.id;
      vif.awlen   <= tr.awlen;
      vif.awsize  <= 3'b010;    
      vif.awburst <= 2'b01;   
      vif.wvalid <= 1'b1;
      vif.wid    <= tr.id; 
      vif.wstrb  <= 4'b1111;
      vif.bready <= 1'b1;
      vif.awaddr  <= tr.awaddr;
      vif.wdata  <= $urandom_range(1,100);
      
      @(posedge vif.wready);
      @(posedge vif.clk);
    
   for(int i = 1; i< len; i++) begin  ///i < 8  1 2 3 4 5 6 7
      vif.awaddr  <= tr.awaddr + 4*i;
      vif.wdata  <= $urandom_range(1,100);
      @(posedge vif.wready);
      @(posedge vif.clk);
    end
      
      vif.wlast   <= 1'b1;  
      vif.awvalid <= 1'b0;
      vif.arvalid <= 1'b0;
      vif.wvalid  <= 1'b0;
      @(posedge vif.clk);
      vif.wlast  <= 1'b0;
      @(negedge vif.bvalid);
   
    
      ->drvnext;
     endtask
  
  
  
  
  
  
   //////////////////////////////Write data in Wrap Mode
  
    task wrap_write(input transaction tr);
      int len = 0;
      len = tr.awlen + 1;  //8
      $display("[DRV] : WRAP MODE -> DATA WRITE DONE");
      @(posedge vif.clk);
      vif.arvalid <= 1'b0;  ///disable read
      vif.resetn <= 1'b1;
      vif.awvalid <= 1'b1;
      vif.awid    <= tr.id;
      vif.awlen   <= tr.awlen;
      vif.awsize  <= 3'b010;    
      vif.awburst <= 2'b10;   
      vif.wvalid <= 1'b1;
      vif.wid    <= tr.id; 
      vif.wstrb  <= 4'b1111;
      vif.bready <= 1'b1;
      
      
      vif.awaddr <= tr.awaddr;
      vif.wdata  <= $urandom_range(1,100);
      @(posedge vif.wready);
      @(posedge vif.clk);
    
      for(int i = 0; i < 7; i++) begin  ///0 1 2 3 4 5 6
      vif.awaddr  <= vif.addr_wrapwr;
      vif.wdata  <= $urandom_range(1,100);
      @(posedge vif.wready);
      @(posedge vif.clk);
      end
      
      vif.wlast  <= 1'b1;  
      @(posedge vif.clk);
      vif.wlast  <= 1'b0;
      vif.awvalid <= 1'b0;
      vif.arvalid <= 1'b0;
      vif.wvalid  <= 1'b0;
      @(negedge vif.bvalid);
   
      ->drvnext;
     endtask
  
  /////////////////////////////////read fixed mode
  
  task fixed_read(input transaction tr);
    
    int len = 0;
    len = tr.arlen + 1; //8
    $display("[DRV] : FIXED MODE -> DATA READ");
      @(posedge vif.clk);
      vif.awvalid <= 1'b0;  /////disable write transaction
      vif.resetn  <= 1'b1;
      vif.arvalid <= 1'b1;
      vif.arid    <= tr.id;
      vif.arlen   <= tr.arlen;
      vif.arsize  <= 3'b010;    
      vif.arburst <= 2'b00;
      vif.rready  <= 1'b1;
        
      for(int i = 0; i < len; i++) begin // 0 1  2 3 4 5 6 7
       vif.araddr  <= tr.araddr;
       @(posedge vif.arready);
       @(posedge vif.clk);
      end
       
     @(negedge vif.rlast);
     vif.arvalid <= 1'b0;
     vif.rready  <= 1'b0;
     
    ->drvnext;
    
    
    
  endtask
  
  
  
  ///////////////////////////////read incr mode
  
    task incr_read(input transaction tr);
      
      int len = 0;
      len = tr.arlen + 1;
      $display("[DRV] : INCR MODE -> DATA READ");
      @(posedge vif.clk);
      vif.awvalid <= 1'b0;  /////disable write transaction
      vif.resetn  <= 1'b1;
      vif.arvalid <= 1'b1;
      vif.arid    <= tr.id;
      vif.arlen   <= tr.arlen;
      vif.arsize  <= 3'b010;    
      vif.arburst <= 2'b01;
      vif.rready  <= 1'b1;
      
  
        
      for(int i = 0; i< len; i++) begin
       vif.araddr  <= tr.araddr + 4*i;
       @(posedge vif.arready);
       @(posedge vif.clk);
      end
       
     @(negedge vif.rlast);
     vif.arvalid <= 1'b0;
     vif.rready  <= 1'b0;
      
     ->drvnext;
    
    
    
  endtask
  
  
  
  //////////////////////////////////////////wrap mode
  
    task wrap_read(input transaction tr);
    
      int len = 0;
      len = 8;
      $display("[DRV] : WRAP MODE -> DATA READ COMPLETE");
      @(posedge vif.clk);
      vif.awvalid <= 1'b0;  /////disable write transaction
      vif.resetn  <= 1'b1;
      vif.arvalid <= 1'b1;
      vif.arid    <= tr.id;
      vif.arlen   <= 4'b0111;
      vif.arsize  <= 3'b010;    
      vif.arburst <= 2'b10;
      vif.rready  <= 1'b1;     
      vif.araddr  <= tr.araddr;
      @(posedge vif.rvalid);
      @(posedge vif.clk);
      
 
  
        
      for(int i = 0; i< 7; i++) begin /// 0123456  
        vif.araddr  <= vif.addr_wraprd;      
        @(posedge vif.rvalid);
        @(posedge vif.clk);
      end
       
     @(negedge vif.rlast);
     vif.arvalid <= 1'b0;
     vif.rready  <= 1'b0;
 
     ->drvnext;
    
  endtask
  
  
  
 
  
  ///////////////////////////////////////////////////////main task
  
  
  task run();
    
    forever begin
             
      mbxgd.get(tr);
     /////////////////////////write mode check and sig gen 
      if(tr.awvalid == 1'b1) begin
              if(tr.awburst == 2'b00)
                begin
                 fixed_write(tr);
                end
              else if (tr.awburst == 2'b01)
                begin
                incr_write(tr);
                end
              else if (tr.awburst == 2'b10)
                begin
                wrap_write(tr);
                end
 
      end   
     
     
   /////////////////////////////read mode check and sig gen
      
       if(tr.arvalid == 1'b1) begin
                 if(tr.arburst  == 2'b00)
                begin
                  fixed_read(tr);
                end
            else if (tr.arburst == 2'b01)
                begin
                incr_read(tr);
                end
            else if (tr.arburst == 2'b10)
                begin
                wrap_read(tr);
                end
                
          end  
    end
  endtask
  
    
  
endclass
