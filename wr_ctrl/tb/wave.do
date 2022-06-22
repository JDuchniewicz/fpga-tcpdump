onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/clk
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/reset
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/empty
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/wr_ctrl
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/wr_ctrl_rdy
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/rd_from_fifo
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/waitrequest
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/control
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/pkt_begin
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/pkt_end
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/fifo_out
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/address
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/writedata
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/burstcount
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/write
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/fifo_out
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_from_fifo
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/wr_ctrl_rdy
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/control
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_begin
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/write_address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burstcount
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/writedata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/write
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/waitrequest
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/state
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/state_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reg_control
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reg_pkt_begin
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reg_pkt_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reg_write_address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/done_reading
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/start_transfer
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/remaining_burst_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25 ns} 0}
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
WaveRestoreZoom {24 ns} {178 ns}
