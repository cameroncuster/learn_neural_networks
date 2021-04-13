        .set    maxin,          15          // number of input nodes + 1
        .set    maxout,         26          // number of nodes output layer
        .set    n_iterations,   2000        // times to train the network
        .set    numfv,          78          // number of feature vectors total
        .set    numuv,          78          // number of test vectors
        .set    log_mod,        100         // print every log_mod iterations

////////////////////////////////////////////////////////////////////////////////

        .data
eta:    .double 0.2

zero:   .double 0.0

////////////////////////////////////////////////////////////////////////////////

        .text
        .global update_weights
        .type   update_weights, %function // void update_weights( double x[],
        // double o_out[], int desired[], double w[maxout][maxin+1]);
update_weights:
        stp     x29, x30, [sp, -16]!

        mov     x4, 0                       // i = 0

forall_rows_of_weights:
        // load values
        //ldr     d0, [x1, x4, lsl 3]         // f0 = o_out[i]
        ldr     w1, [x2, x4, lsl 2]         // r1 = desired[i]
        scvtf   d1, w1                      // f1 = r1

        ldr     d2, zero
        fsub    d2, d0, d2                  // f2 = -( o_out[i] - 1 ) = 1 - o_out[i]
        fneg    d2, d2
        fsub    d3, d1, d0                  // f3 = desired[i] - o_out[i]
        fmul    d1, d2, d3                  // f1 = f2 * f3
        fmul    d0, d2, d0                  // f0 = f2 * o_out[i] ( f0 )

        // f0 is delta[i]
        mov     x5, 0                       // j = 0
        mov     x6, maxin
        mul     x6, x4, x6
        add     x6, x3, x6, lsl 3           // ***** MUST INDEX CORRECTLY *****
        // increment address at each inner loop for w...
forall_weights_in_row:
        ldr     d1, eta
        fmul    d0, d0, d1
        ldr     d2, [x0, x5, lsl 3]         // load x[j]
        ldr     d1, [x6, x5, lsl 3]         // load w[i][j]
        fmadd   d0, d0, d2, d1              // w[i][j] += eta * delta[i] * x[j]
        str     d0, [x6, x5, lsl 3]         // store w[i][j]

        add     x5, x5, 1
        cmp     x5, maxin
        blt     forall_weights_in_row       // for( ; j < maxin + 1; j++ )

        add     x4, x4, 1
        cmp     x4, maxout
        blt     forall_rows_of_weights      // for( ; i < maxout; i++ )

        ldp     x29, x30, [sp], 16
        ret
        .size   update_weights, (. - update_weights)

////////////////////////////////////////////////////////////////////////////////

        .global network_response
        .type   network_respones, %function // void network_response(
        // double x[maxin+1], double w[maxout][maxin+1], double o_out[maxout]);
network_response:
        stp     x29, x30, [sp, -16]!
        stp     x21, x22, [sp, -16]!
        stp     x19, x20, [sp, -16]!
        stp     d8, d9, [sp, -16]!

        mov     x19, x0
        mov     x20, x1
        mov     x21, x2

        mov     x29, 0                      // i = 0
forall_rows_in_output_layer:
        mov     x5, 0                       // j = 0
        mov     x6, maxin
        mul     x6, x6, x29
        add     x6, x20, x6, lsl 3          // r6 is the base address for j loop

        ldr     d8, zero                    // temp = 0

forall_values_in_output_layer:
        ldr     d1, [x6, x5, lsl 3]         // w[i][j]
        ldr     d2, [x19, x5, lsl 3]        // x[j]
        fmsub   d8, d1, d2, d8              // temp -= w[i][j] * x[j]

        add     x5, x5, 1
        cmp     x5, maxin
        blt     forall_values_in_output_layer

        bl      exp

        fmov    d1, 1.0
        fadd    d8, d8, d1

        fdiv    d8, d1, d8

        str     d8, [x21, x29, lsl 3]

        add     x29, x29, 1
        cmp     x29, maxout
        blt     forall_rows_in_output_layer

        ldp     d8, d9, [sp], 16
        ldp     x19, x20, [sp], 16
        ldp     x21, x22, [sp], 16
        ldp     x29, x30, [sp], 16
        ret
        .size   network_response, (. - network_response)
