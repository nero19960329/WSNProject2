
#include <Timer.h>
#include "Sense.h"

configuration SenseAppC 
{ 
} 
implementation { 
  
  components SenseC,MainC, LedsC;

  components new AMSenderC(AM_MSG);
  components ActiveMessageC;

  components new AMReceiverC(AM_MSG);

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;



  SenseC.Packet -> AMSenderC;
  SenseC.AMPacket -> AMSenderC;
  SenseC.AMSend -> AMSenderC;
  SenseC.Control -> ActiveMessageC;

  SenseC.Receive -> AMReceiverC;
}
