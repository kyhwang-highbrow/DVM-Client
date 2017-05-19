#pragma once

#include "MakerScene.h"

class CSelectBox : public cocos2d::Node
{
public:
	CSelectBox();
	~CSelectBox();

	static CSelectBox* create();

	virtual void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, bool transformUpdated);

	inline const cocos2d::Point& begin() const { return _begin; }
	inline void begin(cocos2d::Point p) { _begin = p; }
	inline const cocos2d::Point& end() const { return _end; }
	inline void end(cocos2d::Point p) { _end = p; }

private:
	cocos2d::CustomCommand _customCommand;
	DWORD _updateTimer;
	DWORD _timeDT;
	GLushort _pattern;
	cocos2d::Point _begin;
	cocos2d::Point _end;

	virtual void onDraw(const Mat4 &transform, bool transformUpdated);
};

