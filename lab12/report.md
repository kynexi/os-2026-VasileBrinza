
# Lab 12 — Producer, Consumer and the Other Tools

## Part 1 — Producer and Consumer

1. `sem_wait(&empty)` stops the producer when the buffer is full because it blocks until a free slot becomes available.

2. The consumer waits at the start because `full` is initialized to 0. `sem_wait(&full)` makes it wait until the producer adds an item.

3. When the mutex is acquired before `sem_wait(&empty)`, the producer can hold the mutex while waiting for a free slot. The consumer cannot acquire the mutex to remove an item, resulting in deadlock.

## Part 2 — Condition Variables

1. The variable `ready` remembers whether the message is ready.

2. Yes, it still works in this particular program when using `if`.

3. We use `while` because a thread can experience a spurious wakeup and wake up even when `ready == 0`.

## Part 3 — Readers and Writers

1. The two lines are `if (++readers == 1) sem_wait(&room);` and `if (--readers == 0) sem_post(&room);`. The first reader blocks writers, and the last reader allows writers again.

2. The counter `readers` needs `rlock` to prevent simultaneous modifications. Without it, threads could update the counter incorrectly, causing writers to enter while readers are still active.

3. Writer 2 could wait indefinitely if new readers keep arriving before the current readers leave. This is called starvation.

## Part 4 — Deadlock

1. Thread 1 holds mutex A and waits for mutex B. Thread 2 holds mutex B and waits for mutex A. This creates a circular wait: Thread 1 -> B -> Thread 2 -> A -> Thread 1.

2. Without sleep, the program does not necessarily hang every time because thread scheduling may allow one thread to acquire both mutexes before the other. This makes the deadlock less predictable, not impossible.

3. Taking locks in the same order prevents circular waiting because both threads request A before B.
