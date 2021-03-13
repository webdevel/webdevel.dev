#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcgi_stdio.h>

int main (int argc, char *argv[])
{
    unsigned int count = 0;

    while (FCGI_Accept() >= 0) {
        printf(
            "Content-type: text/text charset=utf-8\r\nStatus: 200 OK\r\n\r\n"
            "FastCGI Hello!\n"
            "Request Count %d running on host %s\n"
            "Process ID: %d\n", ++count, getenv("SERVER_NAME"), getpid()
        );
    }

    return 0;
}
