# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Jun 5 21:06:15 2019
# Designs open: 1
#   Sim: /DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run/simv
# Toplevel windows open: 1
# 	TopLevel.1
#   Source.1: uvm_pkg.\uvm_root::run_test 
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


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{6 56} {1310 757}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 213]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
catch { set Stack.1 [gui_share_window -id ${HSPane.1} -type Stack -silent] }
catch { set Class.1 [gui_share_window -id ${HSPane.1} -type Class -silent] }
catch { set Object.1 [gui_share_window -id ${HSPane.1} -type Object -silent] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 213
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 212} {height 442} {dock_state left} {dock_on_new_line true} {child_hier_colhier 140} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 225]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
catch { set Local.1 [gui_share_window -id ${DLPane.1} -type Local -silent] }
catch { set Member.1 [gui_share_window -id ${DLPane.1} -type Member -silent] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 225
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 428
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 224} {height 442} {dock_state left} {dock_on_new_line true} {child_data_colvariable 152} {child_data_colvalue 17} {child_data_coltype 59} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 165]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1252
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 165
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1304} {height 164} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {+UVM_TESTNAME=environment_test}
gui_set_env SIMSETUP::SIMEXE {./simv}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {/DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run/simv}] } {
gui_sim_run Ucli -exe simv -args { +UVM_TESTNAME=environment_test -ucligui} -dir /DCNFS/users/student/jtrinh/elen613/ETH_uvm/proj/environment/run -nosource
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


set _session_group_1 dut
gui_sg_create "$_session_group_1"
set dut "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { environment_top.dut.clear_stats_tx_octets environment_top.dut.txhfifo_ralmost_empty environment_top.dut.rxdfifo_ren environment_top.dut.rxhfifo_ralmost_empty environment_top.dut.rxdfifo_rstatus environment_top.dut.status_rxdfifo_ovflow environment_top.dut.pkt_rx_val environment_top.dut.txhfifo_wfull environment_top.dut.reset_156m25_n environment_top.dut.wb_stb_i environment_top.dut.ctrl_tx_enable_ctx environment_top.dut.txdfifo_rempty environment_top.dut.rxhfifo_rdata environment_top.dut.status_crc_error environment_top.dut.status_lenght_error environment_top.dut.pkt_rx_err environment_top.dut.rxsfifo_wdata environment_top.dut.pkt_tx_val environment_top.dut.txsfifo_wen environment_top.dut.txdfifo_wdata environment_top.dut.local_fault_msg_det environment_top.dut.txhfifo_rempty environment_top.dut.rxhfifo_wen environment_top.dut.status_rxdfifo_udflow_tog environment_top.dut.rxhfifo_wstatus environment_top.dut.txhfifo_walmost_full environment_top.dut.status_remote_fault_crx environment_top.dut.txdfifo_wfull environment_top.dut.wb_rst_i environment_top.dut.reset_xgmii_tx_n environment_top.dut.pkt_tx_data environment_top.dut.status_pause_frame_rx environment_top.dut.txdfifo_wen environment_top.dut.clk_xgmii_rx environment_top.dut.status_pause_frame_rx_tog environment_top.dut.rxhfifo_ren environment_top.dut.txdfifo_walmost_full environment_top.dut.clear_stats_rx_octets environment_top.dut.rxdfifo_rdata environment_top.dut.pkt_tx_full environment_top.dut.wb_ack_o environment_top.dut.rxdfifo_wstatus environment_top.dut.pkt_rx_sop environment_top.dut.stats_tx_octets environment_top.dut.txdfifo_ren environment_top.dut.status_rxdfifo_ovflow_tog environment_top.dut.status_local_fault_crx environment_top.dut.pkt_rx_mod environment_top.dut.txhfifo_rstatus environment_top.dut.status_txdfifo_udflow_tog environment_top.dut.pkt_tx_sop environment_top.dut.status_lenght_error_tog environment_top.dut.wb_cyc_i environment_top.dut.rxhfifo_wdata environment_top.dut.wb_adr_i environment_top.dut.txdfifo_rstatus environment_top.dut.clear_stats_rx_pkts environment_top.dut.reset_xgmii_rx_n environment_top.dut.txhfifo_rdata environment_top.dut.pkt_tx_mod environment_top.dut.status_remote_fault_ctx environment_top.dut.stats_rx_pkts environment_top.dut.remote_fault_msg_det environment_top.dut.txhfifo_wen environment_top.dut.rxdfifo_rempty environment_top.dut.txsfifo_wdata environment_top.dut.clk_xgmii_tx environment_top.dut.clk_156m25 environment_top.dut.status_txdfifo_ovflow_tog environment_top.dut.pkt_rx_eop environment_top.dut.xgmii_txc environment_top.dut.wb_dat_i environment_top.dut.xgmii_txd environment_top.dut.txhfifo_ren environment_top.dut.status_local_fault environment_top.dut.rxhfifo_rempty environment_top.dut.wb_dat_o environment_top.dut.wb_clk_i environment_top.dut.xgmii_rxc environment_top.dut.xgmii_rxd environment_top.dut.stats_rx_octets environment_top.dut.status_local_fault_ctx environment_top.dut.rxdfifo_wdata environment_top.dut.wb_int_o environment_top.dut.pkt_rx_ren environment_top.dut.txhfifo_wstatus environment_top.dut.txdfifo_rdata environment_top.dut.rxsfifo_wen environment_top.dut.pkt_tx_eop environment_top.dut.txdfifo_ralmost_empty environment_top.dut.rxdfifo_wfull environment_top.dut.status_fragment_error environment_top.dut.rxdfifo_ralmost_empty environment_top.dut.pkt_rx_avail environment_top.dut.status_remote_fault environment_top.dut.clear_stats_tx_pkts environment_top.dut.txdfifo_wstatus {environment_top.dut.$unit} environment_top.dut.rxdfifo_wen environment_top.dut.status_txdfifo_udflow environment_top.dut.rxhfifo_rstatus environment_top.dut.status_fragment_error_tog environment_top.dut.status_crc_error_tog environment_top.dut.stats_tx_pkts environment_top.dut.ctrl_tx_enable environment_top.dut.wb_we_i environment_top.dut.pkt_rx_data environment_top.dut.status_rxdfifo_udflow environment_top.dut.txhfifo_wdata environment_top.dut.status_txdfifo_ovflow }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 229636



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


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} environment_top}
catch {gui_list_select -id ${Hier.1} {environment_top.dut}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Class 'Class.1'
gui_list_set_filter -id ${Class.1} -list { {OVM 1} {VMM 1} {All 1} {Object 1} {UVM 1} {RVM 1} }
gui_list_set_filter -id ${Class.1} -text {*}
gui_change_design -id ${Class.1} -design Sim

# Member 'Member.1'
gui_list_set_filter -id ${Member.1} -list { {InternalMember 0} {RandMember 1} {All 0} {BaseMember 0} {PrivateMember 1} {LibBaseMember 0} {AutomaticMember 1} {VirtualMember 1} {PublicMember 1} {ProtectedMember 1} {OverRiddenMember 0} {InterfaceClassMember 1} {StaticMember 1} }
gui_list_set_filter -id ${Member.1} -text {*}

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {environment_top.dut}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active {uvm_pkg.\uvm_root::run_test } /opt/synopsys-2017/app/vcs-mx/M-2017.03-SP1-1/etc/uvm/base/uvm_root.svh
gui_view_scroll -id ${Source.1} -vertical -set 2060
gui_src_set_reusable -id ${Source.1}
# Warning: Class view not found.
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
#</Session>

