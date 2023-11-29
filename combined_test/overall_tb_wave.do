
onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -group overall_tb
add wave -noupdate -group overall_tb -radix unsigned /overall_tb/*

add wave -noupdate -group overall_tb/counter
add wave -noupdate -group overall_tb/counter -radix unsigned /overall_tb/counter/*

add wave -noupdate -group overall_tb/dut_bullet1
add wave -noupdate -group overall_tb/dut_bullet1 -radix unsigned /overall_tb/dut_bullet1/*

add wave -noupdate -group overall_tb/dut_bullet2
add wave -noupdate -group overall_tb/dut_bullet2 -radix unsigned /overall_tb/dut_bullet2/*

add wave -noupdate -group overall_tb/dut_tank1
add wave -noupdate -group overall_tb/dut_tank1 -radix unsigned /overall_tb/dut_tank1/*

add wave -noupdate -group overall_tb/dut_tank2
add wave -noupdate -group overall_tb/dut_tank2 -radix unsigned /overall_tb/dut_tank2/*

add wave -noupdate -group overall_tb/dut_score1
add wave -noupdate -group overall_tb/dut_score1 -radix unsigned /overall_tb/dut_score1/*

add wave -noupdate -group overall_tb/dut
add wave -noupdate -group overall_tb/dut -radix unsigned /overall_tb/dut/*

WaveRestoreCursors {{Cursor 1} {0 ns} 0}
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 250
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
update
WaveRestoreZoom {0 ns} {1 us}
