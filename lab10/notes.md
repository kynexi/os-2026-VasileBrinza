# Lab 10 — Add Your Own System Call: trace

## Part 3 — Observations

### 1. Why does `trace 32 grep hello README` show only `read`, not `open` or `close`?

32 = 2^5, so only syscall number 5 (`read`) is enabled. `open` (15) and `close` (21) have different bits, which are not enabled.

### 2. Which line makes child processes inherit tracing?

`np->trace_mask = p->trace_mask;` in `fork()`. It copies the parent's trace mask to the child.

### 3. Why is the trace line printed between "hi" and the newline? How many times does echo call write?

`echo` calls `write` twice: once to print `hi` (2 bytes), and once to print the newline (1 byte). The kernel prints the trace immediately after each syscall returns, so the first trace appears between the two writes.

### 4. Which mask traces both `open` (15) and `close` (21), and nothing else?

2^15 + 2^21 = 32768 + 2097152 = **2129920**.
