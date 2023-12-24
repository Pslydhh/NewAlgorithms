#pragma once



#define SM4_ENCRYPT    1
#define SM4_DECRYPT    0
#define SM4_BLOCK_SIZE 16

void SM4_KeySchedule(unsigned char MK[], unsigned int rk[]);//Generate round key
void SM4_Encrypt(unsigned char MK[], unsigned char PlainText[], unsigned char CipherText[]);
void SM4_Decrypt(unsigned char MK[], unsigned char CipherText[], unsigned char PlainText[]);
int SM4_SelfCheck();

void sm4ecb(unsigned char *in, unsigned char *out, unsigned int length, unsigned char *key, unsigned int enc);
void sm4cbc(unsigned char *in, unsigned char *out, unsigned int length, unsigned char *key, unsigned char *ivec, unsigned int enc);
void sm4cfb(const unsigned char *in, unsigned char *out, const unsigned int length, unsigned char *key, const unsigned char *ivec, const unsigned int enc);
void sm4ofb(const unsigned char *in, unsigned char *out, const unsigned int length, unsigned char *key, const unsigned char *ivec);