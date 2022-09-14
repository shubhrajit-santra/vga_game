`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2019 18:56:34
// Design Name: 
// Module Name: clk_div
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


module clk_div
# (parameter COUNT_DIV = 50000)
(  input reset,
input clk_in,
output reg clk_div = 1
);
    
    reg [40:0] count_next = 0 ;
    reg [40:0] count_reg = 0 ;
    reg clk_div_next ;
    
    always@(posedge clk_in or posedge reset)
    if(reset==1'b1)
    count_reg <= 0 ;
    else
   count_reg <= count_next ;
    
    always@(*)begin
    count_next = count_reg ;
    if(count_reg==COUNT_DIV-1)
    count_next = 0 ;
    else
    count_next = count_reg + 1 ;
    end
    
    always@(posedge clk_in)
    if(reset==1'b1)
    clk_div <= 1 ;
    else
      clk_div <= clk_div_next ;
    
    
    always@(*) begin
    clk_div_next = clk_div ;
    if(count_reg==COUNT_DIV-1)
    clk_div_next = ~clk_div ;
    end
    
endmodule

