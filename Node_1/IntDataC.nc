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
    interface Packet;
		interface AMPacket;
    interface AMSend;
    interface Timer<TMilli> as Timer1;
    interface Timer<TMilli> as Timer2;
  }
}
implementation {

	message_t packet;
	bool busy = FALSE;

	bool timer2Opened = FALSE;

	uint16_t integers[2000];
	bool listened[2000];

	uint32_t max = 0, min = 65535, sum = 0, average = 0, median = 0;
	uint16_t curSeq = 0;
	uint16_t lackStack[500];
	int top;
  
  event void Boot.booted() {
  	int i;
  	for (i = 0; i < 2000; ++i) {
			listened[i] = FALSE;
  	}
  	call Control.start();
  }

  task void sendResult() {
		result_msg_t* this_pkt = (result_msg_t*)(call Packet.getPayload(&packet, NULL));
		this_pkt->group_id = 4;
		this_pkt->max = max;
		this_pkt->min = min;
		this_pkt->sum = sum;
		this_pkt->average = average;
		this_pkt->median = median;

		call AMSend.send(0, &packet, sizeof(result_msg_t));
  }

  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer1.startPeriodic(1000);
		} else {
			call Control.start();
		}
  }

  event void Control.stopDone(error_t err) {}

  task void sendLackSeq() {
		if (!busy) {
			filldata_msg_t* this_pkt = (filldata_msg_t*)(call Packet.getPayload(&packet, NULL));
			call Leds.led1Toggle();
			this_pkt->sequence_number = lackStack[top-1]+1;
			--top;
				
			if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(filldata_msg_t)) == SUCCESS) {
				busy = TRUE;
			}
		}
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
		if(&packet == msg) {
			busy = FALSE;
			if (top > 0) {
				post sendLackSeq();
			}
		}
	}

	bool ifLack(int k) {
		if (k < 1995) {
			return listened[k+1] || listened[k+2] || listened[k+3] || listened[k+4];
		} else {
			return listened[(k+1)%2000] || listened[(k+2)%2000] || listened[(k+3)%2000] || listened[(k+4)%2000];
		}
	}

  bool ifAllListened() {
		int i;
		bool flag = TRUE;

		top = 0;
		for (i = 0; i < 2000; ++i) {
			if (listened[i] == FALSE) {
				flag = FALSE;

				if (top < 500 && ifLack(i)) {
					lackStack[top] = i;
					top++;
				} else {
					return FALSE;
				}
			}
		}

		if (top > 0) {
			post sendLackSeq();
		}
		
		return flag;
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
  }

  event void Timer1.fired() {
  	if (ifAllListened()) {
			call Timer1.stop();
			calValue();
			if (timer2Opened == FALSE) {
				timer2Opened = TRUE;
				call Timer2.startPeriodic(10);
			}
  		post sendResult();
			//call Control.stop();
  	}
  }

  event void Timer2.fired() {
  	call Leds.led0Toggle();
		post sendResult();
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
		} else if (len == sizeof(ack_msg_t) && call AMPacket.source(msg) == 0) {
			ack_msg_t* recv_pkt = (ack_msg_t*)payload;
			if (recv_pkt->group_id == 4) {
				call Timer2.stop();
				call Control.stop();
			}
		}
		return msg;
  }
}
