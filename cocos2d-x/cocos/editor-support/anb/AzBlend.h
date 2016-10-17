#ifndef __AZMODEL__AZBLEND__
#define __AZMODEL__AZBLEND__

#include <cmath>

#include "azmodel.pb.h"
#include "azvisual.pb.h"


namespace azModel
{

	class AzBlend
	{
	public:

		AzBlend();
		AzBlend(const azVisual::Key& key);
		AzBlend(const AzBlend& blend);
		AzBlend(float red, float green, float blue, float alpha);
		~AzBlend();

		AzBlend& operator = (const AzBlend& blend);
		AzBlend& mul(const AzBlend& blend);

		inline float getRed() const { return _red; }
		inline float getGreen() const { return _green; }
		inline float getBlue() const { return _blue; }
		inline float getAlpha() const { return _alpha; }
		inline BLEND_MODE getMode() const { return _mode; }

	private:
		float _red;
		float _green;
		float _blue;
		float _alpha;

		BLEND_MODE _mode;
	};

}

#endif//__AZMODEL__AZBLEND__
