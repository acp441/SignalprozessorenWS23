################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

CG_TOOL_ROOT := C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12

GEN_OPTS__FLAG := 
GEN_CMDS__FLAG := 

ORDERED_OBJS += \
"./CircularBuffer.obj" \
"./FIR_filter_asm_sc.obj" \
"./adda.obj" \
"./fir_filter_sc.obj" \
"./i2c.obj" \
"./main_adda_Lab3.obj" \
"./main_adda_Lab3_dec.obj" \
"./main_adda_Lab_pointers.obj" \
"./main_adda_simple_Lab.obj" \
"./main_adda_simple_Lab2_dec.obj" \
"./main_adda_simple_Lab2_int.obj" \
"./pru.obj" \
"D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/lnk/unidaq2.cmd" \
$(GEN_CMDS__FLAG) \
-llibc.a \

-include ../makefile.init

RM := DEL /F
RMDIR := RMDIR /S/Q

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir_vars.mk
-include subdir_rules.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C55_DEPS)),)
-include $(C55_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(S67_DEPS)),)
-include $(S67_DEPS)
endif
ifneq ($(strip $(S62_DEPS)),)
-include $(S62_DEPS)
endif
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(OPT_DEPS)),)
-include $(OPT_DEPS)
endif
ifneq ($(strip $(C??_DEPS)),)
-include $(C??_DEPS)
endif
ifneq ($(strip $(ASM_UPPER_DEPS)),)
-include $(ASM_UPPER_DEPS)
endif
ifneq ($(strip $(S??_DEPS)),)
-include $(S??_DEPS)
endif
ifneq ($(strip $(C64_DEPS)),)
-include $(C64_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(S64_DEPS)),)
-include $(S64_DEPS)
endif
ifneq ($(strip $(INO_DEPS)),)
-include $(INO_DEPS)
endif
ifneq ($(strip $(CLA_DEPS)),)
-include $(CLA_DEPS)
endif
ifneq ($(strip $(S55_DEPS)),)
-include $(S55_DEPS)
endif
ifneq ($(strip $(SV7A_DEPS)),)
-include $(SV7A_DEPS)
endif
ifneq ($(strip $(C62_DEPS)),)
-include $(C62_DEPS)
endif
ifneq ($(strip $(C67_DEPS)),)
-include $(C67_DEPS)
endif
ifneq ($(strip $(PDE_DEPS)),)
-include $(PDE_DEPS)
endif
ifneq ($(strip $(K_DEPS)),)
-include $(K_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(C43_DEPS)),)
-include $(C43_DEPS)
endif
ifneq ($(strip $(S43_DEPS)),)
-include $(S43_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(SA_DEPS)),)
-include $(SA_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXE_OUTPUTS += \
adda_simple.out \

EXE_OUTPUTS__QUOTED += \
"adda_simple.out" \


# All Target
all: adda_simple.out

# Tool invocations
adda_simple.out: $(OBJS) $(CMD_SRCS) $(GEN_CMDS)
	@echo 'Building target: "$@"'
	@echo 'Invoking: C6000 Linker'
	"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/bin/cl6x" -mv6740 --abi=eabi -O2 --define=c6747 --diag_wrap=off --diag_warning=225 --display_error_number --mem_model:const=data --mem_model:data=far_aggregates --interrupt_threshold=50 -z --stack_size=0x1000 -m"adda_simple.map" --heap_size=0x1000 -i"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/lib" -i"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/include" --reread_libs --warn_sections --diag_wrap=off --display_error_number --xml_link_info="adda_simple_linkInfo.xml" --rom_model -o "adda_simple.out" $(ORDERED_OBJS)
	@echo 'Finished building target: "$@"'
	@echo ' '
	@$(MAKE) --no-print-directory post-build

# Other Targets
clean:
	-$(RM) $(EXE_OUTPUTS__QUOTED)
	-$(RM) "CircularBuffer.obj" "FIR_filter_asm_sc.obj" "adda.obj" "fir_filter_sc.obj" "i2c.obj" "main_adda_Lab3.obj" "main_adda_Lab3_dec.obj" "main_adda_Lab_pointers.obj" "main_adda_simple_Lab.obj" "main_adda_simple_Lab2_dec.obj" "main_adda_simple_Lab2_int.obj" "pru.obj" 
	-$(RM) "CircularBuffer.d" "adda.d" "fir_filter_sc.d" "i2c.d" "main_adda_Lab3.d" "main_adda_Lab3_dec.d" "main_adda_Lab_pointers.d" "main_adda_simple_Lab.d" "main_adda_simple_Lab2_dec.d" "main_adda_simple_Lab2_int.d" "pru.d" 
	-$(RM) "FIR_filter_asm_sc.d" 
	-@echo 'Finished clean'
	-@echo ' '

post-build:
	-"../../../../../../TI/C6747/ais/HexAIS_OMAP-L137.exe" -ini ../../../../../../TI/C6747/ais/c6747_ais.ini adda_simple.out &  "../../../../../../Utilities/bin2hex.exe" -o 0x10000 adda_simple.bin adda_simple.hex
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets

