#ifndef __PMP_H
#define __PMP_H

#define PMP_SET_TOR( pmp, pmpcfg, num, addr, r, w, x )  \
  la t0, addr;                \
  srli t0, t0, 2;             \
  csrw pmp, t0;               \
  csrr t3, pmpcfg;            \
  li t0, PMP_TOR | r | w | x; \
  slli t0, t0, num;           \
  li t2, 0xff;                \
  slli t2, t2, num;           \
  not t2, t2;                 \
  and t3, t3, t2;             \
  or t3, t3, t0;              \
  csrw pmpcfg, t3;            \
  .align 2;                   \
1:

#endif