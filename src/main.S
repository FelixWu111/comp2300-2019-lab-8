.syntax unified

.global main
.global SysTick_Handler
.global EXTI0_IRQHandler

.type main, %function
.type SysTick_Handler, %function
SysTick_Handler:
  bl red_led_on
SysTick_Handler_infloop:
  nop
  b SysTick_Handler_infloop
.size SysTick_Handler, .-SysTick_Handler

main:
  bl joystick_init
  bl red_led_init
  bl green_led_init

@ r0: base address
@ r1: offset
@ r2: bit index
@ r3: data (LSB)
@for the SysTick interrupt, you can set the interrupt priority by writing bits 28-31 of the System Handler Priority Register 3
  ldr r0, =0xE000ED20
  mov r1, 0
  mov r2, 28
  mov r3, 1
  bl write_bit

  ldr r0, =0xE000ED20
  mov r1, 0
  mov r2, 29
  mov r3, 1
  bl write_bit

  ldr r0, =0xE000ED20
  mov r1, 0
  mov r2, 30
  mov r3, 0
  bl write_bit

  ldr r0, =0xE000ED20
  mov r1, 0
  mov r2, 31
  mov r3, 1
  bl write_bit
@for the PA0 interrupt, you can set the interrupt priority by writing bits 20-23 of the NVIC interrupt priority register

  ldr r0, =0xE000E404
  mov r1, 0
  mov r2, 20
  mov r3, 1
  bl write_bit

  ldr r0, =0xE000E404
  mov r1, 0
  mov r2, 21
  mov r3, 0
  bl write_bit

  ldr r0, =0xE000E404
  mov r1, 0
  mov r2, 22
  mov r3, 1
  bl write_bit

  ldr r0, =0xE000E404
  mov r1, 0
  mov r2, 23
  mov r3, 0
  bl write_bit


/*
  @load the address for SYST_CSR
  ldr r1, =0xE000E010
  ldr r2, [r1]
  @then set the  0x0101 to enable the counter.
  orr r2, 0x0101
  str r2, [r1]

  @set the SYST_RVR
  ldr r3, =0xE000E014
  ldr r4, [r3]  
  ldr r4, =4000000
  str r4, [r3]

  @set the counter SYST_CVR
  ldr r5, =0xE000E018
  ldr r6, [r5]
*/

//address of SYST_CSR register
  ldr r0, =0xE000E010
  mov r1, 0
  mov r2, 0 
  bl set_bit

  ldr r0, =0xE000E010
  mov r1, 0
  mov r2, 2
  bl set_bit

  ldr r3, =0xE000E014
  ldr r4, [r3]
  ldr r4, =4000000 
  str r4, [r3]

  @set the counter SYST_CVR
  ldr r5, =0xE000E018
  b poll

poll:
  ldr r6, [r5]
  cmp r6, 0 
  beq finished
  b poll

  b main
.size main, .-main

finished:
  bl SysTick_Handler
  b finished




.type EXTI0_IRQHandler, %function
EXTI0_IRQHandler:
  push {lr}
  bl green_led_init
  bl green_led_toggle
  ldr r0, =0x40010414
  mov r1, 0
  mov r2, 0
  bl set_bit
  pop {lr}
  bx lr