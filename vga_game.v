`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2019 18:24:43
// Design Name: 
// Module Name: vga_game
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


module vga_game(
input clk_65M,
input clk_1H,
input clear,
input Vid_on,
input game_on,
input game_startd,
input jumped,
input left,
input right,
input triggered,
input pause,
input [16:0] H_count,
input [16:0] V_count,
input  wire[0:31] brom_counting_data,
input wire[0:535] brom_intro_data,
input wire[0:2047] brom_road_data,
input wire[0:239] brom_dino_data,
//output wire led0,
//output wire led1,
//output wire led2,
output wire[16:0] brom_counting_addr,
output wire[16:0] brom_intro_addr,
output wire[16:0] brom_road_addr,
output wire[16:0] brom_dino_addr,
output reg [3:0] VGA_red,
output reg [3:0] VGA_green,
output reg [3:0] VGA_blue
    );
    
 parameter HPIXELS = 1344 ;
 parameter VLINES = 806 ; //change to 806
 parameter HBP = 296 ;
 parameter HFP = 1320 ;
 parameter VBP = 35 ;    
 parameter VFP = 803 ;
 parameter HSP = 136 ;
 parameter VSP = 6 ;  
 parameter HSCREEN = 1024 ;
 parameter VSCREEN = 768 ;
 
 parameter GROUND_START = 650 ;
 parameter GROUND_SIZE = 10 ;
 reg gnd_on ;
 
 parameter DINO_X_SIZE = 240 ;           // 80
 parameter DINO_Y_STOP = 650 ;
 parameter DINO_Y_SIZE = 160 ;          // 160
 parameter VELOCITY_X_DINO_DEFAULT = 12 ;
 parameter VELOCITY_Y_DINO_DEFAULT = -42 ;
 parameter LEFT = 0 ;
 parameter RIGHT = 400 ;
 parameter DINO_X_START = (LEFT + RIGHT)/2 ;
 
 
 
 parameter COUNTING_1ST_X_START = 961 ;
  parameter COUNTING_1ST_Y_START = 50 ;
  parameter COUNTING_1ST_SIZE = 31 ;
  
  
  parameter COUNTING_2ND_X_START = 920 ;
   parameter COUNTING_2ND_Y_START = 50 ;
   parameter COUNTING_2ND_SIZE = 31 ;
   
 
 ///////////////////////////////////Code for Dino/////////////////////////////////////
 

 wire [16:0] dino_ystart, dino_ystop ;
 wire [16:0] dino_xstart, dino_xstop ;
 
 
 reg [16:0] dino_ystop_reg = DINO_Y_STOP ;
 reg [16:0] dino_xstart_reg = (LEFT + RIGHT)/2 ;

 assign dino_ystop = dino_ystop_reg ;
 assign dino_ystart = dino_ystop_reg - DINO_Y_SIZE ;
 assign dino_xstart = dino_xstart_reg ;
 assign dino_xstop = dino_xstart_reg + DINO_X_SIZE ;
 
 reg [16:0] dino_ystop_next = DINO_Y_STOP;
 reg [16:0] dino_xstart_next = (LEFT + RIGHT)/2 ;
 reg game_stop ;
 always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    begin
    dino_ystop_reg <= DINO_Y_STOP ;
    dino_xstart_reg <= (LEFT + RIGHT)/2 ;
    end
    else
    begin
    dino_ystop_reg <= dino_ystop_next ;
    dino_xstart_reg <= dino_xstart_next ;
    end
 end


wire refr_tick ;
assign refr_tick = ((H_count==0) && (V_count==0)) ; 
 
reg [16:0]  dino_ystop_delta_reg ;
reg [16:0] dino_xstart_delta_reg ;

always@(*)
begin
        dino_ystop_next = dino_ystop_reg ;
    if(game_stop==1'b1)
        dino_ystop_next = DINO_Y_STOP ;
    else if(refr_tick == 1'b1 && pause==1'b0)
        dino_ystop_next = dino_ystop_reg + dino_ystop_delta_reg ;
end 


always@(*)
begin
        dino_xstart_next = dino_xstart_reg ;
    if(game_stop==1'b1)
        dino_xstart_next = (LEFT+RIGHT)/2 ;
    else if(refr_tick == 1'b1 && pause==1'b0)
        dino_xstart_next = dino_xstart_reg + dino_xstart_delta_reg ;
end 


reg [16:0] dino_ystop_delta_next ;
reg [16:0] dino_xstart_delta_next ;

always@(posedge clk_65M)
begin
    if(game_stop==1'b1)
        begin
        dino_ystop_delta_reg <= 0 ;
        dino_xstart_delta_reg <= 0 ;
        end
    else
        begin
        dino_ystop_delta_reg <= dino_ystop_delta_next ;
        dino_xstart_delta_reg <= dino_xstart_delta_next ;
        end
end
 
reg [16:0] dino_velocity_yreg = VELOCITY_Y_DINO_DEFAULT ;
reg [16:0] dino_velocity_xreg = VELOCITY_X_DINO_DEFAULT ; 
reg go ;
always@(*)
begin
        dino_ystop_delta_next = 0 ;
    if(go==1'b1 && pause==1'b0)
        dino_ystop_delta_next = dino_velocity_yreg ;  
end

always@(*)
begin
        dino_xstart_delta_next = 0 ;
    if(left==1'b1 && dino_xstart_reg>=LEFT+VELOCITY_X_DINO_DEFAULT && pause==1'b0)
        dino_xstart_delta_next = -dino_velocity_xreg ;
    else if(right==1'b1 && dino_xstart_reg<=RIGHT-VELOCITY_X_DINO_DEFAULT && pause==1'b0)
         dino_xstart_delta_next = dino_velocity_xreg ; 
end  

reg [16:0] dino_velocity_ynext = VELOCITY_Y_DINO_DEFAULT ; 
reg [16:0] dino_velocity_xnext = VELOCITY_X_DINO_DEFAULT ; 

always@(posedge clk_65M)
begin
if(game_stop==1'b1)
dino_velocity_yreg <= VELOCITY_Y_DINO_DEFAULT ;
else
dino_velocity_yreg <= dino_velocity_ynext ;
end 


always@(*)
begin
    dino_velocity_ynext = dino_velocity_yreg ;
     if(go==1'b1 && refr_tick==1'b1 && dino_velocity_yreg==-VELOCITY_Y_DINO_DEFAULT && pause==1'b0)
        dino_velocity_ynext = VELOCITY_Y_DINO_DEFAULT ;
   else if(go==1'b1 && refr_tick==1'b1 && pause==1'b0)
        dino_velocity_ynext = dino_velocity_yreg + 2 ;
end
      
always@(posedge clk_65M)
begin 
 if(game_stop==1'b1)
   go <= 1'b0 ;
 else if(jumped==1'b1 && refr_tick==1'b1 && pause==1'b0)
    go <= 1'b1 ;
 else if(dino_velocity_yreg==-VELOCITY_Y_DINO_DEFAULT && refr_tick==1'b1 && pause==1'b0)
    go <= 1'b0 ;
end

// Code_for_bullet

parameter BULLET_X_SIZE = 30 ;
parameter BULLET_Y_SIZE = 20 ;
parameter NOZZLE = 20 ;
parameter BULLET_VELOCITY_DEFAULT = 10 ;

 wire [16:0] obs_xstart, obs_xstop, obs_ystart, obs_ystop ;
  wire [16:0] obs1_xstart, obs1_xstop, obs1_ystart, obs1_ystop ;
reg fire ;

wire bullet_obs_hit, bullet_obs1_hit ;

wire [16:0] bullet_xstart, bullet_xstop, bullet_ystart, bullet_ystop ;
reg [16:0] bullet_xstart_reg = DINO_X_START + DINO_X_SIZE - BULLET_X_SIZE ;
reg [16:0] bullet_ystart_reg = DINO_Y_STOP - DINO_Y_SIZE + NOZZLE ;
reg bullet_on ;
 always@(*)
 begin
    if(((H_count>=bullet_xstart+HBP)&&(H_count<bullet_xstop+HBP))&&((V_count>=bullet_ystart+VBP)&&(V_count<bullet_ystop+VBP)))
        bullet_on = 1'b1 ;
    else
        bullet_on = 1'b0 ;
 end
 
 assign bullet_xstart = bullet_xstart_reg ;
 assign bullet_xstop = bullet_xstart_reg + BULLET_X_SIZE ;
 assign bullet_ystart = bullet_ystart_reg ;
 assign bullet_ystop = bullet_ystart_reg + BULLET_Y_SIZE ;
 
 
 reg [16:0] bullet_xstart_next = DINO_X_START + DINO_X_SIZE - BULLET_X_SIZE ;
 reg [16:0] bullet_ystart_next = DINO_Y_STOP - DINO_Y_SIZE + NOZZLE ;
 always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    bullet_xstart_reg <= dino_xstop - BULLET_X_SIZE ;
    else
    bullet_xstart_reg <= bullet_xstart_next ;
 end     
 
 
 always@(*)
begin
        bullet_xstart_next = bullet_xstart_reg ;
    if(game_stop==1'b1)
        bullet_xstart_next = dino_xstop - BULLET_X_SIZE ;
    else if(refr_tick == 1'b1 && fire==1'b1 && pause==1'b0)
        bullet_xstart_next = bullet_xstart_reg + BULLET_VELOCITY_DEFAULT ;
    else if(fire==1'b1 && pause==1'b0)   
        bullet_xstart_next = bullet_xstart_reg ;
    else if(pause==1'b0)
        bullet_xstart_next = dino_xstop - BULLET_X_SIZE ;   
end 

 always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    bullet_ystart_reg <= dino_ystart + NOZZLE ;
    else
    bullet_ystart_reg <= bullet_ystart_next ;
 end   
 
 reg [16:0] bullet_ystart_latch ;
 
  always@(*)
begin
        bullet_ystart_next = bullet_ystart_reg ;
    if(game_stop==1'b1)
        bullet_ystart_next = dino_ystart + NOZZLE ;
    else if(fire==1'b1 && pause==1'b0)
        bullet_ystart_next = bullet_ystart_latch ;
    else if(pause==1'b0)
        bullet_ystart_next = dino_ystart + NOZZLE ;   
end   
 
 always@(posedge fire)
 begin
    bullet_ystart_latch <= dino_ystart + NOZZLE ;
 end
 
 
 assign bullet_obs_hit = bullet_xstop>=obs_xstart && bullet_xstart<=obs_xstop && bullet_ystop>=obs_ystart ;
 assign bullet_obs1_hit = bullet_xstop>=obs1_xstart && bullet_xstart<=obs1_xstop && bullet_ystart<=obs1_ystop ;
 
always@(posedge clk_65M)
begin
 if(game_stop==1'b1)
   fire <= 1'b0 ;
 else if(( bullet_obs_hit  ||  bullet_obs1_hit  || bullet_xstop>=HSCREEN) && refr_tick==1'b1 && pause==1'b0)
    fire <= 1'b0 ;
 else if(triggered==1'b1 && refr_tick==1'b1 && pause==1'b0)
    fire <= 1'b1 ;
end     

/////////////////////////////////////// Code for obstacle//////////////////////////////

 
 parameter OBS_X_START_DEFAULT = 900 ;
 parameter OBS_X_START_DEFAULT1 = 1200 ;
 parameter OBS_X_SIZE = 50 ;
  parameter OBS_X_SIZE1 = 50 ;
 parameter OBS_Y_STOP = 650 ;
 parameter OBS_Y_START1 = 0 ;
 parameter OBS_Y_SIZE = 100 ;
 parameter OBS_Y_SIZE1 = 300 ;
 parameter OBS_VELOCITY_DEFAULT = -4 ;
  parameter OBS_VELOCITY_DEFAULT1 = -4 ;
 parameter SHIFT = 1100 ;
 parameter SHIFT1 = 1400 ;
 parameter OBS_TOP = 180 ;
 parameter OBS_TOP1 = 550 ;
 parameter OBS_BOTTOM = 20 ;
 parameter OBS_BOTTOM1 = 50 ;
 

 
 reg obs_on, obs1_on ;

 reg [16:0] obs_y_size_next = OBS_Y_SIZE ;
 reg [16:0] obs_y_size_reg = OBS_Y_SIZE ;
 
 
 reg [16:0] obs_xstart_reg = OBS_X_START_DEFAULT ;

 assign obs_xstart = obs_xstart_reg ;
 assign obs_xstop = obs_xstart_reg + OBS_X_SIZE ;
 assign obs_ystart = OBS_Y_STOP-obs_y_size_reg ;
 assign obs_ystop = OBS_Y_STOP ;
 
 

 reg [16:0] obs_xstart_next = OBS_X_START_DEFAULT ;
 always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    obs_xstart_reg <= OBS_X_START_DEFAULT ;
    else
    obs_xstart_reg <= obs_xstart_next ;
 end

 
reg [16:0] obs_xstart_delta_reg = OBS_VELOCITY_DEFAULT ;

always@(*)
begin
        obs_xstart_next = obs_xstart_reg ;
    if(game_stop==1'b1)
        obs_xstart_next = OBS_X_START_DEFAULT ;
    else if(bullet_obs_hit==1'b1 && refr_tick==1'b1 && pause==1'b0)    
         obs_xstart_next = SHIFT ; 
    else if(obs_xstop<-OBS_VELOCITY_DEFAULT && refr_tick == 1'b1 && pause==1'b0)
        obs_xstart_next = SHIFT ;  
    else if(refr_tick == 1'b1 && pause==1'b0)
        obs_xstart_next = obs_xstart_reg + OBS_VELOCITY_DEFAULT ;
end 






always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    obs_y_size_reg <= OBS_Y_SIZE ;
    else
    obs_y_size_reg <= obs_y_size_next ;
 end
 
 reg [16:0] obs_size_delta_reg = 2 ;
 always@(*)
begin
        obs_y_size_next = obs_y_size_reg ;
    if(game_stop==1'b1)
        obs_y_size_next = OBS_Y_SIZE ;
    else if(refr_tick == 1'b1 && pause==1'b0)
        obs_y_size_next = obs_y_size_reg + obs_size_delta_reg ; 
end 

reg [16:0] obs_size_delta_next = 2 ;
always@(posedge clk_65M)
begin
    if(game_stop==1'b1)
        obs_size_delta_reg <= 2 ;
    else
        obs_size_delta_reg <= obs_size_delta_next ;  
end

always@(*)
begin
       obs_size_delta_next = obs_size_delta_reg ;
       if(obs_y_size_reg>=OBS_TOP && pause==1'b0)
          obs_size_delta_next = -2 ;
       else if(obs_y_size_reg<=OBS_BOTTOM && pause==1'b0)
          obs_size_delta_next = 2 ; 
end  

// obs2

 reg [16:0] obs1_y_size_next = OBS_Y_SIZE1 ;
 reg [16:0] obs1_y_size_reg = OBS_Y_SIZE1 ;
 
 
 reg [16:0] obs1_xstart_reg = OBS_X_START_DEFAULT1 ;

 assign obs1_xstart = obs1_xstart_reg ;
 assign obs1_xstop = obs1_xstart_reg + OBS_X_SIZE1 ;
 assign obs1_ystart = OBS_Y_START1 ;
 assign obs1_ystop = OBS_Y_START1 + obs1_y_size_reg ;
 
 

 reg [16:0] obs1_xstart_next = OBS_X_START_DEFAULT1 ;
 always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    obs1_xstart_reg <= OBS_X_START_DEFAULT1 ;
    else
    obs1_xstart_reg <= obs1_xstart_next ;
 end

 
reg [16:0] obs1_xstart_delta_reg = OBS_VELOCITY_DEFAULT1 ;

always@(*)
begin
        obs1_xstart_next = obs1_xstart_reg ;
    if(game_stop==1'b1)
        obs1_xstart_next = OBS_X_START_DEFAULT1 ;
    else if(bullet_obs1_hit==1'b1 && refr_tick==1'b1 && pause==1'b0)    
         obs1_xstart_next = SHIFT1 ; 
    else if(obs1_xstop<-OBS_VELOCITY_DEFAULT && refr_tick == 1'b1 && pause==1'b0)
        obs1_xstart_next = SHIFT1 ;  
    else if(refr_tick == 1'b1 && pause==1'b0)
        obs1_xstart_next = obs1_xstart_reg + OBS_VELOCITY_DEFAULT1 ;
end 






always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    obs1_y_size_reg <= OBS_Y_SIZE1 ;
    else
    obs1_y_size_reg <= obs1_y_size_next ;
 end
 
 reg [16:0] obs1_size_delta_reg = 2 ;
 always@(*)
begin
        obs1_y_size_next = obs1_y_size_reg ;
    if(game_stop==1'b1)
        obs1_y_size_next = OBS_Y_SIZE1 ;
    else if(refr_tick == 1'b1 && pause==1'b0)
        obs1_y_size_next = obs1_y_size_reg + obs1_size_delta_reg ; 
end 

reg [16:0] obs1_size_delta_next = 2 ;
always@(posedge clk_65M)
begin
    if(game_stop==1'b1)
        obs1_size_delta_reg <= 2 ;
    else
        obs1_size_delta_reg <= obs1_size_delta_next ;  
end

always@(*)
begin
       obs1_size_delta_next = obs1_size_delta_reg ;
       if(obs1_y_size_reg>=OBS_TOP1 && pause==1'b0)
          obs1_size_delta_next = -2 ;
       else if(obs1_y_size_reg<=OBS_BOTTOM1 && pause==1'b0)
          obs1_size_delta_next = 2 ; 
end  
// parameter OBS_VELOCITY_DEFAULT = -8 ;
 /*

 obstacle ob1 (                             .clk_65M(clk_65M),
                                                .game_stop(game_stop),
                                                .refr_tick(refr_tick),
                                                .bullet_hit(bullet_obs_hit),
                                                .obs_xstart(obs_xstart),
                                                .obs_xstop(obs_xstop),
                                                .obs_ystart(obs_ystart),
                                                .obs_ystop(obs_ystop)
                                                ) ; 
                                             
obstacle #(1500,50,650,150,-8,1500,180,100) ob2 (.clk_65M(clk_65M),
                                                .game_stop(game_stop),
                                                .refr_tick(refr_tick),
                                                .bullet_hit(bullet_obs1_hit),
                                                .obs_xstart(obs1_xstart),
                                                .obs_xstop(obs1_xstop),
                                                .obs_ystart(obs1_ystart),
                                                .obs_ystop(obs1_ystop)
                                                ) ;                                                 
                
 */
 always@(*)
 begin
    if(((H_count>=obs_xstart+HBP)&&(H_count<obs_xstop+HBP))&&((V_count>=obs_ystart+VBP)&&(V_count<obs_ystop+VBP)))
        obs_on = 1'b1 ;
    else
        obs_on = 1'b0 ;
 end
 
  always@(*)
 begin
    if(((H_count>=obs1_xstart+HBP)&&(H_count<obs1_xstop+HBP))&&((V_count>=obs1_ystart+VBP)&&(V_count<obs1_ystop+VBP)))
        obs1_on = 1'b1 ;
    else
        obs1_on = 1'b0 ;
 end
 
 
 /*
 reg [16:0] obs_xstart_reg = OBS_X_START_DEFAULT ;

 assign obs_xstart = obs_xstart_reg ;
 assign obs_xstop = obs_xstart_reg + OBS_X_SIZE ;
 assign obs_ystart = OBS_Y_STOP-obs_y_size_reg ;
 assign obs_ystop = OBS_Y_STOP ;
 
 reg [16:0] obs_xstart_next = OBS_X_START_DEFAULT ;
 always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    obs_xstart_reg <= OBS_X_START_DEFAULT ;
    else
    obs_xstart_reg <= obs_xstart_next ;
 end

 
reg [16:0] obs_xstart_delta_reg = OBS_VELOCITY_DEFAULT ;

always@(*)
begin
        obs_xstart_next = obs_xstart_reg ;
    if(game_stop==1'b1)
        obs_xstart_next = OBS_X_START_DEFAULT ;
    else if((bullet_xstop>=obs_xstart && bullet_xstart<=obs_xstop && bullet_ystop>=obs_ystart) && refr_tick==1'b1)    
         obs_xstart_next = SHIFT ; 
    else if(obs_xstop<-OBS_VELOCITY_DEFAULT && refr_tick == 1'b1)
        obs_xstart_next = SHIFT ;  
    else if(refr_tick == 1'b1)
        obs_xstart_next = obs_xstart_reg + OBS_VELOCITY_DEFAULT ;
end 

 
always@(posedge clk_65M)
 begin
    if(game_stop==1'b1)
    obs_y_size_reg <= OBS_Y_SIZE ;
    else
    obs_y_size_reg <= obs_y_size_next ;
 end
 
 reg [16:0] obs_size_delta_reg = 1 ;
 always@(*)
begin
        obs_y_size_next = obs_y_size_reg ;
    if(game_stop==1'b1)
        obs_y_size_next = OBS_Y_SIZE ;
    else if(refr_tick == 1'b1)
        obs_y_size_next = obs_y_size_reg + obs_size_delta_reg ; 
end 

reg [16:0] obs_size_delta_next = 1 ;
always@(posedge clk_65M)
begin
    if(game_stop==1'b1)
        obs_size_delta_reg <= 1 ;
    else
        obs_size_delta_reg <= obs_size_delta_next ;  
end

always@(*)
begin
       obs_size_delta_next = obs_size_delta_reg ;
       if(obs_y_size_reg>=OBS_TOP)
          obs_size_delta_next = -2 ;
       else if(obs_y_size_reg<=OBS_BOTTOM)
          obs_size_delta_next = 2 ; 
end  
*/

// Code fo score counting
wire [6:0] score;
reg [6:0] count_score_reg = 0 ;
reg [6:0] count_score_next = 0 ;
always@(posedge clk_65M)
 begin
        if(game_stop==1'b1)
        count_score_reg <= 0 ;
        else
        count_score_reg <= count_score_next ;
 end
 
 
 wire screen_obs_hit, screen_obs1_hit ;
 assign screen_obs_hit = obs_xstop<-OBS_VELOCITY_DEFAULT ;
 assign screen_obs1_hit = obs1_xstop<-OBS_VELOCITY_DEFAULT1 ;
  
 always@(*)
 begin
        count_score_next=count_score_reg ;
    if((screen_obs_hit  || screen_obs1_hit ) && refr_tick == 1'b1 && pause==1'b0)
        count_score_next=count_score_reg + 1 ;
    else if((bullet_obs_hit  ||  bullet_obs1_hit ) && refr_tick==1'b1 && pause==1'b0)    
        count_score_next=count_score_reg + 1 ;
 end
 assign score = count_score_reg ;


//**********************COUNTING DIGIT DISPLAYYYYYYYYYYYYYYYYYYYYYYY**************************************
wire[3:0] score_ones;
wire [3:0] score_tens;


bin2bcd b8( .number(score),
            .tens(score_tens),
            .ones(score_ones)
          );


 //wire[0:31] brom_counting_1st_data;
 wire[16:0] brom_counting_1st_addr;
 
  //wire[0:31] brom_counting_2nd_data;
  wire[16:0] brom_counting_2nd_addr;
 
 reg counting_1st_on;
 reg counting_1st;
 wire [16:0] rom_counting_1st_addr,rom_counting_1st_pix;
 always@(*)
  begin
     if((H_count>= COUNTING_1ST_X_START + HBP )&&(H_count < HBP + COUNTING_1ST_X_START + COUNTING_1ST_SIZE)
     &&(V_count>= COUNTING_1ST_Y_START + VBP ) && (V_count<COUNTING_1ST_Y_START + COUNTING_1ST_SIZE +VBP))
         counting_1st_on = 1'b1 ;
     else
         counting_1st_on = 1'b0 ;
  end
  
  
  reg counting_2nd_on;
   reg counting_2nd;
   wire [16:0] rom_counting_2nd_addr,rom_counting_2nd_pix;
   always@(*)
    begin
       if((H_count>= COUNTING_2ND_X_START + HBP )&&(H_count < HBP + COUNTING_2ND_X_START + COUNTING_2ND_SIZE)
       &&(V_count>= COUNTING_2ND_Y_START + VBP ) && (V_count<COUNTING_2ND_Y_START + COUNTING_2ND_SIZE +VBP))
           counting_2nd_on = 1'b1 ;
       else
           counting_2nd_on = 1'b0 ;
    end
   
   
   
   
assign rom_counting_1st_addr = V_count[4:0] - VBP[4:0] - COUNTING_1ST_Y_START;
     
assign brom_counting_1st_addr = rom_counting_1st_addr[4:0] + score_ones*32;
     
assign rom_counting_1st_pix = H_count[4:0] - HBP[4:0] - COUNTING_1ST_X_START;

assign rom_counting_2nd_addr = V_count[4:0] - VBP[4:0] - COUNTING_2ND_Y_START;
 
assign brom_counting_2nd_addr = rom_counting_2nd_addr[4:0] + score_tens*32;
 
assign rom_counting_2nd_pix = H_count[4:0] - HBP[4:0] - COUNTING_2ND_X_START;

assign brom_counting_addr = (counting_1st_on== 1'b1)? brom_counting_1st_addr : brom_counting_2nd_addr;

 
/*
reg [16:0] obs_xstart_delta_next = OBS_VELOCITY_DEFAULT ;

always@(posedge clk_65M)
begin
    if(game_stop==1'b1)
        obs_xstart_delta_reg <= OBS_VELOCITY_DEFAULT ;
    else
        obs_xstart_delta_reg <= obs_xstart_delta_next ;
end
 
reg [16:0] obs_velocity_reg = OBS_VELOCITY_DEFAULT ; 
always@(*)
begin
        obs_xstart_delta_next = obs_velocity_reg ;
end 
*/

//game_stop_conditions

wire dino_obs_hit, dino_obs1_hit ;
assign dino_obs_hit = (obs_xstop>= dino_xstart) && (obs_xstart<= (dino_xstart + DINO_X_SIZE)) && (dino_ystop>=obs_ystart) ;
assign dino_obs1_hit = (obs1_xstop>= dino_xstart) && (obs1_xstart<= (dino_xstart + DINO_X_SIZE)) && (dino_ystart<=obs1_ystop) ;

/*

reg dino_obs_hit_reg =1'b0 ;
reg dino_obs_hit_next = 1'b0 ;
reg dino_obs1_hit_reg = 1'b0 ;
reg dino_obs1_hit_next = 1'b0 ;

always@(posedge clk_65M)
begin
    dino_obs_hit_next <= dino_obs_hit ;
    dino_obs_hit_reg <= dino_obs_hit_next ;
    dino_obs1_hit_next <= dino_obs1_hit ;
    dino_obs1_hit_reg <= dino_obs1_hit_next ;
end


reg [1:0] life_count_reg = 3 ;
reg [1:0] life_count_next = 3 ;
always@(clk_65M)
begin
if(game_stop)
    life_count_reg <= 3 ;
else
    life_count_reg <= life_count_next ;
end

always@(*)
begin
        life_count_next = life_count_reg ;
    if(game_stop==1'b1)
        life_count_next = 3 ;    
        
     else if((dino_obs_hit_next==1'b1 && dino_obs_hit_reg==1'b0)||(dino_obs1_hit_next==1'b1 && dino_obs1_hit_reg==1'b0))  
        life_count_next = life_count_reg-1 ; 
end
*/

/*
reg game_over = 1'b1 ;
always@(posedge clk_65M)
begin
    if(game_startd)
        game_over <= 1'b0 ;
    else if(game_stop)
        game_over <= 1'b1 ;    
end
*/

//wire led0, led1, led2 ;
/*
assign led0 = (~game_stop) ;
assign led1 = (~game_stop) && (life_count_reg==2'd2 || life_count_reg==2'd3);
assign led2 = (~game_stop) && (life_count_reg==2'd3) ;

*/

always@(posedge clk_65M)    // game_stop conditions
begin
   if(clear==1'b1)
      game_stop = 1'b1 ;
   else if(game_on==1'b0)
      game_stop = 1'b1 ;
   else if(dino_obs_hit || dino_obs1_hit) 
      game_stop=1'b1 ;  
   else if(game_startd==1'b1)
      game_stop = 1'b0 ; 
end      

// Dino_run_effect

wire run ;
assign run = clk_1H && (~pause) && (~game_stop) ;

reg dino_on, dino ;
always@(*)
 begin
    if(((H_count>=dino_xstart+HBP)&&(H_count<dino_xstop+HBP))&&((V_count>=dino_ystart+VBP)&&(V_count<dino_ystop+VBP)))
        dino_on = 1'b1 ;
    else
        dino_on = 1'b0 ;
 end

wire [8:0] rom_dino_addr;
wire [7:0] rom_dino_pix ;
assign rom_dino_addr = V_count[8:0] - VBP[8:0] - dino_ystart[8:0] ;
assign brom_dino_addr = rom_dino_addr[8:0] + run * DINO_Y_SIZE ;
assign rom_dino_pix = H_count[7:0] - HBP[7:0] - dino_xstart[7:0] ;   
   
 // Ground_on_condtion
 always@(*)
  begin
  if((V_count>=GROUND_START + VBP)&&(V_count<GROUND_START+GROUND_SIZE+VBP))
   gnd_on = 1'b1 ;
   else
   gnd_on = 1'b0 ;
  end
 
 
 parameter ROAD_X_START = 0 ;
 parameter ROAD_Y_START = 660 ;
 parameter ROAD_X_SIZE = 2048 ;
 parameter ROAD_Y_SIZE = 108 ; 
 parameter ROAD_X_VELOCITY = -4 ;
 
 reg road_on, road ;
 wire [16:0] road_ystart, road_ystop ;
 wire [16:0] road_xstart, road_xstop ;
 
 always@(*)
 begin
    if((V_count>=road_ystart+VBP)&&(V_count<road_ystop+VBP))
        road_on = 1'b1 ;
    else
        road_on = 1'b0 ;
 end
 
 reg [16:0] road_ystart_reg = ROAD_Y_START ;
 reg [16:0] road_xstart_reg = ROAD_X_START ;

 assign road_ystop = road_ystart_reg + ROAD_Y_SIZE ;
 assign road_ystart = road_ystart_reg ;
 assign road_xstart = road_xstart_reg ;
 assign road_xstop = road_xstart_reg + ROAD_X_SIZE ;
 
 

reg [16:0] road_xstart_next = ROAD_X_START ;

always@(posedge clk_65M)
begin
    if(game_stop==1'b1)
        road_xstart_reg <= 0 ;
    else
        road_xstart_reg <= road_xstart_next ;    
end

always@(*)
begin
        road_xstart_next = road_xstart_reg ; 
    if(road_xstop<=1024 && pause==1'b0)   
        road_xstart_next = ROAD_X_START ;
    if(refr_tick==1'b1 && pause==1'b0)
        road_xstart_next = road_xstart_reg +  ROAD_X_VELOCITY ;
end 
  
  wire [11:0] rom_road_pix ;
  assign brom_road_addr = V_count[7:0] - VBP[7:0] - road_ystart[7:0] ;
  assign rom_road_pix = H_count[11:0] - HBP[11:0] - road_xstart[11:0] ;    
  
   // Intro_logic
  parameter INTRO_X_START = 250 ;        
  parameter INTRO_X_SIZE = 536 ;
  parameter INTRO_Y_START = 100 ;
  parameter INTRO_Y_SIZE = 472 ;
  reg intro_on, intro ;
   always@(*)
  begin
    if((H_count>=INTRO_X_START+HBP)&&(H_count<=INTRO_X_START+HBP+INTRO_X_SIZE)
    &&(V_count>=INTRO_Y_START+VBP)&&(V_count<=INTRO_Y_START+VBP+INTRO_Y_SIZE))
       intro_on = 1 ;
    else
       intro_on = 0 ;
  end
  
  wire [10:0] rom_intro_pix ;
  assign brom_intro_addr = V_count[9:0] - VBP[9:0] - INTRO_Y_START ;
  assign rom_intro_pix = H_count[10:0] - HBP[10:0] - INTRO_X_START ;  
  
  
 always@(*)
 begin
    VGA_red = 4'b0000 ;
    VGA_green = 4'b0000 ;
    VGA_blue = 4'b0000 ;
 
   if(Vid_on == 1 && game_on==1 && gnd_on == 1)
    begin
     if(H_count<=RIGHT+DINO_X_SIZE+HBP)
        begin
        VGA_red = 4'b0000 ;
        VGA_green = 4'b1111 ;
        VGA_blue = 4'b0000 ;
        end
     else
        begin
        VGA_red = 4'b0000 ;
        VGA_green = 4'b1111 ;
        VGA_blue = 4'b1111 ;
        end
     end
     
   else if(Vid_on == 1 && game_on==1 && dino_on == 1)
    begin
     dino = brom_dino_data[rom_dino_pix] ;
     if(dino==1'b1)
        begin
        VGA_red = 4'b1111;
        VGA_green = 4'b1111 ;
        VGA_blue = 4'b1111 ;
        end
     else
        begin
        VGA_red = 4'b1111 ;
        VGA_green = 4'b0000 ;
        VGA_blue = 4'b0000 ;
        end  
     end
     
   else if(Vid_on == 1 && game_on==1 && bullet_on == 1)
    begin
     VGA_red = 4'b1111 ;
     VGA_green = 4'b1010 ;
     VGA_blue = 4'b0000 ;
     end     
     
   else if(Vid_on == 1 && game_on==1 && obs_on == 1)
    begin
     VGA_red = 4'b0000 ;
     VGA_green = 4'b0000 ;
     VGA_blue = 4'b1111 ;
     end  
  
    else if(Vid_on == 1 && game_on==1 && obs1_on == 1)
    begin
     VGA_red = 4'b0000 ;
     VGA_green = 4'b0000 ;
     VGA_blue = 4'b0000 ;
     end   
     
  else if(Vid_on == 1 && game_on==1 &&  counting_1st_on == 1)
             begin
              counting_1st = brom_counting_data[rom_counting_1st_pix];
              if(counting_1st==1'b1)
              begin
              VGA_red = 4'b0000 ;
              VGA_green = 4'b0000 ;
              VGA_blue = 4'b1111 ;
              end 
              else
                   begin
                    VGA_red = 4'b1111 ;
                    VGA_green = 4'b1111 ;
                    VGA_blue = 4'b1111 ;
                   end
              end
  
  else if(Vid_on == 1 && game_on==1 &&  counting_2nd_on == 1)
                           begin
                            counting_2nd = brom_counting_data[rom_counting_2nd_pix];
                            if(counting_2nd==1'b1)
                            begin
                             VGA_red = 4'b0000 ;
                             VGA_green = 4'b0000 ;
                             VGA_blue = 4'b1111 ;
                            end 
                            else
                                 begin
                                  VGA_red = 4'b1111 ;
                                  VGA_green = 4'b1111 ;
                                  VGA_blue = 4'b1111 ;
                                 end
                            end
    
    else if(Vid_on == 1 && game_on==1 && road_on==1'b1)    //road
    begin
     road = brom_road_data[rom_road_pix] ;
     if(road==1'b1)
        begin
        VGA_red = 4'b0000 ;
        VGA_green = 4'b0000 ;
        VGA_blue = 4'b0000 ;
        end
     else
        begin
        VGA_red = 4'b1111 ;
        VGA_green = 4'b0000 ;
        VGA_blue = 4'b0000 ;
        end   
    end                           
     
  else if(Vid_on == 1 && game_on==1)    //background_white
    begin
     VGA_red = 4'b1111 ;
     VGA_green = 4'b1111 ;
     VGA_blue = 4'b1111 ;
    end
   
  else if(Vid_on==1 && intro_on==1)
    begin
    intro = brom_intro_data[rom_intro_pix] ;
    if(intro==1'b1)
        begin
        VGA_red = 4'b1111 ;
        VGA_green = 4'b0000 ;
        VGA_blue = 4'b0000 ;
        end
    else
        begin
        VGA_red = 4'b0000 ;
        VGA_green = 4'b0000 ;
        VGA_blue = 4'b0000 ;
        end
    end
    
    else if(Vid_on==1)
    begin
        VGA_red = 4'b0000 ;
        VGA_green = 4'b0000 ;
        VGA_blue = 4'b0000 ;
    end
  end
endmodule

