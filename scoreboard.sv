class scoreboard;
  
  transaction tr;
 
  
  mailbox #(transaction) mbxms;
  
 
  
  bit [31:0] temp;
  
  bit [7:0] data[128] = '{default:0};
  
  int count = 0;
  int len   = 0;
  
 
  
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  
  task run();
    
    forever 
      begin  
        
      
      mbxms.get(tr);
 
      
     if(tr.awvalid == 1'b1) begin
        data[tr.awaddr]     = tr.wdata[7:0];
        data[tr.awaddr + 1] = tr.wdata[15:8];
        data[tr.awaddr + 2] = tr.wdata[23:16];
        data[tr.awaddr + 3] = tr.wdata[31:24]; 
        
        $display("[SCO] : DATA STORED ADDR :%0x and DATA :%0x", tr.awaddr, tr.wdata[7:0]);
        end     
        
        if(tr.arvalid == 1'b1) begin
            temp = {data[tr.araddr + 3],data[tr.araddr + 2],data[tr.araddr + 1],data[tr.araddr] };
           
        $display("[SCO] : DATA READ ADDR :%0x and DATA :%0x MEM :%0x", tr.araddr, tr.rdata, temp);
          if(tr.rdata == 32'hc0c0c0c) 
          begin
           $display("[SCO] : DATA MATCHED : EMPTY LOCATION");
          end
          else if (tr.rdata == temp)
          begin
           $display("[SCO] : DATA MATCHED");
          end
          else
           begin
           $display("[SCO] : DATA MISMATCHED");
           end
       
        end
        
     
    end
  endtask
  
  
endclass
