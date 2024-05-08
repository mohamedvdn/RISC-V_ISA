1.pythagorean theorem

https://www.makerchip.com/sandbox/0DkfBh54w/0oYhG6#

\m4_TLV_version 1d: tl-x.org
\SV
    //pythagores theorem
   `include "sqrt32.v";
   
   m4_makerchip_module
\TLV
   
  
   // DUT (Design Under Test)
   |calc
      ?$valid
         @1
            $aa_sq[7:0] = $aa[3:0] ** 2;
         @2
            $bb_sq[7:0] = $bb[3:0] ** 2;
         @3
            $cc_sq[8:0] = $aa_sq + $bb_sq;
         @4
            $cc[4:0] = sqrt($cc_sq);



\SV
   endmodule