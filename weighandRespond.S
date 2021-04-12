        //.set    eta,            0.2         // learning rate
        .set    maxin,          14          // number of input nodes
        .set    maxout,         26          // number of nodes output layer
        .set    n_iterations,   2000        // times to train the network
        .set    numfv,          78          // number of feature vectors total
        .set    numuv,          78          // number of test vectors
        .set    log_mod,        100         // print every log_mod iterations
////////////////////////////////////////////////////////////////////////////////

        .global update_weights
        .type   update_weights, %function // void update_weights( double x[],
        // double o_out[], int desired[], double w[maxout][maxin+1]);
update_weights:
        stp     x29, x30, [sp, -16]!

        mov     x4, 0                       // i = 0 *-> could be pre-shifted
                                        // e.a. increment by 8 at each iteration
forall_rows_of_weights:
        // load values
        ldr     d0, [x1, x4, lsl 3]         // f0 = o_out[i]
        ldr     d1, [x2, x4, lsl 3]         // f1 = desired[i]

        fmov    d2, 1.0
        fsub    d2, d0, d2                  // f2 = -( o_out[i] - 1 ) = 1 - o_out[i]
        fneg    d2, d2
        fsub    d3, d1, d0                  // d3 = desired[i] - o_out[i]
        fmul    d1, d2, d3                  // d1 = d2 * d3
        fmul    d0, d2, d0                  // d0 = d2 * o_out[i] ( d0 )

        // d0 is delta[i]
        mov     x5, 0                       // j = 0
        //ldr     x6, [x3, x4, lsl 3]         // load base address of weights row
        add     x6, x3, x4, lsl 3
forall_weights_in_row:
        fmov    d1, .25                     // use .25 for small enough value at operand2
        fmul    d0, d0, d1
        ldr     d2, [x0, x5, lsl 3]
        ldr     d1, [x6, x5, lsl 3]         // load w[i][j]
        fmadd   d0, d0, d2, d1              // w[i][j] += eta * delta[i] * x[j]
        str     d0, [x6, x5, lsl 3]         // store w[i][j]

        cmp     x5, maxin
        add     x5, x5, 1
        ble     forall_weights_in_row       // for( ; j <= maxin; j++ )

        cmp     x6, maxout
        add     x6, x6, 1
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
