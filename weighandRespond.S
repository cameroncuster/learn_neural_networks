        .set    maxin,          15          // number of input nodes + 1
        .set    maxout,         26          // number of nodes output layer
        .set    n_iterations,   2000        // times to train the network
        .set    numfv,          78          // number of feature vectors total
        .set    numuv,          78          // number of test vectors
        .set    log_mod,        100         // print every log_mod iterations

////////////////////////////////////////////////////////////////////////////////

        .data
eta:    .double 0.2

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
        ldr     d0, [x1, x4, lsl 3]         // f0 = o_out[i]
        ldr     w1, [x2, x4, lsl 2]         // r1 = desired[i]
        scvtf   d1, w1                      // f1 = r1

        fmov    d2, 1.0
        fsub    d2, d0, d2                  // f2 = -( o_out[i] - 1 ) = 1 - o_out[i]
        fneg    d2, d2
        fsub    d3, d1, d0                  // f3 = desired[i] - o_out[i]
        fmul    d1, d2, d3                  // f1 = f2 * f3
        fmul    d0, d2, d0                  // f0 = f2 * o_out[i] ( f0 )

        // d0 is delta[i]
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

        cmp     x5, maxin
        add     x5, x5, 1
        blt     forall_weights_in_row       // for( ; j < maxin + 1; j++ )

        cmp     x4, maxout
        add     x4, x4, 1
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

        ldp     x29, x30, [sp], 16
        ret
        .size   network_response, (. - network_response)
