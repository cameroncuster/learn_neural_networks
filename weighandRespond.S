////////////////////////////////////////////////////////////////////////////////

        .global update_weights_arm
        .type   update_weights_arm, %function // update_weights_arm(double x[],
        // double o_out[], int desired[], double w[maxout][maxin+1]);
update_weights_arm:
        stp     x29, x30, [sp, -16]!

        ldp     x20, x30, [sp], 16
        ret
        .size   update_weights_arm, (. - update_weights_arm)

////////////////////////////////////////////////////////////////////////////////

        .global network_response_arm
        .type   network_respones_arm, %function // void network_response_arm(
        // double x[maxin+1], double w[maxout][maxin+1], double o_out[maxout]);
network_response_arm:
        stp     x29, x30, [sp, -16]!

        ldp     x20, x30, [sp], 16
        ret
        .size   network_response_arm, (. - network_response_arm)
