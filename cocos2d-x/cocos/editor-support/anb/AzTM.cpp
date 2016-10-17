#include "AzTM.h"

namespace azModel
{

	const float AzTM::PI = 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651f;


	AzTM::AzTM()
		: _m11(1.0f), _m12(0.0f)
		, _m21(0.0f), _m22(1.0f)
		, _m31(0.0f), _m32(0.0f)

		, _scale(1.0f)
	{
	}

	AzTM::AzTM(const Transform2D& t2d, bool invert)
	{
		if (invert)
		{
			float radiran = (float)(t2d.rotate_z() / 360.0f * 2.0f * PI);
			float c = cos(-radiran);
			float s = sin(-radiran);
			float cx = t2d.offset_x() * -1;
			float cy = t2d.offset_y() * -1;
			float sx = 1.0f / (t2d.scale_x() * (t2d.flip_h() ? -1.0f : 1.0f));
			float sy = 1.0f / (t2d.scale_y() * (t2d.flip_v() ? -1.0f : 1.0f));
			float tx = -t2d.position_x();
			float ty = -t2d.position_y();

			_m11 = sx *  c;
			_m12 = sy *  s;
			_m21 = sx * -s;
			_m22 = sy *  c;
			_m31 = (tx * c + ty * -s) * sx + cx;
			_m32 = (tx * s + ty *  c) * sy + cy;

			_scale = 1.0f / t2d.scale_x();

		}
		else
		{
			float radiran = (float)(t2d.rotate_z() / 360.0f * 2.0f * PI);
			float c = cos(radiran);
			float s = sin(radiran);
			float cx = t2d.offset_x();
			float cy = t2d.offset_y();
			float sx = t2d.scale_x() * (t2d.flip_h() ? -1.0f : 1.0f);
			float sy = t2d.scale_y() * (t2d.flip_v() ? -1.0f : 1.0f);
			float tx = t2d.position_x();
			float ty = t2d.position_y();

			_m11 = sx *  c;
			_m12 = sx *  s;
			_m21 = sy * -s;
			_m22 = sy *  c;
			_m31 = (cx * sx * c + cy * sy * -s) + tx;
			_m32 = (cx * sx * s + cy * sy *  c) + ty;

			_scale = t2d.scale_x();
		}
	}

	AzTM::AzTM(const AzTM& tm)
		: _m11(tm._m11), _m12(tm._m12)
		, _m21(tm._m21), _m22(tm._m22)
		, _m31(tm._m31), _m32(tm._m32)

		, _scale(tm._scale)
	{
	}

	AzTM::~AzTM()
	{
	}

	AzTM& AzTM::operator = (const AzTM& tm)
	{
		_m11 = tm._m11; _m12 = tm._m12;
		_m21 = tm._m21; _m22 = tm._m22;
		_m31 = tm._m31; _m32 = tm._m32;

		_scale = tm._scale;

		return *this;
	}

	AzTM& AzTM::mul(const AzTM& tm)
	{
		AzTM tmp(*this);
		_m11 = tmp._m11*tm._m11 + tmp._m12*tm._m21;
		_m12 = tmp._m11*tm._m12 + tmp._m12*tm._m22;

		_m21 = tmp._m21*tm._m11 + tmp._m22*tm._m21;
		_m22 = tmp._m21*tm._m12 + tmp._m22*tm._m22;

		_m31 = tmp._m31*tm._m11 + tmp._m32*tm._m21 + tm._m31;
		_m32 = tmp._m31*tm._m12 + tmp._m32*tm._m22 + tm._m32;

		_scale *= tm._scale;

		return *this;
	}

	void AzTM::mul(float& x, float& y) const
	{
		float tx = _m11*x + _m21*y + _m31;
		float ty = _m12*x + _m22*y + _m32;

		x = tx;
		y = ty;
	}

}
