#include <sys/types.h>  
#include <sys/stat.h>  
#include <fcntl.h>  
#include <stdio.h>  
#include <stdlib.h>  
#include <string.h>  
#include <strings.h>  
#include <unistd.h>  
#include <errno.h>  
#include <sys/stat.h>  
#include <dirent.h>  
#include <sys/mman.h>  
#include <sys/wait.h>  
#include <signal.h>  
#include <sys/ipc.h>  
#include <sys/shm.h>  
#include <sys/msg.h>  
#include <sys/sem.h>  
#include <pthread.h>  
#include <semaphore.h>  
#include <poll.h>  
#include <sys/epoll.h>  
#include <sys/socket.h>  
#include <netinet/in.h>  
#include <arpa/inet.h>  
#include <netinet/in.h>  


char rbuf[50];  
  
int main()  
{  
    int sockfd;  
    int size;  
    int ret;  
    int on =1;  
    struct sockaddr_in saddr;  
    struct sockaddr_in raddr;  
  
    size = sizeof(struct sockaddr_in);  
    bzero(&saddr,size);  
    saddr.sin_family = AF_INET;  
    saddr.sin_port = htons(8888);  
    saddr.sin_addr.s_addr = htonl(INADDR_ANY);  
  

    sockfd = socket(AF_INET,SOCK_DGRAM,0);  
    if(sockfd<0)  
    {  
        perror("socket failed");  
        return -1;  
    }  
  

    setsockopt(sockfd,SOL_SOCKET,SO_REUSEADDR,&on,sizeof(on));   
  

    ret = bind(sockfd,(struct sockaddr*)&saddr,sizeof(struct sockaddr));  
    if(ret<0)  
    {  
        perror("sbind failed");  
        return -1;  
    }  
  
    socklen_t  val = sizeof(struct sockaddr);  
 
    while(1)  
    {  
        puts("waiting data");  
        ret=recvfrom(sockfd,rbuf,50,0,(struct sockaddr*)&raddr,&val);  
        if(ret <0)  
        {  
            perror("recvfrom failed");  
        }  
  
        printf("the data :%s\n",rbuf);  
        bzero(rbuf,50);  
    }  

    close(sockfd);  
    return 0;  
} 
