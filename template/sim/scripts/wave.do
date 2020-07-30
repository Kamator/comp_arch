onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/dut/pipeline_inst/clk
add wave -noupdate /tb_cpu/dut/pipeline_inst/reset
add wave -noupdate -divider -height 40 fetch
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/stall_fetch
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/flush_fetch
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/pcsrc
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/int_pc_cnt
add wave -noupdate -expand -group fetch -childformat {{/tb_cpu/dut/pipeline_inst/mem_i_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_i_in.rddata {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_i_in
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/instr
add wave -noupdate -expand -group fetch /tb_cpu/dut/pipeline_inst/imem_busy_to_stall
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out
add wave -noupdate -expand -group fetch -childformat {{/tb_cpu/dut/pipeline_inst/mem_i_out.address -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/mem_i_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_i_out.address {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/mem_i_out.wrdata {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_i_out
add wave -noupdate -divider -height 50 reg_file
add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/rdaddr1
add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/rdaddr2
add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/rddata1
add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/rddata2
add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/reg_file
add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/int_rdaddr1
add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/int_rdaddr2
#add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/int_rddata1
#add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/int_rddata2
#add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/wraddr
#add wave -noupdate -expand -group reg_file /tb_cpu/dut/pipeline_inst/decode_inst/reg_inst/wrdata
add wave -noupdate -divider -height 40 decode
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/stall
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/flush_dec
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/stall_dec
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/instr
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/int_readdata1
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/int_readdata2
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_in
add wave -noupdate -expand -group decode -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg -radix unsigned} {/tb_cpu/pipeline_inst/dut/decode_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg {-radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write.data {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write
add wave -noupdate -expand -group decode -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 {-radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 {-radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op
add wave -noupdate -expand -group decode -expand /tb_cpu/dut/pipeline_inst/decode_inst/mem_op
add wave -noupdate -expand -group decode -expand /tb_cpu/dut/pipeline_inst/decode_inst/wb_op
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_out
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/exc_dec
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/help_rdaddr1
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/help_rdaddr2
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/reg_readdata1
add wave -noupdate -expand -group decode /tb_cpu/dut/pipeline_inst/decode_inst/reg_readdata2
add wave -noupdate -divider -height 40 exec
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/stall_exec
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/flush_exec
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/int_pc_in
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/int_wbop_in
add wave -noupdate -expand -group exec -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/int_op.rs1 -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/int_op.rs2 -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/int_op.readdata1 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/exec_inst/int_op.readdata2 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/exec_inst/int_op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/int_op.rs1 {-radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/int_op.rs2 {-radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/int_op.readdata1 {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/int_op.readdata2 {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/int_op.imm {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/int_op
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/pc_in
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/reg_write_wr
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/reg_write_mem
#add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/reg_write_mem_to_fwd
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_op_from_dec
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/int_wrdata
add wave -noupdate -expand -group exec /tb_cpu/dut/pipeline_inst/exec_inst/dwr_flag
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/pc_new_out
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/pc_old_out
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/alu_A
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/alu_B
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/alu_A_2
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/alu_B_2
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/alu_R_2
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/aluresult
#add wave -noupdate -expand -group exec /tb_cpu/dut/exec_inst/zero
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/wrdata
add wave -noupdate -divider -height 40 mem
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/clk
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/stall
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/flush_mem
#add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_op
#add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/zero
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/wrdata
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/reg_write
add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_busy
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/memresult
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_out
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/int_pc_old_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_out
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/int_mem_op
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/int_wbop_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/aluresult_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/int_aluresult_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_d_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_d_out
#add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pcsrc
#add wave -noupdate -expand -group mem /tb_cpu/dut/pipeline_inst/mem_inst/reg_write
#add wave -noupdate -expand -group mem -childformat {{/tb_cpu/dut/pipeline_inst/mem_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_inst/mem_in.rddata {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_inst/mem_in
#add wave -noupdate -expand -group mem -childformat {{/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.address {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/mem_inst/mem_out.wrdata {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_inst/mem_out
add wave -noupdate -divider -height 40 memu
add wave -noupdate -expand -group memu /tb_cpu/dut/pipeline_inst/mem_inst/memu_inst/A
add wave -noupdate -expand -group memu /tb_cpu/dut/pipeline_inst/mem_inst/memu_inst/B
add wave -noupdate -expand -group memu /tb_cpu/dut/pipeline_inst/mem_inst/memu_inst/M
add wave -noupdate -expand -group memu /tb_cpu/dut/pipeline_inst/mem_inst/memu_inst/R
add wave -noupdate -expand -group memu /tb_cpu/dut/pipeline_inst/mem_inst/memu_inst/W
add wave -noupdate -expand -group memu /tb_cpu/dut/pipeline_inst/mem_inst/memu_inst/XL
add wave -noupdate -expand -group memu /tb_cpu/dut/pipeline_inst/mem_inst/memu_inst/XS
add wave -noupdate -divider -height 40 wb
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/stall_wb
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/flush_wb
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/old_stall
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/int_memresult
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_op_from_mem
add wave -noupdate -expand -group wb /tb_cpu/dut/pipeline_inst/wb_inst/int_op
add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/aluresult
add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/reg_write
#add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/int_memresult
#add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/int_aluresult
add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/memresult
add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/int_pc_old_in
#add wave -noupdate -expand -group wb -childformat {{/tb_cpu/dut/wb_inst/reg_write.reg -radix unsigned} {/tb_cpu/dut/wb_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/wb_inst/reg_write.reg {-radix unsigned} /tb_cpu/dut/wb_inst/reg_write.data {-radix hexadecimal}} /tb_cpu/dut/wb_inst/reg_write
add wave -noupdate -divider -height 40 ctrl
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/critical_reg_1
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/critical_reg_2
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/int_exec_op
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/int_pcsrc_in
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/int_wb_op_mem
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/pcsrc_out
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/st_cnt
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/st_cnt_nxt
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/dmem_busy_to_stall
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/imem_busy_to_stall
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/fwd_load
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall_flag
add wave -noupdate -expand -group ctrl /tb_cpu/dut/pipeline_inst/ctrl_inst/stall_flag_nxt
add wave -noupdate -divider -height 40 fwd_1
add wave -noupdate -expand -group fwd_1 /tb_cpu/dut/pipeline_inst/do_fwd1
add wave -noupdate -expand -group fwd_1 /tb_cpu/dut/pipeline_inst/exec_op_to_fwd.rs1
add wave -noupdate -expand -group fwd_1 /tb_cpu/dut/pipeline_inst/reg_write_mem_to_fwd
add wave -noupdate -expand -group fwd_1 /tb_cpu/dut/pipeline_inst/reg_write
add wave -noupdate -expand -group fwd_1 /tb_cpu/dut/pipeline_inst/reg_write_wr
add wave -noupdate -divider -height 40 fwd_2
add wave -noupdate -expand -group fwd_2 /tb_cpu/dut/pipeline_inst/do_fwd2
add wave -noupdate -expand -group fwd_2 /tb_cpu/dut/pipeline_inst/exec_op_to_fwd.rs2
add wave -noupdate -expand -group fwd_2 /tb_cpu/dut/pipeline_inst/reg_write_mem_to_fwd
add wave -noupdate -expand -group fwd_2 /tb_cpu/dut/pipeline_inst/reg_write
add wave -noupdate -expand -group fwd_2 /tb_cpu/dut/pipeline_inst/reg_write_wr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {988255000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 227
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {987804685 ps} {992609888 ps}
