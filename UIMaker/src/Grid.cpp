#include "Grid.h"


USING_NS_CC;

bool CGrid::_show = false;
int CGrid::_opacity_factor_index = 0;
float CGrid::_opacity_factor = 1.0f;

CGrid::CGrid()
{
}
CGrid::~CGrid()
{
}

CGrid* CGrid::create()
{
	auto *selected_info = new CGrid();
	if (selected_info && selected_info->init())
	{
		selected_info->setGlobalZOrder(1.0f);
		selected_info->autorelease();
		return selected_info;
	}
	CC_SAFE_DELETE(selected_info);
	return nullptr;
}

void CGrid::invertShow()
{
	_show = _show ? false : true;
}

void CGrid::updateOpacity()
{
	static float opacities[] = { 1.0f, 1.5f, 2.0f, 0.25f, 0.5f, 0.75f, -1.0f };
	if (opacities[++_opacity_factor_index] < 0) _opacity_factor_index = 0;
	_opacity_factor = opacities[_opacity_factor_index];
}

void CGrid::draw(Renderer *renderer, const Mat4& transform, bool transformUpdated)
{
	_customCommand.init(_globalZOrder);
	_customCommand.func = CC_CALLBACK_0(CGrid::onDraw, this, transform, transformUpdated);
	renderer->addCommand(&_customCommand);
}

void CGrid::onDraw(const Mat4 &transform, bool transformUpdated)
{
	Director* director = Director::getInstance();
	CCASSERT(nullptr != director, "Director is null when seting matrix stack");
	director->pushMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
	director->loadMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW, transform);

	float zoom = getParent()->getScale();

	Size size = director->getRunningScene()->getNormalSize();
	size = Size(size.width, size.height);

	GLfloat pos_x = getParent()->getPositionX();
	GLfloat pos_y = getParent()->getPositionY();

	GLfloat ol = -pos_x;
	GLfloat or = ol + size.width;
	GLfloat ot = -pos_y;
	GLfloat ob = ot + size.height;

	GLfloat center_x = (ol + or)*0.5f / zoom;
	GLfloat center_y = (ot + ob)*0.5f / zoom;

	GLfloat half_w = (size.width / zoom)*0.5f;
	GLfloat half_h = (size.height / zoom)*0.5f;

	GLfloat l = center_x - half_w;
	GLfloat r = center_x + half_w;
	GLfloat t = center_y - half_h;
	GLfloat b = center_y + half_h;

	int dx = 1, dy = 1;

	float step = 16;
	if (step < 1) step = 1;

	GLubyte major_r = 0x7f, major_g = 0x7f, major_b = 0x7f, major_a = 0x7f * _opacity_factor;
	GLubyte minor_r = 0xff, minor_g = 0xff, minor_b = 0xff, minor_a = 0x7f * _opacity_factor;
	GLubyte axis_r = 0xff, axis_g = 0xff, axis_b = 0xff, axis_a = 0xff * _opacity_factor;

	if (major_a > 0xff) major_a = 0xff;
	if (minor_a > 0xff) minor_a = 0xff;
	if (axis_a > 0xff) axis_a = 0xff;

	if (_show)
	{
		DrawPrimitives::setDrawColor4B(minor_r, minor_g, minor_b, minor_a);
		for (int i = 1; i*step <= r; ++i)
		{
			float x = (float)i * step;
			if (x < l) continue;

			if (i % 5)
			{
				DrawPrimitives::setDrawColor4B(major_r, major_g, major_b, major_a);
				DrawPrimitives::drawLine(Vec2(x*dx, t*dy), Vec2(x*dx, b*dy));
				DrawPrimitives::setDrawColor4B(minor_r, minor_g, minor_b, minor_a);
				continue;
			}
			DrawPrimitives::drawLine(Vec2(x*dx, t*dy), Vec2(x*dx, b*dy));
		}
		for (int i = 1; -i*step >= l; ++i)
		{
			float x = (float)i * -step;
			if (x > r) continue;

			if (i % 5)
			{
				DrawPrimitives::setDrawColor4B(major_r, major_g, major_b, major_a);
				DrawPrimitives::drawLine(Vec2(x*dx, t*dy), Vec2(x*dx, b*dy));
				DrawPrimitives::setDrawColor4B(minor_r, minor_g, minor_b, minor_a);
				continue;
			}
			DrawPrimitives::drawLine(Vec2(x*dx, t*dy), Vec2(x*dx, b*dy));
		}
		for (int i = 1; i*step <= b; ++i)
		{
			float y = (float)i * step;
			if (y < t) continue;

			if (i % 5)
			{
				DrawPrimitives::setDrawColor4B(major_r, major_g, major_b, major_a);
				DrawPrimitives::drawLine(Vec2(l*dx, y*dy), Vec2(r*dx, y*dy));
				DrawPrimitives::setDrawColor4B(minor_r, minor_g, minor_b, minor_a);
				continue;
			}
			DrawPrimitives::drawLine(Vec2(l*dx, y*dy), Vec2(r*dx, y*dy));
		}
		for (int i = 1; -i*step >= t; ++i)
		{
			float y = (float)-i * step;
			if (y > b) continue;

			if (i % 5)
			{
				DrawPrimitives::setDrawColor4B(major_r, major_g, major_b, major_a);
				DrawPrimitives::drawLine(Vec2(l*dx, y*dy), Vec2(r*dx, y*dy));
				DrawPrimitives::setDrawColor4B(minor_r, minor_g, minor_b, minor_a);
				continue;
			}
			DrawPrimitives::drawLine(Vec2(l*dx, y*dy), Vec2(r*dx, y*dy));
		}
	}

	DrawPrimitives::setDrawColor4B(axis_r, axis_g, axis_b, axis_a);
	if (0 <= b && 0 >= t) DrawPrimitives::drawLine(Vec2(l, 0), Vec2(r, 0));
	if (0 <= r && 0 >= l) DrawPrimitives::drawLine(Vec2(0, t), Vec2(0, b));

	director->popMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
}
