#ifndef __VISUAL_NODE_CCAZVRP_H__
#define __VISUAL_NODE_CCAZVRP_H__

#include "cocos2d.h"

#include <string>

NS_CC_BEGIN

class CC_DLL AzVRP : public Node
{
public:
	static AzVRP* create();
	static AzVRP* create(const std::string& filename);
	static void removeCache(const std::string& filename);
	static void removeCacheAll();
	static void removeUnusedCache();
    static bool isLowEndMode();
    static void setLowEndMode(bool lowendmode);

    virtual bool isIgnoreLowEndMode() = 0;
    virtual void setIgnoreLowEndMode(bool ignore) = 0;

	virtual void onEnter() override;
	virtual void onExit() override;

	virtual bool initWithFile(const std::string& filename) = 0;
	virtual void loadPlistFiles(const std::string& prefix) = 0;
	virtual void buildSprite(const std::string& prefix) = 0;
	virtual void releaseSprite() = 0;
	virtual bool buildEventShapeID(const std::string& plist) = 0;

	virtual bool setVisual(const std::string& visual_group_name, const std::string& visual_name) = 0;
	virtual bool setVisual(const std::string& visual_group_name) = 0;
	virtual bool setVisual(int visual_index) = 0;

	virtual std::string getVisualListLuaTable() = 0;

	inline void setFrame(float v) { _frame = v; }
	virtual void setRepeat(bool v) = 0;
	inline bool isRepeat() const { return _repeat; }
	inline bool isEndAnimation()  const { return (_repeat ? false : (_frame >= _end)); }
	inline float getDuration() const { return (_end) / _fps; }

	inline std::string getVisualGroupName() const { return _visual_group_name; }
	inline std::string getVisualName() const { return _visual_name; }
	inline int	getVisualIndex() const { return _visual_index; }

	inline void enableDrawSocketInfo(bool v) { _draw_sockets = v; }
	inline void enableDrawShapeInfo(bool v) { _draw_shapes = v; }

	void registerScriptLoopHandler(int handler);
	void unregisterScriptLoopHandler();

	virtual void clearSocketHandler() = 0;
	virtual void enableSocketHandler(const std::string& socket_name) = 0;
	void registerScriptSocketHandler(int handler);
	void unregisterScriptSocketHandler();

	virtual void SetCheckValidRect(bool v) = 0;
	virtual cocos2d::Rect getValidRect() const = 0;

    virtual void setCustomShader(int customShaderType, float arg);
    void updateCustomShaderUniforms(bool reset = false);

	virtual float getSocketPosX(const std::string& socket_name) = 0;
	virtual float getSocketPosY(const std::string& socket_name) = 0;

	inline void setTimeScale(float scale) { _timeScale = scale; }
	inline float getTimeScale() const { return _timeScale; }

protected:
	AzVRP(void);
	virtual ~AzVRP(void);

	std::string _file_name;
	std::string _visual_group_name;
	std::string _visual_name;
	int _visual_index;

	std::string _sprite_prefix;

	float _frame;
	float _rendered_frame;
	float _fps;
	float _begin;
	float _end;
	float _deltaTime;
	bool _repeat;

	bool _draw_shapes;
	bool _draw_sockets;

    int _customShaderType;
    GLProgramState* _customShader;

	float _timeScale;

	//
	// for script
	//
	int _loopScriptHandler;
	int _socketScriptHandler;

	//
	// for event shape
	//
public:
	struct EventShape
	{
		int _index;
		float _frame;

		enum
		{
			BOX,
			CIRCLE,
		};
		int _type;

		struct BOX
		{
			float x, y;
			float u_x, u_y;
			float v_x, v_y;
		};
		struct CIRCLE
		{
			float x, y;
			float radius;
		};
		union S
		{
			struct BOX _box;
			struct CIRCLE _circle;
		} _s;
	};
	virtual const EventShape* getEventShapeList() const = 0;
	virtual size_t getEventShapeCount() const = 0;
	virtual const char* getEventShapeName(int index) const = 0;
	virtual int getEventShapeIndex(const std::string& name) const = 0;

	virtual void initEventShapeList() = 0;
	virtual void queryEventShape(float frame) = 0;

	virtual void buildPhysicBody() = 0;
	virtual void buildShapes(PhysicsBody* body) = 0;

	//
	// for socket
	//
public:
	virtual bool bindVRP(const std::string& socket_name, AzVRP* vrp) = 0;
	virtual Node* getSocketNode(const std::string& socket_name) = 0;

	struct Socket
	{
		int _index;
		int _ref_index;
		Mat4 _tm;
	};
	virtual const Socket* getSocketList() const = 0;
	virtual size_t getSocketCount() const = 0;
	virtual const char* getSocketName(int index) const = 0;
	virtual int getSocketIndex(const std::string& name) const = 0;

protected:
	Socket _socket_event;
	float _socket_event_frame;

public:
	inline int getCurrentSocketEvent_Idx() const { return _socket_event._index; }
	inline const char* getCurrentSocketEvent_ID() const { return getSocketName(_socket_event._index); }
	inline int getCurrentSocketEvent_refIdx() const { return _socket_event._ref_index; }
	inline const Mat4& getCurrentSocketEvent_TM() const { return _socket_event._tm; }
	inline float getCurrentSocketEvent_Frame() const { return _socket_event_frame; }

	//
	// for sprite substitutions
	//
public:
	void setSpriteSubstitution(const std::string& src, const std::string& tar);

protected:
	typedef std::map<std::string, std::string> TYPE_SPRITE_SUBSTITUTIONS;
	TYPE_SPRITE_SUBSTITUTIONS _sprite_substitutions;

    static bool s_bLowEndMode;

private:
	CC_DISALLOW_COPY_AND_ASSIGN(AzVRP);
};

NS_CC_END

#endif // __VISUAL_NODE_CCAZVRP_H__
