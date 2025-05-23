#include <library.h>

#define PROMPT "c:> "

int strcmp(const char *s1, const char *s2) {
	char c;
	int rc = 0;
	int i=0;

	while((c = s1[i]) != '\0') {
		if (s2[i] == '\0') {
			rc = -1;
			break;
		} else if (s2[i] != c) {
			rc = -1;
			break;
		}
		i++;
	}

	if (s2[i] != '\0') {
		rc = 1;
	}

	return rc;
}

void execute(char *cmd) {
    if (strcmp(cmd, "exit") == 0) {
        puts("CMD: halt\n");
    } else if (strcmp(cmd, "dir") == 0) {
        puts("CMD: dir\n");
    } else {
        puts(cmd);
        puts(" not found\n");
    }

    return;
}

void shell_init(void) {
    puts("start shell ...\n");
    puts(PROMPT);
}

void shell(void) {
    char cmd[256];
    char c;
    int cmd_pos;

    cmd_pos = 0;
    cmd[0] = '\0';

    puts(PROMPT);

    while (1) {
        if ( (c = getchar()) ) {
            if (c == '\n') {
                puts("\n");
                execute(cmd);
                cmd_pos = 0;
                cmd[0] = '\0';
                puts(PROMPT);
            } else {
                putchar(c);
                cmd[cmd_pos++] = c;
                cmd[cmd_pos] = '\0';
            }
        }
    }

    return;
}