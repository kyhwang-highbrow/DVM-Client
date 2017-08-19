#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "PerpSupportLua.h"
#include "ConfigParser.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "glfw3native.h"
#endif

#define KEY_LENGTH 16

static const unsigned char xorkey[16] = {
	0x01, 0x90, 0x32, 0xcf,
	0x96, 0x7b, 0x5a, 0xe5,
	0xd2, 0xbf, 0x2d, 0xdc,
	0xb6, 0x83, 0x4e, 0x04
};

int SupportLua::luaLoader(lua_State *L)
{
	std::string filename(luaL_checkstring(L, 1));
	size_t pos = filename.rfind(".lua");
	if (pos != std::string::npos)
	{
		filename = filename.substr(0, pos);
	}

	pos = filename.find_first_of(".");
	while (pos != std::string::npos)
	{
		filename.replace(pos, 1, "/");
		pos = filename.find_first_of(".");
	}

	Data data;
	char* buffer;
	ssize_t size;
    
    bool use_lua_extention = USE_LUA_EXT;
    if (use_lua_extention)
    {
        data = FileUtils::getInstance()->getDataFromFile(filename + ".lua");
        if (!data.isNull())
        {
            buffer = (char*)data.getBytes();
            size = data.getSize();
        }
        else
        {
            data = FileUtils::getInstance()->getDataFromFile(filename + ".ps");
            if (!data.isNull())
            {
                // ps파일을 로드한 경우 xor decrypt
                buffer = (char*)data.getBytes();
                size = data.getSize();
                for (int i = 0; i < size; i++)
                {
                    buffer[i] = buffer[i] ^ xorkey[i % KEY_LENGTH];
                }
            }
            else
            {
                log("can not get file data of %s", filename.c_str());
                return 0;
            }
        }
    }
    else
    {
        data = FileUtils::getInstance()->getDataFromFile(filename + ".ps");
        if (!data.isNull())
        {
            // ps파일을 로드한 경우 xor decrypt
            buffer = (char*)data.getBytes();
            size = data.getSize();
            for (int i = 0; i < size; i++)
            {
                buffer[i] = buffer[i] ^ xorkey[i % KEY_LENGTH];
            }
        }
        else
        {
            data = FileUtils::getInstance()->getDataFromFile(filename + ".lua");
            if (!data.isNull())
            {
                buffer = (char*)data.getBytes();
                size = data.getSize();
            }
            else
            {
                log("can not get file data of %s", filename.c_str());
                return 0;
            }
        }
    }

	int skip = 0;
	if (size >= 3 && (unsigned char)buffer[0] == 0xEF) skip = 3;
    filename = filename + ".lua";
	if (luaL_loadbuffer(L, buffer + skip, size - skip, filename.c_str()) != 0)
	{
		luaL_error(L, "error loading module %s from file %s :\n\t%s",
			lua_tostring(L, 1), filename.c_str(), lua_tostring(L, -1));
	}

	return 1;

}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
std::string SupportLua::wstrtostr(const std::wstring &wstr)
{
    std::string strTo;
    char *szTo = new char[wstr.length() + 1];
    szTo[wstr.size()] = '\0';
    WideCharToMultiByte(CP_ACP, 0, wstr.c_str(), -1, szTo, (int)wstr.length(), NULL, NULL);
    strTo = szTo;
    delete[] szTo;
    return strTo;
}

std::string SupportLua::AnsiToUtf8(std::string strAnsi)
{
    std::string ret;
    if (strAnsi.length() > 0)
    {
        int nWideStrLength = MultiByteToWideChar(CP_ACP, 0, strAnsi.c_str(), -1, NULL, 0);
        WCHAR* pwszBuf = (WCHAR*)malloc((nWideStrLength + 1)*sizeof(WCHAR));
        memset(pwszBuf, 0, (nWideStrLength + 1)*sizeof(WCHAR));
        MultiByteToWideChar(CP_ACP, 0, strAnsi.c_str(), -1, pwszBuf, (nWideStrLength + 1)*sizeof(WCHAR));

        int nUtf8Length = WideCharToMultiByte(CP_UTF8, 0, pwszBuf, -1, NULL, 0, NULL, FALSE);
        char* pszUtf8Buf = (char*)malloc((nUtf8Length + 1)*sizeof(char));
        memset(pszUtf8Buf, 0, (nUtf8Length + 1)*sizeof(char));

        WideCharToMultiByte(CP_UTF8, 0, pwszBuf, -1, pszUtf8Buf, (nUtf8Length + 1)*sizeof(char), NULL, FALSE);
        ret = pszUtf8Buf;

        free(pszUtf8Buf);
        free(pwszBuf);
    }
    return ret;
}

std::string SupportLua::Utf8ToAnsi(std::string strUTF8)
{
    std::string ret;
    if (strUTF8.length() > 0)
    {
        int nWideStrLength = MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), -1, NULL, 0);
        WCHAR* pwszBuf = (WCHAR*)malloc((nWideStrLength + 1)*sizeof(WCHAR));
        memset(pwszBuf, 0, (nWideStrLength + 1)*sizeof(WCHAR));
        MultiByteToWideChar(CP_UTF8, 0, strUTF8.c_str(), -1, pwszBuf, (nWideStrLength + 1)*sizeof(WCHAR));

        int nAnsiStrLength = WideCharToMultiByte(CP_ACP, 0, pwszBuf, -1, NULL, 0, NULL, FALSE);
        char* pszAnsiBuf = (char*)malloc((nAnsiStrLength + 1)*sizeof(char));
        memset(pszAnsiBuf, 0, (nAnsiStrLength + 1)*sizeof(char));

        WideCharToMultiByte(CP_ACP, 0, pwszBuf, -1, pszAnsiBuf, (nAnsiStrLength + 1)*sizeof(char), NULL, FALSE);
        ret = pszAnsiBuf;

        free(pszAnsiBuf);
        free(pwszBuf);
    }

    return ret;
}
#endif

std::string SupportLua::openFileDialog()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    HWND hWnd = glfwGetWin32Window(glview->getWindow());

    OPENFILENAME ofn;
    char szFileName[MAX_PATH] = "";

    ZeroMemory(&ofn, sizeof(ofn));

    ofn.lStructSize = sizeof(ofn); // SEE NOTE BELOW
    ofn.hwndOwner = hWnd;
    //ofn.lpstrFilter = L"Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0";
    ofn.lpstrFilter = L"All Files (*.*)\0*.*\0";
    ofn.lpstrFile = (LPWSTR)szFileName;
    ofn.nMaxFile = MAX_PATH;
    ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_ALLOWMULTISELECT ;
    ofn.lpstrDefExt = L"txt";

    if (GetOpenFileName(&ofn))
    {
        // Do something usefull with the filename stored in szFileName 
        return SupportLua::AnsiToUtf8(wstrtostr(ofn.lpstrFile));
    }
#endif

    return "";
}
