/*********************************************************************

 @file      main_adda_simple_Lab.c (Svg, 11-Jul-2023)

 @brief     C.Module.Unidaq2-ADDA Test Program
 @author    D.SignT GmbH & Co. KG, A.Klemenz, modified for MSVC simulation by Svg
 @version   1.0
 @date      2018-01-31, Svg : 07-Okt-20, 16-Aug-21, 22-Nov-21, 19-Jun-23
 @target    C.Module.Unidaq2-ADDA
 @compiler  CCS
 @history   1.0 initial release 2018-01-31 by AK                   */
 
 /***********************************************************************
  includes
***********************************************************************/
#include <BoardSupport/inc/unidaq2.h>       /**< Unidaq2-ADDA BIOS    */
#include <BoardSupport/inc/errors.h>        /**< Error Codes          */
#include <BoardSupport/drv/i2c.h>          /**< Unidaq2-ADDA I2C     */
#include <BoardSupport/drv/adda.h>          /**< Unidaq2-ADDA ADC DAC */

#include <Common/pru.h>        				  /**< PRU subsystem      */

#pragma DATA_SECTION (PRU_addaCode, ".const_slow");
#include <Common/PRU/PRU_adda_bin.h> 		  /**< PRU program code   */

#include <ti/pspiom/cslr/soc_C6747.h>         /**< 6747 peripherals   */
#include <ti/pspiom/cslr/cslr_gpio.h>         /**< GPIO               */

#include <math.h>							  /**< floating-point     */

// includes of Lennard and Victor
#include "int_by_2_FIR_PP_decomp.h"



/***********************************************************************
  defines
***********************************************************************/
// defines of Lennard and Victor
#define NUM_POLY_BRANCHES 2 // Anzahl der Polyphasenkomponenten

// default ratio of sample rates
#define LL 4
#define MM 2

#define ADC_FSAMP (100000/LL)
#define DAC_FSAMP (100000/MM)

//#define SYSMSG_DBG_UART     /**< system messages via Debug UART       */
#define SYSMSG_CCS_CIO      /**< system messages via CCS CIO          */

#ifdef SYSMSG_CCS_CIO
#include <stdio.h>
#endif

// PRU
#define	PRU_NUM		0			/**< the PRU to handle McASP (0 or 1) */


/***********************************************************************
  globals
***********************************************************************/
/*
  Global variables used in interrupts must be declared volatile.
  Place in L1DRAM (.data_crit section) to avoid cache data
  displacement and fastest access time.
 */
#pragma DATA_SECTION (sData, ".data_crit");

volatile int16_t sData[16];
int16_t idx;

PRU_addaOvly PRU_addaRegs = (PRU_addaOvly) (PRU0_DRAM + PRU_NUM * (PRU1_DRAM-PRU0_DRAM));

/***********************************************************************
  globals SP Lab 
***********************************************************************/

// Put your additional global variables here ...

// prototype for our filter
short FIR_filter_sc(    short FIR_delays[],         // delay array
                        short FIR_coe[],            // coefficients
                        short int Ndelays,          // number of coeffs / delays
                        short x_n,                  // current input sample
                        short shft
    );

/***********************************************************************
  end of globals SP Lab
***********************************************************************/

/*******************************************************************//**
  @brief	system message output on Debug UART or via Code Composer
  @param    pstr - pointer to string
  @return	-
***********************************************************************/
void System_puts (char *pstr)
{
#ifdef SYSMSG_DBG_UART
    /*******************************************************************
      locals
    *******************************************************************/
    char c;

    /*******************************************************************
      write to Debug UART
    *******************************************************************/
    while ((c = *pstr++) != 0)
    {
        while (DBG_write(c) != DBG_OK) ;
    }
#endif

#ifdef SYSMSG_CCS_CIO
    /*******************************************************************
      write to CCS CIO
    *******************************************************************/
    printf (pstr);
    fflush(stdout);
#endif
}

/*********************************************************************
  @brief    PRU interrupt for ADC
  @param    -
  @return   -
***********************************************************************/
__interrupt void adcInt (void)
{
    /*******************************************************************
      read all ADC channels and store in floating point format
    *******************************************************************/
    for (idx=0; idx<16; idx++)
	{
		sData[idx] = PRU_addaRegs->adc[idx];
	}

// Put your ADC DSP code here ...
    /************************* autor: Kroeger date: 21.11.2023 ***********************************/
    static short poly_switch = 0;

    // Switch now starts at poly branch zero an then starts to rotate clockwise 
    switch (poly_switch) {
    case 0:
        outData[0] = FIR_filter_sc(H_filt_FIR_design_int_2_0_lab2, b_FIR_int_2_0_HP, N_DELAYS_FIR_DESIGN_INT_BRANCH_2_1_LAB2, sData[0], 14); // Shift by 1 (equals mul by 2) to correct interpolator specific bisection 
        break;
    case 1:
        outData[1] = FIR_filter_sc(H_filt_FIR_design_int_2_1_lab2, b_FIR_int_2_1_HP, N_DELAYS_FIR_DESIGN_INT_BRANCH_2_0_LAB2, sData[0], 14); // Shift by 1 (equals mul by 2) to correct interpolator specific bisection 
        break;
    default:
        break;
    }
    poly_switch++;
    poly_switch %= NUM_POLY_BRANCHES;
    /********************************************************************************************/
}

/*******************************************************************//**
  @brief    PRU interrupt for DAC
  @param    -
  @return   -
***********************************************************************/
__interrupt void dacInt (void)
{

    // Put your DAC DSP code here ...
    /************************* autor: Kroeger date: 21.11.2023 ***********************************/
    // Invertierung jedes zweiten Samples zur Transformation in den Tiefpassbereich
    if (_switch) {
        sData[0] = -sData[0];
        _switch = 0;
    }
    else {
        _switch = 1;
    }
    /********************************************************************************************/


    /*******************************************************************
      write DAC channels 1..8
    *******************************************************************/
    for (idx=0; idx<8; idx++)
	{
		PRU_addaRegs->dac[idx] = sData[idx];
	}
}

/*******************************************************************//**
  main program
***********************************************************************/
void main (void)
{
// Put your variables to be initialized in main() here ...

	/*******************************************************************
	  locals
	*******************************************************************/
//    CSL_GpioRegsOvly GpioRegs = (CSL_GpioRegsOvly)CSL_GPIO_0_REGS;
    int32_t retval;

	/*******************************************************************
	  Board Initialization,
	  required only for CCS debugging to put board into a defined state
	*******************************************************************/
	UNIDAQ2_init (SDRAM_NOINIT | PLL_NOINIT);

	/*******************************************************************
	  print startup message
	*******************************************************************/
    System_puts ("\r\n-------------------------------------------------\r\n"
		  	       "        #######:        UniDAQ2.DSP-ADDA\r\n"
			 	   "        ###'\r\n"
		 		   " .####: ###               PRU ADDA Demo\r\n"
				   " ###    ###\r\n"
				   " '########'  D.SignT GmbH & Co.KG  www.dsignt.de\r\n"
				   "-------------------------------------------------\r\n\n");
    printf("ADC_FSAMP : %15.6f Hz, DAC_FSAMP : %15.6f Hz\n", (float) ADC_FSAMP, (float) DAC_FSAMP);

    /*******************************************************************
      I2C Initialization
    *******************************************************************/
    retval = I2C_init (400000, 0x7E);
    if (retval != ERROR_NONE)
    {
        System_puts("I2C_init() failed! program halted\r\n");
        for (;;);  /* trap or error handling */
    }

    /*******************************************************************
      Interrupt System Initialization
    *******************************************************************/
    INT_init (&INT_vectorTable);
    INT_sel (15, INT_EVT_IIC1_INT);
    INT_instFunc (15, I2C_int);
    INT_sel (4, INT_EVT_PRUEVT6);
    INT_instFunc (4, adcInt);
    INT_sel (5, INT_EVT_PRUEVT7);
    INT_instFunc (5, dacInt);
    INT_start();

    /*******************************************************************
      ADC Initialization:
        +/-10V range
        no oversampling
        sampling clock generated by Timer A, 100kHz
    *******************************************************************/
    retval = ADC_config(RANGE_10, OS_NONE, ADCTRIG_TIMERA, ADC_FSAMP);  // Svg
    if (retval != ERROR_NONE)
    {
        System_puts("ACD_config() failed! program halted\r\n");
        for (;;);  /* trap or error handling */
    }

	/*******************************************************************
	  DAC Initialization:
	    +/-10V range
	    synchronized to ADC
	    no calibration
	    no monitor output
	*******************************************************************/
    retval = DAC_config(DAC_CFGREG_GAIN4, DACTRIG_TIMERB, DAC_FSAMP, NULL, NULL, REF5V, MON_OFF);

    if (retval != ERROR_NONE)
    {
        System_puts("DAC_config() failed! program halted\r\n");
    	for (;;);  /* trap or error handling */
    }

	/*******************************************************************
	  enable PRU, load and execute PRU code
	*******************************************************************/
	PRU_init();
	PRU_load(PRU_NUM, (void *)PRU_addaCode, sizeof(PRU_addaCode));
	if (PRU_run(PRU_NUM) != ERROR_NONE)
	{
        System_puts("PRU_run() failed! program halted\r\n");
        for (;;);  /* trap or error handling */
	}

    /*******************************************************************
      start data acquisition
    *******************************************************************/
    System_puts("signal processing started, loopback ADC 1..8 -> DAC 1..8\r\n");
    DAC_start();
    ADC_start();

	/*******************************************************************
	  main program loop
	*******************************************************************/
	for (;;)
	{
	    // infinite for loop
    } // for (;;)...
}
