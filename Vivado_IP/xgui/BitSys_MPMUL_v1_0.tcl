# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_static_text $IPINST -name "BitSys Information" -parent ${Page_0} -text {8-bit BitSys Multi-Precision Multiplier

Precision:

  00 -> 1-bit, 8 channels
  01 -> 2-bit, 4 channels
  10 -> 4-bit, 2 channels
  11 -> 8-bit, 1 channel

precision and is_signed must remain stable from in_valid to result_valid.

This IP uses Xilinx LUT6_2 primitives.}


}

proc update_PARAM_VALUE.IN_PRECI { PARAM_VALUE.IN_PRECI } {
	# Procedure called to update IN_PRECI when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IN_PRECI { PARAM_VALUE.IN_PRECI } {
	# Procedure called to validate IN_PRECI
	return true
}

proc update_PARAM_VALUE.IN_WIDTH { PARAM_VALUE.IN_WIDTH } {
	# Procedure called to update IN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IN_WIDTH { PARAM_VALUE.IN_WIDTH } {
	# Procedure called to validate IN_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT_WIDTH { PARAM_VALUE.OUT_WIDTH } {
	# Procedure called to update OUT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT_WIDTH { PARAM_VALUE.OUT_WIDTH } {
	# Procedure called to validate OUT_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.IN_WIDTH { MODELPARAM_VALUE.IN_WIDTH PARAM_VALUE.IN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IN_WIDTH}] ${MODELPARAM_VALUE.IN_WIDTH}
}

proc update_MODELPARAM_VALUE.IN_PRECI { MODELPARAM_VALUE.IN_PRECI PARAM_VALUE.IN_PRECI } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IN_PRECI}] ${MODELPARAM_VALUE.IN_PRECI}
}

proc update_MODELPARAM_VALUE.OUT_WIDTH { MODELPARAM_VALUE.OUT_WIDTH PARAM_VALUE.OUT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT_WIDTH}] ${MODELPARAM_VALUE.OUT_WIDTH}
}

