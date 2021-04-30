        .set    maxin,          15          // number of input nodes + 1
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
//   the nodes.                                                   //
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
        ldr     d0, [x1, x4, lsl 3]         // f0 = o_out[i]
        ldr     w5, [x2, x4, lsl 2]         // r5 = desired[i]
        scvtf   d1, w5                      // f1 = r5

        // calculate delta into f0
        fmsub   d2, d0, d0, d0
        fsub    d3, d1, d0
        fmul    d0, d2, d3
        fmul    d0, d4, d0

        // row address
        madd    x6, x4, x7, x3

        mov     x5, 0                       // j = 0

forall_weights_in_row: // vectorize (SIMD)
        ldr     d2, [x0, x5, lsl 3]
        ldr     d3, [x6, x5, lsl 3]
        fmadd   d1, d0, d2, d3              // w[i][j] += eta * delta[i] * x[j]
        str     d1, [x6, x5, lsl 3]         // store w[i][j]

        add     x5, x5, 1
        cmp     x5, maxin
        blt     forall_weights_in_row       // for( ; j < maxin + 1; j++ )

        add     x4, x4, 1
        cmp     x4, maxout
        blt     forall_rows_of_weights      // for( ; i < maxout; i++ )

        ldp     x29, x30, [sp], 16
        ret
        .size   update_weights, (. - update_weights)



////////////////////////////////////////////////////////////////////
//                                                                //
//                function network_response                       //
//                                                                //
//   Calculate the responses of the hidden layer and feed         //
//   these into the output layer.                                 //
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

        mov     x29, 0                      // i = 0
forall_rows_in_output_layer:
        mov     x0, 0                       // j = 0
        mov     x1, maxin
        mul     x1, x1, x29
        lsl     x1, x1, 3
        add     x1, x20, x1                 // r6 is the base address for j loop

        ldr     d8, zero                    // temp = 0

forall_values_in_output_layer:
        // accumulate the product of the weights and the x values (negated)
        ldr     d0, [x1, x0, lsl 3]         // w[i][j]
        ldr     d1, [x19, x0, lsl 3]        // x[j]
        fmsub   d8, d0, d1, d8              // temp -= w[i][j] * x[j]

        add     x0, x0, 1
        cmp     x0, maxin
        blt     forall_values_in_output_layer// for( ; j < maxin; j++ )

        // e^(-temp)
        fmov    d0, d8
        bl      exp

        // 1 + e^(-temp)
        fmov    d1, 1.0
        fadd    d0, d0, d1

        // 1.0 / (1 + e^(-temp))
        fdiv    d0, d1, d0

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
