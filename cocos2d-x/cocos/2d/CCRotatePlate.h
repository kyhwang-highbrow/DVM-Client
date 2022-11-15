#ifndef __CCROTATEPLATE_H__
#define __CCROTATEPLATE_H__

#include "2d/CCNode.h"
#include "base/CCEventListenerTouch.h"

NS_CC_BEGIN

class RotatePlate : public Node, public SlideNodeProtocol
{
public:
    enum OriginDirection
    {
        DOWN,
        UP,
        LEFT,
        RIGHT
    };

    static RotatePlate *create(float radiusX, float radiusY, float minScale, float maxScale, int originDir = OriginDirection::DOWN);

    void setRadiusX(float rX);
    float getRadiusX() { return _radiusX; }
    void setRadiusY(float rY);
    float getRadiusY() { return _radiusY; }
    void setMinScale(float scale);
    float getMinScale() { return _minScale; }
    void setMaxScale(float scale);
    float getMaxScale() { return _maxScale; }
    void setAngle(float angle);
    float getAngle() { return _angle; }
    void setOriginDirection(int dir);
    int getOriginDirection() { return (int)_originDirection; }
    void setRotate(int direction, int count);
    int getFrontChildIndex();
    void setLinearSlide(bool isLinearSlide);

    float getOriginAngle();

    virtual void setNormalSize(const Size& size) override;
    virtual const Size& getNormalSize() const override;

    void setTouchEnabled(bool enabled);
    bool isTouchEnabled() const;

    virtual bool onTouchBegan(Touch *touch, Event *event);
    virtual void onTouchMoved(Touch *touch, Event *event);
    virtual void onTouchEnded(Touch *touch, Event *event);
    virtual void onTouchCancelled(Touch *touch, Event *event);

    virtual void addChild(Node* child, int localZOrder, int tag) override;
    virtual void removeAllChildrenWithCleanup(bool cleanup) override;

    virtual bool isDragging() const override { return _dragging; }
    virtual bool isTouchMoved() const override { return _touchMoved; }
    virtual Rect getTouchableRect() override;

    virtual bool isSlideNode() const override { return true; }

    Rect getSlideTouchableRect();

protected:
    RotatePlate();
    virtual ~RotatePlate();

    bool init(float radiusX, float radiusY, float minScale, float maxScale, int originDir = OriginDirection::DOWN);
    void update(Node *node, float angle);
    void update(float angle) override;

    void deaccelerateSliding(float dt);

    float calcAutoRotateAngleDis(float angle);
    float calcTargetAngle(float angle, float speed);

    int getZOrderByPosition(Vec2 position);
    float getScaleByPosition(Vec2 position);

    float getdt();
    float calcSpeedFromAngle(float angle);
    float calcAngleFromSpeed(float speed);

    void checkRotated();

	void clearDraggingInfo();

    Vec2 _origin;
    float _radiusX;
    float _radiusY;
    float _maxScale;
    float _minScale;

    float _angle;
    float _slidedAngle;
    float _targetAngle;
    float _unitAngle;

    bool _dragging;
    bool _touchMoved;
    Vec2 _touchPoint;
    float _slideSpeed;
    EventListenerTouchOneByOne* _touchListener;

    OriginDirection _originDirection;

    bool _linearSlide;

    struct ChildItem
    {
        Node *child;
        bool isLock;
    };

    std::vector<ChildItem> _childItems;

	int _touchID;
};

NS_CC_END

#endif
