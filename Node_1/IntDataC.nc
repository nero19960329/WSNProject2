/*
 * Author: Wang Zhao
 * Create time: 2015/12/26 10:54
 */

#include "Timer.h"
#include "IntData.h"

module IntDataC {
  uses {
  	interface SplitControl as Control;
    interface Receive;
    interface Boot;
    interface Leds;
  }
}
implementation {

	message_t packet;

	uint32_t integers[2000];
	bool listened[1000];

	uint32_t max = 0, min = -1, sum = 0, average, median;
	uint16_t curSeq = 0;
  
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

  task void calValue() {
  	int i;
  	for (i = 1; i < 2000; ++i) {
			if (integers[i-1] > integers[i]) {
				int temp = integers[i];
				int j = i;
				while (j > 0 && integers[j-1] > temp) {
					integers[j] = integers[j-1];
					--j;
				}
				integers[j] = temp;
			}
  	}

  	max = integers[1999];
  	min = integers[0];
  	//median = (integers[999] + integers[1000]) / 2;

  	if (min == 1) {
			call Leds.led0Toggle();
  	}

  	if (max == 2000) {
			call Leds.led1Toggle();
  	}
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(intdata_msg_t)) {
			call Leds.led2Toggle();
			intdata_msg_t* recv_pkt = (intdata_msg_t*)payload;
			curSeq = recv_pkt->sequence_number - 1;
			integers[curSeq] = recv_pkt->random_integer;

			if (curSeq == 1999) {
				post calValue();
				call Control.stop();
			}
		}
		return msg;
  }
}
