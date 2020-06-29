onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -position end  sim:/fetch_tb/*
add wave -position end  sim:/fetch_tb/uut/prg_cnt*
add wave -position end  sim:/fetch_tb/uut/int_instr
add wave -position end  sim:/fetch_tb/uut/int_pc_cnt


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {135 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {31 ns} {536 ns}
