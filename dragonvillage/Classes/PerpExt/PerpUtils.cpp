#include "PerpUtils.h"

static const unsigned char xorkey[16] = {
	0x01,0x90,0x32,0xcf,
	0x96,0x7b,0x5a,0xe5,
	0xd2,0xbf,0x2d,0xdc,
	0xb6,0x83,0x4e,0x04
};
#define KEY_LENGTH 16

unsigned char *PerpUtils::GetEncrypedFileData(const char *path)
{
    ssize_t size;
    CCFileUtils::getInstance()->fullPathForFilename(path);
    unsigned char *pFileContent = CCFileUtils::getInstance()->getFileData(path, "rb", &size);

	if (!pFileContent) return 0;

	//decrypt
	unsigned long j;
	for(j = 0; j < size; j++) {
		pFileContent[j] = pFileContent[j] ^ xorkey[j % KEY_LENGTH];
	}

    // 종료문자열 처리
    unsigned char *buffer = (unsigned char*)malloc(size + 1);
    memcpy(buffer, pFileContent, size);
    buffer[size] = '\0';
    
    // 메모리 해제
    free(pFileContent);

    return buffer;
}

void PerpUtils::XorEncrypt(const char *path, const char *tar)
{
    FILE *fp = fopen(path, "rb");
    if (!fp) {
        printf("error: %s source file not found.\n", path);
        return ;
    }
    fseek(fp, 0, SEEK_END);
    size_t len = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    unsigned char *plain = (unsigned char*)malloc(len);
    fread(plain, len, 1, fp);
    fclose(fp);

    unsigned char *encryt = (unsigned char*)malloc(len);

    unsigned long i;
    for (i = 0; i < len; i++) {
        encryt[i] = plain[i] ^ xorkey[i % KEY_LENGTH];
    }

    for (i = 0; i < len; i++) {
        char a, b;
        a = encryt[i] ^ xorkey[i % KEY_LENGTH];
        b = plain[i];
        if (a != b) {
            printf("error: decrypt error index %lu\n", i);
            return ;
        }
    }

    fp = fopen((char*)tar, "wb");
    fwrite(encryt, len, 1, fp);
    fclose(fp);

    //printf("encrypt %s -> %s\n", path, tar);
}
