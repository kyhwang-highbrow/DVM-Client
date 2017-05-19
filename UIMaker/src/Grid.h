#pragma once

#include "MakerScene.h"

class CGrid : public cocos2d::Node
{
public:
	CGrid();
	~CGrid();

	static CGrid* create();

	virtual void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, bool transformUpdated);

	void invertShow();
	void updateOpacity();

private:
	static bool _show;
	static int _opacity_factor_index;
	static float _opacity_factor;

	cocos2d::CustomCommand _customCommand;

	virtual void onDraw(const Mat4 &transform, bool transformUpdated);
};


