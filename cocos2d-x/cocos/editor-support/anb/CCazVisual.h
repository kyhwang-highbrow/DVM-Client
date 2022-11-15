#ifndef __VISUAL_NODE_CCAZVISUAL_H__
#define __VISUAL_NODE_CCAZVISUAL_H__

#include "cocos2d.h"

#include <string>

#include "AzID.h"
#include "AzTM.h"
#include "AzBlend.h"
#include "AzDataTrip.h"

namespace azModel {
	class AzDataDictionary;
}

namespace azVisual {
	class Visual;
}

NS_CC_BEGIN


struct transformValues_;

class AzVisualSocket;

class CC_DLL AzVisual : public Node
{
public:
	static const std::string PROJECT_PATH;

	static AzVisual* create();
	static AzVisual* create(const std::string& filename);
	static void removeCache(const std::string& filename);
	static void removeCacheAll();
	static void removeUnusedCache();

	virtual void onEnter() override;
	virtual void onExit() override;

	virtual void update(float deltaTime) override;
	virtual void draw(Renderer *renderer, const Mat4& transform, bool transformUpdated) override;

	bool setFile(const std::string& filename);
	void setSpriteSubstitution(const std::string& src, const std::string& tar);
	void loadPlistFiles(const std::string& prefix);
	void buildSprite(const std::string& prefix);
	void releaseSprite();
	bool buildEventShapeID(const std::string& plist);

	bool setVisual(int visual_group_index, int visual_index);
	bool setVisual(const std::string& visual_group_name, const std::string& visual_name);
	bool setVisual(const std::string& visual_group_name);
	void getVisualList(const std::string& bind_token, std::list<std::string>& visual_list);

	inline void setFrame(float v) { _frame = v; }
	inline void setRepeat(bool v) { _repeat = v; _data_trip_draw.setRepeat(v); _data_trip_event_shape.setRepeat(v); }
	inline bool isRepeat() const { return _repeat; }
	inline bool isEndAnimation()  const { return (_repeat ? false : (_frame >= _end)); }
	inline float getDuration() { return (_end) / _fps; }

	inline std::string getVisualGroupName() const { return _visual_group_name; }
	inline std::string getVisualName() const { return _visual_name; }

	bool bindVisual(const std::string& socket_name, const std::string& filename, const std::string& visual_group_name);
	inline bool bindSocket(const std::string& socket_name, const std::string& filename, const std::string& visual_group_name) { return bindVisual(socket_name, filename, visual_group_name); }
	Node* getSocketNode(const std::string& socket_name);
	void getSocketNodeList(std::list<std::string>& socket_node_list);

	inline void enableDrawVisibleRect(bool v) { _draw_visible_rect = v; }
	inline void enableDrawSocketInfo(bool v) { _draw_sockets = v; }
	inline void enableDrawShapeInfo(bool v) { _draw_shapes = v; }

	cocos2d::Rect getValidRect() const { return cocos2d::Rect(_min_x, _min_y, _max_x - _min_x, _max_y - _min_y); }

	void registerScriptLoopHandler(int handler);
	void unregisterScriptLoopHandler();

    virtual void setOpacityModifyRGB(bool modify) override;
    virtual bool isOpacityModifyRGB(void) const override;

    inline void setAdditiveColor(const Color3B & color) { _additiveColor = color; }

	inline int getShapeCount() { return _shape_info_count; }

	void initEventShapeList();
	void queryEventShape(float frame);

	void buildPhysicBody();
	void buildShapes(PhysicsBody* body);

protected:

	AzVisual(void);
	virtual ~AzVisual(void);

	virtual bool init(void) override;
	virtual bool initWithFile(const std::string& filename);

	static bool load(const std::string& filename, azModel::AzDataDictionary*& azddic, azModel::AzID& project_id);
	static void appendDataToDic(azModel::AzDataDictionary* azddic, const azModel::AzData* data);

	typedef std::map < std::string, std::pair< std::shared_ptr< azModel::AzDataDictionary >, azModel::AzID > > TYPE_VISUAL_CACHE;
	static TYPE_VISUAL_CACHE s_visual_cache;

	std::shared_ptr<azModel::AzDataDictionary> _azddic;
	azModel::AzID _project_id;
	azModel::AzDataTrip _data_trip_draw;
	azModel::AzDataTrip _data_trip_socket;
	void initTripFunction_bitmap(azModel::AzDataTrip&);
	void initTripFunction_sprite(azModel::AzDataTrip&);
	void initTripFunction_particle(azModel::AzDataTrip&);
	void initTripFunction_socket(azModel::AzDataTrip&);

	azModel::AzDataTrip _data_trip_event_shape;
	void initTripFunction_eventshape(azModel::AzDataTrip&);

	std::string _file_name;
	std::string _visual_group_name;
	std::string _visual_name;
	std::string _visual_index;

	const azVisual::Visual* _visual;
	float _frame;
	float _rendered_frame;
	float _begin;
	float _end;
	float _fps;
	float _deltaTime;
	bool _repeat;
    bool _opacityModifyRGB;

    Color3B _additiveColor;


	//
	// for sprite
	//
	typedef struct SPRITE_INFO
	{
		SPRITE_INFO() : _texture(nullptr) {}
		Texture2D* _texture;
		float _l;
		float _t;
		float _r;
		float _b;
		Tex2F _uv_tl;
		Tex2F _uv_bl;
		Tex2F _uv_tr;
		Tex2F _uv_br;
	};
	typedef std::map< long long, SPRITE_INFO > TYPE_SPRITE_MAP;
	TYPE_SPRITE_MAP _sprite_pool;

	std::string _sprite_prefix;

	//
	// for randering with QuadCommand
	//
	const static size_t _quads_alloc_unit = 8;
	cocos2d::V3F_C4B_T2F_Quad* _quads;
	size_t _quads_max;
	size_t _quads_count;
	size_t _flushed_quads_count;

	GLuint _current_texture_name;
	azModel::BLEND_MODE _current_blend_mode;
	GLProgramState* _current_shader_program_state;
	GLProgramState* _color_program_state;

	typedef std::vector< QuadCommand* > TYPE_QUAD_CMD_LIST;
	TYPE_QUAD_CMD_LIST _quad_cmds;
	size_t _quad_cmd_count;

	V3F_C4B_T2F_Quad& getQuad();
	void flushQuad();

	//
	// for visible
	//
	float _min_x;
	float _min_y;
	float _max_x;
	float _max_y;
	bool _draw_visible_rect;

	void addQuadVisibleRect();

	//
	// for socket
	//
	struct SocketInfo;

	class CC_DLL BinderNode : public Node
	{
	protected:
		BinderNode() : _socket(nullptr) {}
		virtual ~BinderNode() {}

	public:
		static BinderNode * create(void)
		{
			BinderNode * ret = new BinderNode();
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

		void bind(SocketInfo* socket) { _socket = socket; if (!socket) setVisible(false); else setVisible(true); }

		SocketInfo* _socket;

		virtual const Mat4& getNodeToParentTransform() const
		{
			if (!_socket) return Mat4::IDENTITY;
			return _socket->_tm;
		}
	};

	struct SocketBinder
	{
		SocketBinder() : _frame(0.0f) {}
		~SocketBinder() {}

		std::shared_ptr<azModel::AzDataDictionary> _azddic;
		azModel::AzID _project_id;
		azModel::AzDataTrip _data_trip;

		const azVisual::VisualGroup* _visual_group;
		const azVisual::Visual* _visual;
		float _frame;
		float _begin;
		float _end;
	};
	typedef std::map< const azVisual::Socket*, SocketBinder* > TYPE_SOCKET_BINDER_LIST;
	TYPE_SOCKET_BINDER_LIST _socket_binders;

	typedef std::map< const azVisual::Socket*, BinderNode* > TYPE_NODE_BINDER_LIST;
	TYPE_NODE_BINDER_LIST _node_binders;

	struct SocketInfo
	{
		SocketInfo() : _socket(nullptr) {}
		~SocketInfo() {}

		const azVisual::Socket* _socket;
		std::string _reference_index;
		Mat4 _tm;
	};
	typedef std::vector< SocketInfo* > TYPE_SOCKET_INFO_LIST;
	TYPE_SOCKET_INFO_LIST _socket_infos;
	size_t _socket_info_count;
	bool _draw_sockets;

	void addQuadSocketInfo();

protected:
	//
	// for event shape
	//
	struct ShapeInfo
	{
		ShapeInfo() : _shape(nullptr) {}
		~ShapeInfo() {}

		const azVisual::EventShape* _shape;

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
	typedef std::vector< ShapeInfo* > TYPE_SHAPE_INFO_LIST;
	TYPE_SHAPE_INFO_LIST _shape_infos;
	size_t _shape_info_count;
	bool _draw_shapes;

	void addQuadShapeInfo();

	typedef std::map< long long, int > TYPE_EVENT_SHAPE_ID_LIST;
	TYPE_EVENT_SHAPE_ID_LIST _event_shape_ids;

	typedef std::map < std::string, ValueMap > TYPE_EVENT_SHAPE_IDS_CACHE;
	static TYPE_EVENT_SHAPE_IDS_CACHE s_event_shape_ids_cache;

	//
	// for sprite substitutions
	//
	typedef std::map<std::string, std::string> TYPE_SPRITE_SUBSTITUTIONS;
	TYPE_SPRITE_SUBSTITUTIONS _sprite_substitutions;

	//
	// for script
	//
	int _loopScriptHandler;

private:
	CC_DISALLOW_COPY_AND_ASSIGN(AzVisual);
};

NS_CC_END

#endif // __VISUAL_NODE_CCAZVISUAL_H__
