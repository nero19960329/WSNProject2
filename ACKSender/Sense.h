
#ifndef SENSE_H
#define SENSE_H

enum {
    AM_MSG = 0,
    TIMER_PERIOD_MILLI = 250
};

typedef nx_struct ack_msg_t {
	nx_uint8_t group_id;
}ack_msg_t;

typedef nx_struct result_msg_t {
	nx_uint8_t group_id;
	nx_uint32_t max;
	nx_uint32_t min;
	nx_uint32_t sum;
	nx_uint32_t average;
	nx_uint32_t median;
}result_msg_t;

#endif
