#include "KLuaToken.h"

#include <cstdlib>
#include <cstdio>
#include <cstring>


KLuaToken::KLuaToken()
	: m_lua(nullptr)
	, m_size(0)
	, m_cursor(0)
	, m_tmp(0)
{
}

KLuaToken::~KLuaToken()
{
	Release();
}

void KLuaToken::Release()
{
	if(m_lua) ::free(m_lua);
	m_lua = nullptr;
	m_size = 0;
	m_cursor = 0;
	m_tmp = 0;
}

bool KLuaToken::ReadFile(const char* filename)
{
	Release();

	if(!filename) return false;

	FILE* pf = ::fopen(filename, "rb");

	fpos_t filebeginpos, fileendpos;
	::fgetpos(pf, &filebeginpos);
	::fseek(pf, 0, SEEK_END);
	::fgetpos(pf, &fileendpos);
	::fseek(pf, 0, SEEK_SET);
    m_size = (size_t)(fileendpos - filebeginpos);

	m_lua = (char*)::malloc(m_size+1);
	if(!m_lua)
	{
		::fclose(pf);
		return false;
	}
	fread(m_lua, m_size, 1, pf);
	m_lua[m_size] = 0;

	m_cursor = m_lua;

	::fclose(pf);

	return true;
}

void KLuaToken::CopyBuffer(const char* json)
{
	Release();

	if(!json) return;

	m_size = strlen(json);
	m_lua = (char*)::malloc(m_size+1);
	if(!m_lua) return;
	memcpy(m_lua, json, m_size);
	m_lua[m_size] = 0;

	m_cursor = m_lua;
}

void KLuaToken::ResetOffset()
{
	m_cursor = m_lua;
}

char* KLuaToken::SkipWhiteSpace(char* c)
{
	while(*c != 0 && *c <= ' ') ++ c;
	return c;
}

char* KLuaToken::SkipToken(char* c)
{
	while (*c != 0 && *c > ' ' &&
		*c != '{' && *c != '}' &&
		*c != '[' && *c != ']' &&
		*c != ':' && *c != ',' && *c != ';' && *c != '=' &&
		*c != '\"' && *c != '\'') ++ c;
	return c;
}

char* KLuaToken::SkipQuotation(char* c, int e)
{
	while(*c != 0 && *c != e) ++ c;
	return c;
}

const char* KLuaToken::Token()
{
	if(m_cursor >= m_lua + m_size) return 0;

	char* begin = m_cursor;
	char* end = 0;

	switch(m_tmp)
	{
	case '{': m_tmp = 0; return "{";
	case '}': m_tmp = 0; return "}";
	case '[': m_tmp = 0; return "[";
	case ']': m_tmp = 0; return "]";
	}

	do
	{
		begin = SkipWhiteSpace(begin);

		switch(*begin)
		{
		case 0:
			m_cursor ++;
			return 0;
		case '{': m_cursor = ++ begin; return "{";
		case '}': m_cursor = ++ begin; return "}";
		case '[': m_cursor = ++ begin; return "[";
		case ']': m_cursor = ++ begin; return "]";
		case '\"':
		case '\'':
			++ begin;
			end = SkipQuotation(begin, *(begin-1));
			break;
		case ',':
		case ':':
		case ';':
		case '=':
			++ begin;
			break;
		default:
			end = SkipToken(begin);
			break;
		}
	}
	while(end == 0 && *begin);

	m_cursor = end;
	if(m_cursor > m_lua + m_size) return 0;

	m_tmp = *m_cursor;
	*(m_cursor ++) = 0;

	return begin;
}

void KLuaToken::PassNextValue()
{
	if (m_cursor >= m_lua + m_size) return;

	char* begin = m_cursor;
	while (*m_cursor != 0 && *m_cursor != ';') ++m_cursor;
}
