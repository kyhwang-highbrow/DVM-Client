/****************************************************************************
Copyright (c) 2013      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#include "2d/CCFontFreeType.h"

#include <stdio.h>
#include <algorithm>
#include "base/CCDirector.h"
#include "base/ccUTF8.h"
#include "ConvertUTF.h"
#include "platform/CCFileUtils.h"
#include "edtaa3func.h"
#include FT_BBOX_H

NS_CC_BEGIN

// @emoji
#define UNI_SUR_HIGH_START  (UTF32)0xD800
#define UNI_SUR_HIGH_END    (UTF32)0xDBFF
#define UNI_SUR_LOW_START   (UTF32)0xDC00
#define UNI_SUR_LOW_END     (UTF32)0xDFFF

FT_Library FontFreeType::_FTlibrary;
bool       FontFreeType::_FTInitialized = false;
const int  FontFreeType::DistanceMapSpread = 3;
const bool FontFreeType::IsForceKerning = true;

typedef struct _DataRef
{
    Data data;
    unsigned int referenceCount;
} DataRef;

static std::unordered_map<std::string, DataRef> s_cacheFontData;
static std::unordered_map<std::string, std::string> s_fallbackFontNames;
static std::multimap<std::string, std::string> s_fallbackFontNameMultiMap;

void FontFreeType::setFallbackFont(const std::string &fontName, const std::string &fallbackFontName)
{
	//s_fallbackFontNames[fontName] = fallbackFontName;
    addFallbackFont(fontName, fallbackFontName);
}

void FontFreeType::resetFallbackFont()
{
	s_fallbackFontNames.clear();
    s_fallbackFontNameMultiMap.clear();
}

/**
 * Add Fallback Font Name
 */
void FontFreeType::addFallbackFont(const std::string& fontName, const std::string& fallbackFontName)
{
    s_fallbackFontNameMultiMap.insert(std::pair<std::string, std::string>(fontName, fallbackFontName));
}

// @emoji
bool FontFreeType::makeUTF32Char(const std::u16string& utf16String, int i, int length, unsigned int &utf32Char)
{
    static const int halfShift = 10;
    static const UTF32 halfBase = 0x0010000UL;

    unsigned int ch = utf16String[i];

    bool isValidChar = true;

    if (ch >= UNI_SUR_HIGH_START && ch <= UNI_SUR_HIGH_END)
    {
        if (i + 1 < length)
        {
            unsigned int ch2 = utf16String[i + 1];
            if (ch2 >= UNI_SUR_LOW_START && ch2 <= UNI_SUR_LOW_END)
            {
                ch = ((ch - UNI_SUR_HIGH_START) << halfShift) + (ch2 - UNI_SUR_LOW_START) + halfBase;
            }
        }
    }
    else if (ch >= UNI_SUR_LOW_START && ch <= UNI_SUR_LOW_END)
    {
        if (i - 1 >= 0)
        {
            unsigned int ch2 = utf16String[i = 1];
            if (ch2 >= UNI_SUR_HIGH_START && ch <= UNI_SUR_HIGH_END)
            {
                isValidChar = false;
            }
        }
    }

    utf32Char = ch;
    return isValidChar;
}

FontFreeType * FontFreeType::create(const std::string &fontName, int fontSize, GlyphCollection glyphs, const char *customGlyphs, bool distanceFieldEnabled /* = false */, int outline /* = 0 */)
{
    FontFreeType *tempFont = new FontFreeType(distanceFieldEnabled, outline);

    if (!tempFont)
        return nullptr;
    
    tempFont->setCurrentGlyphCollection(glyphs, customGlyphs);
    
    if (!tempFont->createFontObject(fontName, fontSize))
    {
        delete tempFont;
        return nullptr;
    }
    return tempFont;
}

bool FontFreeType::initFreeType()
{
    if (_FTInitialized == false)
    {
        // begin freetype
        if (FT_Init_FreeType( &_FTlibrary ))
            return false;
        
        _FTInitialized = true;
    }
    
    return  _FTInitialized;
}

void FontFreeType::shutdownFreeType()
{
    if (_FTInitialized == true)
    {
        FT_Done_FreeType(_FTlibrary);
        _FTInitialized = false;
    }
}

FT_Library FontFreeType::getFTLibrary()
{
    initFreeType();
    return _FTlibrary;
}

FontFreeType::FontFreeType(bool distanceFieldEnabled /* = false */, int outline /* = 0 */)
: _fontRef(nullptr)
, _distanceFieldEnabled(distanceFieldEnabled)
, _outlineSize(outline)
, _stroker(nullptr)
, _isDualChannelOutput(false)
{
    if (_outlineSize > 0)
    {
        _outlineSize *= CC_CONTENT_SCALE_FACTOR();
        FT_Stroker_New(FontFreeType::getFTLibrary(), &_stroker);
        FT_Stroker_Set(_stroker,
            (int)(_outlineSize * 64),
            FT_STROKER_LINECAP_ROUND,
            FT_STROKER_LINEJOIN_ROUND,
            0);
    }
}

bool FontFreeType::createFontObject(const std::string &fontName, int fontSize)
{
    // save font name locally
    _fontName = fontName;
    _fontSize = fontSize;

    _fontRef = getFontObject(fontName, fontSize);
    if (_fontRef)
    {
		return true;
    }

    return false;
}

FT_Face FontFreeType::getFontObject(const std::string &fontName, int fontSize)
{
    FT_Face face;
	DataRef *dataRef;

    auto it = s_cacheFontData.find(fontName);
    if (it != s_cacheFontData.end())
    {
		dataRef = &(it->second);
		dataRef->referenceCount += 1;
    }
    else
    {
		dataRef = &s_cacheFontData[fontName];

		dataRef->referenceCount = 1;
		dataRef->data = FileUtils::getInstance()->getDataFromFile(fontName);

        if (dataRef->data.isNull())
        {
			releaseFontCache(fontName);
			return nullptr;
        }
    }

	if (FT_New_Memory_Face(getFTLibrary(), s_cacheFontData[fontName].data.getBytes(), s_cacheFontData[fontName].data.getSize(), 0, &face))
	{
		releaseFontCache(fontName);
		return nullptr;
	}

    // we want to use unicode
	if (FT_Select_Charmap(face, FT_ENCODING_UNICODE))
	{
		releaseFontCache(fontName);
		return nullptr;
	}

    // set the requested font size
    int dpi = 72;
    int fontSizePoints = (int)(64.f * fontSize * CC_CONTENT_SCALE_FACTOR());
	if (FT_Set_Char_Size(face, fontSizePoints, fontSizePoints, dpi, dpi))
	{
		releaseFontCache(fontName);
		return nullptr;
	}

    return face;
}



FontFreeType::~FontFreeType()
{
    if (_stroker)
    {
        FT_Stroker_Done(_stroker);
    }

	if (_fontRef)
    {
        FT_Done_Face(_fontRef);
		releaseFontCache(_fontName);
	}


    /*
	std::string fontName = _fontName;
	while (!fontName.empty())
	{
		auto it = s_fallbackFontNames.find(fontName);
		if (it != s_fallbackFontNames.end())
		{
			fontName = it->second;

			auto it2 = _fallbackFontRefs.find(fontName);
			if (it2 != _fallbackFontRefs.end())
			{
				FT_Done_Face(it2->second);
				releaseFontCache(fontName);

                _fallbackFontRefs.erase(it2);
			}
		}
		else
		{
			fontName.clear();
		}
	}
    */

    releaseFallbackFontRefs();
}

void FontFreeType::releaseFont(const std::string& fontName)
{
    auto item = s_cacheFontData.begin();
    while (s_cacheFontData.end() != item)
    {
        if (item->first.find(fontName) != std::string::npos)
            item = s_cacheFontData.erase(item);
        else
            item++;
    }
}

/**
 * Release Font ref map
 */
void FontFreeType::releaseFallbackFontRefs()
{
    for (auto iter = _fallbackFontRefMultiMap.begin(); iter != _fallbackFontRefMultiMap.end(); iter++) {
        FT_Done_Face(iter->second.FontRef);
        releaseFont(iter->second.FontName);
    }
}

void FontFreeType::releaseFontCache(const std::string &fontName)
{
	auto it = s_cacheFontData.find(fontName);
	if (it != s_cacheFontData.end())
	{
		if (it->second.referenceCount > 0)
		{
			it->second.referenceCount -= 1;
		}

		if (it->second.referenceCount == 0)
		{
			s_cacheFontData.erase(it);
		}
	}
}

FontAtlas * FontFreeType::createFontAtlas()
{
    FontAtlas *atlas = new FontAtlas(*this);
    if (_usedGlyphs != GlyphCollection::DYNAMIC)
    {
        std::u16string utf16;
        if (StringUtils::UTF8ToUTF16(getCurrentGlyphCollection(), utf16))
        {
            atlas->prepareLetterDefinitions(utf16);
        }
    }
    this->release();
    return atlas;
}

int * FontFreeType::getHorizontalKerningForTextUTF16(const std::u16string& text, int &outNumLetters) const
{
    if (!_fontRef)
        return nullptr;
    
    outNumLetters = static_cast<int>(text.length());

    if (!outNumLetters)
        return nullptr;
    
    int *sizes = new int[outNumLetters];
    if (!sizes)
        return nullptr;
    memset(sizes, 0, outNumLetters * sizeof(int));

    bool hasKerning = FT_HAS_KERNING(_fontRef) != 0;
    if (hasKerning)
    {
        int start = 1;
        unsigned int theChar1 = 0;
        FontFreeType::makeUTF32Char(text, 0, outNumLetters, theChar1);
        if (theChar1 != text[0])
        {
            ++start;
        }

        for (int c = start; c < outNumLetters; ++c)
        {
            unsigned int theChar2 = 0;
            FontFreeType::makeUTF32Char(text, c, outNumLetters, theChar2);
            sizes[c] = getHorizontalKerningForChars(theChar1, theChar2);

            if (theChar2 != text[c])
            {
                ++c;
            }

            theChar1 = theChar2;
        }
    }

    if (IsForceKerning && _outlineSize > 0)
    {
        for (int c = 1; c < outNumLetters; ++c)
        {
            sizes[c] -= _outlineSize * 2;
        }
    }
    
    return sizes;
}

// @emoji
int FontFreeType::getHorizontalKerningForChars(unsigned int firstChar, unsigned int secondChar) const
{
    FT_Face fontRef = _fontRef;

    // get the ID to the char we need
    auto glyphIndex1 = FT_Get_Char_Index(fontRef, firstChar);
    
    if (!glyphIndex1)
        return 0;
    
    // get the ID to the char we need
    auto glyphIndex2 = FT_Get_Char_Index(fontRef, secondChar);
    
    if (!glyphIndex2)
        return 0;
    
    FT_Vector kerning;
    
    if (FT_Get_Kerning(fontRef, glyphIndex1, glyphIndex2, FT_KERNING_DEFAULT, &kerning))
        return 0;
    
    return (static_cast<int>(kerning.x >> 6));
}

int FontFreeType::getFontMaxHeight() const
{
    //int rawHeight = _fontRef->size->metrics.height;
    int rawHeight = _fontRef->size->metrics.ascender - _fontRef->size->metrics.descender;

    int height = (static_cast<int>(rawHeight >> 6));

    if (IsForceKerning && _outlineSize > 0)
    {
        height += _outlineSize * 2;
    }

    return height;
}

int FontFreeType::getFontAscender() const
{
    return (static_cast<int>(_fontRef->size->metrics.ascender >> 6));
}

// @emoji
unsigned char * FontFreeType::getGlyphBitmap(unsigned int theChar, long &outWidth, long &outHeight, Rect &outRect, int &xAdvance)
{
    bool invalidChar = true;
    unsigned char * ret = nullptr;

    do 
    {
		FT_Face fontRef = getFontRef(theChar);
		
		if (!fontRef)
		{
			break;
		}

        outRect.origin.x    =  (fontRef->glyph->metrics.horiBearingX >> 6);
        outRect.origin.y    = -(fontRef->glyph->metrics.horiBearingY >> 6);
        outRect.size.width  =  (fontRef->glyph->metrics.width  >> 6);
        outRect.size.height =  (fontRef->glyph->metrics.height >> 6);

        xAdvance = (static_cast<int>(fontRef->glyph->metrics.horiAdvance >> 6));

        outWidth  = fontRef->glyph->bitmap.width;
        outHeight = fontRef->glyph->bitmap.rows;
        ret = fontRef->glyph->bitmap.buffer;

        if (_outlineSize > 0)
        {
            auto copyBitmap = new unsigned char[outWidth * outHeight];
            memcpy(copyBitmap,ret,outWidth * outHeight * sizeof(unsigned char));

            FT_BBox bbox;
            auto outlineBitmap = getGlyphBitmapWithOutline(fontRef, theChar, bbox);
            if(outlineBitmap == nullptr)
            {
                ret = nullptr;
                delete [] copyBitmap;
                break;
            }

            auto outlineWidth = (bbox.xMax - bbox.xMin)>>6;
            auto outlineHeight = (bbox.yMax - bbox.yMin)>>6;

            auto blendWidth = outlineWidth > outWidth ? outlineWidth : outWidth;
            auto blendHeight = outlineHeight > outHeight ? outlineHeight : outHeight;

            long index,index2;
            auto blendImage = new unsigned char[blendWidth * blendHeight * 2];
            memset(blendImage, 0, blendWidth * blendHeight * 2);

            auto px = (blendWidth - outlineWidth) / 2;
            auto py = (blendHeight - outlineHeight) / 2;
            for (int x = 0; x < outlineWidth; ++x)
            {
                for (int y = 0; y < outlineHeight; ++y)
                {
                    index = px + x + ( (py + y) * blendWidth );
                    index2 = x + (y * outlineWidth);
                    blendImage[2 * index] = outlineBitmap[index2];
                }
            }

            px = (blendWidth - outWidth) / 2;
            py = (blendHeight - outHeight) / 2;
            for (int x = 0; x < outWidth; ++x)
            {
                for (int y = 0; y < outHeight; ++y)
                {
                    index = px + x + ( (y + py) * blendWidth );
                    index2 = x + (y * outWidth);
                    blendImage[2 * index + 1] = copyBitmap[index2];
                }
            }

            outRect.origin.x = bbox.xMin >> 6;
            outRect.origin.y = - (bbox.yMax >> 6);
            xAdvance += 2 * _outlineSize;
            outRect.size.width  =  blendWidth;
            outRect.size.height =  blendHeight;
            outWidth  = blendWidth;
            outHeight = blendHeight;

            delete [] outlineBitmap;
            delete [] copyBitmap;
            ret = blendImage;
        }

        invalidChar = false;
    } while (0);

    if (invalidChar)
    {
        outRect.size.width  = 0;
        outRect.size.height = 0;
        xAdvance = 0;

        return nullptr;
    }
    else
    {
       return ret;
    }
}

// @emoji
unsigned char * FontFreeType::getGlyphBitmapWithOutline(FT_Face fontRef, unsigned int theChar, FT_BBox &bbox)
{   
    unsigned char* ret = nullptr;

    FT_UInt gindex = FT_Get_Char_Index(fontRef, theChar);
    if (FT_Load_Glyph(fontRef, gindex, FT_LOAD_NO_BITMAP) == 0)
    {
        if (fontRef->glyph->format == FT_GLYPH_FORMAT_OUTLINE)
        {
            FT_Glyph glyph;
            if (FT_Get_Glyph(fontRef->glyph, &glyph) == 0)
            {
                FT_Glyph_StrokeBorder(&glyph, _stroker, 0, 1);
                if (glyph->format == FT_GLYPH_FORMAT_OUTLINE)
                {
                    FT_Outline *outline = &reinterpret_cast<FT_OutlineGlyph>(glyph)->outline;
                    FT_Glyph_Get_CBox(glyph,FT_GLYPH_BBOX_GRIDFIT,&bbox);
                    long width = (bbox.xMax - bbox.xMin)>>6;
                    long rows = (bbox.yMax - bbox.yMin)>>6;

                    FT_Bitmap bmp;
                    bmp.buffer = new unsigned char[width * rows];
                    memset(bmp.buffer, 0, width * rows);
                    bmp.width = (int)width;
                    bmp.rows = (int)rows;
                    bmp.pitch = (int)width;
                    bmp.pixel_mode = FT_PIXEL_MODE_GRAY;
                    bmp.num_grays = 256;

                    FT_Raster_Params params;
                    memset(&params, 0, sizeof (params));
                    params.source = outline;
                    params.target = &bmp;
                    params.flags = FT_RASTER_FLAG_AA;
                    FT_Outline_Translate(outline,-bbox.xMin,-bbox.yMin);
                    FT_Outline_Render(_FTlibrary, outline, &params);

                    ret = bmp.buffer;
                }
                FT_Done_Glyph(glyph);
            }
        }
    }

    return ret;
}

unsigned char * makeDistanceMap(unsigned char *img, long width, long height, bool isDualChannelOutput)
{
    long pixelAmount = (width + 2 * FontFreeType::DistanceMapSpread) * (height + 2 * FontFreeType::DistanceMapSpread);

    short * xdist = (short *)  malloc( pixelAmount * sizeof(short) );
    short * ydist = (short *)  malloc( pixelAmount * sizeof(short) );
    double * gx   = (double *) calloc( pixelAmount, sizeof(double) );
    double * gy      = (double *) calloc( pixelAmount, sizeof(double) );
    double * data    = (double *) calloc( pixelAmount, sizeof(double) );
    double * outside = (double *) calloc( pixelAmount, sizeof(double) );
    double * inside  = (double *) calloc( pixelAmount, sizeof(double) );
    long i,j;

    // Convert img into double (data) rescale image levels between 0 and 1
    long outWidth = width + 2 * FontFreeType::DistanceMapSpread;
    for (i = 0; i < width; ++i)
    {
        for (j = 0; j < height; ++j)
        {
            data[j * outWidth + FontFreeType::DistanceMapSpread + i] = img[j * width + i] / 255.0;
        }
    }

    width += 2 * FontFreeType::DistanceMapSpread;
    height += 2 * FontFreeType::DistanceMapSpread;

    // Transform background (outside contour, in areas of 0's)   
    computegradient( data, (int)width, (int)height, gx, gy);
    edtaa3(data, gx, gy, (int)width, (int)height, xdist, ydist, outside);
    for( i=0; i< pixelAmount; i++)
        if( outside[i] < 0.0 )
            outside[i] = 0.0;

    // Transform foreground (inside contour, in areas of 1's)   
    for( i=0; i< pixelAmount; i++)
        data[i] = 1 - data[i];
    computegradient( data, (int)width, (int)height, gx, gy);
    edtaa3(data, gx, gy, (int)width, (int)height, xdist, ydist, inside);
    for( i=0; i< pixelAmount; i++)
        if( inside[i] < 0.0 )
            inside[i] = 0.0;

    // The bipolar distance field is now outside-inside
    double dist;
    unsigned char *out;
    if (!isDualChannelOutput)
    {
        // Single channel 8-bit output (bad precision and range, but simple)
        out = (unsigned char *)malloc(pixelAmount * sizeof(unsigned char));
        for (i = 0; i < pixelAmount; i++)
        {
            dist = outside[i] - inside[i];
            dist = 128.0 - dist * 16;
            if (dist < 0) dist = 0;
            if (dist > 255) dist = 255;
            out[i] = (unsigned char)dist;
        }
    }
    else
    {
        // Dual channel 16-bit output (more complicated, but good precision and range)
        out = (unsigned char *)malloc(pixelAmount * 3 * sizeof(unsigned char));
        for (i = 0; i < pixelAmount; i++)
        {
            dist = outside[i] - inside[i];
            dist = 128.0 - dist * 16;
            if (dist < 0.0) dist = 0.0;
            if (dist >= 256.0) dist = 255.999;
            // R channel is a copy of the original grayscale image
            out[3 * i] = img[i];
            // G channel is fraction
            out[3 * i + 1] = (unsigned char)(256 - (dist - floor(dist)* 256.0));
            // B channel is truncated integer part
            out[3 * i + 2] = (unsigned char)dist;
        }
    }
    
    free( xdist );
    free( ydist );
    free( gx );
    free( gy );
    free( data );
    free( outside );
    free( inside );

    return out;
}

void FontFreeType::renderCharAt(unsigned char *dest,int posX, int posY, unsigned char* bitmap,long bitmapWidth,long bitmapHeight)
{
    int iX = posX;
    int iY = posY;

    if (_distanceFieldEnabled)
    {
        auto distanceMap = makeDistanceMap(bitmap, bitmapWidth, bitmapHeight, _isDualChannelOutput);

        bitmapWidth += 2 * DistanceMapSpread;
        bitmapHeight += 2 * DistanceMapSpread;

        for (long y = 0; y < bitmapHeight; ++y)
        {
            long bitmap_y = y * bitmapWidth;

            for (long x = 0; x < bitmapWidth; ++x)
            {    
                if (_isDualChannelOutput)
                {
                    // Dual channel 16-bit output (more complicated, but good precision and range)
                    int index = (iX + (iY * FontAtlas::CacheTextureWidth)) * 3;
                    int index2 = (bitmap_y + x) * 3;
                    dest[index] = distanceMap[index2];
                    dest[index + 1] = distanceMap[index2 + 1];
                    dest[index + 2] = distanceMap[index2 + 2];
                }
                else
                {
                    // Single channel 8-bit output 
                    dest[iX + (iY * FontAtlas::CacheTextureWidth)] = distanceMap[bitmap_y + x];
                }

                iX += 1;
            }

            iX  = posX;
            iY += 1;
        }
        free(distanceMap);
    }
    else if(_outlineSize > 0)
    {
        unsigned char tempChar;
        for (long y = 0; y < bitmapHeight; ++y)
        {
            long bitmap_y = y * bitmapWidth;

            for (int x = 0; x < bitmapWidth; ++x)
            {
                tempChar = bitmap[(bitmap_y + x) * 2];
                dest[(iX + ( iY * FontAtlas::CacheTextureWidth ) ) * 2] = tempChar;
                tempChar = bitmap[(bitmap_y + x) * 2 + 1];
                dest[(iX + ( iY * FontAtlas::CacheTextureWidth ) ) * 2 + 1] = tempChar;

                iX += 1;
            }

            iX  = posX;
            iY += 1;
        }
        delete [] bitmap;
    }
    else
    {
        for (long y = 0; y < bitmapHeight; ++y)
        {
            long bitmap_y = y * bitmapWidth;

            for (int x = 0; x < bitmapWidth; ++x)
            {
                unsigned char cTemp = bitmap[bitmap_y + x];

                // the final pixel
                dest[(iX + ( iY * FontAtlas::CacheTextureWidth ) )] = cTemp;

                iX += 1;
            }

            iX  = posX;
            iY += 1;
        }
    } 
}

FT_UInt FontFreeType::getCharGlyphIndex(FT_Face &fontRef, unsigned int theChar)
{
	if (!_fontRef)
	{
		fontRef = nullptr;
		return 0;
	}

	auto glyphIndex = FT_Get_Char_Index(_fontRef, theChar);
	if (glyphIndex != 0)
	{
		fontRef = _fontRef;
		return glyphIndex;
	}

    // 이하는 기본 폰트에서 글자를 못찾아 fallback font 탐색을 시도

    // fallback font name을 순회하며 fallback font ret 체크, 없으면 생성 있으면 get glyph 시도
    auto equalRange = s_fallbackFontNameMultiMap.equal_range(_fontName);
    for (auto iter = equalRange.first; iter != equalRange.second; iter++) {
        std::string fallbackFontName = iter->second;
        FT_Face fallbackFontRef = nullptr;

        // 생성된 font ref 있는지 탐색
        auto equalRange2 = _fallbackFontRefMultiMap.equal_range(_fontName);
        for (auto iter2 = equalRange2.first; iter2 != equalRange2.second; iter2++) {
            if (iter2->second.FontName == fallbackFontName) {
                fallbackFontRef = iter2->second.FontRef;
            }
        }

        // font 못찾은 것이니 생성
        if (fallbackFontRef == nullptr) {
            fallbackFontRef = getFontObject(fallbackFontName, _fontSize);
            if (fallbackFontRef)
                _fallbackFontRefMultiMap.insert(std::pair<std::string, FallbackFont>(_fontName, FallbackFont(fallbackFontName, fallbackFontRef)));
            else
                CCLOG("[FallbackFont] Failed to create font : %s", fallbackFontName.c_str());
        }

        // fallbackFontRef가 있으면 glyph 탐색, 0이면 다른 fallback font 시도
        if (fallbackFontRef != nullptr)
        {
            glyphIndex = FT_Get_Char_Index(fallbackFontRef, theChar);
            if (glyphIndex != 0) {
                fontRef = fallbackFontRef;
                return glyphIndex;
            }
        }
    }

    fontRef = nullptr;
    return 0;
}

FT_Face FontFreeType::getFontRef(unsigned int theChar)
{
	FT_Face fontRef;

	auto glyphIndex = getCharGlyphIndex(fontRef, theChar);
	if (glyphIndex == 0)
	{
		return nullptr;
	}

	if (_distanceFieldEnabled)
	{
		if (FT_Load_Glyph(fontRef, glyphIndex, FT_LOAD_RENDER | FT_LOAD_NO_HINTING | FT_LOAD_NO_AUTOHINT))
		{
			return nullptr;
		}
	}
	else
	{
		if (FT_Load_Glyph(fontRef, glyphIndex, FT_LOAD_RENDER))
		{
			return nullptr;
		}
	}

	return fontRef;
}


NS_CC_END
