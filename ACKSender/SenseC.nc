
#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 100

module SenseC {
  uses {
  	interface SplitControl as Control;
  	interface AMSend;
  	interface Packet;
  	interface AMPacket;
    interface Boot;
    interface Leds;

    interface Receive;
  }
}
implementation {

	message_t packet;

	bool busy = FALSE;

	uint16_t cur_temp = 0;
	uint16_t cur_humid = 0;
	uint16_t cur_light = 0;
	
	uint16_t counter = 0;
  
  event void Boot.booted() {
  	call Control.start();
  }

  
  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			
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
		if(len == sizeof(result_msg_t) && call AMPacket.source(msg) == 10 && call AMPacket.destination(msg) == 0) {
			result_msg_t* recv_pkt = (result_msg_t*)payload;
			ack_msg_t* this_pkt = (ack_msg_t*)(call Packet.getPayload(&packet, NULL));
			this_pkt -> group_id = 4;
			if(call AMSend.send(10, &packet, sizeof(ack_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led0Toggle();
			}
		}
		return msg;
	}
}

