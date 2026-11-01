# Laboratory Work 7 — Processes, Redirection and Pipes

**Student:** Vasile Brînză  
**Group:** FAF-242  
**Subject:** Operating Systems  
**Academic year:** 2026–2027

## Part 1 — `fork()`, `exec()` and `wait()`

### What I did

Created `run.c`, compiled it with `gcc -Wall -Wextra -o run run.c`, and ran it. Then replaced the `ls` command with `date`, and finally with the nonexistent command `nosuchprog`. Restored the original `ls` version afterward.

### Commands and actual outputs

**Original `ls` version:**

```text
parent: my PID is 4484
child: my PID is 4485, my parent is 4484
total 24
-rwxrwxr-x 1 kynex kynex 16400 Nov  2 00:03 run
-rw-rw-r-- 1 kynex kynex   688 Nov  2 00:02 run.c
parent: child 4485 ended with status 0
```

**`date` experiment:**

```text
parent: my PID is 4493
child: my PID is 4494, my parent is 4493
Mon Nov  2 12:03:31 AM EET 2026
parent: child 4494 ended with status 0
```

**Nonexistent program experiment:**

```text
parent: my PID is 4501
child: my PID is 4502, my parent is 4501
exec: No such file or directory
parent: child 4502 ended with status 127
```

### Observations

1. `perror("exec")` is printed only for `nosuchprog` because a successful `execlp()` replaces the child process image and does not return. When execution fails, `execlp()` returns, so the child continues to `perror("exec")`.

2. The child prints `4484` as its parent PID in the first run. This is the PID of the original parent process, returned in the child by `getppid()`.

3. The parent sees exit status `0` when `ls` executes successfully, and status `127` when `nosuchprog` cannot be executed. The latter is the value passed to `exit(127)` after `execlp()` fails.

## Part 2 — Zombie process

### What I did

Created `zombie.c` from the original `run.c` by inserting `sleep(20)` immediately before `waitpid()`. Compiled it and started it in the background with its standard output redirected to `/dev/null`. Inspected the process table after two seconds.

### Command and actual output

```bash
./zombie > /dev/null &
ZPID=$!
sleep 2
ps -o pid,ppid,stat,cmd -p "$ZPID" --ppid "$ZPID"
```

```text
[1] 4520
    PID    PPID STAT CMD
   4520    3471 S    ./zombie
   4522    4520 Z    [ls] <defunct>
```

### Observations

1. The `ls` process has the letter `Z` in the `STAT` column. It means the child has terminated, but its parent has not yet collected its exit status; it is a zombie process.

2. The terminal transcript confirms that the zombie existed while the parent was sleeping. The transcript does not contain a second `ps` output after the 20-second sleep, so its disappearance was not independently captured. In the program, `waitpid(pid, &status, 0)` executes after `sleep(20)` and reaps the child, removing its zombie process-table entry.

## Part 3 — Output redirection

### What I did

Created `redirect.c`, compiled it with `gcc -Wall -Wextra -o redirect redirect.c`, and ran it. The child closes file descriptor `1`, opens `out.txt`, and executes `ls -l`.

### Commands and actual outputs

```text
open gave descriptor 1
done: the listing is in out.txt
```

Then inspected the file with `head -3 out.txt`:

```text
total 68
-rw-r--r-- 1 kynex kynex     0 Nov  2 00:04 out.txt
-rwxrwxr-x 1 kynex kynex 16344 Nov  2 00:04 redirect
```

### Observations

1. `open()` returned descriptor `1` because the program first called `close(1)`, freeing standard output. `open()` allocates the lowest available file descriptor, which was therefore `1`.

2. The listing does not appear on the terminal because descriptor `1` now refers to `out.txt`. The `ls` process inherits that file-descriptor setup after `exec()` and writes its standard output to the file.

3. To redirect errors using `2> err.txt`, descriptor `2` (standard error) should be closed before calling `open()`.

## Part 4 — Pipe

### What I did

Created `pipeline.c` using `pipe()`, two calls to `fork()`, `dup()`, `close()`, and `execlp()` to implement `ls /etc | wc -l`. Compiled and compared the result with the equivalent shell pipeline.

### Commands and actual outputs

```bash
gcc -Wall -Wextra -o pipeline pipeline.c && ./pipeline
echo "Shell result:"
ls /etc | wc -l
```

```text
258
Shell result:
258
```

After restoring the working version, the program was run again:

```text
258
```

### Observations

1. Yes. The program and the shell pipeline both produced `258`.

2. The experiment to break the pipe was run using `timeout 4 ./pipeline` after a `sed` command commented out occurrences of `close(p[1]);`. The terminal returned to the prompt and the program did not print a line count during that run. The transcript does not include the timeout exit code. The source-edit command commented out every matching occurrence, not only the parent's close, so this was not a clean isolated test of the parent's close operation.

3. The underlying reason a reader can wait indefinitely is that it receives EOF only after all write descriptors referring to the pipe have been closed. If the parent keeps the pipe's writing end open, `wc` cannot detect EOF after `ls` exits.

### Conclusion

In this laboratory, I used `fork()` to create a child process, `execlp()` to replace the child process image with another program, and `waitpid()` to collect the child's exit status. The experiments showed that a failed `exec` returns to the child code, while a successful `exec` does not. I also observed a zombie process while its parent was sleeping, redirected standard output to a file by changing file descriptor `1`, and implemented a pipeline using a pipe and duplicated file descriptors. The pipeline produced the same line count as the equivalent shell command: `258`. The experiments demonstrate why unused pipe descriptors must be closed so that readers can receive EOF.
