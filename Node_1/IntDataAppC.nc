/*
 * Author: Wang Zhao
 * Create time: 2015/12/26 10:54
 */

#include "IntData.h"

configuration IntDataAppC {} 
implementation { 
  
  components IntDataC, MainC, LedsC;

	components ActiveMessageC;
  components new AMReceiverC(AM_MSG);

  IntDataC.Boot -> MainC;
  IntDataC.Leds -> LedsC;

	IntDataC.Control -> ActiveMessageC;
  IntDataC.Receive -> AMReceiverC;
}
