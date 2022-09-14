`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2019 16:57:10
// Design Name: 
// Module Name: vga_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_ctrl(
input clk_65M,
input clear,
output reg V_sync,
output reg H_sync,
output [16:0] H_count,
output [16:0] V_count,
output reg Vid_on
 );
 
 parameter HPIXELS = 1344 ;
 parameter VLINES = 806 ; //change to 806
 parameter HBP = 296 ;
 parameter HFP = 1320 ;
 parameter VBP = 35 ;    
 parameter VFP = 803 ;
 parameter HSP = 136 ;
 parameter VSP = 6 ;    //change to 6

reg [16:0] H_count_reg, H_count_next ;

always@(posedge clk_65M)    // code for H_count
begin
  if(clear==1'b1)
  H_count_reg <= 17'd0 ;
  else
  H_count_reg <= H_count_next ;
end

always@(*)
begin
        H_count_next = H_count_reg ;
    if(H_count_reg == HPIXELS-1) 
        H_count_next = 17'd0 ;
    else
        H_count_next = H_count_reg + 1 ;     
end  
 
assign H_count = H_count_reg ;
 
always@(*)      //  Code for H_sync
begin
if(H_count_reg < HSP) 
H_sync = 1'b0 ;
else
H_sync = 1'b1 ;
end 

reg V_count_en ;        // Code for V_count_en
always@(*)
begin
    if(H_count_reg==HPIXELS-1)
    V_count_en <= 1'b1 ;
    else
    V_count_en <= 1'b0 ;
 end


reg [16:0] V_count_reg, V_count_next ;

always@(posedge clk_65M)    // code for V_count
begin
  if(clear==1'b1)
  V_count_reg <= 17'd0 ;
  else
  V_count_reg <= V_count_next ;
end

always@(*)
begin
        V_count_next = V_count_reg ;
   if(V_count_en == 1'b1)    
   begin 
    if(V_count_reg == VLINES-1) 
        V_count_next = 17'd0 ;
    else 
        V_count_next = V_count_reg + 1 ;     
   end
end  
 
assign V_count = V_count_reg ;

always@(*)      //  Code for V_sync
begin
if(V_count_reg < VSP) 
V_sync = 1'b0 ;
else
V_sync = 1'b1 ;
end 

always@(*)      // Code for Vid_on
    begin
       if((H_count_reg>HBP) && (H_count_reg<HFP) && (V_count_reg>VBP) && (V_count_reg<VFP))
          Vid_on = 1'b1 ;
       else
          Vid_on = 1'b0 ;
    end

endmodule
