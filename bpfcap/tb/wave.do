onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/clk
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/reset
add wave -noupdate -expand -group top -expand -group s0 -radix hexadecimal /tb_top/avs_s0_write
add wave -noupdate -expand -group top -expand -group s0 -radix hexadecimal /tb_top/avs_s0_read
add wave -noupdate -expand -group top -expand -group s0 -radix hexadecimal /tb_top/avs_s0_address
add wave -noupdate -expand -group top -expand -group s0 -radix hexadecimal /tb_top/avs_s0_writedata
add wave -noupdate -expand -group top -expand -group s0 -radix hexadecimal /tb_top/avs_s0_readdata
add wave -noupdate -expand -group top -expand -group m0_read -radix hexadecimal /tb_top/avs_m0_burstcount
add wave -noupdate -expand -group top -expand -group m0_read -radix hexadecimal /tb_top/avs_m0_address
add wave -noupdate -expand -group top -expand -group m0_read -radix hexadecimal /tb_top/avs_m0_readdata
add wave -noupdate -expand -group top -expand -group m0_read -radix hexadecimal /tb_top/avs_m0_read
add wave -noupdate -expand -group top -expand -group m0_read /tb_top/avs_m0_waitrequest
add wave -noupdate -expand -group top /tb_top/avs_m0_readdatavalid
add wave -noupdate -expand -group top -expand -group m1_write -radix hexadecimal /tb_top/avs_m1_address
add wave -noupdate -expand -group top -expand -group m1_write -radix hexadecimal /tb_top/avs_m1_writedata
add wave -noupdate -expand -group top -expand -group m1_write -radix hexadecimal /tb_top/avs_m1_write
add wave -noupdate -expand -group top -expand -group m1_write -radix hexadecimal /tb_top/avs_m1_burstcount
add wave -noupdate -expand -group top -expand -group m1_write /tb_top/avs_m1_waitrequest
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/writedata
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/readdata
add wave -noupdate -group mm_if /tb_top/mm_if/reset
add wave -noupdate -group mm_if /tb_top/mm_if/clock
add wave -noupdate -group mm_if /tb_top/mm_if/address
add wave -noupdate -group mm_if /tb_top/mm_if/byteenable
add wave -noupdate -group mm_if /tb_top/mm_if/read
add wave -noupdate -group mm_if /tb_top/mm_if/readdata
add wave -noupdate -group mm_if /tb_top/mm_if/response
add wave -noupdate -group mm_if /tb_top/mm_if/write
add wave -noupdate -group mm_if /tb_top/mm_if/writedata
add wave -noupdate -group mm_if /tb_top/mm_if/waitrequest
add wave -noupdate -expand -group ts /tb_top/dut/ts/clk
add wave -noupdate -expand -group ts /tb_top/dut/ts/reset_n
add wave -noupdate -expand -group ts -radix decimal /tb_top/dut/ts/seconds
add wave -noupdate -expand -group ts -radix decimal /tb_top/dut/ts/nanoseconds
add wave -noupdate -expand -group ts -radix decimal /tb_top/dut/ts/counter
add wave -noupdate -expand -group ts -radix decimal /tb_top/dut/ts/increment
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/clk
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reset
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/new_request
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_s0_address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_s0_writedata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_s0_write
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_s0_read
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_s0_readdata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m0_address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m0_readdata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m0_read
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m0_burstcount
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m1_address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m1_writedata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m1_write
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/avs_m1_burstcount
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_ctrl_rdy
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/wr_ctrl_rdy
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_ctrl
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/wr_ctrl
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_from_fifo
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/wr_to_fifo
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/state
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/out_control
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/out_pkt_begin
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/out_pkt_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/usedw
add wave -noupdate -expand -group dut /tb_top/dut/empty
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/almost_full
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/fifo_in
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/fifo_out
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/clk
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/reset
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/address
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/read
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/write
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/readdata
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/state
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/writedata
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/out_control
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/out_pkt_begin
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/out_pkt_end
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/control
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/pkt_begin
add wave -noupdate -group regs -radix hexadecimal /tb_top/dut/regs/pkt_end
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/new_request
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/clk
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/reset
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/rd_ctrl_rdy
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/wr_ctrl_rdy
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/rd_ctrl
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/wr_ctrl
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/state_out
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/state
add wave -noupdate -group pkt_ctrl -radix hexadecimal /tb_top/dut/packet_control/state_next
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/clk
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/reset
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/rd_ctrl
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/almost_full
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/control
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/pkt_begin
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/pkt_end
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/fifo_in
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/rd_ctrl_rdy
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/address
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/readdata
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/read
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/wr_to_fifo
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/burstcount
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/state
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/state_next
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/reg_control
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/reg_pkt_begin
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/reg_pkt_end
add wave -noupdate -expand -group rd_ctrl -radix hexadecimal /tb_top/dut/read_control/done_sending
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/clk
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/reset
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/wr_ctrl
add wave -noupdate -expand -group wr_ctrl /tb_top/dut/write_control/empty
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/fifo_out
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/wr_ctrl_rdy
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/control
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/pkt_begin
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/pkt_end
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/address
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/writedata
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/write
add wave -noupdate -expand -group wr_ctrl /tb_top/dut/write_control/rd_from_fifo
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/burstcount
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/state
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/state_next
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/reg_control
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/reg_pkt_begin
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/reg_pkt_end
add wave -noupdate -expand -group wr_ctrl -radix hexadecimal /tb_top/dut/write_control/done_reading
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/clock
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/data
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/rdreq
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/sclr
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/wrreq
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/almost_full
add wave -noupdate -expand -group fifo /tb_top/dut/fifo_i/empty
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/q
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/dut/fifo_i/usedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {296 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 184
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
WaveRestoreZoom {279 ns} {554 ns}
