/*
 * Author: Wang Zhao
 * Create time: 2015/12/14 17:23
 */

#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 10

module SenseC {
  uses {
  	interface SplitControl as Control;
  	interface AMSend;
  	interface Packet;
  	interface AMPacket;
    interface Boot;
    interface Leds;
    interface Timer<TMilli>;
		interface Random;
    interface Receive;
  }
}
implementation {

	message_t packet;

	bool busy = FALSE;
	
	uint16_t counter = 0;
	uint32_t num[2000];
	uint16_t i=0;
  
  event void Boot.booted() {
  	for(i=0; i<2000; i++){
			//num[i] = call Random.rand32();
			num[i] = i+1;
  	}
  	call Control.start();
  }

  event void Timer.fired() {
    if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)(call Packet.getPayload(&packet, NULL));
			if (counter < 2000) {
				this_pkt->random_integer = num[counter];
				this_pkt->sequence_number = ++counter;
			} else if (counter == 2000){
				counter = 0;
				this_pkt->random_integer = num[counter];
				this_pkt->sequence_number = ++counter;
			}
			
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led0Toggle();
			}
		}
  }


  
  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer.startPeriodic(10);
		} else {
			call Control.start();
		}
  }

  event void Control.stopDone(error_t err) {}

	event void AMSend.sendDone(message_t* msg, error_t error) {
		if(&packet == msg) {
			busy = FALSE;
		}
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if(len == sizeof(sense_msg_t)) {
			sense_msg_t* this_pkt = (sense_msg_t*)payload;
		}
		return msg;
	}
}

