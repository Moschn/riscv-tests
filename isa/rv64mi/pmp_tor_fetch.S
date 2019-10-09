# See LICENSE for license details.

#*****************************************************************************
# pmp.S
#-----------------------------------------------------------------------------
#
# Test PMP.
#

#include "riscv_test.h"
#include "test_macros.h"
#include "pmp.h"

#define MEM_START         0x80000000
#define PROTECTED_MEM     0x80008000
#define PROTECTED_MEM_END 0x8000f000

RVTEST_RV64M
RVTEST_CODE_BEGIN

  # use mstatus.MPP to check existence of U mode.
  li t0, MSTATUS_MPP
  csrc mstatus, t0
  csrr t2, mstatus
  and t0, t0, t2
  beqz t0, 1f

  # If U mode doesn't exist, pass immediately
  j pass

1:
  TEST_CASE_EXCEPT(1, CAUSE_FETCH_ACCESS, test_2, \
    PMP_SET_TOR(pmpaddr0, pmpcfg0, 0, _protected_start, PMP_R, PMP_W, PMP_X); \
    PMP_SET_TOR(pmpaddr1, pmpcfg0, 8, _protected_stop, 0, 0, 0); \
    li t0, MSTATUS_MPP; \
    csrc mstatus, t0; \
    la t0, 1f; \
    csrw mepc, t0; \
    mret; \
  1: \
    jal _protected_start; \
  );

  TEST_CASE_NO_EXCEPT(2, CAUSE_FETCH_ACCESS, end, \
    PMP_SET_TOR(pmpaddr0, pmpcfg0, 0, unprot_code, PMP_R, PMP_W, PMP_X); \
    PMP_SET_TOR(pmpaddr1, pmpcfg0, 8, unprot_code_end, 0, 0, PMP_X); \
    li t0, MSTATUS_MPP; \
    csrc mstatus, t0; \
    la t0, 1f; \
    csrw mepc, t0; \
    mret; \
  1: \
    jal unprot_code; \
  );


end:
  j pass;
TEST_PASSFAIL
TEST_CASE_EXCEPT_INIT_HANDLER
RVTEST_CODE_END

unprot_code:
  ret
unprot_code_end:
  j fail

  .data
RVTEST_DATA_BEGIN

  TEST_DATA
  .globl _protected_start
  .globl _protected_stop
_protected_start:
  ret
  .align 4, 0
_protected_stop:
  .dword 0

RVTEST_DATA_END
