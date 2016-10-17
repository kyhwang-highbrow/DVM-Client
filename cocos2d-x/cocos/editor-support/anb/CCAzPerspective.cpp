#include "CCAzPerspective.h"

#include "renderer/CCGroupCommand.h"
#include "renderer/CCRenderer.h"
#include "renderer/CCCustomCommand.h"


NS_CC_BEGIN

AzPerspective* AzPerspective::create()
{
	AzPerspective * ret = new AzPerspective();
	if (ret && ret->init())
	{
		ret->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(ret);
	}
	return ret;
}

AzPerspective::AzPerspective()
	: _z_eye(1.1566f)
{

}

AzPerspective::~AzPerspective()
{
}

void AzPerspective::setProjectionMatrix(const Mat4& mat)
{
	_projectionMatrix = mat;
}

void AzPerspective::setProjectionMatrix(float fieldOfView, float zNearPlane, float zFarPlane)
{
	auto size = Director::getInstance()->getWinSize();
	Mat4::createPerspective(fieldOfView, (GLfloat)size.width / size.height, zNearPlane, zFarPlane, &_projectionMatrix);

	_width = size.width;
	_height = size.height;
	_z_eye = size.height / 1.1566f;
	Vec3 eye(size.width / 2, size.height / 2, _z_eye), center(size.width / 2, size.height / 2, 0.0f), up(0.0f, 1.0f, 0.0f);
	Mat4::createLookAt(eye, center, up, &_lookupMatrix);
}

float AzPerspective::getWidth() const
{
	return _width;
}
float AzPerspective::getHeight() const
{
	return _height;
}
float AzPerspective::getZEye() const
{
	return _z_eye;
}
Vec2 AzPerspective::getContectPoint(const Node* node, const Vec2& point) const
{
	Mat4 tmp = node->getWorldToNodeTransform();
	Vec3 v0(_width / 2, _height / 2, _z_eye);
	Vec3 v1(point.x, point.y, 0);
	Vec3 o;
	Vec3 p;
	tmp.transformPoint(v0, &o);
	tmp.transformPoint(v1, &p);
	Vec3 dir(p);
	dir.subtract(o);
	dir.normalize();
	Vec3 normal(0, 0, 1);

	float dot_v = dir.dot(normal);
	if (abs(dot_v) < 0.00001f) return Point(FLT_MAX, FLT_MAX);

	float t = -o.z / dot_v;
	Vec3 contect(dir * t + o);

	return Point(contect.x, contect.y);
}

void AzPerspective::onBeginDraw()
{
	Director* director = Director::getInstance();
	CCASSERT(nullptr != director, "Director is null when seting matrix stack");

	director->pushMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_PROJECTION);
	director->loadMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_PROJECTION, _projectionMatrix);
	director->multiplyMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_PROJECTION, _lookupMatrix);
}

void AzPerspective::onEndDraw()
{
	Director* director = Director::getInstance();
	CCASSERT(nullptr != director, "Director is null when seting matrix stack");

	director->popMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_PROJECTION);
}

void AzPerspective::visit(Renderer *renderer, const Mat4 &parentTransform, bool parentTransformUpdated)
{
	// quick return if not visible. children won't be drawn.
	if (!_visible)
	{
		return;
	}

	_groupCommand.init(_globalZOrder);
	renderer->addCommand(&_groupCommand);
	renderer->pushGroup(_groupCommand.getRenderQueueID());

	bool dirty = parentTransformUpdated || _transformUpdated;
	if (dirty)
		_modelViewTransform = this->transform(parentTransform);
	_transformUpdated = false;

	// IMPORTANT:
	// To ease the migration to v3.0, we still support the Mat4 stack,
	// but it is deprecated and your code should not rely on it
	Director* director = Director::getInstance();
	CCASSERT(nullptr != director, "Director is null when seting matrix stack");

	director->pushMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
	director->loadMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW, _modelViewTransform);

	_beginCommand.init(_globalZOrder);
	_beginCommand.func = CC_CALLBACK_0(AzPerspective::onBeginDraw, this);
	renderer->addCommand(&_beginCommand);

	int i = 0;
	if (!_children.empty())
	{
		sortAllChildren();
		// draw children zOrder < 0
		for (; i < _children.size(); i++)
		{
			auto node = _children.at(i);

			if (node && node->getLocalZOrder() < 0)
				node->visit(renderer, _modelViewTransform, dirty);
			else
				break;
		}
		// self draw,currently we have nothing to draw on AzPerspective, so there is no need to add render command
		this->draw(renderer, _modelViewTransform, dirty);

		for (auto it = _children.cbegin() + i; it != _children.cend(); ++it) {
			(*it)->visit(renderer, _modelViewTransform, dirty);
		}
	}
	else
	{
		this->draw(renderer, _modelViewTransform, dirty);
	}

	// reset for next frame
	_orderOfArrival = 0;

	_endCommand.init(_globalZOrder);
	_endCommand.func = CC_CALLBACK_0(AzPerspective::onEndDraw, this);
	renderer->addCommand(&_endCommand);

	renderer->popGroup();

	director->popMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
}


NS_CC_END
