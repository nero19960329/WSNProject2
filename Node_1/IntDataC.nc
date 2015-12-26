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
    interface Timer<TMilli>;
  }
}
implementation {

	message_t packet;

	uint16_t integers[2000];
	bool listened[2000];

	uint32_t max = 0, min = 65535, sum = 0, average, median;
	uint16_t curSeq = 0;
  
  event void Boot.booted() {
  	int i;
  	for (i = 0; i < 2000; ++i) {
			listened[i] = FALSE;
  	}
  	call Control.start();
  }

  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer.startPeriodic(500);
		} else {
			call Control.start();
		}
  }

  event void Control.stopDone(error_t err) {}

  bool ifAllListened() {
		int i;
		for (i = 0; i < 2000; ++i) {
			if (listened[i] == FALSE) {
				return FALSE;
			}
		}
		return TRUE;
  }

	void calValue() {
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

  	for (i = 0; i < 2000; ++i) {
			sum += integers[i];
  	}

  	max = integers[1999];
  	min = integers[0];
  	average = sum / 2000;
  	median = (integers[999] + integers[1000]) / 2;

  	if (min == 1) {
			call Leds.led0Toggle();
  	}

  	if (max == 2000) {
			call Leds.led1Toggle();
  	}
  }

  event void Timer.fired() {
  	if (ifAllListened()) {
			call Timer.stop();
			call Control.stop();
			calValue();
  	}
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(intdata_msg_t)) {
			intdata_msg_t* recv_pkt = (intdata_msg_t*)payload;
			call Leds.led2Toggle();

			curSeq = recv_pkt->sequence_number - 1;
			if (listened[curSeq] == FALSE) {
				listened[curSeq] = TRUE;
				integers[curSeq] = (uint16_t)recv_pkt->random_integer;
			}
		}
		return msg;
  }
}
