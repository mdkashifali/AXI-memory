class generator;
  
  transaction tr;
  mailbox #(transaction) mbxgd;
  
  event done; ///gen completed sending requested no. of transaction
  event drvnext; /// dr complete its wor;
  event sconext; ///scoreboard complete its work
 
   int count = 0;
  
  function new( mailbox #(transaction) mbxgd);
    this.mbxgd = mbxgd;   
    tr =new();
  endfunction
  
    task run();
    
    for(int i=0; i <= count; i++) begin
      assert(tr.randomize) else $error("Randomization Failed"); 
      
      if(tr.awburst == 2'b10)
        begin
          tr.awlen = 4'b0111;
        end
      
      
      if(tr.arburst == 2'b10)
        begin
          tr.arlen = 4'b0111;
        end
      
     // $display("[GEN] : WRITE : %0b READ : %0b BURST MODE : %0d",tr.awvalid, tr.arvalid, tr.awburst);
      $display("[GEN] : WR :%0b RD:%0b WRBUR : %0d RDBUR: %0d WRADDR :%0d RDADDR : %0d WLEN :%0d RLEN :%0d",tr.awvalid, tr.arvalid, tr.awburst, tr.arburst, tr.awaddr, tr.araddr, tr.awlen, tr.arlen);
      mbxgd.put(tr);
      @(drvnext);
      @(sconext);
    end
    ->done;
  endtask
  
   
endclass
