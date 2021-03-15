#include "webdevel.dev.h"

extern char **environ;

static void printEnv(char *label, char **envp)
{
    FCGI_printf("%s", label);
    for ( ; *envp != NULL; envp++) {
        FCGI_printf("%s\n", *envp);
    }
    FCGI_printf("\n");
}

int main (int argc, char **argv)
{
    char **hostEnv = environ;
    unsigned int count = 0;

    while (FCGI_Accept() >= 0) {
        FCGI_printf(
            "Content-type: text/plain; charset=us-ascii\r\n"
            "Status: 200 OK\r\n\r\n"
            "APP INFORMATION\n"
            "---------------\n"
            "REQUEST COUNT %d\n"
            "ENTRYPOINT PARAMETER COUNT %d\n"
            "ENTRYPOINT PARAMETER %s\n"
            "PROCESS ID %d\n\n",
            ++count, argc, *argv, getpid()
        );
        printEnv("HOST ENVIRONMENT\n----------------\n", hostEnv);
        printEnv("REQUEST ENVIRONMENT\n-------------------\n", environ);
    }

    return 0;
}
