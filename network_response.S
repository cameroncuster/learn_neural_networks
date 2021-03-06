        .set    maxin,          15          // number of input nodes + 1
        .set    maxinVec,       14          // number of input nodes - 1
        .set    shiftedMaxin,   maxin * 8   // shift the maxin value
        .set    maxout,         26          // number of nodes output layer
        .set    n_iterations,   2000        // times to train the network
        .set    numfv,          78          // number of feature vectors total
        .set    numuv,          78          // number of test vectors
        .set    log_mod,        100         // print every log_mod iterations

////////////////////////////////////////////////////////////////////////////////

        .section .rodata
eta:    .double 0.2
        .align  3

zero:   .double 0.0
        .align  3



        .text
////////////////////////////////////////////////////////////////////
//                                                                //
//                function network_response                       //
//                                                                //
//   Calculate the responses of the hidden layer and feed         //
//   these into the output layer. Highly optimized for vectorized //
//   instructions in response out layer.                          //
//                                                                //
//   Calls : none                                                 //
//                                                                //
//   Called By : train                                            //
//               test_uniform                                     //
////////////////////////////////////////////////////////////////////

        .global network_response
        .type   network_respones, %function // void network_response(
        // double x[maxin+1], double w[maxout][maxin+1], double o_out[maxout] )
network_response:
        stp     x29, x30, [sp, -16]!
        stp     x21, x22, [sp, -16]!
        stp     x19, x20, [sp, -16]!
        stp     d8, d9, [sp, -16]!

        mov     x19, x0                     // r19 = x[]
        mov     x20, x1                     // r20 = w[][]
        mov     x21, x2                     // r21 = o_out[]
        mov     x22, shiftedMaxin           // const r22 = shiftedMaxin
        fmov    d9, 1.0                     // const f9 = 1.0

        mov     x29, 0                      // i = 0
forall_rows_in_output_layer:
        mov     x0, 0                       // j = 0
        madd    x1, x22, x29, x20           // calculate w[][] index preshifted

        ldr     d8, zero                    // temp = 0

        // copy address
        mov     x2, x19

forall_values_in_output_row:
        // accumulate the product of the weights and the x values (negated)
        ld1     {v1.2d}, [x2], 16           // x[j] and x[j+1]
        ld1     {v0.2d}, [x1], 16           // w[i][j] and w[i][j+1]
        fmul    v0.2d, v0.2d, v1.2d         // vectorized w[][] * x[]
        // sum all values in the vector and subtract from temp
        faddp   d1, v0.2d                   // sum of all elements in vector
        fsub    d8, d8, d1                  // temp -= sum

        add     x0, x0, 2
        cmp     x0, maxinVec
        blt     forall_values_in_output_row // for( ; j < maxinVec; j += 2 )

for_remaining_values_in_output_row:
        // accumulate the product of the weights and the x values (negated)
        ldr     d1, [x2], 8                 // x[j]
        ldr     d0, [x1], 8                 // w[i][j]
        fmsub   d8, d0, d1, d8              // temp -= w[i][j] * x[j]

        add     x0, x0, 1
        cmp     x0, maxin
        blt     for_remaining_values_in_output_row // for( ; j < maxin; j++ )

        // e^(-temp)
        fmov    d0, d8
        bl      exp

        // 1.0 + e^(-temp)
        fadd    d0, d9, d0

        // 1.0 / (1 + e^(-temp))
        fdiv    d0, d9, d0

        // o_out[i] = 1.0 / (1 + e^(-temp))
        str     d0, [x21, x29, lsl 3]

        add     x29, x29, 1
        cmp     x29, maxout
        blt     forall_rows_in_output_layer // for( ; i < maxout; i++ )

        ldp     d8, d9, [sp], 16
        ldp     x19, x20, [sp], 16
        ldp     x21, x22, [sp], 16
        ldp     x29, x30, [sp], 16
        ret
        .size   network_response, (. - network_response)
