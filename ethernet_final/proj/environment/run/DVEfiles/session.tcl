# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Fri Jun 7 22:09:08 2019
# Designs open: 1
#   Sim: /DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run/simv
# Toplevel windows open: 1
# 	TopLevel.2
#   Wave.1: 110 signals
#   Group count = 1
#   Group dut signal count = 110
# End_DVE_Session_Save_Info

# DVE version: M-2017.03-SP1-1_Full64
# DVE build date: Jul 10 2017 21:08:24


#<Session mode="Full" path="/DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{40 51} {1258 708}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 353} {child_wave_right 860} {child_wave_colname 174} {child_wave_colvalue 175} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) none
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) none
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) none
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{-ucligui +UVM_TESTNAME=environment_test.sv}}
gui_set_env SIMSETUP::SIMEXE {/DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run/simv}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {/DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run/simv}] } {
gui_sim_run Ucli -exe simv -args {-ucligui +UVM_TESTNAME=environment_test.sv} -dir /DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 1ps
gui_set_time_units 1ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {environment_top.dut}


set _session_group_2 dut
gui_sg_create "$_session_group_2"
set dut "$_session_group_2"

gui_sg_addsignal -group "$_session_group_2" { environment_top.dut.clear_stats_tx_octets environment_top.dut.txhfifo_ralmost_empty environment_top.dut.rxdfifo_ren environment_top.dut.rxhfifo_ralmost_empty environment_top.dut.rxdfifo_rstatus environment_top.dut.status_rxdfifo_ovflow environment_top.dut.pkt_rx_val environment_top.dut.txhfifo_wfull environment_top.dut.reset_156m25_n environment_top.dut.wb_stb_i environment_top.dut.ctrl_tx_enable_ctx environment_top.dut.txdfifo_rempty environment_top.dut.rxhfifo_rdata environment_top.dut.status_crc_error environment_top.dut.status_lenght_error environment_top.dut.pkt_rx_err environment_top.dut.rxsfifo_wdata environment_top.dut.pkt_tx_val environment_top.dut.txsfifo_wen environment_top.dut.txdfifo_wdata environment_top.dut.local_fault_msg_det environment_top.dut.txhfifo_rempty environment_top.dut.rxhfifo_wen environment_top.dut.status_rxdfifo_udflow_tog environment_top.dut.rxhfifo_wstatus environment_top.dut.txhfifo_walmost_full environment_top.dut.status_remote_fault_crx environment_top.dut.txdfifo_wfull environment_top.dut.wb_rst_i environment_top.dut.reset_xgmii_tx_n environment_top.dut.pkt_tx_data environment_top.dut.status_pause_frame_rx environment_top.dut.txdfifo_wen environment_top.dut.clk_xgmii_rx environment_top.dut.status_pause_frame_rx_tog environment_top.dut.rxhfifo_ren environment_top.dut.txdfifo_walmost_full environment_top.dut.clear_stats_rx_octets environment_top.dut.rxdfifo_rdata environment_top.dut.pkt_tx_full environment_top.dut.wb_ack_o environment_top.dut.rxdfifo_wstatus environment_top.dut.pkt_rx_sop environment_top.dut.stats_tx_octets environment_top.dut.txdfifo_ren environment_top.dut.status_rxdfifo_ovflow_tog environment_top.dut.status_local_fault_crx environment_top.dut.pkt_rx_mod environment_top.dut.txhfifo_rstatus environment_top.dut.status_txdfifo_udflow_tog environment_top.dut.pkt_tx_sop environment_top.dut.status_lenght_error_tog environment_top.dut.wb_cyc_i environment_top.dut.rxhfifo_wdata environment_top.dut.wb_adr_i environment_top.dut.txdfifo_rstatus environment_top.dut.clear_stats_rx_pkts environment_top.dut.reset_xgmii_rx_n environment_top.dut.txhfifo_rdata environment_top.dut.pkt_tx_mod environment_top.dut.status_remote_fault_ctx environment_top.dut.stats_rx_pkts environment_top.dut.remote_fault_msg_det environment_top.dut.txhfifo_wen environment_top.dut.rxdfifo_rempty environment_top.dut.txsfifo_wdata environment_top.dut.clk_xgmii_tx environment_top.dut.clk_156m25 environment_top.dut.status_txdfifo_ovflow_tog environment_top.dut.pkt_rx_eop environment_top.dut.xgmii_txc environment_top.dut.wb_dat_i environment_top.dut.xgmii_txd environment_top.dut.txhfifo_ren environment_top.dut.status_local_fault environment_top.dut.rxhfifo_rempty environment_top.dut.wb_dat_o environment_top.dut.wb_clk_i environment_top.dut.xgmii_rxc environment_top.dut.xgmii_rxd environment_top.dut.stats_rx_octets environment_top.dut.status_local_fault_ctx environment_top.dut.rxdfifo_wdata environment_top.dut.wb_int_o environment_top.dut.pkt_rx_ren environment_top.dut.txhfifo_wstatus environment_top.dut.txdfifo_rdata environment_top.dut.rxsfifo_wen environment_top.dut.pkt_tx_eop environment_top.dut.txdfifo_ralmost_empty environment_top.dut.rxdfifo_wfull environment_top.dut.status_fragment_error environment_top.dut.rxdfifo_ralmost_empty environment_top.dut.pkt_rx_avail environment_top.dut.status_remote_fault environment_top.dut.clear_stats_tx_pkts environment_top.dut.txdfifo_wstatus {environment_top.dut.$unit} environment_top.dut.rxdfifo_wen environment_top.dut.status_txdfifo_udflow environment_top.dut.rxhfifo_rstatus environment_top.dut.status_fragment_error_tog environment_top.dut.status_crc_error_tog environment_top.dut.stats_tx_pkts environment_top.dut.ctrl_tx_enable environment_top.dut.wb_we_i environment_top.dut.pkt_rx_data environment_top.dut.status_rxdfifo_udflow environment_top.dut.txhfifo_wdata environment_top.dut.status_txdfifo_ovflow }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 0



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 280
gui_list_add_group -id ${Wave.1} -after {New Group} {dut}
gui_list_select -id ${Wave.1} {environment_top.dut.reset_156m25_n }
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group dut  -position in

gui_marker_move -id ${Wave.1} {C1} 0
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

