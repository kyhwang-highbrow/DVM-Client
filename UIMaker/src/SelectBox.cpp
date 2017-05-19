#include "EntityHelper.h"
#include "SelectBox.h"

USING_NS_CC;

CSelectBox::CSelectBox()
	: _pattern(0x0f0f)
	, _updateTimer(0)
	, _timeDT(10)
{
}
CSelectBox::~CSelectBox()
{
}

CSelectBox* CSelectBox::create()
{
	auto *selected_info = new CSelectBox();
	if (selected_info && selected_info->init())
	{
		selected_info->setGlobalZOrder(1.0f);
		selected_info->autorelease();
		return selected_info;
	}
	CC_SAFE_DELETE(selected_info);
	return nullptr;
}

void CSelectBox::draw(Renderer *renderer, const Mat4& transform, bool transformUpdated)
{
	_customCommand.init(_globalZOrder);
	_customCommand.func = CC_CALLBACK_0(CSelectBox::onDraw, this, transform, transformUpdated);
	renderer->addCommand(&_customCommand);
}

void CSelectBox::onDraw(const Mat4 &transform, bool transformUpdated)
{
	Director* director = Director::getInstance();
	CCASSERT(nullptr != director, "Director is null when seting matrix stack");
	director->pushMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
	director->loadMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW, transform);

	GLfloat l = _begin.x;
	GLfloat r = _end.x;
	GLfloat t = _begin.y;
	GLfloat b = _end.y;

	GLubyte axis_r = 0xff, axis_g = 0x33, axis_b = 0x1f, axis_a = 0x7f;

	glEnable(GL_LINE_STIPPLE);

	DWORD currentTime = GetTickCount();
	if (_updateTimer < currentTime)
	{
		_updateTimer = currentTime + _timeDT;

		_pattern <<= 1;
		if (!(_pattern & 0x10)) _pattern |= 1;
	}

	glLineStipple(1, ~_pattern);
	DrawPrimitives::setDrawColor4B(axis_r, axis_g, axis_b, axis_a);
	DrawPrimitives::drawLine(Vec2(l, t), Vec2(r, t));
	DrawPrimitives::drawLine(Vec2(r, t), Vec2(r, b));
	DrawPrimitives::drawLine(Vec2(r, b), Vec2(l, b));
	DrawPrimitives::drawLine(Vec2(l, b), Vec2(l, t));


	glLineStipple(1, _pattern);
	DrawPrimitives::setDrawColor4B(axis_r, axis_g, axis_b, 0xff);
	DrawPrimitives::drawLine(Vec2(l, t), Vec2(r, t));
	DrawPrimitives::drawLine(Vec2(r, t), Vec2(r, b));
	DrawPrimitives::drawLine(Vec2(r, b), Vec2(l, b));
	DrawPrimitives::drawLine(Vec2(l, b), Vec2(l, t));

	glDisable(GL_LINE_STIPPLE);

	director->popMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
}
