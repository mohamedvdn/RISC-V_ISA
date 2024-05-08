Lab on error condition within an computation pipeline
   
https://www.makerchip.com/sandbox/0DkfBh54w/0vghg0#

\m5_TLV_version 1d: tl-x.org
\m5
   
   // =================================================
   // Welcome!  New to Makerchip? Try the "Learn" menu.
   // =================================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   |comp
      ?$valid
         @1
            $err1 = $bad_input | $illegal_op;
         @3
            $err2 = $err1 | $over_flow;
         @6
            $err3 = $err2 | $div_by_zero;
         
      
         

\SV
   endmodule