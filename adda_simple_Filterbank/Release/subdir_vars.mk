################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

# Add inputs and outputs from these tool invocations to the build variables 
CMD_SRCS += \
D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/lnk/unidaq2.cmd 

ASM_SRCS += \
../FIR_filter_asm_sc.asm 

C_SRCS += \
D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/drv/adda.c \
../fir_filter_sc.c \
D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/drv/i2c.c \
../main_adda_Lab6_int.c \
../main_adda_Lab6_perfRecon.c \
D:/ti_work/UniDAQ2.DSP-ADDA/Common/pru.c 

C_DEPS += \
./adda.d \
./fir_filter_sc.d \
./i2c.d \
./main_adda_Lab6_int.d \
./main_adda_Lab6_perfRecon.d \
./pru.d 

OBJS += \
./FIR_filter_asm_sc.obj \
./adda.obj \
./fir_filter_sc.obj \
./i2c.obj \
./main_adda_Lab6_int.obj \
./main_adda_Lab6_perfRecon.obj \
./pru.obj 

ASM_DEPS += \
./FIR_filter_asm_sc.d 

OBJS__QUOTED += \
"FIR_filter_asm_sc.obj" \
"adda.obj" \
"fir_filter_sc.obj" \
"i2c.obj" \
"main_adda_Lab6_int.obj" \
"main_adda_Lab6_perfRecon.obj" \
"pru.obj" 

C_DEPS__QUOTED += \
"adda.d" \
"fir_filter_sc.d" \
"i2c.d" \
"main_adda_Lab6_int.d" \
"main_adda_Lab6_perfRecon.d" \
"pru.d" 

ASM_DEPS__QUOTED += \
"FIR_filter_asm_sc.d" 

ASM_SRCS__QUOTED += \
"../FIR_filter_asm_sc.asm" 

C_SRCS__QUOTED += \
"D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/drv/adda.c" \
"../fir_filter_sc.c" \
"D:/ti_work/UniDAQ2.DSP-ADDA/BoardSupport/drv/i2c.c" \
"../main_adda_Lab6_int.c" \
"../main_adda_Lab6_perfRecon.c" \
"D:/ti_work/UniDAQ2.DSP-ADDA/Common/pru.c" 


