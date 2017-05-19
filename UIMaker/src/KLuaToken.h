#ifndef __K_LUA_TOKEN_H__
#define __K_LUA_TOKEN_H__


// KLuaToken *********************************************************************
class KLuaToken
{
public:
    KLuaToken();
    ~KLuaToken();

	void Release();

private:
	char*  m_lua;
	size_t m_size;
	char*  m_cursor;
	char   m_tmp;

public:
	bool ReadFile(const char* filename);
	void CopyBuffer(const char* json);

	void ResetOffset();

	const char* Token();

	void PassNextValue();

private:
	char* SkipWhiteSpace(char* c);
	char* SkipToken(char* c);
	char* SkipQuotation(char* c, int e);
};

#endif//__K_LUA_TOKEN_H__
