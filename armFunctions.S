#include "constant.h"
        .bss
delta:  .skip 4096

        .data
        .text
        .global _Z14update_weightsPdS_PiPA15_d
        .type   _Z14update_weightsPdS_PiPA15_d, %function
  
_Z14update_weightsPdS_PiPA15_d:
    stp x29, x30, [sp, -16]!        //registers x0, x1, x2, and x3 have addresses
    mov w9, -1                      //row index (i)
    mov w10, 0                      //col index (j)

loopOne:
    add w9, w9, 1                   //start at i = 0
    /*
    cmp w9, 26                      //compare to maxout
    bgt return
    */
    fmov d10, 1.0                   //move 1.0 into d10
    ldr d11, [x1, x9, lsl 3]        //d11 = o_out[i]
    ldr w13, [x2, x9, lsl 2]        //d13 = desired[i]

    ucvtf d13, w13                  //convert int to double

    fsub d12, d10, d11              //d12 = 1 - o_out[i] 
    fsub d13, d13, d11              //d13 = desired[i] - o_out[i]
    fmul d11, d11, d12              
    fmul d11, d11, d13  

    adr x14, delta
    str d11, [x14, x9, lsl 3]       //delta[i] = d11
        
    mov w10, 0                      //j = 0

loopTwo:
    cmp w10, 14                     //compare to maxin
    bge loopOne
    fmov d4, 2.0                    //calculate eta
    fmov d5, 10.0
    fdiv d4, d4, d5                 //eta
    
    adr x14, delta
    ldr d10, [x14, x9, lsl 3]       //d10 = delta[i]
    ldr d11, [x0, x10, lsl 3]       //d11 = x[j]
    fmul d12, d4, d10
    fmul d12, d12, d11              //change = 0.2 * delta[i] * x[j]
    
    //calculate offset
    mov w4, 15                      //column size
    mul w4, w9, w4                  //rowIndex * colSize
    add w4, w4, w10                 //added to colIndex
    
    ldr d13, [x3, x4, lsl 3]        //load array w[i][j]
    fadd d13, d13, d12
    str d13, [x3, x4, lsl 3]    

    add w10, w10, 1
    b loopTwo
                

return:     
    mov w0, 0
    ldp x29, x30, [sp], 16
    ret
