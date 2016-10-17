#include "CCActionInterval3D.h"

NS_CC_BEGIN

//
// MoveBy3D
//

MoveBy3D* MoveBy3D::create(float duration, const Vec3& deltaPosition)
{
    MoveBy3D *ret = new MoveBy3D();
    ret->initWithDuration(duration, deltaPosition);
    ret->autorelease();

    return ret;
}

bool MoveBy3D::initWithDuration(float duration, const Vec3& deltaPosition)
{
    if (ActionInterval::initWithDuration(duration))
    {
        _positionDelta = deltaPosition;
        return true;
    }

    return false;
}

MoveBy3D* MoveBy3D::clone(void) const
{
    // no copy constructor
    auto a = new MoveBy3D();
    a->initWithDuration(_duration, _positionDelta);
    a->autorelease();
    return a;
}

void MoveBy3D::startWithTarget(Node *target)
{
    ActionInterval::startWithTarget(target);
    _previousPosition = _startPosition = target->getPosition3D();
}

MoveBy3D* MoveBy3D::reverse() const
{
    return MoveBy3D::create(_duration, Vec3(-_positionDelta.x, -_positionDelta.y, -_positionDelta.z));
}


void MoveBy3D::update(float t)
{
    if (_target)
    {
#if CC_ENABLE_STACKABLE_ACTIONS
        Vec3 currentPos = _target->getPosition3D();
        Vec3 diff = currentPos - _previousPosition;
        _startPosition = _startPosition + diff;
        Vec3 newPos = _startPosition + (_positionDelta * t);
        _target->setPosition3D(newPos);
        _previousPosition = newPos;
#else
        _target->setPosition(_startPosition + _positionDelta * t);
#endif // CC_ENABLE_STACKABLE_ACTIONS
    }
}



//
// MoveTo3D
//

MoveTo3D* MoveTo3D::create(float duration, const Vec3& position)
{
    MoveTo3D *ret = new MoveTo3D();
    ret->initWithDuration(duration, position);
    ret->autorelease();

    return ret;
}

bool MoveTo3D::initWithDuration(float duration, const Vec3& position)
{
    if (ActionInterval::initWithDuration(duration))
    {
        _endPosition = position;
        return true;
    }

    return false;
}

MoveTo3D* MoveTo3D::clone(void) const
{
    // no copy constructor
    auto a = new MoveTo3D();
    a->initWithDuration(_duration, _endPosition);
    a->autorelease();
    return a;
}

void MoveTo3D::startWithTarget(Node *target)
{
    MoveBy3D::startWithTarget(target);
    _positionDelta = _endPosition - target->getPosition3D();
}



//
// MoveToTarget
//

MoveToTarget* MoveToTarget::create(float speed, const Node * pToTarget)
{
    MoveToTarget *ret = new MoveToTarget();

    ret->initWithToTarget(speed, pToTarget);
    ret->autorelease();

    return ret;
}

bool MoveToTarget::initWithToTarget(float speed, const Node * pToTarget)
{
    _speed = speed;
    _toTarget = pToTarget;
    _previousTime = 0;

    return false;
}

MoveToTarget* MoveToTarget::clone(void) const
{
    // no copy constructor
    auto a = new MoveToTarget();
    a->initWithToTarget(_speed, _toTarget);
    a->autorelease();
    return a;
}

MoveToTarget* MoveToTarget::reverse() const
{
    return (MoveToTarget *)this;
}

void MoveToTarget::update(float t)
{
    _elapsed  = 0;
    _duration = 1;

    float dt = t - _previousTime;

    if (_toTarget && _target)
    {
        Vec2 targetPos = _target->getPosition();
        Vec2 posDelta  = _toTarget->getPosition() - targetPos;

#if CC_ENABLE_STACKABLE_ACTIONS
        Vec2 dir = posDelta;
        dir.normalize();

        float distance = posDelta.getLength();
        float moveLength = MIN(_speed * dt, distance);

        Vec2 newPos = targetPos + dir * moveLength;
        _target->setPosition(newPos);

        if(distance == moveLength)
        {
            _elapsed = 1;
        }
#else
        _target->setPosition(targetPos + posDelta * t);
#endif // CC_ENABLE_STACKABLE_ACTIONS
    }

    _previousTime = t;
}

//
// JumpBy3D
//

JumpBy3D* JumpBy3D::create(float duration, const Vec3& position, float height, int jumps)
{
    JumpBy3D *jumpBy = new JumpBy3D();
    jumpBy->initWithDuration(duration, position, height, jumps);
    jumpBy->autorelease();

    return jumpBy;
}

bool JumpBy3D::initWithDuration(float duration, const Vec3& position, float height, int jumps)
{
    CCASSERT(jumps >= 0, "Number of jumps must be >= 0");

    if (ActionInterval::initWithDuration(duration) && jumps >= 0)
    {
        _delta = position;
        _height = height;
        _jumps = jumps;

        return true;
    }

    return false;
}

JumpBy3D* JumpBy3D::clone(void) const
{
    // no copy constructor
    auto a = new JumpBy3D();
    a->initWithDuration(_duration, _delta, _height, _jumps);
    a->autorelease();
    return a;
}

void JumpBy3D::startWithTarget(Node *target)
{
    ActionInterval::startWithTarget(target);
    _previousPos = _startPosition = target->getPosition3D();
}

void JumpBy3D::update(float t)
{
    // parabolic jump (since v0.8.2)
    if (_target)
    {
        float frac = fmodf(t * _jumps, 1.0f);
        
        float x = _delta.x * t;
        float y = _delta.y * t;
        float z = _delta.z * t;
        
        y += _height * 4 * frac * (1 - frac);
        
#if CC_ENABLE_STACKABLE_ACTIONS
        Vec3 currentPos = _target->getPosition3D();

        Vec3 diff = currentPos - _previousPos;
        _startPosition = diff + _startPosition;

        Vec3 newPos = _startPosition + Vec3(x, y, z);
        _target->setPosition3D(newPos);

        _previousPos = newPos;
#else
        _target->setPosition(_startPosition + Vec2(x, y));
#endif // !CC_ENABLE_STACKABLE_ACTIONS
    }
}

JumpBy3D* JumpBy3D::reverse() const
{
    return JumpBy3D::create(_duration, Vec3(-_delta.x, -_delta.y, -_delta.z),
        _height, _jumps);
}



//
// JumpTo3D
//

JumpTo3D* JumpTo3D::create(float duration, const Vec3& position, float height, int jumps)
{
    JumpTo3D *jumpTo = new JumpTo3D();
    jumpTo->initWithDuration(duration, position, height, jumps);
    jumpTo->autorelease();

    return jumpTo;
}

JumpTo3D* JumpTo3D::clone(void) const
{
    // no copy constructor
    auto a = new JumpTo3D();
    a->initWithDuration(_duration, _delta, _height, _jumps);
    a->autorelease();
    return a;
}

JumpTo3D* JumpTo3D::reverse() const
{
    CCASSERT(false, "reverse() not supported in JumpTo");
    return nullptr;
}

void JumpTo3D::startWithTarget(Node *target)
{
    JumpBy3D::startWithTarget(target);
    _delta = Vec3(_delta.x - _startPosition.x, _delta.y - _startPosition.y, _delta.z - _startPosition.z);
}



// Bezier cubic formula:
//    ((1 - t) + t)3 = 1 
// Expands to ...
//   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1 
static inline float bezierat(float a, float b, float c, float d, float t)
{
    return (powf(1 - t, 3) * a +
        3 * t*(powf(1 - t, 2))*b +
        3 * powf(t, 2)*(1 - t)*c +
        powf(t, 3)*d);
}

//
// BezierBy3D
//

BezierBy3D* BezierBy3D::create(float t, const ccBezier3DConfig& c)
{
    BezierBy3D *bezierBy = new BezierBy3D();
    bezierBy->initWithDuration(t, c);
    bezierBy->autorelease();

    return bezierBy;
}

bool BezierBy3D::initWithDuration(float t, const ccBezier3DConfig& c)
{
    if (ActionInterval::initWithDuration(t))
    {
        _config = c;
        return true;
    }

    return false;
}

void BezierBy3D::startWithTarget(Node *target)
{
    ActionInterval::startWithTarget(target);
    _previousPosition = _startPosition = target->getPosition3D();
}

BezierBy3D* BezierBy3D::clone(void) const
{
    // no copy constructor
    auto a = new BezierBy3D();
    a->initWithDuration(_duration, _config);
    a->autorelease();
    return a;
}

void BezierBy3D::update(float time)
{
    if (_target)
    {
        float xa = 0;
        float xb = _config.controlPoint_1.x;
        float xc = _config.controlPoint_2.x;
        float xd = _config.endPosition.x;

        float ya = 0;
        float yb = _config.controlPoint_1.y;
        float yc = _config.controlPoint_2.y;
        float yd = _config.endPosition.y;

        float za = 0;
        float zb = _config.controlPoint_1.z;
        float zc = _config.controlPoint_2.z;
        float zd = _config.endPosition.z;

        float x = bezierat(xa, xb, xc, xd, time);
        float y = bezierat(ya, yb, yc, yd, time);
        float z = bezierat(za, zb, zc, zd, time);

#if CC_ENABLE_STACKABLE_ACTIONS
        Vec3 currentPos = _target->getPosition3D();
        Vec3 diff = currentPos - _previousPosition;
        _startPosition = _startPosition + diff;

        Vec3 newPos = _startPosition + Vec3(x, y, z);
        _target->setPosition3D(newPos);

        _previousPosition = newPos;
#else
        _target->setPosition(_startPosition + Vec2(x, y));
#endif // !CC_ENABLE_STACKABLE_ACTIONS
    }
}

BezierBy3D* BezierBy3D::reverse(void) const
{
    ccBezier3DConfig r;

    r.endPosition = -_config.endPosition;
    r.controlPoint_1 = _config.controlPoint_2 + (-_config.endPosition);
    r.controlPoint_2 = _config.controlPoint_1 + (-_config.endPosition);

    BezierBy3D *action = BezierBy3D::create(_duration, r);
    return action;
}

//
// BezierTo
//

BezierTo3D* BezierTo3D::create(float t, const ccBezier3DConfig& c)
{
    BezierTo3D *bezierTo = new BezierTo3D();
    bezierTo->initWithDuration(t, c);
    bezierTo->autorelease();

    return bezierTo;
}

bool BezierTo3D::initWithDuration(float t, const ccBezier3DConfig &c)
{
    if (ActionInterval::initWithDuration(t))
    {
        _toConfig = c;
        return true;
    }

    return false;
}

BezierTo3D* BezierTo3D::clone(void) const
{
    // no copy constructor
    auto a = new BezierTo3D();
    a->initWithDuration(_duration, _toConfig);
    a->autorelease();
    return a;
}

void BezierTo3D::startWithTarget(Node *target)
{
    BezierBy3D::startWithTarget(target);
    _config.controlPoint_1 = _toConfig.controlPoint_1 - _startPosition;
    _config.controlPoint_2 = _toConfig.controlPoint_2 - _startPosition;
    _config.endPosition = _toConfig.endPosition - _startPosition;
}

BezierTo3D* BezierTo3D::reverse() const
{
    CCASSERT(false, "CCBezierTo doesn't support the 'reverse' method");
    return nullptr;
}

NS_CC_END