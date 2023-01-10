#include "put_bits.h"

#include <stdio.h>
#include <stdlib.h>

#ifndef AV_WB32
#define AV_WB32(p, val)                                                        \
  do {                                                                         \
    uint32_t d = (val);                                                        \
    ((uint8_t *)(p))[3] = (d);                                                 \
    ((uint8_t *)(p))[2] = (d) >> 8;                                            \
    ((uint8_t *)(p))[1] = (d) >> 16;                                           \
    ((uint8_t *)(p))[0] = (d) >> 24;                                           \
  } while (0)
#endif

void init_put_bits(PutBitContext *s, uint8_t *buffer, int buffer_size) {
  if (buffer_size < 0) {
    buffer_size = 0;
    buffer = NULL;
  }

  s->size_in_bits = 9 * buffer_size; // con 9 deberia valer pues nuestro simbolo
                                     // mas largo mide 9 bits
  s->buf = buffer;
  s->buf_end = s->buf + buffer_size * 2;
  s->buf_ptr = s->buf;
  s->bit_left = 32;
  s->bit_buf = 0;
}

/**
 * @return the total number of bits written to the bitstream.
 */
int put_bits_count(PutBitContext *s) {
  return (s->buf_ptr - s->buf) * 8 + 32 - s->bit_left;
}

/**
 * Write up to 31 bits into a bitstream.
 * Use put_bits32 to write 32 bits.
 */
void put_bits(PutBitContext *s, int n, unsigned int value) {
  unsigned int bit_buf;
  int bit_left;

  if (n <= 31 && value < (1U << n)) {
  } else {
    printf("Error!!!!!!!! n > 31\n");
    abort();
  }

  bit_buf = s->bit_buf;
  bit_left = s->bit_left;

  if (n < bit_left) {
    bit_buf = (bit_buf << n) | value;
    bit_left -= n;
  } else {
    bit_buf <<= bit_left;
    bit_buf |= value >> (n - bit_left);
    if (3 < s->buf_end - s->buf_ptr) {
      AV_WB32(s->buf_ptr, bit_buf);
      s->buf_ptr += 4;
    } else {
      printf("Internal error, put_bits buffer too small\n");
      abort();
    }
    bit_left += 32 - n;
    bit_buf = value;
  }

  s->bit_buf = bit_buf;
  s->bit_left = bit_left;
}

void put_bits_flush(PutBitContext *s) {

#ifndef BITSTREAM_WRITER_LE
  if (s->bit_left < 32)
    s->bit_buf <<= s->bit_left;
#endif
  while (s->bit_left < 32) {
#ifdef BITSTREAM_WRITER_LE
    *s->buf_ptr++ = s->bit_buf;
    s->bit_buf >>= 8;
#else
    *s->buf_ptr++ = s->bit_buf >> 24;
    s->bit_buf <<= 8;
#endif
    s->bit_left += 8;
  }
  s->bit_left = 32;
  s->bit_buf = 0;
}
