#ifndef __PERP_SUPPORT_PATCH__
#define __PERP_SUPPORT_PATCH__

USING_NS_CC;

using namespace std;
#include <string>
#include "../cocos2d-x/external/unzip/unzip.h"
#include "LoginPlatform.h"

#define UNZ_MD5ERROR					(UNZ_CUSTOM-1)
#define UNZ_TARGETFILE_OPENFAIL			(UNZ_CUSTOM-2)
#define UNZ_TARGETFILE_WRITEFAIL		(UNZ_CUSTOM-3)

class SupportPatch {

public:
	static void makeDir(string dir);
    static void makePath(string path);
	static string makeFakePath(string path, string fakeStr);
	static void removeDir(string dir);

	static string getExtensionPath();
	static string getPatchPath(const char* ver);
	static void setPatchPath(const char* dir);

	static int unzipEachFile(unzFile zipFile, unz_file_info64 &fileInfo64, const char *srcFileName, const char* tarPath, const char* fakeStr);
	static int unzipFiles(const char* src, const char* md5, const char* tar, const char* fakeStr);

	static void startUnzipThread(const char* src, const char* md5, const char* tar, const char* fakeStr, std::function<void(int)> callback);
	static void endUnzipThread();

	static bool isSameMd5(const char* fileName, const char* md5);
	static void getCheckSum(char output[], const unsigned char input[], unsigned int len);
	static void getMd5(const char* fileName, char* tar);

};

#endif