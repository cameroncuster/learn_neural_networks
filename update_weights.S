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
//               PROCEDURE update_weights                         //
//                                                                //
//   First update the output weights then back up through         //
//   the nodes. Highly optomized for vectorized instructions in   //
//   update.                                                      //
//                                                                //
//   Calls : none                                                 //
//                                                                //
//   Called By : train                                            //
////////////////////////////////////////////////////////////////////

        .global update_weights
        .type   update_weights, %function // void update_weights( double x[],
        // double o_out[], int desired[], double w[maxout][maxin+1] )
update_weights:
        stp     x29, x30, [sp, -16]!

        ldr     d4, eta                     // const f4 = eta(0.2)

        mov     x7, shiftedMaxin            // const r7 = shiftedMaxin

        mov     x4, 0                       // i = 0

forall_rows_of_weights:
        // load values
        ldr     d0, [x1], 8                 // f0 = o_out[i]
        ldr     w5, [x2], 4                 // r5 = desired[i]
        scvtf   d1, w5                      // f1 = r5

        // calculate delta into f0
        fmsub   d2, d0, d0, d0      // expression 1 - ( o_out[i] - o_out[i]^2 )
        fsub    d3, d1, d0          // expression 2 - ( desired[i] - o_out[i] )
        fmul    d0, d2, d3          // product of 1 and 2
        fmul    d0, d4, d0          /* delta = ( o_out[i] - o_out[i]^2 ) *
                                        ( desired[i] - o_out[i] ) * eta */

        fmov    x5, d0
        dup    v5.2d, x5                    // v5.2d[0] && v5.2d[1] == delta

        // row address
        madd    x6, x4, x7, x3

        mov     x5, 0                       // j = 0

        // copy address
        mov     x10, x0

forall_weights_in_row:
        ld1     {v2.2d}, [x10], 16          // x[j] and x[j+1]
        ld1     {v3.2d}, [x6]               // w[i][j] and w[i][j+1]

        // w[i][j] += eta * delta[i] * x[j]
        // w[i][j+1] += eta * delta[i] * x[j+1]
        fmul    v1.2d, v5.2d, v2.2d
        fadd    v1.2d, v1.2d, v3.2d

        st1     {v1.2d}, [x6], 16           // store w[i][j] and w[i][j+1]

        add     x5, x5, 2
        cmp     x5, maxinVec
        blt     forall_weights_in_row       // for( ; j < maxinVec; j += 2 )

for_remaining_weights_in_row:
        ldr     d2, [x10], 8                // x[j]
        ldr     d3, [x6]                    // w[i][j]
        fmadd   d1, d0, d2, d3              // w[i][j] += eta * delta[i] * x[j]
        str     d1, [x6], 8                 // store w[i][j]

        add     x5, x5, 1
        cmp     x5, maxin
        blt     for_remaining_weights_in_row// for( ; j < maxin; j++ )

        add     x4, x4, 1
        cmp     x4, maxout
        blt     forall_rows_of_weights      // for( ; i < maxout; i++ )

        ldp     x29, x30, [sp], 16
        ret
        .size   update_weights, (. - update_weights)
