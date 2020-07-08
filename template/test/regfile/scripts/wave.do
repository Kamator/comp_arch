onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate -divider Input
add wave -noupdate -radix unsigned /tb/inp.rdaddr1
add wave -noupdate -radix unsigned /tb/inp.rdaddr2
add wave -noupdate /tb/inp.regwrite
add wave -noupdate /tb/inp.stall
add wave -noupdate -radix unsigned /tb/inp.wraddr
add wave -noupdate -radix hexadecimal /tb/inp.wrdata
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/outp.rddata1
add wave -noupdate -radix hexadecimal /tb/outp.rddata2

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {5250 ns}
