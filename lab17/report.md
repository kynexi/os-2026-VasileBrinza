
# Lab 17 — Threads Share Memory, and Race

## Observation 1: Shared memory

Thread 2 printing a non-zero counter at startup proves that both threads share the same memory space and access the same global counter variable. Changes made by one thread are visible to the other.

## Observation 2: Lost updates

The final counter is less than expected because `counter++` is not atomic. It consists of three operations:

1. Read the current value.
2. Add 1.
3. Write the new value.

If two threads read the same value before either writes the result, both calculate the same incremented value. One update overwrites the other. The result varies because thread scheduling and execution timing differ between runs.

## Observation 3: Four threads and a solution

With four threads, contention increases and more updates are lost. In my tests, the final counter was approximately 1.05–1.15 million instead of 4 million.

A mutex around `counter++` would prevent simultaneous access and ensure that each increment is completed safely.
