quit -sim

setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vcom -2008 -work work ../score/score_const.vhd
vcom -2008 -work work ../bullets/tank_const.vhd
vcom -2008 -work work ../gamestate/gamestate.vhd
vcom -2008 -work work ../tanks/tanks.vhd
vcom -2008 -work work ../bullets/bullets.vhd
vcom -2008 -work work ../bullets/move_object.vhd
vcom -2008 -work work ../score/score.vhd
vcom -2008 -work work overall_test.vhd

vsim +notimingchecks -L work work.overall_tb -wlf overall_tb_sim.wlf

do overall_tb_wave.do

run 100 ns