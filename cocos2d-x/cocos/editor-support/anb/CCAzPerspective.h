#ifndef __MISCNODE_CCAZPERSPECTIVE_NODE_H__
#define __MISCNODE_CCAZPERSPECTIVE_NODE_H__

#include "cocos2d.h"

NS_CC_BEGIN

class CC_DLL AzPerspective : public Node
{
public:
	static AzPerspective* create();

	void setProjectionMatrix(const Mat4& mat);
	void setProjectionMatrix(float fieldOfView, float zNearPlane, float zFarPlane);

	float getWidth() const;
	float getHeight() const;
	float getZEye() const;
	Vec2 getContectPoint(const Node* node, const Vec2& point) const;

	// overrides
	virtual void visit(Renderer *renderer, const Mat4 &parentTransform, bool parentTransformUpdated) override;

protected:
	AzPerspective();
	virtual ~AzPerspective();

	void onBeginDraw();
	void onEndDraw();

	Mat4 _projectionMatrix, _lookupMatrix;
	GroupCommand _groupCommand;
	CustomCommand _beginCommand;
	CustomCommand _endCommand;

	float _width;
	float _height;
	float _z_eye;
};
NS_CC_END

#endif