################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

# Each subdirectory must supply rules for building sources it contributes
%.obj: ../%.asm $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/bin/cl6x" -mv6740 --abi=eabi -O2 --include_path="C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/include" --include_path="../../../../" --include_path="../../../../../../TI/C6747/psp" --define=c6747 --diag_wrap=off --diag_warning=225 --display_error_number --mem_model:const=data --mem_model:data=far_aggregates --interrupt_threshold=50 --preproc_with_compile --preproc_dependency="$(basename $(<F)).d_raw" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

adda.obj: D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/drv/adda.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/bin/cl6x" -mv6740 --abi=eabi -O2 --include_path="C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/include" --include_path="../../../../" --include_path="../../../../../../TI/C6747/psp" --define=c6747 --diag_wrap=off --diag_warning=225 --display_error_number --mem_model:const=data --mem_model:data=far_aggregates --interrupt_threshold=50 --preproc_with_compile --preproc_dependency="$(basename $(<F)).d_raw" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

%.obj: ../%.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/bin/cl6x" -mv6740 --abi=eabi -O2 --include_path="C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/include" --include_path="../../../../" --include_path="../../../../../../TI/C6747/psp" --define=c6747 --diag_wrap=off --diag_warning=225 --display_error_number --mem_model:const=data --mem_model:data=far_aggregates --interrupt_threshold=50 --preproc_with_compile --preproc_dependency="$(basename $(<F)).d_raw" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

i2c.obj: D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/drv/i2c.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/bin/cl6x" -mv6740 --abi=eabi -O2 --include_path="C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/include" --include_path="../../../../" --include_path="../../../../../../TI/C6747/psp" --define=c6747 --diag_wrap=off --diag_warning=225 --display_error_number --mem_model:const=data --mem_model:data=far_aggregates --interrupt_threshold=50 --preproc_with_compile --preproc_dependency="$(basename $(<F)).d_raw" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

pru.obj: D:/ti_work/UniDAQ2.DSP-ADDA/Common/pru.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/bin/cl6x" -mv6740 --abi=eabi -O2 --include_path="C:/ti/ccs1230/ccs/tools/compiler/ti-cgt-c6000_8.3.12/include" --include_path="../../../../" --include_path="../../../../../../TI/C6747/psp" --define=c6747 --diag_wrap=off --diag_warning=225 --display_error_number --mem_model:const=data --mem_model:data=far_aggregates --interrupt_threshold=50 --preproc_with_compile --preproc_dependency="$(basename $(<F)).d_raw" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: "$<"'
	@echo ' '


