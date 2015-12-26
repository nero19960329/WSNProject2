/*
 * Author: Wang Zhao
 * Create time: 2015/12/26 10:54
 */

#include "IntData.h"

configuration IntDataAppC {} 
implementation { 
  
  components IntDataC, MainC, LedsC, new TimerMilliC();

	components ActiveMessageC;
  components new AMSenderC(AM_MSG);
  components new AMReceiverC(AM_MSG);

  IntDataC.Boot -> MainC;
  IntDataC.Leds -> LedsC;
  IntDataC.Timer -> TimerMilliC;

	IntDataC.Control -> ActiveMessageC;
	IntDataC.Packet -> AMSenderC;
  IntDataC.AMSend -> AMSenderC;
  IntDataC.Receive -> AMReceiverC;
}
