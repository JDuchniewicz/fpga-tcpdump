onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/clk
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/reset
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/wr_ctrl
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/almost_empty
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/wr_ctrl_rdy
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/control
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/pkt_begin
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/pkt_end
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/fifo_out
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/address
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/writedata
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/write
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/clk
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reset
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/wr_ctrl
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/almost_empty
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/fifo_out
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/wr_ctrl_rdy
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/control
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_begin
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/writedata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/write
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/state
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/state_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reg_control
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reg_pkt_begin
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reg_pkt_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/control_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_begin_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_end_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/addr_offset
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/addr_offset_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/done_reading
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/done_reading_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
