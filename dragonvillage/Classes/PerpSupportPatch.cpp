#include "cocos2d.h"
#include "PerpSupportPatch.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <sys/stat.h>
#include <direct.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#endif

///////////////////////////////////////////////////////////////////////////
//추가 다운로드 디렉토리
#define EXTENTION_RESOURCE_DIR       "patch_0_0_0/"
///////////////////////////////////////////////////////////////////////////

#define MAX_FILE_NAME_LENGTH	256
#define MAX_ZIP_BUFFER			1024

static unsigned char s_buffer[MAX_ZIP_BUFFER];

int SupportPatch::unzipEachFile(unzFile zipFile, unz_file_info64 &fileInfo64, const char *srcFileName, const char* tarPath, const char* fakeStr)
{
	int ret = UNZ_OK;

	if (fileInfo64.uncompressed_size == 0)
	{
		// 디렉토리라는 뜻이므로 mkdir!
		string dir = tarPath;
		dir.append(srcFileName);
        makePath(dir);
	}
	else
	{
		// 현재 가리키는 파일을 열어서 압축을 푼다.
		ret = unzOpenCurrentFile(zipFile);
		if (ret != UNZ_OK)
		{
			return ret;
		}

		string basePath = tarPath;

		// 임시저장 파일이름 설정
		string fakePath = basePath + makeFakePath(srcFileName, fakeStr);
        string path = basePath + srcFileName;

        // 폴더명을 구하고, 폴더가 없을 경우 생성
        makePath(path);

		FILE *targetFile = fopen(fakePath.c_str(), "wb");
		if (targetFile == NULL)
		{
			unzCloseCurrentFile(zipFile);
			return UNZ_TARGETFILE_OPENFAIL;
		}

		int readSize = 0;

		// MAX_ZIP_BUFFER만큼 읽어와 임시저장 파일에 쓴다.
		while ((readSize = unzReadCurrentFile(zipFile, s_buffer, MAX_ZIP_BUFFER)) > 0)
		{
			if (fwrite(s_buffer, readSize, 1, targetFile) <= 0)
			{
				// 쓰기 오류 상황
				ret = UNZ_TARGETFILE_WRITEFAIL;
				break;
			}
		}

		if (readSize < 0)
		{
			// read_size < 0 일 경우 에러코드임
			ret = readSize;
		}

		fclose(targetFile);
		unzCloseCurrentFile(zipFile);

		if (ret == UNZ_OK)
		{
			remove(path.c_str());
			rename(fakePath.c_str(), path.c_str());
		}
		else
		{
			remove(path.c_str());
			remove(fakePath.c_str());
		}
	}

	return ret;
}

int SupportPatch::unzipFiles(const char *src, const char *md5, const char *tar, const char *fakeStr)
{
	if (!isSameMd5(src, md5))
	{
		return UNZ_MD5ERROR;
	}

	unzFile zipFile = unzOpen(src);

	int ret = UNZ_OK;

	char fileName[MAX_FILE_NAME_LENGTH + 1];
	unz_file_info64 fileInfo64;

	ret = unzGoToFirstFile(zipFile);

	while (ret == UNZ_OK)
	{
		ret = unzGetCurrentFileInfo64(zipFile, &fileInfo64, fileName, sizeof(fileName) - 1, NULL, 0, NULL, 0);
		if (ret != UNZ_OK)
		{
			unzClose(zipFile);
			return ret;
		}

		ret = unzipEachFile(zipFile, fileInfo64, fileName, tar, fakeStr);
		if (ret != UNZ_OK)
		{
			unzClose(zipFile);
			return ret;
		}

		ret = unzGoToNextFile(zipFile);
	}

	if (ret == UNZ_END_OF_LIST_OF_FILE)
	{
		ret = UNZ_OK;
	}

	unzClose(zipFile);

	return ret;
}

static std::thread* s_unzipThread = nullptr;

void unzipThreadFunc(const char *src, const char *md5, const char *tar, const char *fakeStr, std::function<void(int)> callback)
{
    const int ret = SupportPatch::unzipFiles(src, md5, tar, fakeStr);
    Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
        callback(ret);
    });
}

void SupportPatch::startUnzipThread(const char *src, const char *md5, const char *tar, const char *fakeStr, std::function<void(int)> callback)
{
	endUnzipThread();
    s_unzipThread = new std::thread(&unzipThreadFunc, src, md5, tar, fakeStr, callback);
}

void SupportPatch::endUnzipThread()
{
	if (s_unzipThread != nullptr)
	{
		s_unzipThread->join();
		CC_SAFE_DELETE(s_unzipThread);
	}
}

string SupportPatch::makeFakePath(string path, string fakeStr)
{
	int latestPos = 0;
	for(int cur = 0; cur < path.length(); )
	{
		int findPos = (int)path.find("/", cur);
		if(findPos >= 0)
		{
			latestPos = findPos;
			cur = latestPos + 1;
		}
		else
		{
			break;
		}
	}
	path.insert(latestPos + 1, fakeStr, 0, fakeStr.length());

	return path;
}

void SupportPatch::makeDir(string dir)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	mkdir(dir.c_str());
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    mkdir(dir.c_str(), S_IRWXU);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	int ret = mkdir(dir.c_str(), 0777);
	if (ret == 0) {
		log("mkdir %s is success\n", dir.c_str());
	}
	else {
		log("mkdir %s is failed(%d)\n", dir.c_str(), ret);
	}
#endif
}

void SupportPatch::makePath(string path)
{
    std::list<string> list;
    
    while (true)
    {
        size_t found = path.find_last_of("/\\");
        path = path.substr(0, found);

        struct stat sb;
        if (stat(path.c_str(), &sb) != 0)
        {
            list.push_front(path);
        }
        else
        {
            break;
        }
    }

    for (auto iter = list.begin(); iter != list.end(); iter++)
        makeDir(*iter);
}

void SupportPatch::removeDir(string dir)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	HANDLE di;
	WIN32_FIND_DATAA file_data;

	if ((di = FindFirstFileA((dir + "/*").c_str(), &file_data)) == INVALID_HANDLE_VALUE)
		return; // No files found

	do {
		const string file_name = file_data.cFileName;
		const string full_file_name = dir + "/" + file_name;
		const bool is_directory = (file_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0;

		if (file_name[0] == '.')
			continue;

		if (is_directory)
		{
			removeDir(full_file_name);
			continue;
		}

		remove(full_file_name.c_str());
	} while (FindNextFileA(di, &file_data));

	FindClose(di);

	rmdir(dir.c_str());
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    // something to do..
#else
	DIR *di;
	struct dirent *ent;
	struct stat st;

	di = opendir(dir.c_str());

	if (di != NULL)
	{
		while ((ent = readdir(di)) != NULL)
		{
			const string file_name = ent->d_name;
			const string full_file_name = dir + "/" + file_name;

			if (file_name[0] == '.')
				continue;

			if (stat(full_file_name.c_str(), &st) == -1)
				continue;

			const bool is_directory = (st.st_mode & S_IFDIR) != 0;

			if (is_directory)
			{
				removeDir(full_file_name);
				continue;
			}

			remove(full_file_name.c_str());
		}

		closedir(di);

		rmdir(dir.c_str());
	}
#endif
}

string SupportPatch::getExtensionPath()
{
    return EXTENTION_RESOURCE_DIR;
}

string SupportPatch::getPatchPath(const char* ver)
{
	string base = "patch_";
	base.append(ver);
	base.append("/");
	int findPos = 0;
	while (findPos < base.length())
	{
		findPos = (int)base.find(".", findPos);
		if (findPos < 0)	break;
		base.replace(findPos, 1, "_");
	}
	//fixPathForWIN32(path);

	return base;
}

#include "md5.h"

#define MD5_BUFFER_LENGTH		1024
#define MD5_LENGTH				16
#define MD5_CHECKSUM_LENGTH		32

bool SupportPatch::isSameMd5(const char* fileName, const char* md5)
{
	// 체크썸을 구해 비교
	char checkSum[MD5_CHECKSUM_LENGTH + 1];
	memset(checkSum, 0, sizeof(checkSum));
	getMd5(fileName, checkSum);
	if(strcmp(checkSum, md5) == 0)	return true;
	else							return false;
}

void SupportPatch::getMd5(const char* fileName, char* tar)
{
	MD5_CTX info;
	MD5_Init(&info);

	int ret_md5 = 0;
	ssize_t len = 0;
	unsigned char* p =  CCFileUtils::getInstance()->getFileData(fileName, "rb", &len);

	// MD5_BUFFER_LENGTH만큼 읽어와 md5 생성
	unsigned char buf[MD5_BUFFER_LENGTH];
	unsigned int total = 0;
	int i = 0;
	while(total < len)
	{
		int block_size = MD5_BUFFER_LENGTH;
		if(len - total < MD5_BUFFER_LENGTH)
			block_size = (int)(len - total);

		memcpy(buf, p + (MD5_BUFFER_LENGTH * i), block_size);
		ret_md5 = MD5_Update(&info, buf, block_size);
		total += block_size;
		i++;
	}

	unsigned char newMd5[MD5_LENGTH];
	memset(newMd5, 0, sizeof(newMd5));
	MD5_Final(newMd5, &info);

	// 체크썸을 구해 비교
	char checkSum[MD5_CHECKSUM_LENGTH + 1];
	memset(checkSum, 0, sizeof(checkSum));
	getCheckSum(checkSum, newMd5, MD5_LENGTH);

	strcpy(tar, checkSum);
}

void SupportPatch::getCheckSum(char output[], const unsigned char input[], unsigned int len)
{
	for(int i = 0; i < len; i++)
	{
		sprintf(&output[i * 2], "%02x", input[i]);
	}
}


