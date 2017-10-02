//#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include<string.h>

int main(void)
{
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    char *key,*value,*ch;

    char file_name[10] = "read";
    strcat(file_name, "1");
    char *input_file = strcat(file_name,".txt");
    printf("%s\n", input_file);
    fp = fopen(input_file, "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);

    while ((read = getline(&line, &len, fp)) != -1) {
        //printf("Retrieved line of length %zu :\n", read);
        //printf("%s", line);
        if(read > 4){      // 
            ch = strtok(line, " ");
            key = ch;
            while (ch != NULL) {
                ch = strtok(NULL, " ");
                if(ch!=NULL){
                    value=ch;
                }
            }
            printf("%s, %s\n", key, value);
        }
    }
    fclose(fp);
    if (line)
        free(line);
    exit(EXIT_SUCCESS);
}