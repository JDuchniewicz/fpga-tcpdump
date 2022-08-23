onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group top -radix hexadecimal /tb_top/clk
add wave -noupdate -group top -radix hexadecimal /tb_top/reset
add wave -noupdate -group top -radix hexadecimal /tb_top/empty
add wave -noupdate -group top -radix hexadecimal /tb_top/wr_ctrl
add wave -noupdate -group top -radix hexadecimal /tb_top/wr_ctrl_rdy
add wave -noupdate -group top -radix hexadecimal /tb_top/rd_from_fifo
add wave -noupdate -group top -radix hexadecimal /tb_top/waitrequest
add wave -noupdate -group top -radix hexadecimal /tb_top/write
add wave -noupdate -group top -radix hexadecimal /tb_top/control
add wave -noupdate -group top -radix hexadecimal /tb_top/pkt_begin
add wave -noupdate -group top -radix hexadecimal /tb_top/pkt_end
add wave -noupdate -group top -radix hexadecimal /tb_top/fifo_out
add wave -noupdate -group top -radix hexadecimal /tb_top/address
add wave -noupdate -group top -radix hexadecimal /tb_top/writedata
add wave -noupdate -group top -radix hexadecimal /tb_top/burstcount
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/i_clk
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/i_reset
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/i_valid
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/o_ready
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/i_data
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/o_valid
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/i_ready
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/o_data
add wave -noupdate -group skbf1 -radix hexadecimal /tb_top/dut/skbf1/w_data
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/i_clk
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/i_reset
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/i_valid
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/o_ready
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/i_data
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/o_valid
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/i_ready
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/o_data
add wave -noupdate -group skbf2 -radix hexadecimal /tb_top/dut/skbf2/w_data
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/total_size
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burst_size
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/total_burst_remaining
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burst_segment_remaining_count
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burstcount
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/control
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_begin
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/fifo_out
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/write_address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/writedata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/write
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/waitrequest
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/start_transfer
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_from_fifo
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/done_reading
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burst_start
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burst_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/first_burst
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/first_burst_wait_fifo_fill
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/timestamp_pkt_reg
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/timestamp_pkt_cnt
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/state
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/state_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/tx_accept
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/wr_ctrl_rdy
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_from_fifo_d
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/clock
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/data
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/rdreq
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/sclr
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/wrreq
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/almost_full
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/empty
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/q
add wave -noupdate -expand -group fifo -radix hexadecimal /tb_top/fifo_sim/usedw
add wave -noupdate -expand -group ts -radix decimal /tb_top/ts/clk
add wave -noupdate -expand -group ts -radix decimal /tb_top/ts/reset_n
add wave -noupdate -expand -group ts -radix decimal /tb_top/ts/seconds
add wave -noupdate -expand -group ts -radix decimal /tb_top/ts/nanoseconds
add wave -noupdate -expand -group ts -radix decimal /tb_top/ts/counter
add wave -noupdate -expand -group ts -radix decimal /tb_top/ts/increment
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6486 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 183
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
WaveRestoreZoom {6216 ns} {7758 ns}
