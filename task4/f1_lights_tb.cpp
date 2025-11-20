#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vf1_lights.h"

#include "vbuddy.cpp"     // include vbuddy code
#define MAX_SIM_CYC 100000

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  Vf1_lights* top = new Vf1_lights;
  // init trace dump
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("f1_lights.vcd");

  // init Vbuddy
  if (vbdOpen()!=1) return(-1);
  vbdHeader("L3T4: Lights Out & Away We Go!");
  vbdSetMode(1);    // set Vbuddy to one shot mode

  // initialize simulation inputs
  top->N = 25;
  top->clk = 0;
  top->rst = 0;
  top->trigger = 0;

  bool lights_off_event = false; 
  bool timer_started = false;
  bool arm_reaction_logic = false; 
  bool button_pressed = false;
  int current_state = 0;
  int previous_state = 0;

  // run simulation for MAX_SIM_CYC clock cycles
  for (int simcyc=0; simcyc<MAX_SIM_CYC; simcyc++) {
    // dump variables into VCD file and toggle clock
    if (simcyc<2){
        top->rst = 1;
        } else {
        top->rst = 0;
    }
    for (int tick=0; tick<2; tick++) {
      top->clk = !top->clk;
      top->eval();
      tfp->dump(2*simcyc + tick);
    }
    
    button_pressed = vbdFlag();   //read button press from vbuddy
    top->trigger = 0;          //default trigger to 0
    if (current_state == 0 && !timer_started && !lights_off_event) {
        top->trigger = button_pressed;
    }
    vbdBar(top->data_out & 0xFF);   //display lights on vbuddy

    //detecting when to start reaction timer
    current_state = top->data_out & 0xFF;

    if (current_state == 0xFF) {
        arm_reaction_logic = true;
    }

    // 4. Detect "Lights Out" Event
    // If logic is armed, and we see a transition from Non-Zero to Zero -> LIGHTS OUT!
    if (arm_reaction_logic && previous_state != 0 && current_state == 0) {
        lights_off_event = true;
        timer_started = false; 
        arm_reaction_logic = false; // Reset arming flag
    }

    // 5. Start Stopwatch
    // If the lights just went out, start the Vbuddy hardware timer immediately.
    if (lights_off_event && !timer_started) {
        vbdInitWatch();       
        timer_started = true; 
        lights_off_event = false; 
        vbdHeader("Go!"); 
    }

    // 6. Measure Reaction Time
    // If timer is running, we wait for the USER to press the button again.
    if (timer_started) {
        // Check if user pressed button (trigger went high again)
        // Note: Since top->trigger is driven by vbdFlag(), checking top->trigger here works.
        if (button_pressed) {
            int reaction_time = vbdElapsed(); // Get elapsed time in ms
            
            // Display reaction time on 7-segment display
            // Convert milliseconds to decimal digits (BCD-like) for display
            int hundreds = (reaction_time / 100) % 10;
            int tens = (reaction_time / 10) % 10;
            int units = reaction_time % 10;
            
            vbdHex(3, hundreds);
            vbdHex(2, tens);
            vbdHex(1, units);
            
            timer_started = false; // Stop monitoring until next race
        }
    }

    // Update previous state for next cycle's edge detection
    previous_state = current_state;

    // Exit logic
    if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) exit(0);
  }

  vbdClose();     // ++++
  tfp->close(); 
  exit(0);
}