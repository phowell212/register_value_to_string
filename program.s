.section    .bss
strBuffer:  .space 23    // Reserve space for 20 digits + newline + null terminator

.section .text
.global _start

_start:
    mov     x0,     #12                         // Example number
    bl      convert_to_string                   

    // Prepare to print the converted string
    mov     x0,     #1                          // File descriptor for stdout
    ldr     x1,     =strBuffer                  // Address of the string buffer
    ldr     x2,     =23                         // Maximum buffer size
    mov     x8,     #64                         // syscall: sys_write
    svc     #0

    // Exit
    mov     x0,     #0                          // Exit status
    mov     x8,     #93                         // syscall: sys_exit
    svc     #0

// Function: Convert signed 64-bit int in x0 to a string in strBuffer
// Input: x0 (signed 64-bit integer)
// Output: strBuffer (ASCII string)
convert_to_string:
    ldr     x2,     =strBuffer + 21             // Point to the buffer end, leaving space for a null terminator

    // Check if the number is negative
    mov     x5,     x0                          // Copy x0 to x5 for sign check
    tbnz    x5,     #63,     negative           // If negative, jump to 'negative' label

    // Positive number, jump directly to conversion
    b       positive

negative:
    // If negative, prepare to convert by making the number positive and setting a flag to add '-' later
    neg     x0,     x0                          // Make the number positive for conversion
    mov     w6,     #1                          // Set flag indicating a negative number

positive:
    // Pre-load the newline character to the buffer's end
    mov     w3,     #10                         // Newline
    strb    w3,     [x2],   #-1

    mov     x3,     #10                         // Divisor for conversion

loop:
    udiv    x1,     x0,     x3
    msub    x4,     x1,     x3,     x0          // Get remainder

    add     x4,     x4,     #48                 // Convert to ASCII
    strb    w4,     [x2],   #-1                 // Store character

    mov     x0,     x1                          // Prepare for next iteration
    cbnz    x0,     loop                        // Continue if x0 is not zero

    // If the number was negative, prepend '-'
    cbz     w6,     append_null                 // If not negative, skip to appending null terminator
    mov     w4,     #45                         // ASCII for '-'
    strb    w4,     [x2],   #-1                 // Prepend '-'

append_null:
    // Append null terminator
    mov     w3,     #0
    strb    w3,     [x2]
    
    ret

