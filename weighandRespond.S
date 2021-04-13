        .set    maxin,          15          // number of input nodes + 1
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
        ldr     w5, [x2, x4, lsl 2]         // r5 = desired[i]
        scvtf   d1, w5                      // f1 = r5

        // calculate delta into f0
        fsub    d2, d1, d0
        fmov    d3, 1.0
        fsub    d3, d3, d0
        fmul    d2, d2, d3
        fmul    d0, d2, d0

        // row address
        mov     x5, maxin
        mul     x5, x4, x5
        lsl     x5, x5, 3
        add     x6, x5, x3

        mov     x5, 0                       // j = 0

forall_weights_in_row:
        ldr     d1, eta
        fmul    d1, d0, d1
        ldr     d2, [x0, x5, lsl 3]         // load x[j]
        ldr     d3, [x6, x5, lsl 3]         // load w[i][j]
        fmadd   d1, d1, d2, d3              // w[i][j] += eta * delta[i] * x[j]
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
        mov     x0, 0                       // j = 0
        mov     x1, maxin
        mul     x1, x1, x29
        lsl     x1, x1, 3
        add     x1, x20, x1                 // r6 is the base address for j loop

        ldr     d8, zero                    // temp = 0

forall_values_in_output_layer:
        ldr     d0, [x1, x0, lsl 3]         // w[i][j]
        ldr     d1, [x19, x0, lsl 3]        // x[j]
        fmsub   d8, d0, d1, d8              // temp -= w[i][j] * x[j]

        add     x0, x0, 1
        cmp     x0, maxin
        blt     forall_values_in_output_layer

        fmov    d0, d8
        bl      exp

        fmov    d1, 1.0
        fadd    d0, d0, d1

        fdiv    d0, d1, d0

        str     d0, [x21, x29, lsl 3]

        add     x29, x29, 1
        cmp     x29, maxout
        blt     forall_rows_in_output_layer

        ldp     d8, d9, [sp], 16
        ldp     x19, x20, [sp], 16
        ldp     x21, x22, [sp], 16
        ldp     x29, x30, [sp], 16
        ret
        .size   network_response, (. - network_response)
