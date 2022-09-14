`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2019 16:47:36
// Design Name: 
// Module Name: top_VGA_game
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


module top_VGA_game(
input clk_100M,
input clear,
input game_on,
input game_start,
input jump,
input L,
input R,
input trigger,
input pause,
//output led0,
//output led1,
//output led2,
output H_sync,
output V_sync,
output [3:0] VGA_red,
output [3:0] VGA_green,
output [3:0] VGA_blue
);

wire clk_65M, clk_5M ;
clk_wiz cw(.clk_65M(clk_65M),.clk_5M(clk_5M),.clk_100M(clk_100M)); 

wire clk_250H ;
clk_div #(.COUNT_DIV(20000/2)) cd1(.reset(1'b0),.clk_in(clk_5M),.clk_div(clk_250H)) ; // put parameter here

wire clk_1H ;
clk_div #(.COUNT_DIV(2500000/2)) cd2(.reset(1'b0),.clk_in(clk_5M),.clk_div(clk_1H)) ;

wire game_startd ;
pb_debounce p1(.clk_250H(clk_250H),.inp_pb(game_start),.out_deb(game_startd)) ;

wire jumped ;
pb_debounce p2(.clk_250H(clk_250H),.inp_pb(jump),.out_deb(jumped)) ;

wire right ;
pb_debounce p3(.clk_250H(clk_250H),.inp_pb(R),.out_deb(right)) ;

wire left ;
pb_debounce p4(.clk_250H(clk_250H),.inp_pb(L),.out_deb(left)) ;

wire triggered ;
pb_debounce p5(.clk_250H(clk_250H),.inp_pb(trigger),.out_deb(triggered)) ;

wire [0:31] brom_counting_data ;
wire [8:0] brom_counting_addr ;

score_counting sc(
  .clka(clk_65M),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(brom_counting_addr),  // input wire [8 : 0] addra
  .douta(brom_counting_data)  // output wire [31 : 0] douta
);

wire [0:535] brom_intro_data ;
wire [8:0] brom_intro_addr ;
intro_blk my_intro (
  .clka(clk_65M),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(brom_intro_addr),  // input wire [8 : 0] addra
  .douta(brom_intro_data)  // output wire [535 : 0] douta
);
  
  
wire [0:2047] brom_road_data ;
wire [6:0] brom_road_addr ;
  blk_rom_road br(
  .clka(clk_65M),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(brom_road_addr),  // input wire [6 : 0] addra
  .douta(brom_road_data)  // output wire [2047 : 0] douta
);
  
wire [0:239] brom_dino_data ;
wire [8:0] brom_dino_addr ;  
blk_rom_dino bd (
  .clka(clk_65M),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(brom_dino_addr),  // input wire [8 : 0] addra
  .douta(brom_dino_data)  // output wire [239 : 0] douta
);  
    
wire [16:0] V_count, H_count ;
wire Vid_on ;
vga_ctrl vc (.clk_65M(clk_65M),.clear(clear),.V_sync(V_sync),.H_sync(H_sync),.V_count(V_count),.H_count(H_count),.Vid_on(Vid_on)) ;

vga_game vg (.clk_65M(clk_65M),
             .clk_1H(clk_1H),
             .clear(clear),
             .Vid_on(Vid_on),
             .game_on(game_on),
             .game_startd(game_startd),
             .jumped(jumped),
             .right(right),
             .left(left),
             .triggered(triggered),
             .pause(pause),
             .brom_counting_addr(brom_counting_addr),
             .brom_counting_data(brom_counting_data),
             .brom_road_addr(brom_road_addr),
             .brom_road_data(brom_road_data),
             .brom_intro_data( brom_intro_data),
             .brom_intro_addr( brom_intro_addr),
             .brom_dino_data( brom_dino_data),
             .brom_dino_addr( brom_dino_addr),
//             .led0(led0),
//             .led1(led1),
//             .led2(led2),
             .H_count(H_count),
             .V_count(V_count),
             .VGA_red(VGA_red),
             .VGA_green(VGA_green),
             .VGA_blue(VGA_blue)) ;
endmodule
