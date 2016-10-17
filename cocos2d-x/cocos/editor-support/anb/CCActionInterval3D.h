#ifndef __CC_ACTION_INTERVAL_3D__
#define __CC_ACTION_INTERVAL_3D__

#include "cocos2d.h"

NS_CC_BEGIN

//
// MoveBy3D
//

class CC_DLL MoveBy3D : public ActionInterval
{
public:
    static MoveBy3D* create(float duration, const Vec3& deltaPosition);

    //
    // Overrides
    //
    virtual MoveBy3D* clone() const override;
    virtual MoveBy3D* reverse(void) const  override;
    virtual void startWithTarget(Node *target) override;
    virtual void update(float time) override;

CC_CONSTRUCTOR_ACCESS:
    MoveBy3D() {}
    virtual ~MoveBy3D() {}

    /** initializes the action */
    bool initWithDuration(float duration, const Vec3& deltaPosition);

protected:
    Vec3 _positionDelta;
    Vec3 _startPosition;
    Vec3 _previousPosition;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(MoveBy3D);
};



//
// MoveTo3D
//

class CC_DLL MoveTo3D : public MoveBy3D
{
public:
    /** creates the action */
    static MoveTo3D* create(float duration, const Vec3& position);

    //
    // Overrides
    //
    virtual MoveTo3D* clone() const override;
    virtual void startWithTarget(Node *target) override;

CC_CONSTRUCTOR_ACCESS:
    MoveTo3D() {}
    virtual ~MoveTo3D() {}

    /** initializes the action */
    bool initWithDuration(float duration, const Vec3& position);

protected:
    Vec3 _endPosition;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(MoveTo3D);
};



//
// MoveToTarget
//

class CC_DLL MoveToTarget : public ActionInterval
{
public:
    /** creates the action */
    static MoveToTarget* create(float speed, const Node * pToTarget);

    //
    // Overrides
    //
    virtual MoveToTarget* clone() const override;
    virtual MoveToTarget* reverse(void) const override;
    virtual void update(float time) override;

CC_CONSTRUCTOR_ACCESS:
    MoveToTarget() {}
    virtual ~MoveToTarget() {}

    /** initializes the action */
    bool initWithToTarget(float speed, const Node * pToTarget);

protected:
    const Node * _toTarget;
    float _speed;
    float _previousTime;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(MoveToTarget);
};



//
// JumpBy3D
//

class CC_DLL JumpBy3D : public ActionInterval
{
public:
    /** creates the action */
    static JumpBy3D* create(float duration, const Vec3& position, float height, int jumps);

    //
    // Overrides
    //
    virtual JumpBy3D* clone() const override;
    virtual JumpBy3D* reverse(void) const override;
    virtual void startWithTarget(Node *target) override;
    virtual void update(float time) override;

CC_CONSTRUCTOR_ACCESS:
    JumpBy3D() {}
    virtual ~JumpBy3D() {}

    /** initializes the action */
    bool initWithDuration(float duration, const Vec3& position, float height, int jumps);

protected:
    Vec3           _startPosition;
    Vec3           _delta;
    float           _height;
    int             _jumps;
    Vec3           _previousPos;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(JumpBy3D);
};



//
// JumpTo3D
//

class CC_DLL JumpTo3D : public JumpBy3D
{
public:
    /** creates the action */
    static JumpTo3D* create(float duration, const Vec3& position, float height, int jumps);

    //
    // Override
    //
    virtual void startWithTarget(Node *target) override;
    virtual JumpTo3D* clone() const override;
    virtual JumpTo3D* reverse(void) const override;

private:
    JumpTo3D() {}
    virtual ~JumpTo3D() {}
    CC_DISALLOW_COPY_AND_ASSIGN(JumpTo3D);
};


typedef struct _ccBezier3DConfig {
    //! end position of the bezier
    Vec3 endPosition;
    //! Bezier control point 1
    Vec3 controlPoint_1;
    //! Bezier control point 2
    Vec3 controlPoint_2;
} ccBezier3DConfig;

//
// BezierBy3D
//

class CC_DLL BezierBy3D : public ActionInterval
{
public:
    /** creates the action with a duration and a bezier configuration
    * @code
    * when this function bound to js or lua,the input params are changed
    * in js: var create(var t,var table)
    * in lua: lcaol create(local t, local table)
    * @endcode
    */
    static BezierBy3D* create(float t, const ccBezier3DConfig& c);

    //
    // Overrides
    //
    virtual BezierBy3D* clone() const override;
    virtual BezierBy3D* reverse(void) const override;
    virtual void startWithTarget(Node *target) override;
    virtual void update(float time) override;

CC_CONSTRUCTOR_ACCESS:
    BezierBy3D() {}
    virtual ~BezierBy3D() {}

    /** initializes the action with a duration and a bezier configuration */
    bool initWithDuration(float t, const ccBezier3DConfig& c);

protected:
    ccBezier3DConfig _config;
    Vec3 _startPosition;
    Vec3 _previousPosition;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(BezierBy3D);
};



//
// BezierTo3D
//

class CC_DLL BezierTo3D : public BezierBy3D
{
public:
    /** creates the action with a duration and a bezier configuration
    * @code
    * when this function bound to js or lua,the input params are changed
    * in js: var create(var t,var table)
    * in lua: lcaol create(local t, local table)
    * @endcode
    */
    static BezierTo3D* create(float t, const ccBezier3DConfig& c);

    //
    // Overrides
    //
    virtual void startWithTarget(Node *target) override;
    virtual BezierTo3D* clone() const override;
    virtual BezierTo3D* reverse(void) const override;

CC_CONSTRUCTOR_ACCESS:
    BezierTo3D() {}
    virtual ~BezierTo3D() {}

    bool initWithDuration(float t, const ccBezier3DConfig &c);

protected:
    ccBezier3DConfig _toConfig;

private:
    CC_DISALLOW_COPY_AND_ASSIGN(BezierTo3D);
};

NS_CC_END

#endif