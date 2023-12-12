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
#include "dec_kernel_int_WS23.h"
#include "CircularBuffer.h"




/***********************************************************************
  defines
***********************************************************************/
// defines of Lennard and Victor
// NUM_POLY_BRANCHES wird in dec_kernel_int.h definiert
// K und BUFFER_SIZE werden in CircularBuffer.c definiert

// default ratio of sample rates
#define LL 2
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

RingBuffer ringbuf;
short rbOut = 0;
volatile short sDataOut[2];


/***********************************************************************
  globals SP Lab (Lennard and Victor)
***********************************************************************/

// Put your additional global variables here ...
short yDecOut; // Ausgang der aufsummierten PP des Dezimators, geht zum Kernel
short kernelOut; // Ausgang des Kernel-Filters, geht zum Interpolator
short yIntOut; // Ausgang des Interpolator, soll zum DAC


// prototype for our filter
short FIR_filter_sc(    short FIR_delays[],         // delay array
                        short FIR_coe[],            // coefficients
                        short int Ndelays,          // number of coeffs / delays
                        short x_n,                  // current input sample
                        short shft
    );



/*
#define MM 4
short *p2p_H_polyphase_filter_DEC[MM]
p2p_H_polyphase_filter_DEC[0] = H_polyphase_filt_0_delays_DEC;
p2p_H_polyphase_filter_DEC[0] = H_polyphase_filt_0_delays_DEC;
p2p_H_polyphase_filter_DEC[0] = H_polyphase_filt_0_delays_DEC;
p2p_H_polyphase_filter_DEC[0] = H_polyphase_filt_0_delays_DEC;
*/

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
#define NUM_CHANNELS 1  // number of adc channels we are using
    static short counter = 0;
    for (idx=0; idx<NUM_CHANNELS; idx++)
	{
		sData[idx] = PRU_addaRegs->adc[idx];

		/* if(counter == 999){
            sData[idx] = 32767;

        } else{
            sData[idx] = 0;
        }*/

	}
    counter++;
    counter %= 1000;

// Put your ADC DSP code here ...
    static short poly_switch = 0;

    // Zählen der ISRs zur gezielten Auswahl der PP und Delays
    static int adcCount = 0;  

    // Berechnung einer Polyphase des Dezimators
    yDecOut += FIR_filter_sc(p2p_H_polyphase_filt_DEC[adcCount], p2p_b_boly_Dec_Int[adcCount], delays[adcCount], sData[0], 15);

    adcCount++;
    if(adcCount == NUM_POLY_BRANCHES){
      kernelOut = FIR_filter_sc(H_filt_Kernel, b_Kernel, N_delays_Kernel, yDecOut, 15);
      adcCount = 0;
      yDecOut = 0; 
    }

    // Berechnung des in Polyphasen zerlegten Interpolators
    // muss hinter der Berechnung von kernelOut stehen, sonst bringen wir zusätzliches T ein
    sDataOut[0] = FIR_filter_sc(p2p_H_polyphase_filt_INT[adcCount], p2p_b_boly_Dec_Int[NUM_POLY_BRANCHES - 2 - adcCount], delays[NUM_POLY_BRANCHES - 2 - adcCount], kernelOut, 13);

    // Branching-Filter
    enqueue(&ringbuf, sData[0]);
    static int branch_wait = 0;
    if(branch_wait == K){
        rbOut = dequeue(&ringbuf);
        sDataOut[1] = sDataOut[0] - rbOut; // In sDataOut[1] steht das Ausgangssample des Interpolators
    } else{
        branch_wait++;
    }

}

/*******************************************************************//**
  @brief    PRU interrupt for DAC
  @param    -
  @return   -
***********************************************************************/
__interrupt void dacInt (void)
{

    // Put your DAC DSP code here ...


    /*******************************************************************
      write DAC channels 1..8
    *******************************************************************/
#define NUM_DAC_CHANNELS 2
    for (idx=0; idx<NUM_DAC_CHANNELS; idx++)
	{
		PRU_addaRegs->dac[idx] = sDataOut[idx];
	}
}

/*******************************************************************//**
  main program
***********************************************************************/
void main (void)
{
// Put your variables to be initialized in main() here ...

   initializeBuffer(&ringbuf);

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
