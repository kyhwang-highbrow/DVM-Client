#include "AzBlend.h"

namespace azModel
{

	AzBlend::AzBlend()
		: _red(1.0f)
		, _green(1.0f)
		, _blue(1.0f)
		, _alpha(1.0f)
		, _mode(ALPHA)
	{
	}

	AzBlend::AzBlend(const azVisual::Key& key)
	{
		_red = key.color_r();
		_green = key.color_g();
		_blue = key.color_b();
		_alpha = key.alpha();
		_mode = key.blend_mode();
	}

	AzBlend::AzBlend(const AzBlend& blend)
		: _red(blend._red)
		, _green(blend._green)
		, _blue(blend._blue)
		, _alpha(blend._alpha)
		, _mode(blend._mode)
	{
	}

	AzBlend::AzBlend(float red, float green, float blue, float alpha)
		: _red(red)
		, _green(green)
		, _blue(blue)
		, _alpha(alpha)
		, _mode(ALPHA)
	{
	}

	AzBlend::~AzBlend()
	{
	}

	AzBlend& AzBlend::operator = (const AzBlend& blend)
	{
		_red = blend._red;
		_green = blend._green;
		_blue = blend._blue;
		_alpha = blend._alpha;
		_mode = blend._mode;

		return *this;
	}

	AzBlend& AzBlend::mul(const AzBlend& blend)
	{
		_red = _red * blend._red;
		_green = _green * blend._green;
		_blue = _blue * blend._blue;
		_alpha = _alpha * blend._alpha;

		if (blend._mode > 1)
		{
			_mode = blend._mode;
		}		

		return *this;
	}

}
