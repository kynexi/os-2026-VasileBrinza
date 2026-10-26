# Lab 2 notes – Vasile Brînză, FAF-242

## Part 2 – Use xv6 as the Unix it is
1. Three programs xv6 ships with: ls (lists a directory), cat (prints a file), echo (prints its arguments).
2. A pipe needs (a) process creation and scheduling – fork/exec to run the writer and the reader at the same time – and (b) inter-process communication – an in-kernel buffer (the pipe) that connects the writer's stdout to the reader's stdin.
3. The xv6 shell has the essentials (running commands, pipes, redirection) in under 500 lines of C, but none of bash's conveniences: no tab completion, history, variables or job control.

## Part 3 – Read the source
1. user/cat.c uses read() (read bytes from a file descriptor into a buffer), write() (write the buffer to fd 1, stdout), open() (open a file by path and get a descriptor), close() (release the descriptor) and exit() (end the process).
2. sys_read is implemented in kernel/sysfile.c, line 69.
3. kernel/ runs in privileged supervisor mode with direct access to memory and devices; user/ runs in unprivileged user mode and has to ask the kernel through system calls.

## Update for the current xv6
In August 2025 the system call sleep() was renamed to pause(), so user/sleep.c now calls pause(atoi(argv[1])).
