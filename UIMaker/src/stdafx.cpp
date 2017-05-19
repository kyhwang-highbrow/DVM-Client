
// stdafx.cpp : 표준 포함 파일만 들어 있는 소스 파일입니다.
// UI.Maker.pch는 미리 컴파일된 헤더가 됩니다.
// stdafx.obj에는 미리 컴파일된 형식 정보가 포함됩니다.

#include "stdafx.h"


#define MAX_CONVERT_STRING_SIZE  (1024*10)

std::wstring UTF16LE(const std::string& _str)
{
	WCHAR wstr[MAX_CONVERT_STRING_SIZE] = { 0, };
	MultiByteToWideChar(CP_UTF8, 0, _str.c_str(), _str.size() + 1, wstr, MAX_CONVERT_STRING_SIZE);

	return std::wstring(wstr);
}
std::wstring UTF16(const std::string& _str)
{
	WCHAR wstr[MAX_CONVERT_STRING_SIZE] = { 0, };
	MultiByteToWideChar(CP_ACP, 0, _str.c_str(), _str.size() + 1, wstr, MAX_CONVERT_STRING_SIZE);

	return std::wstring(wstr);
}

std::string UTF8(const std::wstring& _str)
{
	CHAR str[MAX_CONVERT_STRING_SIZE] = { 0, };
	WideCharToMultiByte(CP_UTF8, 0, _str.c_str(), _str.size() + 1, str, MAX_CONVERT_STRING_SIZE, 0, 0);

	return std::string(str);
}

std::string ASCII(const std::wstring& _str)
{
	CHAR str[MAX_CONVERT_STRING_SIZE] = { 0, };
	WideCharToMultiByte(CP_ACP, 0, _str.c_str(), _str.size() + 1, str, MAX_CONVERT_STRING_SIZE, 0, 0);

	return std::string(str);
}
