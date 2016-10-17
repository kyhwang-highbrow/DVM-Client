#ifndef __AZMODEL__AZTM__
#define __AZMODEL__AZTM__

#include <cmath>

#include "azmodel.pb.h"


namespace azModel
{

	class AzTM
	{
	public:

		static const float PI;


		AzTM();
		AzTM(const Transform2D& t2d, bool invert = false);
		AzTM(const AzTM& tm);
		~AzTM();

		AzTM& operator = (const AzTM& tm);
		AzTM& mul(const AzTM& tm);
		void mul(float& x, float& y) const;

		inline float getTranslateX() const { return _m31; }
		inline float getTranslateY() const { return _m32; }
		inline float getRad() const { return 0; }
		inline float getScale() const { return _scale; }

		float _m11, _m12;
		float _m21, _m22;
		float _m31, _m32;

		float _scale;
	};

}

#endif//__AZMODEL__AZTM__
