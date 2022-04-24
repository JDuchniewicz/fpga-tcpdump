onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/clk
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/reset
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/rd_ctrl
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/almost_full
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/rd_ctrl_rdy
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/control
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/pkt_begin
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/pkt_end
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/fifo_in
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/address
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/readdata
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/dummy_data
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/read
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/burstcount
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/i
add wave -noupdate -expand -group top -radix hexadecimal /tb_top/j
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/clk
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/reset
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_ctrl
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/almost_full
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/control
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_begin
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/pkt_end
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/fifo_in
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/rd_ctrl_rdy
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/address
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/readdata
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/read
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burstcount
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
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/done_sending
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/done_sending_next
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/packet_byte_count
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burst_index
add wave -noupdate -expand -group dut -radix hexadecimal /tb_top/dut/burst_index_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {196 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
