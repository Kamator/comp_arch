onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -expand -noupdate -divider -height 40 data_st_tb
add wave -expand -group tb sim:/data_st_tb/clk
add wave -expand -group tb sim:/data_st_tb/byteena
add wave -expand -group tb sim:/data_st_tb/data_in
add wave -expand -group tb sim:/data_st_tb/data_out
add wave -expand -group tb sim:/data_st_tb/index
add wave -expand -group tb sim:/data_st_tb/rd
add wave -expand -group tb sim:/data_st_tb/we
add wave -expand -noupdate -divider -height 40 data_st_1w
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/r_byte_one
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/r_byte_two
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/r_byte_three
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/r_byte_four
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/w_byte_one
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/w_byte_two
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/w_byte_three
add wave -expand -group data_st_1w sim:/data_st_tb/data_st_inst/data_st_1w_inst/w_byte_four
add wave -expand -noupdate -divider -height 40 ram_1
add wave -expand -group ram_1 sim:/data_st_tb/data_st_inst/data_st_1w_inst/single_clock_rw_ram_inst_1/ram
add wave -expand -noupdate -divider -height 40 ram_2
add wave -expand -group ram_2 sim:/data_st_tb/data_st_inst/data_st_1w_inst/single_clock_rw_ram_inst_2/ram
add wave -expand -noupdate -divider -height 40 ram_3
add wave -expand -group ram_3 sim:/data_st_tb/data_st_inst/data_st_1w_inst/single_clock_rw_ram_inst_3/ram
add wave -expand -noupdate -divider -height 40 ram_4
add wave -expand -group ram_4 sim:/data_st_tb/data_st_inst/data_st_1w_inst/single_clock_rw_ram_inst_4/ram
