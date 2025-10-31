#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vf1_clk.h"

#include "vbuddy.cpp"     // include vbuddy code
#define MAX_SIM_CYC 100000

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  Vf1_clk* top = new Vf1_clk;
  // init trace dump
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  top->trace (tfp, 99);
  tfp->open ("f1_clk.vcd");

  // init Vbuddy
  if (vbdOpen()!=1) return(-1);
  vbdHeader("L3T3: F1 CLK");
  vbdSetMode(0);

  // initialize simulation inputs
  top->clk = 0;
  top->rst = 0;
  top->en = 0;
  top->N = 25;

  // run simulation for MAX_SIM_CYC clock cycles
  for (int simcyc=0; simcyc<MAX_SIM_CYC; simcyc++) {
    // dump variables into VCD file and toggle clock
    for (int tick=0; tick<2; tick++) {
      top->clk = !top->clk;
      top->eval();
      tfp->dump(2*simcyc + tick);
    }
    
    top->en = vbdFlag();
    vbdBar(top->data_out & 0xFF);

    // either simulation finished, or 'q' is pressed
    if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) exit(0); 
    // ... exit if finish OR 'q' pressed
  }

  vbdClose();     // ++++
  tfp->close(); 
  exit(0);
}
