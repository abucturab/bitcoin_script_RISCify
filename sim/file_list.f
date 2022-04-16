// Include directories
      -incdir ../EllipticCurves_SystemVerilog/src/components
      -incdir ../EllipticCurves_SystemVerilog/src/ecdsa
      -incdir ../EllipticCurves_SystemVerilog/src/elgamal
      -incdir ../EllipticCurves_SystemVerilog/src/primitives
      -incdir ../EllipticCurves_SystemVerilog/src/rng

//Source Files
      ../EllipticCurves_SystemVerilog/src/components/elliptic_curve_structs.sv
      ../EllipticCurves_SystemVerilog/src/components/reg_256.sv
      ../EllipticCurves_SystemVerilog/src/primitives/hash/sha_mainloop.sv
      ../EllipticCurves_SystemVerilog/src/primitives/hash/sha_256.sv
      ../EllipticCurves_SystemVerilog/src/primitives/hash/sha_padder.sv
      ../EllipticCurves_SystemVerilog/src/primitives/hash/SHA256.sv
      ../EllipticCurves_SystemVerilog/src/primitives/hash/ripemd_160.sv
      ../EllipticCurves_SystemVerilog/src/primitives/modular_operations/add.sv
      ../EllipticCurves_SystemVerilog/src/primitives/modular_operations/square_root.sv
      ../EllipticCurves_SystemVerilog/src/primitives/modular_operations/multiplier.sv
      ../EllipticCurves_SystemVerilog/src/primitives/modular_operations/modular_inverse.sv
      ../EllipticCurves_SystemVerilog/src/primitives/modular_operations/barrett_reduction.sv
      ../EllipticCurves_SystemVerilog/src/primitives/point_operations/point_add.sv
      ../EllipticCurves_SystemVerilog/src/primitives/point_operations/gen_point.sv
      ../EllipticCurves_SystemVerilog/src/primitives/point_operations/point_double.sv
      ../EllipticCurves_SystemVerilog/src/ecdsa/sign/ecdsa_sign.sv
      ../EllipticCurves_SystemVerilog/src/ecdsa/sign/ecdsa_sign_control.sv
      ../EllipticCurves_SystemVerilog/src/ecdsa/sign/ecdsa_sign_datapath.sv
      ../EllipticCurves_SystemVerilog/src/ecdsa/verify/ecdsa_verify_control.sv
      ../EllipticCurves_SystemVerilog/src/ecdsa/verify/ecdsa_verify_datapath.sv
      ../EllipticCurves_SystemVerilog/src/ecdsa/verify/ecdsa_verify.sv
      ../EllipticCurves_SystemVerilog/src/rng/quarter_round.sv
      ../EllipticCurves_SystemVerilog/src/rng/chacha.sv
      ../ripemd160/sub_block_left.sv
      ../ripemd160/sub_block_right.sv
      ../ripemd160/ripemd160.sv
      ../V1_Script/scriptHeader.vh
      //../V1_Script/check_multisig.sv
      ../V1_Script/AluScript_rev1.sv
      ../V1_Script/scriptTop_rev1.sv
      //../testbench/op_dup_test.sv
