#ifndef SENSE_H
#define SENSE_H

enum {
    AM_MSG = 0,
    TIMER_PERIOD_MILLI = 250
};

typedef nx_struct sense_msg_t {
	nx_uint16_t sequence_number;
	nx_uint32_t random_integer;
}sense_msg_t;

#endif
