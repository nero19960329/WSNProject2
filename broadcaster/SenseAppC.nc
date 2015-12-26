/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include <Timer.h>
#include "Sense.h"

configuration SenseAppC 
{ 
} 
implementation { 
  
  components SenseC,MainC, LedsC, new TimerMilliC();

  components RandomC;

  components new AMSenderC(AM_MSG);
  components ActiveMessageC;

  components new AMReceiverC(AM_MSG);

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Timer -> TimerMilliC;
  
  SenseC.Packet -> AMSenderC;
  SenseC.AMPacket -> AMSenderC;
  SenseC.AMSend -> AMSenderC;
  SenseC.Control -> ActiveMessageC;

  SenseC.Receive -> AMReceiverC;

	SenseC.Random->RandomC;
  
}
