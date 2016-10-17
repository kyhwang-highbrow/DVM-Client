#include "CCRotatePlate.h"
#include "math/CCMath.h"
#include "base/CCDirector.h"
#include "CCGLView.h"
#include "platform/CCDevice.h"

NS_CC_BEGIN

#define SLIDE_SPEED_FACTOR  120.0f
#define SLIDE_DEACCEL_RATE  0.92f
//#define MOVE_INCH           7.0f/160.0f
#define MOVE_INCH           35.0f/160.0f

static float convertDistanceFromPointToInch(float pointDis)
{
    auto glview = Director::getInstance()->getOpenGLView();
    float factor = (glview->getScaleX() + glview->getScaleY()) / 2;
    return pointDis * factor / Device::getDPI();
}

static bool isNotYetTouchMove(float value)
{
    return (fabs(convertDistanceFromPointToInch(value)) < MOVE_INCH);
}

static float normalizeAngle(float angle)
{
    float normalizedAngle = angle - ((int)angle / 360) * 360.0f;
    
    if (normalizedAngle < 0.0f) { normalizedAngle += 360.0f; }
    if (normalizedAngle >= 360.0f) { normalizedAngle -= 360.0f; }

    return normalizedAngle;
}

static bool isEqualFloat(float value1, float value2)
{
    return (fabs(value1 - value2) < FLT_EPSILON);
}

static float LinearSin(float angle)
{
    angle = normalizeAngle(angle);
    float ret = 0.0f;

    if (angle >= 0.0f && angle < 90.0f)
    {
        ret = (1.0f / 90.0f) * angle;
    }
    else if (angle >= 90.0f && angle < 270.0f)
    {
        ret = (-1.0f / 90.0f) * angle + 2.0f;
    }
    else if (angle >= 270.0f && angle <= 360.0f)
    {
        ret = (1.0f / 90.0f) * angle - 4.0f;
    }

    return ret;
}

static float LinearSin2(float angle)
{
    angle = normalizeAngle(angle);
    float ret = 0.0f;

    if (angle >= 0.0f && angle < 360.0f)
    {
        ret = (-1.0f / 90.0f) * angle + 2.0f;
    }
    else if (angle == 360.0f)
    {
        ret = 2.0f;
    }

    return ret;
}

static float LinearSin3(float angle)
{
    angle = normalizeAngle(angle);
    float ret = 0.0f;

    if (angle >= 0.0f && angle < 180.0f)
    {
        ret = (1.0f / 90.0f) * angle;
    }
    else if (angle >= 180.0f && angle <= 360.0f)
    {
        ret = (1.0f / 90.0f) * angle - 4.0f;
    }

    return ret;
}

static float LinearCos(float angle)
{
    angle = normalizeAngle(angle);
    float ret = 0.0f;

    if (angle >= 0.0f && angle < 180.0f)
    {
        ret = (-1.0f / 90.0f) * angle + 1.0f;
    }
    else if (angle >= 180.0f && angle <= 360.0f)
    {
        ret = (1.0f / 90.0f) * angle - 3.0f;
    }

    return ret;
}

static float LinearCos2(float angle)
{
    angle = normalizeAngle(angle);
    float ret = 0.0f;

    if (angle >= 0.0f && angle < 90.0f)
    {
        ret = (1.0f / 90.0f) * angle + 1.0f;
    }
    else if (angle >= 90.0f && angle <= 360.0f)
    {
        ret = (1.0f / 90.0f) * angle - 3.0f;
    }

    return ret;
}

static float LinearCos3(float angle)
{
    angle = normalizeAngle(angle);
    float ret = 0.0f;

    if (angle >= 0.0f && angle < 280.0f)
    {
        ret = (-1.0f / 90.0f) * angle + 1.0f;
    }
    else if (angle >= 270.0f && angle <= 360.0f)
    {
        ret = (-1.0f / 90.0f) * angle + 5.0f;
    }

    return ret;
}

RotatePlate *RotatePlate::create(float radiusX, float radiusY, float minScale, float maxScale, int originDir)
{
    RotatePlate *ret = new RotatePlate();

    if (ret && ret->init(radiusX, radiusY, minScale, maxScale, originDir))
    {
        ret->autorelease();
        return ret;
    }

    CC_SAFE_DELETE(ret);
    return ret;
}

RotatePlate::RotatePlate()
{
    _origin = Vec2::ZERO;
    _radiusX = 1.0f;
    _radiusY = 1.0f;
    _maxScale = 1.0f;
    _minScale = 1.0f;
    _angle = 0.0f;
    _slidedAngle = 0.0f;
    _targetAngle = 0.0f;
    _unitAngle = 360.0f;
    _dragging = false;
    _touchMoved = false;
    _touchPoint = Vec2::ZERO;
    _slideSpeed = 0.0f;
    _touchListener = nullptr;
    _childItems.clear();
    _originDirection = OriginDirection::DOWN;
    _linearSlide = false;
	_touchID = -1;	//무브중에 다른 터치 들어왔을때 체크하기위해서
}

RotatePlate::~RotatePlate()
{
    for (auto item : _childItems)
    {
        item.child->release();
    }
}

bool RotatePlate::init(float radiusX, float radiusY, float minScale, float maxScale, int originDir)
{
    _radiusX = radiusX;
    _radiusY = radiusY;
    setContentSize(Size(_radiusX * 2.0f, _radiusY * 2.0f));

    _minScale = minScale;
    _maxScale = maxScale;

    _originDirection = (OriginDirection)originDir;

    setTouchEnabled(true);

    return true;
}

void RotatePlate::addChild(Node *child, int zOrder, int tag)
{
    Node::addChild(child, zOrder, tag);

    child->retain();

    ChildItem item;
    item.child = child;
    item.isLock = false;
    _childItems.push_back(item);

    _unitAngle = 360.0f / _childItems.size();

    update(_angle);
}

void RotatePlate::removeAllChildrenWithCleanup(bool cleanup)
{
    for (auto item : _childItems)
    {
        item.child->release();
    }

    _childItems.clear();

    Node::removeAllChildrenWithCleanup(cleanup);

    _angle = 0.0f;
    _slidedAngle = 0.0f;
    _targetAngle = 0.0f;
    _unitAngle = 360.0f;
}

Rect RotatePlate::getTouchableRect()
{
    Vec2 screenPos = this->convertToWorldSpace(Vec2::ZERO);
    Rect rect(screenPos.x + _radiusX * getScaleX(), screenPos.y, 0, 0);

    if (_childItems.size() > 0)
    {
        int childIndex = getFrontChildIndex();
        auto child = _childItems[childIndex].child;
        auto childSize = child->getNormalSize();
        childSize.width *= getScaleX();
        childSize.height *= getScaleY();

        rect.origin.x -= childSize.width * child->getAnchorPoint().x;
        rect.origin.y -= childSize.height * child->getAnchorPoint().y;
        rect.size.width += childSize.width;
        rect.size.height += childSize.height;
    }

    return rect;
}

Rect RotatePlate::getSlideTouchableRect()
{
    Vec2 screenPos = this->convertToWorldSpace(Vec2::ZERO);
    Rect rect(screenPos.x, screenPos.y, _radiusX * getScaleX() * 2.0f, _radiusY * getScaleY() * 2.0f);

    if (_childItems.size() > 0)
    {
        int childIndex = getFrontChildIndex();
        auto child = _childItems[childIndex].child;
        auto childSize = child->getNormalSize();
        childSize.width *= getScaleX();
        childSize.height *= getScaleY();

        rect.origin.x -= childSize.width * child->getAnchorPoint().x;
        rect.origin.y -= childSize.height * child->getAnchorPoint().y;
        rect.size.width += childSize.width;
        rect.size.height += childSize.height;
    }

    return rect;
}

void RotatePlate::setRadiusX(float rX)
{
    _radiusX = rX;
    setContentSize(Size(_radiusX * 2.0f, _radiusY * 2.0f));
    update(_angle);
}

void RotatePlate::setRadiusY(float rY)
{
    _radiusY = rY;
    setContentSize(Size(_radiusX * 2.0f, _radiusY * 2.0f));
    update(_angle);
}

void RotatePlate::setMinScale(float scale)
{
    _minScale = scale;
    update(_angle);
}

void RotatePlate::setMaxScale(float scale)
{
    _maxScale = scale;
    update(_angle);
}

void RotatePlate::setAngle(float angle)
{
    update(angle);
    checkRotated();
}

void RotatePlate::setOriginDirection(int dir)
{
    _originDirection = (OriginDirection)dir;
    update(_angle);
}

void RotatePlate::setRotate(int direction, int count)
{
    _slideSpeed = calcSpeedFromAngle((_unitAngle * (count + 0.25f)));

    if (direction < 0)
    {
        _slideSpeed = -_slideSpeed;
    }

    _targetAngle = calcTargetAngle(_angle, _slideSpeed);
    this->schedule(schedule_selector(RotatePlate::deaccelerateSliding));
}

int RotatePlate::getFrontChildIndex()
{
    float normalizedAngle = normalizeAngle(_slidedAngle);
    int childCount = _children.size();

    int index = 0;

    float delta = _unitAngle * 0.5f;
    float minAngle = normalizedAngle - delta;
    float maxAngle = normalizedAngle + delta;

    for (int i = 0; i < childCount; i++)
    {
        float posAngle = i * _unitAngle;

        if (posAngle > minAngle && posAngle < maxAngle)
        {
            index = (i == 0 ? 0 : childCount - i);
            break;
        }
    }

    return index;
}

void RotatePlate::setLinearSlide(bool isLinearSlide)
{
    _linearSlide = isLinearSlide;
}

void RotatePlate::setNormalSize(const Size& size)
{
    setRadiusX(size.width * 0.5f);
    setRadiusY(size.height * 0.5f);
}

const Size& RotatePlate::getNormalSize() const
{
    static Size size;
    size.width = _radiusX * 2.0f;
    size.height = _radiusY * 2.0f;
    return size;
}

bool RotatePlate::isTouchEnabled() const
{
    return _touchListener != nullptr;
}

void RotatePlate::setTouchEnabled(bool enabled)
{
    _eventDispatcher->removeEventListener(_touchListener);
    _touchListener = nullptr;

    if (enabled)
    {
        _touchListener = EventListenerTouchOneByOne::create();
        _touchListener->onTouchBegan = CC_CALLBACK_2(RotatePlate::onTouchBegan, this);
        _touchListener->onTouchMoved = CC_CALLBACK_2(RotatePlate::onTouchMoved, this);
        _touchListener->onTouchEnded = CC_CALLBACK_2(RotatePlate::onTouchEnded, this);
        _touchListener->onTouchCancelled = CC_CALLBACK_2(RotatePlate::onTouchCancelled, this);

        _eventDispatcher->addEventListenerWithSceneGraphPriority(_touchListener, this);
    }
    else
    {
		clearDraggingInfo();
    }
}

bool RotatePlate::onTouchBegan(Touch *touch, Event *event)
{
    if (!this->isVisible())
        return false;

    if (_childItems.size() <= 1)
        return false;

    if (!touch)
        return false;

	Rect rect = getSlideTouchableRect();
    Vec2 touchLocation = touch->getLocation();

    if (!rect.containsPoint(touchLocation))
        return false;

	if (_dragging == true && _touchID != touch->getID())
		return true;

    _touchPoint = this->convertTouchToNodeSpace(touch);
    _touchMoved = false;
    _dragging = true;
    _slideSpeed = 0.0f;

    _angle = normalizeAngle(_angle);

	_touchID = touch->getID();

    return true;
}

void RotatePlate::onTouchMoved(Touch *touch, Event *event)
{
    if (!this->isVisible())
        return;

    if (!touch)
        return;

    if ( _dragging && _touchID == touch->getID() )
    {
        Vec2 newPoint = this->convertTouchToNodeSpace(touch);
        Vec2 moveDistance = newPoint - _touchPoint;

        float dist;
        float factor;
        switch (_originDirection)
        {
        case OriginDirection::DOWN:
            dist = moveDistance.x;
            factor = _radiusX;
            break;
        case OriginDirection::UP:
            dist = -moveDistance.x;
            factor = _radiusX;
            break;
        case OriginDirection::LEFT:
            dist = -moveDistance.y;
            factor = _radiusY;
            break;
        case OriginDirection::RIGHT:
            dist = moveDistance.y;
            factor = _radiusY;
            break;
        }

        if (!_touchMoved && isNotYetTouchMove(dist))
        {
            return;
        }

        if (!_touchMoved)
        {
            dist = 0.0f;
        }

        _slideSpeed = dist;
        _touchPoint = newPoint;
        _touchMoved = true;

        float angleDis = _slideSpeed * SLIDE_SPEED_FACTOR / factor;
        update(_angle + angleDis);
        
    }
}

void RotatePlate::onTouchEnded(Touch *touch, Event *event)
{
    if (!this->isVisible())
        return;

    if (!touch || _touchID < 0)
        return;

	if ( _dragging == true && _touchID != touch->getID() )
		return;
    
    /*
    if (isNotYetTouchMove(_slideSpeed))
    {
        _slideSpeed = calcSpeedFromAngle(calcAutoRotateAngleDis(_angle));
    }
    */

    if (isEqualFloat(_slideSpeed, 0.0f))
    {
        _slideSpeed = calcSpeedFromAngle(calcAutoRotateAngleDis(_angle));        
    }

    if (!isEqualFloat(_slideSpeed, 0.0f))
    {
        float value = calcSpeedFromAngle(_unitAngle);
        //float factor = 0.75f;

        if (_slideSpeed > 0.0f)
        {
            /*
            if (_slideSpeed > value)
                _slideSpeed = value;
            else if (_slideSpeed < value * factor)
                _slideSpeed = value * factor;
            */
            _slideSpeed = value;
        }
        else
        {
            /*
            if (_slideSpeed < -value)
                _slideSpeed = -value;
            else if (_slideSpeed > -value * factor)
                _slideSpeed = -value * factor;
            */
            _slideSpeed = -value;
        }

        _targetAngle = calcTargetAngle(_angle, _slideSpeed);
        this->schedule(schedule_selector(RotatePlate::deaccelerateSliding));
    }
    else
    {
        checkRotated();
    }

	clearDraggingInfo();
}

void RotatePlate::onTouchCancelled(Touch *touch, Event *event)
{
    if (!this->isVisible())
    {
        return;
    }

	clearDraggingInfo();
}

void RotatePlate::deaccelerateSliding(float dt)
{
    if (_dragging)
    {
        this->unschedule(schedule_selector(RotatePlate::deaccelerateSliding));
        return;
    }

    float angleDis = _slideSpeed * SLIDE_SPEED_FACTOR * dt;
    float newAngle = _angle + angleDis;

    bool isEnd = false;

    if (_slideSpeed > 0.0f)
    {
        if (newAngle > _targetAngle)
        {
            isEnd = true;
            newAngle = _targetAngle;
        }
    }
    else
    {
        if (newAngle < _targetAngle)
        {
            isEnd = true;
            newAngle = _targetAngle;
        }
    }

	//정위치로 안가는것 막기위해서
    if( isEnd == false && fabs(angleDis) < 0.05f )
    {
        //CCLOG("==deaccelerateSliding-> fabs(angleDis) < 0.05f ======");
        newAngle = _targetAngle;
        isEnd = true;
    }
    
    update(newAngle);

    if (isEnd)
    {        
        this->unschedule(schedule_selector(RotatePlate::deaccelerateSliding));
        checkRotated();
    }

    _slideSpeed *= SLIDE_DEACCEL_RATE;
}

float RotatePlate::getOriginAngle()
{
    float originAngle = 0.0f;

    switch (_originDirection)
    {
    case OriginDirection::DOWN:
        originAngle = -90.0f;
        break;
    case OriginDirection::UP:
        originAngle = 90.0f;
        break;
    case OriginDirection::LEFT:
        originAngle = 180.0f;
        break;
    case OriginDirection::RIGHT:
        originAngle = 0.0f;
        break;
    }

    return originAngle;
}

int RotatePlate::getZOrderByPosition(Vec2 position)
{
    bool isBackSide = false;

    switch (_originDirection)
    {
    case OriginDirection::DOWN:
        isBackSide = (position.y > _origin.y);
        break;
    case OriginDirection::UP:
        isBackSide = (position.y < _origin.y);
        break;
    case OriginDirection::LEFT:
        isBackSide = (position.x > _origin.x);
        break;
    case OriginDirection::RIGHT:
        isBackSide = (position.x < _origin.x);
        break;
    }

    if (isBackSide)
        return -1;

    return 0;
}

float RotatePlate::getScaleByPosition(Vec2 position)
{
    float scale = 1.0f;

    switch (_originDirection)
    {
    case OriginDirection::DOWN:
        scale = _minScale + (_maxScale - _minScale) * ((_radiusY - (position.y - _origin.y)) / (2 * _radiusY));
        break;
    case OriginDirection::UP:
        scale = _maxScale + (_maxScale - _minScale) * (((position.y - _origin.y) - _radiusY) / (2 * _radiusY));
        break;
    case OriginDirection::LEFT:
        scale = _minScale + (_maxScale - _minScale) * ((_radiusX - (position.x - _origin.x)) / (2 * _radiusX));
        break;
    case OriginDirection::RIGHT:
        scale = _maxScale + (_maxScale - _minScale) * (((position.x - _origin.x) - _radiusX) / (2 * _radiusX));
        break;
    }

    return scale;
}

void RotatePlate::update(Node *node, float angle)
{
    _origin.x = 0;
    _origin.y = 0;

    angle += getOriginAngle();
    float x, y;

    if (_linearSlide)
    {
        switch (_originDirection)
        {
        case OriginDirection::DOWN:
            x = _origin.x + _radiusX * LinearCos2(angle);
            y = _origin.y + _radiusY * LinearSin(angle);
            break;
        case OriginDirection::UP:
            x = _origin.x + _radiusX * LinearCos3(angle);
            y = _origin.y + _radiusY * LinearSin(angle);
            break;
        case OriginDirection::LEFT:
            x = _origin.x + _radiusX * LinearCos(angle);
            y = _origin.y + _radiusY * LinearSin2(angle);
            break;
        case OriginDirection::RIGHT:
            x = _origin.x + _radiusX * LinearCos(angle);
            y = _origin.y + _radiusY * LinearSin3(angle);
            break;
        }
    }
    else
    {
        x = _origin.x + _radiusX * cosf(CC_DEGREES_TO_RADIANS(angle));
        y = _origin.y + _radiusY * sinf(CC_DEGREES_TO_RADIANS(angle));
    }

    node->setDockPoint(Vec2(0.5f, 0.5f));
    node->setPosition(x, y);

    float scale = getScaleByPosition(Vec2(x, y));
    node->setScale(scale);

    int zOrder = getZOrderByPosition(Vec2(x, y));
    node->setZOrder(zOrder);
}

void RotatePlate::update(float angle)
{
    _angle = angle;

    int childCount = _childItems.size();
    for (int i = 0; i < childCount; ++i)
    {
        auto child = _childItems[i].child;
        float childAngle = _angle + (i * 360.f / childCount);
        update(child, childAngle);
    }
}

float RotatePlate::calcAutoRotateAngleDis(float angle)
{
    float normalizedAngle = normalizeAngle(angle);
    float returningAngle = 0.0f;

    for (float thisAngle = 0; thisAngle < 360; thisAngle += _unitAngle)
    {
        float halfNextAngle = thisAngle + _unitAngle * 0.5f;
        float nextAngle = thisAngle + _unitAngle;

        if (normalizedAngle >= thisAngle && normalizedAngle < halfNextAngle)
        {
            return thisAngle - normalizedAngle;
        }

        if (normalizedAngle >= halfNextAngle && normalizedAngle < nextAngle)
        {
            return nextAngle - normalizedAngle;
        }
    }

    return 0.0f;
}

float RotatePlate::calcTargetAngle(float angle, float speed)
{
    if (isEqualFloat(speed, 0.0f))
        return angle;
    
    float angleLimit = calcAngleFromSpeed(speed);
    float predicatedAngle = angle + angleLimit;
    float normalizedAngle = normalizeAngle(predicatedAngle);
    
    //CCLOG("                                          ");
    //CCLOG("------------------------------------------");
    //CCLOG("angle          : %f", angle);
    //CCLOG("speed          : %f", speed);
    //CCLOG("angleLimit     : %f", angleLimit);
    //CCLOG("predicatedAngle    : %f", predicatedAngle);
    //CCLOG("normalizedAngle    : %f", normalizedAngle);
    //CCLOG("_unitAngle : %f", _unitAngle);

    float retAngle = predicatedAngle;

    for (float thisAngle = 0; thisAngle < 360; thisAngle += _unitAngle)
    {
        float nextAngle = thisAngle + _unitAngle;

        if (normalizedAngle > thisAngle && normalizedAngle < nextAngle)
        {
            if (speed > 0.0f){
                //CCLOG("return in speed > 0 : %f", predicatedAngle + (thisAngle - normalizedAngle));
                retAngle = normalizeAngle(thisAngle);               
                break;
                //return predicatedAngle + (thisAngle - normalizedAngle);
            }
            else{
                //CCLOG("return in else : %f", predicatedAngle + (nextAngle - normalizedAngle));
                retAngle = normalizeAngle(nextAngle);               
                break;
                //return predicatedAngle + (nextAngle - normalizedAngle);
            }
        }
    }

    if (predicatedAngle >= 360.f)
        retAngle += 360.f;
    else if (predicatedAngle < 0.f && retAngle > 0)
        retAngle -= 360.f;
    
    //CCLOG("return in ret : %f", retAngle);

    return retAngle;
}

float RotatePlate::getdt()
{
    float dt = Director::getInstance()->getAnimationInterval();

    return dt;
}

float RotatePlate::calcSpeedFromAngle(float angle)
{
    float speed = (angle * (1.0f - SLIDE_DEACCEL_RATE)) / (getdt() * SLIDE_SPEED_FACTOR);

    return speed;
}

float RotatePlate::calcAngleFromSpeed(float speed)
{
    float angle = (speed * getdt() * SLIDE_SPEED_FACTOR) / (1.0f - SLIDE_DEACCEL_RATE);

    return angle;
}

void RotatePlate::checkRotated()
{
    int oldIndex = getFrontChildIndex();
    _slidedAngle = _angle;
    int newIndex = getFrontChildIndex();

    //CCLOG("                                          ");
    //CCLOG("--------------checkRotated----------------------------");
    //CCLOG("oldIndex          : %d", oldIndex);
    //CCLOG("newIndex          : %d", newIndex);

    if (oldIndex != newIndex)
    {
#if CC_ENABLE_SCRIPT_BINDING
        if (kScriptTypeNone != _scriptType)
        {
            BasicScriptData data(this);
            ScriptEvent scriptEvent(kRotatePlateRotatedEvent, &data);
            ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&scriptEvent);
        }
#endif
    }
}

void RotatePlate::clearDraggingInfo()
{
	_dragging = false;
	_touchMoved = false;
	_touchID = -1;
}

NS_CC_END
