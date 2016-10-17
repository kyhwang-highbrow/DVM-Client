#if !defined(NO_COCOS2DX)
#include "cocos2d.h"
#else
#include <Windows.h>
#endif

#include "a2dToken4x.h"

#include <string>

#if defined(NO_COCOS2DX)
#define MAX_CONVERT_STRING_SIZE  (1024*10)

std::string UTF82ASCII(const std::string& _str)
{
	WCHAR wstr[MAX_CONVERT_STRING_SIZE] = { 0, };
	MultiByteToWideChar(CP_UTF8, 0, _str.c_str(), _str.size() + 1, wstr, MAX_CONVERT_STRING_SIZE);


	CHAR str[MAX_CONVERT_STRING_SIZE] = { 0, };
	WideCharToMultiByte(CP_ACP, 0, wstr, wcslen(wstr) + 1, str, MAX_CONVERT_STRING_SIZE, 0, 0);

	return std::string(str);
}
std::string ASCII2UTF8(const std::string& _str)
{
	WCHAR wstr[MAX_CONVERT_STRING_SIZE] = { 0, };
	MultiByteToWideChar(CP_ACP, 0, _str.c_str(), _str.size() + 1, wstr, MAX_CONVERT_STRING_SIZE);

	CHAR str[MAX_CONVERT_STRING_SIZE] = { 0, };
	WideCharToMultiByte(CP_UTF8, 0, wstr, wcslen(wstr) + 1, str, MAX_CONVERT_STRING_SIZE, 0, 0);

	return std::string(str);
}
#endif

namespace azModel {

	a2dToken4x::a2dToken4x()
		: _datas(0)
		, _size(0)
		, _cursor(0)
		, _tmp(0)
	{
	}

	a2dToken4x::~a2dToken4x()
	{
		release();
	}

	void a2dToken4x::release()
	{
		if (_datas) ::free(_datas);
		_datas = 0;
		_size = 0;
		_cursor = 0;
		_tmp = 0;
	}

	bool a2dToken4x::readFile(const std::string& filename)
	{
		release();

#if !defined(NO_COCOS2DX)
		std::string fullpath = cocos2d::FileUtils::getInstance()->fullPathForFilename(filename.c_str());
		if (fullpath.size() == 0)
		{
			return false;
		}

		cocos2d::Data data = cocos2d::FileUtils::getInstance()->getDataFromFile(fullpath);
		if (data.isNull()) return false;

		_size = data.getSize();
		_datas = (char*)(data.getBytes());
		_cursor = _datas;
		if (!_datas) return false;

		data.fastSet(nullptr, 0);
#else
		FILE* pf;
		errno_t e = ::fopen_s(&pf, UTF82ASCII(filename).c_str(), "rb");

		fpos_t filebeginpos, fileendpos;
		::fgetpos(pf, &filebeginpos);
		::fseek(pf, 0, SEEK_END);
		::fgetpos(pf, &fileendpos);
		::fseek(pf, 0, SEEK_SET);
		_size = (size_t)(fileendpos - filebeginpos);

		_datas = (char*)::malloc(_size + 1);
		if (!_datas)
		{
			::fclose(pf);
			return false;
		}
		fread(_datas, _size, 1, pf);
		_datas[_size] = 0;

		_cursor = _datas;

		::fclose(pf);
#endif

		return true;
	}

	bool a2dToken4x::rereadUTF8()
	{
#if defined(NO_COCOS2DX)
		int unicode_len = MultiByteToWideChar(CP_ACP, 0, _cursor, -1, NULL, 0);
		wchar_t* unicode_str = (wchar_t*)malloc((unicode_len + 1)*sizeof(wchar_t));
		if (!unicode_str) return 0;
		memset(unicode_str, 0, (unicode_len + 1)*sizeof(wchar_t));
		MultiByteToWideChar(CP_ACP, 0, _cursor, -1, (wchar_t*)unicode_str, unicode_len);

		int utf8_len = WideCharToMultiByte(CP_UTF8, 0, unicode_str, -1, NULL, 0, NULL, NULL);
		char* utf8_str = (char*)malloc((utf8_len + 1)*sizeof(char));
		if (!utf8_str) return 0;
		memset(utf8_str, 0, (utf8_len + 1)*sizeof(char));
		WideCharToMultiByte(CP_UTF8, 0, unicode_str, -1, utf8_str, utf8_len + 1, NULL, NULL);

		free(unicode_str);
		free(_datas);

		_datas = utf8_str;
		_cursor = utf8_str;
		_size = utf8_len;
#endif
		return true;
	}

	void a2dToken4x::readText(const char* text)
	{
		release();

		if (!text) return;

		_size = strlen(text);
		_datas = (char*)::malloc(_size + 1);
		if (!_datas) return;
		memcpy(_datas, text, _size);
		_datas[_size] = 0;

		_cursor = _datas;
	}

	void a2dToken4x::resetOffset()
	{
		_cursor = _datas;
	}

	char* a2dToken4x::skipWhiteSpace(char* c)
	{
		while (*c != 0 && *c <= ' ') ++c;
		return c;
	}

	char* a2dToken4x::skipToken(char* c)
	{
		while (*c != 0 && *c > ' ' &&
			*c != '{' && *c != '}' &&
			*c != '[' && *c != ']' &&
			*c != ':' && *c != ',' &&
			*c != '\"' && *c != '\'') ++c;
		return c;
	}

	char* a2dToken4x::skipQuotation(char* c, int e)
	{
		while (*c != 0 && *c != e) ++c;
		return c;
	}

	const char* a2dToken4x::getToken()
	{
		if (_cursor >= _datas + _size) return 0;

		char* begin = _cursor;
		char* end = 0;

		switch (_tmp)
		{
		case '{': _tmp = 0; return "{";
		case '}': _tmp = 0; return "}";
		case '[': _tmp = 0; return "[";
		case ']': _tmp = 0; return "]";
		}

		do
		{
			begin = skipWhiteSpace(begin);

			switch (*begin)
			{
			case 0:
				++_cursor;
				return 0;
			case '{': _cursor = ++begin; return "{";
			case '}': _cursor = ++begin; return "}";
			case '[': _cursor = ++begin; return "[";
			case ']': _cursor = ++begin; return "]";
			case '\"':
			case '\'':
				++begin;
				end = skipQuotation(begin, *(begin - 1));
				break;
			case ',':
			case ':':
				++begin;
				break;
			default:
				end = skipToken(begin);
				break;
			}
		} while (end == 0 && *begin);

		_cursor = end;
		if (_cursor > _datas + _size) return 0;

		_tmp = *_cursor;
		*(_cursor++) = 0;

		return begin;
	}

}
