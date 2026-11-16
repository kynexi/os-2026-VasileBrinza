# Operating Systems — Lab 11
## The Race and the Semaphore

### Part 1 — See the race

1. `counter++` consists of three CPU-level steps:
   - Read the current value of `counter` from memory.
   - Add 1 to the value.
   - Write the updated value back to memory.

2. Two threads can read the same value before either writes its result. Both calculate the same incremented value, and both write it back. One increment is therefore lost.

3. The result differs between runs because thread scheduling and execution timing are nondeterministic. The threads may interleave their operations differently each time.

### Part 2 — Fix it: mutex, then semaphore

1. Yes. Both `mutex.c` and `sem.c` consistently produced 2,000,000 in all three runs.

2. With `sem_init(&s, 0, 2)`, two threads can enter the critical section simultaneously. This no longer guarantees exclusive access, so race conditions and lost increments can occur.

3. The locked versions are slower because acquiring and releasing synchronization primitives adds overhead, and threads may have to wait for access to the shared counter.

### Part 3 — A semaphore as a signal

1. With an initial value of 1, B immediately passes `sem_wait()` and reads an empty string because A has not written the message yet. The initial permit allows B to proceed without waiting for A.

2. A semaphore initialized to 0 acts as a signal: a thread waits until another thread calls `sem_post()` to notify it that something is ready.

### Part 4 — A semaphore as a counter: the parking lot

1. The largest value of `inside` is 3. The semaphore initialized with `PLACES = 3` and the `sem_wait(&places)` call guarantee that no more than three cars can enter simultaneously.

2. With `PLACES = 1`, the semaphore acts like a lock: only one car can occupy the parking lot at a time. The `inside` counter alternates between 0 and 1.
