m_right_list = [[5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12], [6, 11, 3, 7, 0, 13, 5, 10, 14, 15, 8, 12, 4, 9, 1, 2], [15, 5, 1, 3, 7, 14, 6, 9, 11, 8, 12, 2, 10, 0, 4, 13], [8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10, 14], [12, 15, 10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11]]
m_left_list = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], [7, 4, 13, 1, 10, 6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8], [3, 10, 14, 4, 9, 15, 8, 1, 2, 7, 0, 6, 13, 11, 5, 12], [1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5, 6, 2], [4, 0, 5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13]]
s_left_list = [[11, 4, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8], [7, 6, 8, 13, 11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12], [11, 13, 6, 7, 14, 9, 13, 15, 14, 8, 13, 6, 4, 12, 7, 5], [11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5, 6, 8, 6, 5, 12], [9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5, 6]]
s_right_list = [[8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6], [9, 13, 15, 7, 12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11], [9, 7, 15, 11, 8, 6, 6, 14, 12, 13, 5, 14, 13, 13, 7, 5], [15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9, 12, 5, 15, 8], [8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11]]

for i in range(5):
    print(f"if(stage=={i}) begin")
    print(f"    sub_block_left_K_val = K{i};")
    print(f"    sub_block_right_K_val = K{i}_1;")
    print(f"    unique casez(sub_block_iter_counter)")
    for j in range(16):
        print(f"        8'd{j}: begin")
        print(f"            sub_block_left_message_in = padded_msg[{m_left_list[i][j]}];")
        print(f"            sub_block_left_shift_amount = 'd{s_left_list[i][j]};")
        print(f"            sub_block_right_message_in = padded_msg[{m_right_list[i][j]}];")
        print(f"            sub_block_right_shift_amount = 'd{s_right_list[i][j]};")
        print("        end")
    print(f"        default: begin")
    print(f"            sub_block_left_message_in='x;")
    print(f"            sub_block_left_shift_amount='x;")
    print(f"            sub_block_right_message_in='x;")
    print(f"            sub_block_right_shift_amount='x;")
    print(f"        end")
    print("    endcase")
    print("end")