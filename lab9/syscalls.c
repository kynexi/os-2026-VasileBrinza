
#include <fcntl.h>    // open
#include <unistd.h>   // write, read, close
#include <string.h>   // strlen
#include <stdio.h>    // printf, perror

int main(void) {
    const char *msg = "hello, kernel\n";

    // Open or create the file for writing.
    int fd = open("note.txt", O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    printf("open returned descriptor %d\n", fd);

    // Write the message to the file.
    ssize_t n = write(fd, msg, strlen(msg));
    printf("write sent %zd bytes\n", n);

    close(fd);

    // Open the same file for reading.
    fd = open("note.txt", O_RDONLY);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    char buf[64];
    n = read(fd, buf, sizeof(buf) - 1);

    if (n < 0) {
        perror("read");
        close(fd);
        return 1;
    }

    buf[n] = '\0';
    printf("read got %zd bytes: %s", n, buf);

    close(fd);

    return 0;
}
