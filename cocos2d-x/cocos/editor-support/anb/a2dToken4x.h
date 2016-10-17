#ifndef __AZMODEL__A2D_TOKEN_H__
#define __AZMODEL__A2D_TOKEN_H__

#include <string>


namespace azModel {

	class a2dToken4x
	{
	public:
		a2dToken4x();
		~a2dToken4x();

		void release();

	private:
		char*  _datas;
		size_t _size;
		char*  _cursor;
		char   _tmp;

	public:
		bool readFile(const std::string& filename);
		void readText(const char* text);

		void resetOffset();

		const char* getToken();

		bool rereadUTF8();

	private:
		char* skipWhiteSpace(char* c);
		char* skipToken(char* c);
		char* skipQuotation(char* c, int e);
	};

}

#endif//__AZMODEL__A2D_TOKEN_H__
