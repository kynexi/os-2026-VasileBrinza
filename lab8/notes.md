# Lab 8 — The Same Calls, Inside Your Own OS

**Course:** Operating Systems — FCIM / FAF / UTM, 2026–2027  
**Track:** B — xv6  
**Student:** Vasile Brînză  
**Group:** FAF-242

## Part 1 — `run` inside xv6

### 1. Initial build and boot

From `~/xv6-riscv`, I ran:

```sh
make qemu
```

The xv6 kernel booted successfully and displayed:

```text
xv6 kernel is booting
hart 2 starting
hart 1 starting
init: starting sh
$
```

### 2. Run the child as `echo`

After adding `user/run.c` and `$U/_run\` to `UPROGS`, I rebuilt xv6 with `make qemu` and ran `run`.

Actual output:

```text
$ run
parent: my pid is 3
child: my pid is 4
hello from the child
parent: child 4 ended with status 0
$
```

This confirms that the parent created a child, the child successfully executed `echo`, and the parent collected its exit status.

### 3. Run the child as `ls`

I changed the argument list and executable from `echo` to `ls`, rebuilt xv6, and ran `run`.

Actual output (directory listing shortened only by removing no entries):

```text
$ run
parent: my pid is 3
child: my pid is 4
.              1 1 1024
..             1 1 1024
README         2 2 2441
cat            2 3 36808
echo           2 4 35656
forktest       2 5 17448
grep           2 6 40248
init           2 7 36112
kill           2 8 35600
ln             2 9 35384
ls             2 10 38944
mkdir          2 11 35640
rm             2 12 35624
sh             2 13 58664
stressfs       2 14 52064
usertests      2 15 202520
grind          2 16 52064
wc             2 17 37792
zombie         2 18 34992
logstress      2 19 37576
forphan        2 20 36400
dorphan        2 21 35840
sync           2 22 35056
sleep          2 23 35376
args           2 24 35376
find           2 25 38768
mystat         2 26 36576
run            2 27 35960
console        3 28 0
parent: child 4 ended with status 0
$
```

The terminal transcript also contains a second `ls` run with the same listing and successful child status.

### 4. Execute a nonexistent program

I changed the executable to `nosuchprog`, rebuilt xv6, and ran `run`.

Actual output:

```text
$ run
parent: my pid is 3
child: my pid is 4
exec failed
parent: child 4 ended with status 1
$
```

This confirms that `exec()` failed and the child executed `exit(1)`.

### Observe — Part 1

**1. Write the three calls that `run.c` uses in xv6 and the three calls `run.c` used on Linux in Lab 7. What is the same?**

In xv6, the calls are:
- `fork()` — creates a child process.
- `exec()` — replaces the child process with another program.
- `wait()` — waits for the child to finish.

In the Linux version from Lab 7, the calls were:
- `fork()`
- `execlp()` — executes another program.
- `waitpid()` — waits for a child process.

The names and interfaces differ, but the purpose and sequence are the same: create a child, execute a program in it, and wait for it to finish.

**2. Who prints "hello from the child": the code of `run`, or `echo`?**

The `echo` program prints `hello from the child`. The `run` program passes the arguments to `exec()`. When `exec()` succeeds, the child process is replaced by `echo`, so the remaining code in `run` does not execute.

**3. Why is the status 1 here and 127 on Linux?**

The xv6 program explicitly calls `exit(1)` after `exec()` fails. The Linux program from Lab 7 calls `exit(127)` after a failed `exec`. The status values differ because the programs choose different exit codes; they are not automatically assigned by `exec()`.

## Part 2 — `pingpong`

### 1. Build and run

I added `user/pingpong.c` and `$U/_pingpong\` to `UPROGS`, then ran:

```sh
make qemu
```

The build completed and the filesystem image included both `user/_run` and `user/_pingpong`.

I ran `pingpong` inside xv6.

Actual output:

```text
$ pingpong
4: received ping
3: received pong
$
```

The child (PID 4) printed `received ping` first. The parent (PID 3) printed `received pong` after receiving the byte back.

### Observe — Part 2

**1. Why do you need TWO pipes, and not one for both directions?**

A pipe is unidirectional: data is written through its write end and read through its read end. The parent sends a byte to the child, and the child sends a byte back to the parent. Two pipes are therefore needed, one for each direction.

**2. Nothing in your code says "wait until the child has replied". Which call makes the parent wait?**

The parent's `read(c2p[0], &b, 1)` blocks while the pipe has no data available. It therefore waits until the child writes the byte into the second pipe. The later `wait(0)` waits for the child process to terminate.

## Conclusion

The experiments show that xv6 provides the same basic process-management pattern as Linux: `fork`, `exec`, and `wait`, although the interfaces differ. The `run` program demonstrated successful execution of another program and handling of an `exec` failure. The `pingpong` program demonstrated communication in both directions using two unidirectional pipes. The observed output confirms that the child receives the message first and the parent receives the reply afterward.
