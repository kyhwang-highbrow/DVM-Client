
// stdafx.cpp : ǥ�� ���� ���ϸ� ��� �ִ� �ҽ� �����Դϴ�.
// UI.Maker.pch�� �̸� �����ϵ� ����� �˴ϴ�.
// stdafx.obj���� �̸� �����ϵ� ���� ������ ���Ե˴ϴ�.

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
