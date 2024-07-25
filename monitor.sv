class monitor;
    
  virtual axi_if vif;
 
  
  transaction tr;
 
  event sconext;
  int len = 0;
  
  mailbox #(transaction) mbxms;
 
 
  
 
  
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  
  task run();
    
    tr = new();
    
    forever 
      begin
        
        
      @(posedge vif.clk);
        
      //////////////////////////write logic  
        
    if(vif.awvalid == 1'b1) begin 
         len = vif.awlen + 1;  
         tr.awvalid = vif.awvalid;
         tr.arvalid = vif.arvalid;
         
         
      for(int i = 0; i< len; i++) begin
       @(posedge vif.wready); 
       @(posedge vif.clk);
       tr.awaddr = vif.awaddr;
       tr.wdata  = vif.wdata;
       tr.awburst = vif.awburst;   
       mbxms.put(tr);
       $display("[MON] : ADDR : %0x DATA : %0x BURST TYPE : %0d",tr.awaddr, tr.wdata, tr.awburst);    
      end
       
      @(posedge vif.clk);
      @(negedge vif.bvalid);
      @(posedge vif.clk);
      $display("[MON] : Transaction Complete");  
   end
 
     /////////////////////read logic   
        
       if(vif.arvalid == 1'b1)
        begin
         len = vif.arlen + 1;    
         tr.awvalid = vif.awvalid;
         tr.arvalid = vif.arvalid;
         
     
      for(int i = 0; i< len; i++) begin  
       @(posedge  vif.rvalid);
       @(posedge vif.clk);
       tr.rdata  = vif.rdata;
       tr.arburst = vif.arburst;
       tr.araddr = vif.araddr;
       mbxms.put(tr); 
       $display("[MON] : ADDR : %0x DATA : %0x BURST TYPE : %0d",tr.araddr, tr.rdata, tr.arburst);
       end
       
      @(posedge vif.clk);
      @(negedge vif.rlast);
      @(posedge vif.clk);
      $display("[MON] : Transaction Complete");
      end
       ->sconext; 
      end 
  endtask
 
  
  
endclass
