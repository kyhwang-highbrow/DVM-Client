#include <string.h>
#include <algorithm>
#include "CCAzVRP.h"


// external

extern std::unordered_map<std::string, std::string>  g_luaType;

using namespace std;

#if defined(_WINDOWS)
#define VRP_INLINE
#else
#define VRP_INLINE inline
#endif


struct VRP {
	unsigned int _type;
	unsigned int _varsion;
	unsigned int _visuals_offset;
	unsigned int _sprites_offset;
	unsigned int _sockets_offset;
	unsigned int _event_shapes_offset;
	unsigned int _fonts_offset;
	unsigned int _plists_offset;

	typedef struct KEY {
		unsigned short _frame;
		unsigned char _flags_sbvh__blend_mode;
		unsigned char _ref_index;
		float _x;
		float _y;
		float _offset_x;
		float _offset_y;
		float _rotate_z;
		float _scale_x;
		float _scale_y;
		unsigned char _color_r;
		unsigned char _color_g;
		unsigned char _color_b;
		unsigned char _alpha;

		VRP_INLINE unsigned char getBlendMode() const { return _flags_sbvh__blend_mode & 0x0f; }
		VRP_INLINE bool isFlipH() const { return (_flags_sbvh__blend_mode & 0x10) != 0; }
		VRP_INLINE bool isFlipV() const { return (_flags_sbvh__blend_mode & 0x20) != 0; }
		VRP_INLINE bool isBlank() const { return (_flags_sbvh__blend_mode & 0x40) != 0; }
		VRP_INLINE bool isCircle() const { return (_flags_sbvh__blend_mode & 0x80) != 0; }
		VRP_INLINE bool isBox() const { return (_flags_sbvh__blend_mode & 0x80) == 0; }
	};
	enum class REF_TYPE
	{
		VISUAL,
		SPRITE,
		SOCKET,
		EVENT_SHAPE,
	};
	typedef struct VISUAL;
	typedef struct LAYER {
		unsigned int _reference_type_and_offest;
		unsigned short _begin;
		unsigned short _end;
		KEY _keys[2];

		VRP_INLINE REF_TYPE getReferenceType() const
		{
			if ((_reference_type_and_offest & 0x80000000) == 0) return REF_TYPE::VISUAL;
			return (REF_TYPE)((_reference_type_and_offest & 0x7fff0000) >> 16);
		}
		VRP_INLINE VISUAL* getVisual(const VRP* vrp) const
		{
			return (VISUAL*)(((const char*)vrp) + _reference_type_and_offest);
		}
		VRP_INLINE int getIndex() const
		{
			return _reference_type_and_offest & 0xffff;
		}
		VRP_INLINE int begin() const { return _begin; }
		VRP_INLINE int end() const { return _end; }
		bool get(KEY& out_key, float frame, bool repeat) const
		{
			int iframe = frame;
			if (iframe < _begin) return false;
			if (iframe > _end) return false;

			if (_begin == _end)
			{
				out_key = _keys[0];
				return true;
			}
			
			const KEY* pick_key = _keys;
			while (pick_key->_frame < frame)
			{
				if (pick_key->_frame == _end) // 마지막 키에 데 대한 처리
				{
					out_key = *pick_key;
					return true;
				}
				++pick_key;
			}

			float pick_frame = pick_key->_frame;

			if (pick_frame == frame)
			{
				out_key = *pick_key;
				return true;
			}

			if (pick_key == _keys) return false;

			auto prev_key = pick_key;
			--prev_key;

			float prev_frame = prev_key->_frame;
			float bias = (frame - prev_frame) / (pick_frame - prev_frame);
			interpolate(out_key, bias, *prev_key, *pick_key);

			return true;
		}
		void interpolate(KEY& key, float bias, const KEY& begin, const KEY& end) const
		{
			float inv_bias = 1.0f - bias;

			key._x = ((begin._x * inv_bias) + (end._x * bias));
			key._y = ((begin._y * inv_bias) + (end._y * bias));
			key._scale_x = ((begin._scale_x * inv_bias) + (end._scale_x * bias));
			key._scale_y = ((begin._scale_y * inv_bias) + (end._scale_y * bias));
			key._offset_x = ((begin._offset_x * inv_bias) + (end._offset_x * bias));
			key._offset_y = ((begin._offset_y * inv_bias) + (end._offset_y * bias));
			key._rotate_z = ((begin._rotate_z * inv_bias) + (end._rotate_z * bias));
			key._color_r = (unsigned char)((begin._color_r * inv_bias) + (end._color_r * bias));
			key._color_g = (unsigned char)((begin._color_g * inv_bias) + (end._color_g * bias));
			key._color_b = (unsigned char)((begin._color_b * inv_bias) + (end._color_b * bias));
			key._alpha = (unsigned char)((begin._alpha * inv_bias) + (end._alpha * bias));

			key._flags_sbvh__blend_mode = begin._flags_sbvh__blend_mode;
			key._ref_index = begin._ref_index;
		}
	};
	typedef struct VISUAL {
		unsigned int _group_name_offset;
		unsigned int _name_offset;
		float _fps;
		unsigned short _begin;
		unsigned short _end;
		int _count;
		unsigned int _layer_offset[2];

		VRP_INLINE float fps() const { return _fps; }
		VRP_INLINE int begin() const { return _begin; }
		VRP_INLINE int end() const { return _end; }
		VRP_INLINE int layerCount() const { return _count; }
		VRP_INLINE const char* getGroupName(const VRP* vrp) const { if (_group_name_offset) return ((const char*)vrp) + _group_name_offset; return nullptr; }
		VRP_INLINE const char* getName(const VRP* vrp) const { if (_name_offset) return ((const char*)vrp) + _name_offset; return nullptr; }
		VRP_INLINE LAYER* get(const VRP* vrp, int index) const { if (index >= 0 && index < _count && _layer_offset[index]) return (LAYER*)(((const char*)vrp) + _layer_offset[index]); return nullptr; }
	};
	typedef struct VISUALS {
		int _count;
		unsigned int _visual_offset[2];

		VRP_INLINE VISUAL* getVisual(const VRP* vrp, const std::string& visual_group_name, const std::string& visual_name, int& visual_index) const
		{
			for (auto i = 0; i < _count; ++i)
			{
				if (!_visual_offset[i]) continue;
				auto visual = (VISUAL*)(((const char*)vrp) + _visual_offset[i]);

//				CCLOG("visual group:name [%s : %s]", visual->getGroupName(vrp), visual->getName(vrp));

				if (visual_group_name != visual->getGroupName(vrp)) continue;
				if (visual_name != visual->getName(vrp)) continue;

				visual_index = i;

				return visual;
			}
			return nullptr;
		}
		VRP_INLINE VISUAL* getVisual(const VRP* vrp, const std::string& visual_group_name, std::string& visual_name, int& visual_index) const
		{
			for (auto i = 0; i < _count; ++i)
			{
				if (!_visual_offset[i]) continue;
				auto visual = (VISUAL*)(((const char*)vrp) + _visual_offset[i]);

//				CCLOG("visual group:name [%s : %s]", visual->getGroupName(vrp), visual->getName(vrp));

				if (visual_group_name != visual->getGroupName(vrp)) continue;

				visual_name = visual->getName(vrp);
				visual_index = i;

				return visual;
			}
			return nullptr;
		}
		VRP_INLINE VISUAL* getVisual(const VRP* vrp, int index, std::string* visual_group_name, std::string* visual_name) const
		{
			if (index < 0 || index >= _count) return nullptr;

			auto visual = (VISUAL*)(((const char*)vrp) + _visual_offset[index]);
			if (!visual) return nullptr;

			if (visual_group_name) *visual_group_name = visual->getGroupName(vrp);
			if (visual_name) *visual_name = visual->getName(vrp);

			return visual;
		}
	};
	VRP_INLINE VISUAL* getVisual(const std::string& visual_group_name, const std::string& visual_name, int& visual_index) const
	{
		if (!_visuals_offset) return nullptr;

		auto visuals = (VISUALS*)(((const char*)this) + _visuals_offset);
		if (!visuals) return nullptr;

		return visuals->getVisual(this, visual_group_name, visual_name, visual_index);
	}
	VRP_INLINE VISUAL* getVisual(const std::string& visual_group_name, std::string& visual_name, int& visual_index) const
	{
		if (!_visuals_offset) return nullptr;

		auto visuals = (VISUALS*)(((const char*)this) + _visuals_offset);
		if (!visuals) return nullptr;

		return visuals->getVisual(this, visual_group_name, visual_name, visual_index);
	}
	VRP_INLINE VISUAL* getVisual(int index, std::string* visual_group_name, std::string* visual_name) const
	{
		if (!_visuals_offset) return nullptr;

		auto visuals = (VISUALS*)(((const char*)this) + _visuals_offset);
		if (!visuals) return nullptr;

		return visuals->getVisual(this, index, visual_group_name, visual_name);
	}
	VRP_INLINE int getVisualCount() const
	{
		if (!_visuals_offset) return 0;

		auto visuals = (VISUALS*)(((const char*)this) + _visuals_offset);
		if (!visuals) return 0;

		return visuals->_count;
	}
	typedef struct SPRITES {
		int _count;
		unsigned int _name_offset[2];
	};
	VRP_INLINE int getSpriteCount() const
	{
		if (!_sprites_offset) return 0;

		auto sprites = (SPRITES*)(((const char*)this) + _sprites_offset);
		if (!sprites) return 0;

		return sprites->_count;
	}
	VRP_INLINE const char* getSpriteName(int index) const
	{
		if (index < 0) return "";
		if (!_sprites_offset) return "";

		auto sprites = (SPRITES*)(((const char*)this) + _sprites_offset);
		if (!sprites) return "";

		if (index >= sprites->_count) return "";

		return (((const char*)this) + sprites->_name_offset[index]);
	}
	VRP_INLINE int getSpriteIndex(const std::string& name) const
	{
		if (!_sprites_offset) return -1;

		auto sprites = (SPRITES*)(((const char*)this) + _sprites_offset);
		if (!sprites) return -1;

		for (auto i = 0; i < sprites->_count; ++i)
		{
			if (name != (((const char*)this) + sprites->_name_offset[i])) continue;

			return i;
		}
		return -1;
	}
	typedef struct SOCKETS {
		int _count;
		unsigned int _name_offset[2];
	};
	VRP_INLINE int getSocketCount() const
	{
		if (!_sockets_offset) return 0;

		auto sockets = (SOCKETS*)(((const char*)this) + _sockets_offset);
		if (!sockets) return 0;

		return sockets->_count;
	}
	VRP_INLINE const char* getSocketName(int index) const
	{
		if (index < 0) return "";
		if (!_sockets_offset) return "";

		auto sockets = (SOCKETS*)(((const char*)this) + _sockets_offset);
		if (!sockets) return "";

		if (index >= sockets->_count) return "";

		return (((const char*)this) + sockets->_name_offset[index]);
	}
	VRP_INLINE int getSocketIndex(const std::string& name) const
	{
		if (!_sockets_offset) return -1;

		auto sockets = (SOCKETS*)(((const char*)this) + _sockets_offset);
		if (!sockets) return -1;

		for (auto i = 0; i < sockets->_count; ++i)
		{
			if (name != (((const char*)this) + sockets->_name_offset[i])) continue;

			return i;
		}
		return -1;
	}
	typedef struct EVENT_SHAPES {
		int _count;
		unsigned int _name_offset[2];
	};
	VRP_INLINE int getEventShapeCount() const
	{
		if (!_event_shapes_offset) return 0;

		auto event_shapes = (EVENT_SHAPES*)(((const char*)this) + _event_shapes_offset);
		if (!event_shapes) return 0;

		return event_shapes->_count;
	}
	VRP_INLINE const char* getEventShapeName(int index) const
	{
		if (index < 0) return "";
		if (!_event_shapes_offset) return "";

		auto event_shapes = (EVENT_SHAPES*)(((const char*)this) + _event_shapes_offset);
		if (!event_shapes) return "";

		if (index >= event_shapes->_count) return "";

		return (((const char*)this) + event_shapes->_name_offset[index]);
	}
	VRP_INLINE int getEventShapeIndex(const std::string& name) const
	{
		if (!_event_shapes_offset) return -1;

		auto event_shapes = (EVENT_SHAPES*)(((const char*)this) + _event_shapes_offset);
		if (!event_shapes) return -1;

		for (auto i = 0; i < event_shapes->_count; ++i)
		{
			if (name != (((const char*)this) + event_shapes->_name_offset[i])) continue;

			return i;
		}
		return -1;
	}
	typedef struct PLISTS {
		int _count;
		unsigned int _name_offset[2];
	};
	VRP_INLINE int getPlistCount() const
	{
		if (!_plists_offset) return 0;

		auto plists = (PLISTS*)(((const char*)this) + _plists_offset);
		if (!plists) return 0;

		return plists->_count;
	}
	VRP_INLINE const char* getPlistName(int index) const
	{
		if (index < 0) return "";
		if (!_plists_offset) return "";

		auto plists = (PLISTS*)(((const char*)this) + _plists_offset);
		if (!plists) return "";

		if (index >= plists->_count) return "";

		return (((const char*)this) + plists->_name_offset[index]);
	}


	class TM
	{
	public:
		static const float PI;

		TM() : _m11(1.0f), _m12(0.0f), _m21(0.0f), _m22(1.0f), _m31(0.0f), _m32(0.0f), _scale(1.0f) {}
		TM(const KEY& key, bool invert = false)
		{
			if (invert)
			{
				float radiran = (float)(key._rotate_z*PI*2.0f);
				float c = cos(-radiran);
				float s = sin(-radiran);
				float cx = key._offset_x * -1;
				float cy = key._offset_y * -1;
				float sx = 1.0f / (key._scale_x * (key.isFlipH() ? -1.0f : 1.0f));
				float sy = 1.0f / (key._scale_y * (key.isFlipV() ? -1.0f : 1.0f));
				float tx = -key._x;
				float ty = -key._y;

				_m11 = sx *  c;
				_m12 = sy *  s;
				_m21 = sx * -s;
				_m22 = sy *  c;
				_m31 = (tx * c + ty * -s) * sx + cx;
				_m32 = (tx * s + ty *  c) * sy + cy;

				_scale = 1.0f / key._scale_x;

			}
			else
			{
				float radiran = (float)(key._rotate_z*PI*2.0f);
				float c = cos(radiran);
				float s = sin(radiran);
				float cx = key._offset_x;
				float cy = key._offset_y;
				float sx = key._scale_x * (key.isFlipH() ? -1.0f : 1.0f);
				float sy = key._scale_y * (key.isFlipV() ? -1.0f : 1.0f);
				float tx = key._x;
				float ty = key._y;

				_m11 = sx *  c;
				_m12 = sx *  s;
				_m21 = sy * -s;
				_m22 = sy *  c;
				_m31 = (cx * sx * c + cy * sy * -s) + tx;
				_m32 = (cx * sx * s + cy * sy *  c) + ty;

				_scale = key._scale_x;
			}
		}

		VRP_INLINE TM& operator = (const TM& tm)
		{
			_m11 = tm._m11; _m12 = tm._m12;
			_m21 = tm._m21; _m22 = tm._m22;
			_m31 = tm._m31; _m32 = tm._m32;

			_scale = tm._scale;

			return *this;
		}
		VRP_INLINE TM& mul(const TM& tm)
		{
			TM tmp(*this);
			_m11 = tmp._m11*tm._m11 + tmp._m12*tm._m21;
			_m12 = tmp._m11*tm._m12 + tmp._m12*tm._m22;
			_m21 = tmp._m21*tm._m11 + tmp._m22*tm._m21;
			_m22 = tmp._m21*tm._m12 + tmp._m22*tm._m22;
			_m31 = tmp._m31*tm._m11 + tmp._m32*tm._m21 + tm._m31;
			_m32 = tmp._m31*tm._m12 + tmp._m32*tm._m22 + tm._m32;
			_scale *= tm._scale;

			return *this;
		}
		VRP_INLINE void mul(float& x, float& y) const
		{
			float tx = _m11*x + _m21*y + _m31;
			float ty = _m12*x + _m22*y + _m32;
			x = tx;
			y = ty;
		}

		VRP_INLINE float getTranslateX() const { return _m31; }
		VRP_INLINE float getTranslateY() const { return _m32; }
		VRP_INLINE float getScale() const { return _scale; }

		float _m11, _m12;
		float _m21, _m22;
		float _m31, _m32;

		float _scale;
	};
	class BLEND
	{
	public:
		enum MODE
		{
			NONE,
			ALPHA,
			SCREEN,
			MULTI,
			ADD,
			SUB,
			LIGHTEN,
		};

		BLEND() : _color_r(255), _color_g(255), _color_b(255), _alpha(255), _blend_mode(ALPHA) {}
		BLEND(unsigned char r, unsigned char g, unsigned char b, unsigned char a) : _color_r(r), _color_g(g), _color_b(b), _alpha(a), _blend_mode(ALPHA) {}
		BLEND(const KEY& key) : _color_r(key._color_r), _color_g(key._color_g), _color_b(key._color_b), _alpha(key._alpha), _blend_mode((MODE)key.getBlendMode()) {}
		BLEND(const BLEND& blend) : _color_r(blend._color_r), _color_g(blend._color_g), _color_b(blend._color_b), _alpha(blend._alpha), _blend_mode(blend._blend_mode) {}

		VRP_INLINE BLEND& operator = (const BLEND& blend)
		{
			_color_r = blend._color_r;
			_color_g = blend._color_g;
			_color_b = blend._color_b;
			_alpha = blend._alpha;
			_blend_mode = blend._blend_mode;

			return *this;
		}
		VRP_INLINE BLEND& mul(const BLEND& blend)
		{
			_color_r = (((unsigned int)_color_r + 1) * blend._color_r) >> 8;
			_color_g = (((unsigned int)_color_g + 1) * blend._color_g) >> 8;
			_color_b = (((unsigned int)_color_b + 1) * blend._color_b) >> 8;
			_alpha = (((unsigned int)_alpha + 1) * blend._alpha) >> 8;

			if (blend._blend_mode > 1)
			{
				_blend_mode = blend._blend_mode;
			}

			return *this;
		}

		unsigned char _color_r;
		unsigned char _color_g;
		unsigned char _color_b;
		unsigned char _alpha;

		MODE _blend_mode;
	};
};


const float VRP::TM::PI = 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651f;



NS_CC_BEGIN

#if CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__ARGS__) (ceil(__ARGS__))
#endif


struct SPRITE_INFO
{
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
typedef std::vector< SPRITE_INFO > TYPE_SPRITE_LIST;

typedef std::vector< AzVRP* > TYPE_SOCKET_BINDER_LIST;

class CC_DLL AzVRP_IMPL;
class QuadMaker;

static void makeQuad(QuadMaker& maker, AzVRP* vrp, VRP::TM& tm, VRP::BLEND& blend, int ref_index);

class QuadMaker
{
public:
	QuadMaker();
	~QuadMaker();

	void init();

	inline void setRepeat(bool v) { _repeat = v; }

	void begin(TYPE_SPRITE_LIST& sprite_pool, TYPE_SOCKET_BINDER_LIST& socket_binders, const Mat4& transform, float globalZOrder, bool check_visible_rect);
	void beginSocket(TYPE_SPRITE_LIST& sprite_pool, TYPE_SOCKET_BINDER_LIST& socket_binders);
	void endSocket();
	void make(const VRP* vrp, const VRP::VISUAL* visual, float frame);
	void make(const VRP* vrp, const VRP::VISUAL* visual, float frame, unsigned char r, unsigned char g, unsigned char b, unsigned char a);
	void make(const VRP* vrp, const VRP::VISUAL* visual, float frame, VRP::TM& tm, VRP::BLEND& blend);
	void make(const AzVRP::EventShape* shape_infos, int shape_info_count);
	void make(const AzVRP::Socket* socket_infos, int socket_info_count);
	void flush();

	void updateTransform(const Mat4& transform);

	void add(Renderer *renderer);

    void setCustomShader(GLProgramState *customShader);

    bool isIgnoreLowEndMode() { return m_bIgnoreLowEndMode; }
    void setIgnoreLowEndMode(bool ignore) { m_bIgnoreLowEndMode = ignore; }

protected:
	void make(const VRP::VISUAL* visual, float frame, VRP::TM& tm, VRP::BLEND& blend);
	void make(int sprite_index, VRP::TM& tm, VRP::BLEND& blend);
	void make(int socket_index, VRP::TM& tm, VRP::BLEND& blend, int ref_index);
	void makeBox(const AzVRP::EventShape& shape_info);
	void makeCircle(const AzVRP::EventShape& shape_info);

	V3F_C4B_T2F_Quad& getQuad();

private:
	const static size_t _quads_alloc_unit = 8;
	cocos2d::V3F_C4B_T2F_Quad* _quads;
	size_t _quads_max;
	size_t _quads_count;
	size_t _flushed_quads_count;

	GLuint _current_texture_name;
	int _current_blend_mode;
	GLProgramState* _current_shader_program_state;
	GLProgramState* _texture_program_state;
	GLProgramState* _color_program_state;

	typedef std::vector< QuadCommand* > TYPE_QUAD_CMD_LIST;
	TYPE_QUAD_CMD_LIST _quad_cmds;
	size_t _quad_cmd_count;

	const VRP* _vrp;
	const VRP* _vrp_backup;
	TYPE_SPRITE_LIST* _sprite_pool;
	TYPE_SPRITE_LIST* _sprite_pool_backup;
	TYPE_SOCKET_BINDER_LIST* _socket_binders;
	TYPE_SOCKET_BINDER_LIST* _socket_binders_backup;
	float _globalZOrder;
	const Mat4* _transform;

	bool _repeat;

	//
	// for visible
	//
	float _min_x;
	float _min_y;
	float _max_x;
	float _max_y;
	bool _check_visible_rect;

    bool m_bIgnoreLowEndMode;

public:
	inline cocos2d::Rect getValidRect() const { return cocos2d::Rect(_min_x, _min_y, _max_x - _min_x, _max_y - _min_y); }
};

QuadMaker::QuadMaker()
: _quads(nullptr)
, _quads_max(0)
, _quad_cmd_count(0)
, _texture_program_state(nullptr)
, _color_program_state(nullptr)
, _repeat(true)
, _check_visible_rect(false)
, m_bIgnoreLowEndMode(false)
{
}
QuadMaker::~QuadMaker()
{
	if (_quads) free(_quads);
	_quads = nullptr;
	_quads_max = 0;

	for (auto* quad : _quad_cmds)
	{
		if (quad) delete quad;
	}
	_quad_cmds.clear();
}

void QuadMaker::init()
{
	_texture_program_state = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP);
	_color_program_state = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_COLOR_NO_MVP);
}

void QuadMaker::begin(TYPE_SPRITE_LIST& sprite_pool, TYPE_SOCKET_BINDER_LIST& socket_binders, const Mat4& transform, float globalZOrder, bool check_visible_rect)
{
	_sprite_pool = &sprite_pool;
	_socket_binders = &socket_binders;
	_transform = &transform;

	_quad_cmd_count = 0;
	_quads_count = 0;
	_flushed_quads_count = 0;
	_current_texture_name = -1;
	_current_shader_program_state = _texture_program_state;
	_globalZOrder = globalZOrder;
	_check_visible_rect = check_visible_rect;

	_min_x = FLT_MAX;
	_min_y = FLT_MAX;
	_max_x = -FLT_MAX;
	_max_y = -FLT_MAX;
}
void QuadMaker::beginSocket(TYPE_SPRITE_LIST& sprite_pool, TYPE_SOCKET_BINDER_LIST& socket_binders)
{
	_sprite_pool_backup = _sprite_pool;
	_socket_binders_backup = _socket_binders;
	_vrp_backup = _vrp;

	_sprite_pool = &sprite_pool;
	_socket_binders = &socket_binders;
}
void QuadMaker::endSocket()
{
	_sprite_pool = _sprite_pool_backup;
	_socket_binders = _socket_binders_backup;
	_vrp = _vrp_backup;
}
void QuadMaker::make(const VRP* vrp, const VRP::VISUAL* visual, float frame)
{
	_vrp = vrp;

	VRP::TM tm;
	VRP::BLEND blend;
	make(visual, frame, tm, blend);
}
void QuadMaker::make(const VRP* vrp, const VRP::VISUAL* visual, float frame, unsigned char r, unsigned char g, unsigned char b, unsigned char a)
{
	_vrp = vrp;

	VRP::TM tm;
	VRP::BLEND blend(r, g, b, a);
	make(visual, frame, tm, blend);
}
void QuadMaker::make(const VRP* vrp, const VRP::VISUAL* visual, float frame, VRP::TM& tm, VRP::BLEND& blend)
{
	_vrp = vrp;

	make(visual, frame, tm, blend);
}
void QuadMaker::make(const VRP::VISUAL* visual, float frame, VRP::TM& tm, VRP::BLEND& blend)
{
	if (!visual) return;

	const VRP::VISUAL* sub_visual = nullptr;
	float sub_visual_frame;

	int layer_count = visual->layerCount();
	for (int i = 0; i < layer_count; ++i)
	{
		auto layer = visual->get(_vrp, i);

		VRP::KEY key;
		if (!layer->get(key, frame, _repeat)) continue;

		VRP::TM curr_tm(key);
		curr_tm.mul(tm);

		VRP::BLEND curr_blend(key);
		curr_blend.mul(blend);

		switch (layer->getReferenceType())
		{
		case VRP::REF_TYPE::VISUAL:
			sub_visual = layer->getVisual(_vrp);
			sub_visual_frame = (layer->_end == layer->_begin) ? 0 : (frame - layer->_begin) * sub_visual->_end / (layer->_end - layer->_begin);

			if (sub_visual_frame < 0) sub_visual_frame = 0;
			if (sub_visual_frame > sub_visual->_end) sub_visual_frame = sub_visual->_end;

			make(sub_visual, sub_visual_frame, curr_tm, curr_blend);
			break;
        case VRP::REF_TYPE::SPRITE:
            {
            if ((m_bIgnoreLowEndMode == true) || !AzVRP::isLowEndMode() || (curr_blend._blend_mode == VRP::BLEND::ALPHA))
                {
                    make(layer->getIndex(), curr_tm, curr_blend);
                }
            }break;
		case VRP::REF_TYPE::SOCKET: make(layer->getIndex(), curr_tm, curr_blend, key._ref_index); break;
		case VRP::REF_TYPE::EVENT_SHAPE: break;
		default: break;
		}
	}
}
void QuadMaker::make(int sprite_index, VRP::TM& tm, VRP::BLEND& blend)
{
	const auto& sprite = _sprite_pool->at(sprite_index);

	auto texture = sprite._texture;
	if (!texture) return;

	float x0 = sprite._l, y0 = sprite._t;
	float x1 = sprite._l, y1 = sprite._b;
	float x2 = sprite._r, y2 = sprite._t;
	float x3 = sprite._r, y3 = sprite._b;

	tm.mul(x0, y0);
	tm.mul(x1, y1);
	tm.mul(x2, y2);
	tm.mul(x3, y3);

	if (_check_visible_rect)
	{
		_min_x = std::min(_min_x, x0);
		_min_x = std::min(_min_x, x1);
		_min_x = std::min(_min_x, x2);
		_min_x = std::min(_min_x, x3);

		_min_y = std::min(_min_y, y0);
		_min_y = std::min(_min_y, y1);
		_min_y = std::min(_min_y, y2);
		_min_y = std::min(_min_y, y3);

		_max_x = std::max(_max_x, x0);
		_max_x = std::max(_max_x, x1);
		_max_x = std::max(_max_x, x2);
		_max_x = std::max(_max_x, x3);

		_max_y = std::max(_max_y, y0);
		_max_y = std::max(_max_y, y1);
		_max_y = std::max(_max_y, y2);
		_max_y = std::max(_max_y, y3);
	}

	auto current_texture_name = texture->getName();
	auto current_blend_mode = blend._blend_mode;
	auto current_shader_program_state = _texture_program_state;
	if (_current_texture_name != current_texture_name ||
		_current_blend_mode != current_blend_mode ||
		_current_shader_program_state != current_shader_program_state)
	{
		flush();

		_current_texture_name = current_texture_name;
		_current_blend_mode = current_blend_mode;
		_current_shader_program_state = current_shader_program_state;
	}

	Color4B color(blend._color_r, blend._color_g, blend._color_b, blend._alpha);
	if (_current_blend_mode > VRP::BLEND::ALPHA)
	{
		color.r = ((int)color.r * color.a) >> 8;
		color.g = ((int)color.g * color.a) >> 8;
		color.b = ((int)color.b * color.a) >> 8;
	}

	V3F_C4B_T2F_Quad& quad = getQuad();
	quad.tl.vertices = Vertex3F(x0, y0, 0);
	quad.bl.vertices = Vertex3F(x1, y1, 0);
	quad.tr.vertices = Vertex3F(x2, y2, 0);
	quad.br.vertices = Vertex3F(x3, y3, 0);
	quad.tl.colors = color;
	quad.bl.colors = color;
	quad.tr.colors = color;
	quad.br.colors = color;
	quad.tl.texCoords = sprite._uv_tl;
	quad.bl.texCoords = sprite._uv_bl;
	quad.tr.texCoords = sprite._uv_tr;
	quad.br.texCoords = sprite._uv_br;
}
void QuadMaker::make(int socket_index, VRP::TM& tm, VRP::BLEND& blend, int ref_index)
{
	if (_socket_binders->size() <= socket_index) return;

	auto vrp = _socket_binders->at(socket_index);
	if (!vrp) return;

	makeQuad(*this, vrp, tm, blend, ref_index);
}
void QuadMaker::make(const AzVRP::EventShape* shape_infos, int shape_info_count)
{
	for (int i = 0; i < shape_info_count; ++i)
	{
		auto& shape_info = shape_infos[i];
		switch (shape_info._type)
		{
		case AzVRP::EventShape::BOX: makeBox(shape_info); break;
		case AzVRP::EventShape::CIRCLE: makeCircle(shape_info); break;
		}
	}
}
void QuadMaker::makeBox(const AzVRP::EventShape& shape_info)
{
	auto& box = shape_info._s._box;

	auto current_shader_program_state = _color_program_state;
	if (_current_blend_mode != VRP::BLEND::ALPHA ||
		_current_shader_program_state != current_shader_program_state)
	{
		flush();

		_current_texture_name = 0;
		_current_blend_mode = VRP::BLEND::ALPHA;
		_current_shader_program_state = current_shader_program_state;
	}

	static Color4B color(0x10, 0xff, 0x30, 0x60);
	V3F_C4B_T2F_Quad& quad = getQuad();
	quad.tl.vertices = Vertex3F(box.x + box.u_x + box.v_x, box.y + box.u_y + box.v_y, 0);
	quad.bl.vertices = Vertex3F(box.x + box.u_x - box.v_x, box.y + box.u_y - box.v_y, 0);
	quad.tr.vertices = Vertex3F(box.x - box.u_x + box.v_x, box.y - box.u_y + box.v_y, 0);
	quad.br.vertices = Vertex3F(box.x - box.u_x - box.v_x, box.y - box.u_y - box.v_y, 0);
	quad.tl.colors = color;
	quad.bl.colors = color;
	quad.tr.colors = color;
	quad.br.colors = color;
}
void QuadMaker::makeCircle(const AzVRP::EventShape& shape_info)
{
	auto& circle = shape_info._s._circle;

	auto current_shader_program_state = _color_program_state;
	if (_current_blend_mode != VRP::BLEND::ALPHA ||
		_current_shader_program_state != current_shader_program_state)
	{
		flush();

		_current_texture_name = 0;
		_current_blend_mode = VRP::BLEND::ALPHA;
		_current_shader_program_state = current_shader_program_state;
	}

	int segments = 20;
	const float coef = 2.0f * (float)M_PI / segments;
	GLfloat prev_arc_x = circle.radius + circle.x;
	GLfloat prev_arc_y = circle.y;
	static Color4B color(0x10, 0xff, 0x30, 0x60);
	for (unsigned int i = 0; i <= segments; i++) {
		float rads = i*coef;
		GLfloat arc_x = circle.radius * cosf(rads) + circle.x;
		GLfloat arc_y = circle.radius * sinf(rads) + circle.y;

		V3F_C4B_T2F_Quad& quad = getQuad();
		quad.tl.vertices = Vertex3F(circle.x, circle.y, 0);
		quad.bl.vertices = Vertex3F(prev_arc_x, prev_arc_y, 0);
		quad.tr.vertices = Vertex3F(arc_x, arc_y, 0);
		quad.br.vertices = Vertex3F(arc_x, arc_y, 0);
		quad.tl.colors = color;
		quad.bl.colors = color;
		quad.tr.colors = color;
		quad.br.colors = color;

		prev_arc_x = arc_x;
		prev_arc_y = arc_y;
	}
}
void QuadMaker::make(const AzVRP::Socket* socket_infos, int socket_info_count)
{
	auto current_shader_program_state = _color_program_state;
	for (int i = 0; i < socket_info_count; ++i)
	{
		Vec3 translation;
		socket_infos[i]._tm.getTranslation(&translation);

		float x0 = translation.x + 0.0f, y0 = translation.y + 0.0f;
		float x1 = translation.x - 5.0f, y1 = translation.y + 10.0f;
		float x2 = translation.x + 0.0f, y2 = translation.y + 0.0f;
		float x3 = translation.x + 5.0f, y3 = translation.y + 10.0f;

		if (_current_blend_mode != VRP::BLEND::ALPHA ||
			_current_shader_program_state != current_shader_program_state)
		{
			flush();

			_current_blend_mode = VRP::BLEND::ALPHA;
			_current_shader_program_state = current_shader_program_state;
		}

		static Color4B color(0xff, 0x10, 0x30, 0x60);
		V3F_C4B_T2F_Quad& quad = getQuad();
		quad.tl.vertices = Vertex3F(x0, y0, 0);
		quad.bl.vertices = Vertex3F(x1, y1, 0);
		quad.tr.vertices = Vertex3F(x2, y2, 0);
		quad.br.vertices = Vertex3F(x3, y3, 0);
		quad.tl.colors = color;
		quad.bl.colors = color;
		quad.tr.colors = color;
		quad.br.colors = color;
	}
}
V3F_C4B_T2F_Quad& QuadMaker::getQuad()
{
	if (_quads_count >= _quads_max)
	{
		int new_quads_max = _quads_max + _quads_alloc_unit;
		auto new_quads = (V3F_C4B_T2F_Quad*)realloc(_quads, new_quads_max * sizeof(V3F_C4B_T2F_Quad));
		if (!new_quads)
		{
			CCLOG("QuadMaker failed - realloc for quad (%d -> %d)", _quads_max, new_quads_max);
			return _quads[_quads_count - 1];
		}
		
		if (_quads != new_quads)
		{
			for (auto quad_cmd : _quad_cmds)
			{
				quad_cmd->setQuads(new_quads + (quad_cmd->getQuads() - _quads));
			}
		}

		_quads = new_quads;
		_quads_max = new_quads_max;
	}
	return _quads[_quads_count++];
}
void QuadMaker::flush()
{
	if (_quads_count == 0) return;

	QuadCommand* quad_cmd = nullptr;
	if (_quad_cmd_count < _quad_cmds.size())
	{
		quad_cmd = _quad_cmds[_quad_cmd_count];
	}
	else
	{
		quad_cmd = new QuadCommand;
		_quad_cmds.resize(_quad_cmd_count + 1);
		_quad_cmds[_quad_cmd_count] = quad_cmd;
	}
	++_quad_cmd_count;

	BlendFunc blend_func;
	switch (_current_blend_mode)
	{
	case VRP::BLEND::NONE:		blend_func.src = GL_ONE;       blend_func.dst = GL_ZERO;                break;
	default:
	case VRP::BLEND::ALPHA:		blend_func.src = GL_SRC_ALPHA; blend_func.dst = GL_ONE_MINUS_SRC_ALPHA; break;
	case VRP::BLEND::SCREEN:	blend_func.src = GL_ONE;       blend_func.dst = GL_ONE_MINUS_SRC_COLOR; break;
	case VRP::BLEND::MULTI:		blend_func.src = GL_DST_COLOR; blend_func.dst = GL_ONE_MINUS_SRC_ALPHA; break;
	case VRP::BLEND::ADD:		blend_func.src = GL_SRC_ALPHA; blend_func.dst = GL_ONE;                 break;
	case VRP::BLEND::SUB:		blend_func.src = GL_ZERO;      blend_func.dst = GL_ONE_MINUS_SRC_COLOR; break;
	case VRP::BLEND::LIGHTEN:	blend_func.src = GL_ZERO;      blend_func.dst = GL_ONE_MINUS_SRC_COLOR; break;
//	case azModel::OVERDRAW:
	}

	quad_cmd->init(_globalZOrder, _current_texture_name, _current_shader_program_state, blend_func, _quads + _flushed_quads_count, _quads_count - _flushed_quads_count, *_transform);

	_flushed_quads_count = _quads_count;
}

void QuadMaker::updateTransform(const Mat4& transform)
{
	for (int i = 0; i < _quad_cmd_count; ++i)
	{
		_quad_cmds[i]->init(
			_quad_cmds[i]->getGlobalOrder(),
			_quad_cmds[i]->getTextureID(),
			_quad_cmds[i]->getGLProgramState(),
			_quad_cmds[i]->getBlendType(),
			_quad_cmds[i]->getQuads(),
			_quad_cmds[i]->getQuadCount(),
			transform);
	}
}
void QuadMaker::add(Renderer *renderer)
{
	for (int i = 0; i < _quad_cmd_count; ++i)
	{
		renderer->addCommand(_quad_cmds[i]);
	}
}

void QuadMaker::setCustomShader(GLProgramState *customShader)
{
    if (!customShader)
        return;

    _texture_program_state = customShader;
}


class CC_DLL AzVRP_IMPL : public AzVRP
{
public:
	typedef std::map < std::string, std::shared_ptr< const VRP > > TYPE_VRP_CACHE;
	static TYPE_VRP_CACHE s_vrp_cache;
    static bool s_bLowEndMode;

	static void removeCache(const std::string& filename);
	static void removeCacheAll();
	static void removeUnusedCache();

    static bool isLowEndMode() { return s_bLowEndMode; }
    static void setLowEndMode(bool lowendmode) { s_bLowEndMode = lowendmode; }

    virtual bool isIgnoreLowEndMode() override { return _quad_maker.isIgnoreLowEndMode(); }
    virtual void setIgnoreLowEndMode(bool ignore) override { _quad_maker.setIgnoreLowEndMode(ignore); }

	AzVRP_IMPL();
	virtual ~AzVRP_IMPL();

	void clear();

	virtual bool init() override;
	virtual bool initWithFile(const std::string& filename) override;
	bool initWithData(const unsigned char* data, ssize_t dataLen);

	virtual bool setVisual(const std::string& visual_group_name, const std::string& visual_name) override;
	virtual bool setVisual(const std::string& visual_group_name) override;
	virtual bool setVisual(int visual_index) override;
	virtual void loadPlistFiles(const std::string& prefix) override;
	virtual void buildSprite(const std::string& prefix) override;
	virtual void releaseSprite() override;
	virtual bool buildEventShapeID(const std::string& plist) override;

	virtual void setRepeat(bool v) override { _repeat = v;  _quad_maker.setRepeat(v); }

	virtual std::string getVisualListLuaTable() override;
    virtual void getVisualList(const std::string& bind_token, std::list<std::string>& visual_list) override;

    virtual void setCustomShader(int customShaderType, float arg) override;
	virtual float getSocketPosX(const std::string& socket_name) override;
	virtual float getSocketPosY(const std::string& socket_name) override;

protected:
	std::shared_ptr< const VRP > _vrp;
	const VRP::VISUAL* _visual;

public:
	virtual void update(float deltaTime) override;
	virtual void draw(Renderer *renderer, const Mat4& transform, bool transformUpdated) override;

	void draw(QuadMaker& _quad_maker, VRP::TM& tm, VRP::BLEND& blend, int ref_index);

protected:
	QuadMaker _quad_maker;

	TYPE_SPRITE_LIST _sprite_pool;

	//
	// for event shape
	//
	virtual const EventShape* getEventShapeList() const override { return &(_shape_infos.at(0)); }
	virtual size_t getEventShapeCount() const override { return _shape_info_count; }
	virtual const char* getEventShapeName(int index) const override { if (!_vrp) return nullptr; return _vrp->getEventShapeName(index); }
	virtual int getEventShapeIndex(const std::string& name) const override { if (!_vrp) return -1; return _vrp->getEventShapeIndex(name); }
	virtual void buildPhysicBody() override;
	virtual void buildShapes(PhysicsBody* body) override;

	typedef std::vector< EventShape > TYPE_EVENT_SHAPE_LIST;
	TYPE_EVENT_SHAPE_LIST _shape_infos;
	size_t _shape_info_count;

	typedef std::vector< int > TYPE_EVENT_SHAPE_ID_LIST;
	TYPE_EVENT_SHAPE_ID_LIST _event_shape_ids;

	typedef std::map < std::string, ValueMap > TYPE_EVENT_SHAPE_IDS_CACHE;
	static TYPE_EVENT_SHAPE_IDS_CACHE s_event_shape_ids_cache;

public:
	virtual void initEventShapeList() override;
	virtual void queryEventShape(float frame) override;

protected:
	virtual void queryEventShape(const VRP::VISUAL* visual, float frame, VRP::TM& tm);
	virtual void queryEventShape(int event_shape_index, VRP::TM& tm, bool is_box);

	void addQuadShapeInfo();
	void addQuadBox(EventShape& shape_info);
	void addQuadCircle(EventShape& shape_info);

	//
	// for socket
	//
public:
	virtual bool bindVRP(const std::string& socket_name, AzVRP* vrp) override;

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

		void bind(Socket* socket) { _socket = socket; if (!socket) setVisible(false); else setVisible(true); }

		Socket* _socket;

		virtual const Mat4& getNodeToParentTransform() const
		{
			if (!_socket) return Mat4::IDENTITY;
			return _socket->_tm;
		}
	};

	virtual Node* getSocketNode(const std::string& socket_name) override;
    virtual void getSocketNodeList(std::list<std::string>& socket_node_list) override;

	virtual void clearSocketHandler() override;
	virtual void enableSocketHandler(const std::string& socket_name) override;

protected:
	TYPE_SOCKET_BINDER_LIST _socket_binders;

	typedef std::vector< BinderNode* > TYPE_NODE_BINDER_LIST;
	TYPE_NODE_BINDER_LIST _node_binders;

	virtual const Socket* getSocketList() const override { return &(_socket_infos.at(0)); }
	virtual size_t getSocketCount() const override { return _socket_info_count; }
	virtual const char* getSocketName(int index) const override { if (!_vrp) return nullptr; return _vrp->getSocketName(index); }
	virtual int getSocketIndex(const std::string& name) const override { if (!_vrp) return -1; return _vrp->getSocketIndex(name); }

	typedef std::vector< Socket > TYPE_SOCKET_INFO_LIST;
	TYPE_SOCKET_INFO_LIST _socket_infos;
	size_t _socket_info_count;

	unsigned int* _socket_event_mask;
	int _socket_event_mask_size;

	void updateSocket();
	void updateSocket(const VRP::VISUAL* visual, float frame, VRP::TM& tm);
	void updateSocket(int socket_index, VRP::TM& tm, int ref_index);

	void updateSocketEvent();
	void updateSocketEvent(const VRP::VISUAL* visual, float frame, VRP::TM& tm);
	void updateSocketEvent(int socket_index, float frame, VRP::TM& tm, int ref_index);

	void addQuadSocketInfo();


	bool _check_visible_rect;

public:
	virtual void SetCheckValidRect(bool v) override { _check_visible_rect = v; }
	virtual cocos2d::Rect getValidRect() const override { return _quad_maker.getValidRect(); }
};

AzVRP_IMPL::TYPE_VRP_CACHE AzVRP_IMPL::s_vrp_cache;
AzVRP_IMPL::TYPE_EVENT_SHAPE_IDS_CACHE AzVRP_IMPL::s_event_shape_ids_cache;
bool AzVRP_IMPL::s_bLowEndMode = false;


AzVRP* AzVRP::create(const std::string& filename)
{
	std::string typeName = typeid(cocos2d::AzVRP_IMPL).name(); // AzVRP_IMPL 객체를 루아에서 자식 객체 목록으로 전달 받기 위해 등록
	if (g_luaType.find(typeName) == g_luaType.end())
	{
		g_luaType[typeName] = "cc.AzVRP";
	}

	auto *vrp = new AzVRP_IMPL();
	if (vrp && vrp->initWithFile(filename))
	{
		vrp->autorelease();
		return vrp;
	}
	CC_SAFE_DELETE(vrp);
	return nullptr;
}
AzVRP* AzVRP::create()
{
	auto *vrp = new AzVRP_IMPL();
	if (vrp && vrp->init())
	{
		vrp->autorelease();
		return vrp;
	}
	CC_SAFE_DELETE(vrp);
	return nullptr;
}
bool AzVRP::setFile(const std::string& filename)
{
    return initWithFile(filename);
}
void AzVRP::removeCache(const std::string& filename)
{
	AzVRP_IMPL::removeCache(filename);
}
void AzVRP::removeCacheAll()
{
	AzVRP_IMPL::removeCacheAll();
}
void AzVRP::removeUnusedCache()
{
	AzVRP_IMPL::removeUnusedCache();
}
bool AzVRP::isLowEndMode()
{
    return AzVRP_IMPL::isLowEndMode();
}
void AzVRP::setLowEndMode(bool lowendmode)
{
    AzVRP_IMPL::setLowEndMode(lowendmode);
}


AzVRP::AzVRP()
: _frame(0.0f)
, _rendered_frame(-2)
, _repeat(true)
, _draw_shapes(false)
, _draw_sockets(false)
, _loopScriptHandler(0)
, _socketScriptHandler(0)
, _visual_index(-1)
, _customShaderType(0)
, _customShader(nullptr)
, _timeScale(1.0f)
{
}
AzVRP::~AzVRP()
{
    unregisterScriptLoopHandler();
}

void AzVRP::onEnter()
{
	Node::onEnter();

	/* 
		17.6.19 @mskim
		A2D 사용시 Schedular에서 markedForDeletion이 이미 false인 객체가 다시 schedule 등록될때 에러 발생하는 증상이 다량 발생
		A2D자체를 땠다가 다시 붙이는 과정에서 발생하는 것으로 추정됨.
		이를 방지하기 위해 임시로 unscheduleUpdate을 호출하도록함
	*/
	unscheduleUpdate();
	scheduleUpdate();
}
void AzVRP::onExit()
{
	unscheduleUpdate();

	Node::onExit();
}

void AzVRP::setSpriteSubstitution(const std::string& src, const std::string& tar)
{
	auto sprite_iter = _sprite_substitutions.find(src);
	if (sprite_iter != _sprite_substitutions.end()) {
		CCLog("already set substitution.");
		return;
	}
	_sprite_substitutions.insert(TYPE_SPRITE_SUBSTITUTIONS::value_type(src, tar));
}

void AzVRP::registerScriptLoopHandler(int handler)
{
	unregisterScriptLoopHandler();
	_loopScriptHandler = handler;
}
void AzVRP::unregisterScriptLoopHandler()
{
	if (0 != _loopScriptHandler)
	{
		ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_loopScriptHandler);
		_loopScriptHandler = 0;
	}
}

void AzVRP::registerScriptSocketHandler(int handler)
{
	unregisterScriptSocketHandler();
	_socketScriptHandler = handler;
}
void AzVRP::unregisterScriptSocketHandler()
{
	if (0 != _socketScriptHandler)
	{
		ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_socketScriptHandler);
		_socketScriptHandler = 0;
	}
}

void AzVRP::setCustomShader(int customShaderType, float arg)
{
    Texture2D *texture;

    _customShaderType = customShaderType;

    switch (customShaderType)
    {
    case 1:
        _customShader = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_CUSTOM_ERASER);
        _customShader->setUniformVec2("u_winSize", Director::getInstance()->getWinSize());
        _customShader->setUniformFloat("u_speed", arg);
        break;

    case 2:
        _customShader = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_CUSTOM_DISSOLVE);
        _customShader->setUniformVec2("u_winSize", Director::getInstance()->getWinSize());
        _customShader->setUniformFloat("u_speed", arg);
        texture = Director::getInstance()->getTextureCache()->getTextureForKey("shader_texture");
        _customShader->setUniformTexture("u_dissolveTexture", texture->getName(), false);
        break;

    case 3:
        _customShader = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_CUSTOM_EMBOSS);
        break;

    case 4:
        _customShader = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_CUSTOM_COLOR_RAMP);
        texture = Director::getInstance()->getTextureCache()->getTextureForKey("shader_texture");
        _customShader->setUniformTexture("u_colorRampTexture", texture->getName(), false);
        break;

	case 5:
		_customShader = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_CUSTOM_BLUR);
		_customShader->setUniformFloat("blurRadius", arg);
		break;

	case 6:
		_customShader = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_CUSTOM_GRAY);
		break;

    default:
        _customShader = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP);
        _customShaderType = 0;
        break;
    }

    updateCustomShaderUniforms(true);
}

void AzVRP::updateCustomShaderUniforms(bool reset)
{
    static float oldGlobalTime = 0.0f;

    if (_customShaderType == 0 || _customShader == nullptr)
    {
        return;
    }

    if (_customShaderType == 1 || _customShaderType == 2)
    {
        float globalTime = Director::getInstance()->getTotalFrames() * Director::getInstance()->getAnimationInterval();

        if (reset)
        {
            oldGlobalTime = globalTime;
        }

        float time = globalTime - oldGlobalTime;

        _customShader->setUniformFloat("u_time", time / 10.0f);
    }
}


AzVRP_IMPL::AzVRP_IMPL()
: _vrp(nullptr)
, _visual(nullptr)
, _shape_info_count(0)
, _socket_info_count(0)
, _socket_event_mask(nullptr)
, _socket_event_mask_size(0)
, _check_visible_rect(false)
{

}
AzVRP_IMPL::~AzVRP_IMPL()
{
	clear();
}

void AzVRP_IMPL::clear()
{
	releaseSprite();

	if (_socket_event_mask) free(_socket_event_mask);
	_socket_event_mask = nullptr;
	_socket_event_mask_size = 0;

	_sprite_pool.clear();

	for (auto binder : _socket_binders)
	{
		if (binder)
		{
			binder->release();
		}
	}
	_socket_binders.clear();

	for (auto binder : _node_binders)
	{
		if (binder)
		{
			binder->release();
			removeChild(binder);
		}
	}
	_node_binders.clear();

	_vrp = nullptr;
}

float AzVRP_IMPL::getSocketPosX(const std::string& socket_name)
{
	int index = getSocketIndex(socket_name);

	if (index >= 0 && _socket_infos.size() > index)
	{
		Vec3 v3;
		for (int i = 0; i < _socket_infos.size(); i++)
		{
			if (_socket_infos.at(i)._index == index)
			{
				_socket_infos.at(i)._tm.getTranslation(&v3);
			}
		}
		float ret = v3.x;
		ret = getScaleX() * ret;
		return ret;
	}
	return 0;
}

float AzVRP_IMPL::getSocketPosY(const std::string& socket_name)
{
	int index = getSocketIndex(socket_name);

	if (index >= 0 && _socket_infos.size() > index)
	{
		Vec3 v3;
		for (int i = 0; i < _socket_infos.size(); i++)
		{
			if (_socket_infos.at(i)._index == index)
			{
				_socket_infos.at(i)._tm.getTranslation(&v3);
			}
		}
		float ret = v3.y;
		ret = getScaleY() * ret;
		return  ret;
	}
	return 0;
}

void AzVRP_IMPL::removeCache(const std::string& filename)
{
	auto cache_iter = s_vrp_cache.find(filename);
	if (cache_iter == s_vrp_cache.end()) return;

	s_vrp_cache.erase(cache_iter);
}
void AzVRP_IMPL::removeCacheAll()
{
	s_vrp_cache.clear();
}
void AzVRP_IMPL::removeUnusedCache()
{
	for (auto cache_iter = s_vrp_cache.begin(); cache_iter != s_vrp_cache.end();)
	{
		if (cache_iter->second.use_count() <= 1)
		{
			cache_iter = s_vrp_cache.erase(cache_iter);
		}
		else
		{
			++cache_iter;
		}
	}
}

bool AzVRP_IMPL::init(void)
{
	clear();

	// shader state
	setGLProgramState(GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP));

	_quad_maker.init();

	return true;
}
bool AzVRP_IMPL::initWithFile(const std::string& filename)
{
	clear();

	if (filename.empty()) return false;

	auto cache_iter = s_vrp_cache.find(filename);
	if (cache_iter != s_vrp_cache.end())
	{
		_vrp = cache_iter->second;
	}
	else
	{
		std::string fullpath = cocos2d::FileUtils::getInstance()->fullPathForFilename(filename.c_str());
		if (fullpath.size() == 0)
		{
			return false;
		}

		cocos2d::Data data = cocos2d::FileUtils::getInstance()->getDataFromFile(fullpath);
		if (data.isNull()) return false;

		if (!initWithData(data.getBytes(), data.getSize())) return false;

		s_vrp_cache.insert(TYPE_VRP_CACHE::value_type(filename, std::shared_ptr< const VRP >(_vrp)));
		//CCLOG("AzVRP add cache : %s", filename.c_str());
	}

	_file_name = filename;

	// shader state
	setGLProgramState(GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP));

	_quad_maker.init();

	// socket event
	_socket_event_mask_size = sizeof(unsigned int) * ((_vrp->getSocketCount() + 31) >> 5);
	if (_socket_event_mask_size > 0)
	{
		_socket_event_mask = (unsigned int*)malloc(_socket_event_mask_size);
		memset(_socket_event_mask, 0, _socket_event_mask_size);
	}

	return true;
}
bool AzVRP_IMPL::initWithData(const unsigned char* data, ssize_t dataLen)
{
	clear();

	bool ret = false;

	do
	{
		CC_BREAK_IF(!data || dataLen <= 0);

		unsigned char* unpackedData = nullptr;
		ssize_t unpackedLen = 0;

		//detecgt and unzip the compress file
		if (ZipUtils::isCCZBuffer(data, dataLen))
		{
			unpackedLen = ZipUtils::inflateCCZBuffer(data, dataLen, &unpackedData);
		}
		else if (ZipUtils::isGZipBuffer(data, dataLen))
		{
			unpackedLen = ZipUtils::inflateMemory(const_cast<unsigned char*>(data), dataLen, &unpackedData);
		}
		else
		{
			unpackedData = const_cast<unsigned char*>(data);
			unpackedLen = dataLen;
		}

		void* vrp = nullptr;
		if (unpackedData == data)
		{
			vrp = malloc(unpackedLen);
			memcpy(vrp, unpackedData, unpackedLen);
		}
		else
		{
			vrp = (VRP*)unpackedData;
		}
		_vrp = shared_ptr<const VRP>((VRP*)vrp);

		ret = true;
	} while (0);

	return ret;
}

void AzVRP_IMPL::loadPlistFiles(const std::string& prefix)
{
	if (!_vrp) return;

	std::string path;
	auto split_pos = _file_name.rfind('/');
	if (split_pos != std::string::npos)
	{
		path = _file_name.substr(0, split_pos + 1);
	}

	int count = _vrp->getPlistCount();
	for (int i = 0; i < count; ++i)
	{
		CCSpriteFrameCache::getInstance()->addSpriteFramesWithFileNPrefix(prefix, path + _vrp->getPlistName(i));
	}
}
void AzVRP_IMPL::buildSprite(const std::string& prefix)
{
	if (!_vrp) return;

	_sprite_prefix = prefix;

	int count = _vrp->getSpriteCount();
	_sprite_pool.resize(count);
	for (int i = 0; i < count; ++i)
	{
//		CCLOG("%d : sprite name - '%s'", i, _vrp->getSpriteName(i));

		auto& sprite_info = _sprite_pool.at(i);
		sprite_info._texture = nullptr;

		std::string filename = _vrp->getSpriteName(i);
		auto sprite_substitutions_iter = _sprite_substitutions.find(filename);
		if (sprite_substitutions_iter != _sprite_substitutions.end())
		{
			filename = sprite_substitutions_iter->second;
		}

		auto sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(prefix + filename);
		if (!sprite_frame)
		{
			sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);
			if (!sprite_frame)
			{
				CCLOG("%d : can not find sprite - '%s'", i, (prefix + _vrp->getSpriteName(i)).c_str());

				continue;
			}
		}

		sprite_frame->retain();

		sprite_info._texture = sprite_frame->getTexture();

		auto& sprite_rect = sprite_frame->getRect();
		int sprite_w = sprite_rect.size.width;
		int sprite_h = sprite_rect.size.height;
		int sprite_x = sprite_rect.origin.x;
		int sprite_y = sprite_rect.origin.y;
		auto& offeset = sprite_frame->getOffsetInPixels();

		sprite_info._l = offeset.x - (int)(sprite_w * 0.5f);
		sprite_info._r = sprite_info._l + sprite_w;
		sprite_info._t = offeset.y - (int)(sprite_h * 0.5f);
		sprite_info._b = sprite_info._t + sprite_h;

		float texture_w = sprite_info._texture->getPixelsWide();
		float texture_h = sprite_info._texture->getPixelsHigh();

		if (sprite_frame->isRotated())
		{
			float uv_l =  ((float)sprite_x + 0.5f)             / texture_w;
			float uv_r = (((float)sprite_x - 0.5f) + sprite_h) / texture_w;
			float uv_t =  ((float)sprite_y + 0.5f)             / texture_h;
			float uv_b = (((float)sprite_y - 0.5f) + sprite_w) / texture_h;

			sprite_info._uv_tl = Tex2F(uv_l, uv_t);
			sprite_info._uv_bl = Tex2F(uv_r, uv_t);
			sprite_info._uv_tr = Tex2F(uv_l, uv_b);
			sprite_info._uv_br = Tex2F(uv_r, uv_b);
		}
		else
		{
			float uv_l =  ((float)sprite_x + 0.5f)             / texture_w;
			float uv_r = (((float)sprite_x - 0.5f) + sprite_w) / texture_w;
			float uv_t =  ((float)sprite_y + 0.5f)             / texture_h;
			float uv_b = (((float)sprite_y - 0.5f) + sprite_h) / texture_h;

			sprite_info._uv_tl = Tex2F(uv_l, uv_b);
			sprite_info._uv_bl = Tex2F(uv_l, uv_t);
			sprite_info._uv_tr = Tex2F(uv_r, uv_b);
			sprite_info._uv_br = Tex2F(uv_r, uv_t);
		}
	}
}
void AzVRP_IMPL::releaseSprite()
{
	if (!_vrp) return;

	int count = _vrp->getSpriteCount();
	_sprite_pool.resize(count);
	for (int i = 0; i < count; ++i)
	{
		// CCLOG("%d : sprite name - '%s'", i, _vrp->getSpriteName(i));

		auto& sprite_info = _sprite_pool.at(i);
		sprite_info._texture = nullptr;

		std::string filename = _vrp->getSpriteName(i);
		auto sprite_substitutions_iter = _sprite_substitutions.find(filename);
		if (sprite_substitutions_iter != _sprite_substitutions.end())
		{
			filename = sprite_substitutions_iter->second;
		}

		auto sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(_sprite_prefix + filename);
		if (!sprite_frame)
		{
			sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);
			if (!sprite_frame)
			{
				// CCLOG("%d : can not find sprite - '%s'", i, (_sprite_prefix + _vrp->getSpriteName(i)).c_str());

				continue;
			}
		}

		sprite_frame->release();
	}
}

bool AzVRP_IMPL::buildEventShapeID(const std::string& plist)
{
	auto plist_fullpath = FileUtils::getInstance()->fullPathForFilename(plist);

	ValueMap* event_shape_ids = nullptr;
	auto event_shape_ids_iter = s_event_shape_ids_cache.find(plist);
	if (event_shape_ids_iter == s_event_shape_ids_cache.end())
	{
		ValueMap new_dict = FileUtils::getInstance()->getValueMapFromFile(plist_fullpath.c_str());
		if (new_dict.empty()) return false;

		auto ret_insert = s_event_shape_ids_cache.insert(TYPE_EVENT_SHAPE_IDS_CACHE::value_type(plist, new_dict));
		if (!ret_insert.second) return false;

		event_shape_ids = &(ret_insert.first->second);
	}
	else
	{
		event_shape_ids = &(event_shape_ids_iter->second);
	}

	int event_shape_count = _vrp->getEventShapeCount();
	_event_shape_ids.resize(event_shape_count);
	for (int i = 0; i < event_shape_count; ++i)
	{
		auto id_iter = event_shape_ids->find(_vrp->getEventShapeName(i));
		if (id_iter == event_shape_ids->end())
		{
			_event_shape_ids.at(i) = -1;
			continue;
		}
		_event_shape_ids.at(i) = id_iter->second.asInt();
	}

	return true;
}
bool AzVRP_IMPL::setVisual(const std::string& visual_group_name, const std::string& visual_name)
{
	if (!_vrp) return false;

	_visual_group_name = visual_group_name;
	_visual_name = visual_name;
	_visual_index = -1;

	_visual = _vrp->getVisual(visual_group_name, visual_name, _visual_index);
	if (!_visual) return false;

	_begin = _visual->begin();
	_end = _visual->end();
	_fps = _visual->fps();
	_frame = 0.0f;
	_rendered_frame = -1.0f;

	updateSocket();
	this->unregisterScriptLoopHandler();

	return true;
}
bool AzVRP_IMPL::setVisual(const std::string& visual_group_name)
{
	if (!_vrp) return false;

	_visual_group_name = visual_group_name;
	_visual_index = -1;

	_visual = _vrp->getVisual(visual_group_name, _visual_name, _visual_index);
	if (!_visual) return false;

	_begin = _visual->begin();
	_end = _visual->end();
	_fps = _visual->fps();
	_frame = 0.0f;
	_rendered_frame = -1.0f;

	updateSocket();
	this->unregisterScriptLoopHandler();

	return true;
}
bool AzVRP_IMPL::setVisual(int visual_index)
{
	if (!_vrp) return false;

	_visual = _vrp->getVisual(visual_index, &_visual_group_name, &_visual_name);
	if (!_visual) return false;

	_begin = _visual->begin();
	_end = _visual->end();
	_fps = _visual->fps();
	_frame = 0.0f;
	_rendered_frame = -1.0f;

	updateSocket();
	this->unregisterScriptLoopHandler();

	return true;
}

bool AzVRP_IMPL::bindVRP(const std::string& socket_name, AzVRP* vrp)
{
	if (!_vrp) return false;

	int socket_index = _vrp->getSocketIndex(socket_name);
	if (socket_index < 0) return false;

	if (_socket_binders.size() < _vrp->getSocketCount())
	{
		_socket_binders.resize(_vrp->getSocketCount());
	}

	auto& socket = _socket_binders[socket_index];
	if (socket) socket->release();
	
	if (vrp) vrp->retain();
	socket = vrp;

	return true;
}
Node* AzVRP_IMPL::getSocketNode(const std::string& socket_name)
{
	if (!_vrp) return 0;

	int socket_index = _vrp->getSocketIndex(socket_name);
	if (socket_index < 0) return 0;

	if (_node_binders.size() < _vrp->getSocketCount())
	{
		_node_binders.resize(_vrp->getSocketCount());
	}

	auto& binder = _node_binders[socket_index];
	if (!binder)
	{
		binder = BinderNode::create();
		binder->retain();
		addChild(binder);

		for (auto socket_info : _socket_infos)
		{
			if (socket_info._index != socket_index) continue;

			binder->bind(&socket_info);
			break;
		}
	}

	return binder;
}

void AzVRP_IMPL::getSocketNodeList(std::list<std::string>& socket_node_list)
{
    socket_node_list.clear();

    if (!_vrp) return;

    int count = _vrp->getSocketCount();
    std::string name;
    for (int i = 0; i < count; ++i)
    {
        name = _vrp->getSocketName(i);
        socket_node_list.push_back(name);
    }
}

std::string AzVRP_IMPL::getVisualListLuaTable()
{
	if (!_vrp) return "";

	std::stringstream s;

	s << "{" << std::endl;
	std::string group_name;
	std::string name;
	int count = _vrp->getVisualCount();
	for (int i = 0; i < count; ++i)
	{
		auto visual = _vrp->getVisual(i, &group_name, &name);
		if (!visual) continue;

		s << "[" << i+1 << "] = { group = '" << group_name << "'; name = '" << name << "'; };" << std::endl;
	}
	s << "}" << std::endl;

	return s.str();
}

void AzVRP_IMPL::getVisualList(const std::string& bind_token, std::list<std::string>& visual_list)
{
    if (!_vrp) return;

    visual_list.clear();

    std::string group_name;
    std::string name;
    int count = _vrp->getVisualCount();
    for (int i = 0; i < count; ++i)
    {
        auto visual = _vrp->getVisual(i, &group_name, &name);
        if (!visual) continue;

        visual_list.push_back(group_name + bind_token + name);
    }
}

void AzVRP_IMPL::initEventShapeList()
{
	_shape_info_count = 0;
}
void AzVRP_IMPL::queryEventShape(float frame)
{
	VRP::TM tm;
	queryEventShape(_visual, frame, tm);
}
void AzVRP_IMPL::queryEventShape(const VRP::VISUAL* visual, float frame, VRP::TM& tm)
{
	if (!visual) return;

	const VRP::VISUAL* sub_visual = nullptr;
	float sub_visual_frame;

	auto vrp = _vrp.get();

	int layer_count = visual->layerCount();
	for (int i = 0; i < layer_count; ++i)
	{
		auto layer = visual->get(vrp, i);

		VRP::KEY key;
		if (!layer->get(key, frame, _repeat)) continue;

		VRP::TM curr_tm(key);
		curr_tm.mul(tm);

		switch (layer->getReferenceType())
		{
		case VRP::REF_TYPE::VISUAL:
			sub_visual = layer->getVisual(vrp);
			sub_visual_frame = (visual->_end == visual->_begin) ? 0 : (frame - visual->_begin) * sub_visual->_end / (visual->_end - visual->_begin);
			queryEventShape(sub_visual, sub_visual_frame, curr_tm);
			break;
		case VRP::REF_TYPE::EVENT_SHAPE: queryEventShape(layer->getIndex(), curr_tm, key.isBox()); break;
		case VRP::REF_TYPE::SPRITE:
		case VRP::REF_TYPE::SOCKET: break;
		default: break;
		}
	}
}
void AzVRP_IMPL::queryEventShape(int event_shape_index, VRP::TM& tm, bool is_box)
{
	if (_shape_info_count >= _shape_infos.size())
	{
		_shape_infos.resize(_shape_info_count + 1);
	}

	auto& shape_info = _shape_infos[_shape_info_count++];
	shape_info._index = event_shape_index;
	shape_info._type = is_box ? EventShape::BOX : EventShape::CIRCLE;

	if (is_box)
	{
		auto& box = shape_info._s._box;
		box.x = box.y = 0.0f;
		box.u_x = box.v_y = 0.5f;
		box.u_y = box.v_x = 0.0f;
		tm.mul(box.x, box.y);
		tm.mul(box.u_x, box.u_y);
		tm.mul(box.v_x, box.v_y);
		box.u_x -= box.x;
		box.u_y -= box.y;
		box.v_x -= box.x;
		box.v_y -= box.y;
	}
	else
	{
		auto& circle = shape_info._s._circle;
		circle.x = circle.y = 0.0f;
		tm.mul(circle.x, circle.y);
		circle.radius = tm.getScale() * 0.5f;
	}
}
void AzVRP_IMPL::buildPhysicBody()
{
	auto* body = getPhysicsBody();
	if (!body)	return;

	float frameDuration = _frame - _rendered_frame;

	if (_rendered_frame == -1)
	{
		initEventShapeList();
		queryEventShape(_frame);
		body->removeAllShapes();
		buildShapes(body);
	}
	else if (frameDuration > 1)
	{
		body->removeAllShapes();
		initEventShapeList();
		float frame_ = _rendered_frame;
		while (frame_ < _frame)
		{
			queryEventShape(frame_);
			frame_ += 1.0f;
			if (_shape_info_count == body->getShapes().size()) continue;
			buildShapes(body);
		}
	}
	else
	{
		initEventShapeList();
		queryEventShape(_frame);
		int  shapes_size = body->getShapes().size();
		if (_shape_info_count == shapes_size) return;
		if (_shape_info_count != shapes_size)
		{
			body->removeAllShapes();
		}
		buildShapes(body);
	}
}

void AzVRP_IMPL::buildShapes(PhysicsBody* body)
{
	for (auto& shape_info : _shape_infos)
	{
		int event_id = _event_shape_ids.at(shape_info._index);

		switch (shape_info._type)
		{
		case AzVRP::EventShape::CIRCLE:
		{
			Size size_ = Size(shape_info._s._circle.x, shape_info._s._circle.y);
			auto shape = PhysicsShapeCircle::create(shape_info._s._circle.radius, PHYSICSBODY_MATERIAL_DEFAULT, size_);
			if (!body->getShape(event_id))
			{
				shape->setTag(event_id);
				body->addShape(shape);
			}
		}break;
		case AzVRP::EventShape::BOX:
		{
			Point u = Point(shape_info._s._box.u_x, shape_info._s._box.u_y);
			Point v = Point(shape_info._s._box.v_x, shape_info._s._box.v_y);
			Size box_size_ = Size(u.getLength() * 2, v.getLength() * 2);

			float angle = CC_RADIANS_TO_DEGREES(u.getAngle());
			Size off_set_ = Size(shape_info._s._box.x * getScaleX(), shape_info._s._box.y * getScaleY());
			auto maerial = PhysicsMaterial(1.0f, 0, 0);
			auto shapeBox = PhysicsShapeBox::create(box_size_ * getScaleX(), maerial, off_set_);

			if (!body->getShape(event_id))
			{
				shapeBox->setTag(event_id);
				body->addShape(shapeBox);
			}
		}break;
		}
	}
}

void AzVRP_IMPL::updateSocket()
{
	_socket_info_count = 0;

	for (auto binder : _node_binders)
	{
		if (!binder) continue;

		binder->bind(nullptr);
	}

	VRP::TM tm;
	updateSocket(_visual, _frame, tm);
}
void AzVRP_IMPL::updateSocket(const VRP::VISUAL* visual, float frame, VRP::TM& tm)
{
	if (!visual) return;

	const VRP::VISUAL* sub_visual = nullptr;
	float sub_visual_frame;

	auto vrp = _vrp.get();

	int layer_count = visual->layerCount();
	for (int i = 0; i < layer_count; ++i)
	{
		auto layer = visual->get(vrp, i);

		VRP::KEY key;
		if (!layer->get(key, frame, _repeat)) continue;

		VRP::TM curr_tm(key);
		curr_tm.mul(tm);

		switch (layer->getReferenceType())
		{
		case VRP::REF_TYPE::VISUAL:
			sub_visual = layer->getVisual(vrp);
			sub_visual_frame = (visual->_end == visual->_begin) ? 0 : (frame - visual->_begin) * sub_visual->_end / (visual->_end - visual->_begin);
			updateSocket(sub_visual, sub_visual_frame, curr_tm);
			break;
		case VRP::REF_TYPE::SOCKET: updateSocket(layer->getIndex(), curr_tm, key._ref_index); break;
		case VRP::REF_TYPE::SPRITE:
		case VRP::REF_TYPE::EVENT_SHAPE: break;
		default: break;
		}
	}
}
void AzVRP_IMPL::updateSocket(int socket_index, VRP::TM& tm, int ref_index)
{
	if (_socket_info_count >= _socket_infos.size())
	{
		_socket_infos.resize(_socket_info_count + 1);
	}
	
	auto& socket_info = _socket_infos[_socket_info_count++];
	socket_info._index = socket_index;
	socket_info._ref_index = ref_index;
	socket_info._tm.setIdentity();
	socket_info._tm.m[0] = tm._m11;
	socket_info._tm.m[1] = tm._m12;
	socket_info._tm.m[4] = tm._m21;
	socket_info._tm.m[5] = tm._m22;
	socket_info._tm.m[12] = tm._m31;
	socket_info._tm.m[13] = tm._m32;

	if (_node_binders.size() > socket_index)
	{
		auto binder = _node_binders[socket_index];
		if (binder)
		{
			binder->bind(&socket_info);
		}
	}
}

void AzVRP_IMPL::clearSocketHandler()
{
	if (_socket_event_mask_size > 0)
	{
		memset(_socket_event_mask, 0, _socket_event_mask_size);
	}
}
void AzVRP_IMPL::enableSocketHandler(const std::string& socket_name)
{
	if (!_vrp || _socket_event_mask_size <= 0) return;

	int idx = _vrp->getSocketIndex(socket_name);
	if (idx < 0) return;

	_socket_event_mask[idx >> 5] |= 1 << (idx & 0x1f);
}
void AzVRP_IMPL::updateSocketEvent(const VRP::VISUAL* visual, float frame, VRP::TM& tm)
{
	if (!visual) return;

	const VRP::VISUAL* sub_visual = nullptr;
	float sub_visual_frame;

	auto vrp = _vrp.get();

	int layer_count = visual->layerCount();
	for (int i = 0; i < layer_count; ++i)
	{
		auto layer = visual->get(vrp, i);

		VRP::KEY key;
		if (!layer->get(key, frame, _repeat)) continue;

		VRP::TM curr_tm(key);
		curr_tm.mul(tm);

		switch (layer->getReferenceType())
		{
		case VRP::REF_TYPE::VISUAL:
			sub_visual = layer->getVisual(vrp);
			sub_visual_frame = (visual->_end == visual->_begin) ? 0 : (frame - visual->_begin) * sub_visual->_end / (visual->_end - visual->_begin);
			updateSocketEvent(sub_visual, sub_visual_frame, curr_tm);
			break;
		case VRP::REF_TYPE::SOCKET: updateSocketEvent(layer->getIndex(), frame, curr_tm, key._ref_index); break;
		case VRP::REF_TYPE::SPRITE:
		case VRP::REF_TYPE::EVENT_SHAPE: break;
		default: break;
		}
	}
}
void AzVRP_IMPL::updateSocketEvent(int socket_index, float frame, VRP::TM& tm, int ref_index)
{
	if ((_socket_event_mask[socket_index >> 5] & (1 << (socket_index & 0x1f))) == 0) return;

	_socket_event._index = socket_index;
	_socket_event._ref_index = ref_index;
	_socket_event._tm.setIdentity();
	_socket_event._tm.m[0] = tm._m11;
	_socket_event._tm.m[1] = tm._m12;
	_socket_event._tm.m[4] = tm._m21;
	_socket_event._tm.m[5] = tm._m22;
	_socket_event._tm.m[12] = tm._m31;
	_socket_event._tm.m[13] = tm._m32;

	_socket_event_frame = frame;

	CommonScriptData data(_socketScriptHandler, "socket_event", this);
	ScriptEvent event(kCommonEvent, (void*)&data);
	ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);
}

void AzVRP_IMPL::update(float deltaTime)
{
	if (!_visual) return;
	Node::update(deltaTime);

	if (_timeScale != 1.0f)
	{
		deltaTime *= _timeScale;
	}

	_deltaTime = deltaTime;

	float prev_frame = _frame;
	if (_end > 0.0f)
	{
		bool is_send_event = false;

		if (_frame < 0) _frame = 0;
		else _frame += deltaTime * _fps;
		if (_repeat)
		{
			while (_frame > _end)
			{
				_frame -= _end;
				is_send_event = true;
			}
		}
		else
		{
			if (_frame > _end)
			{
				_frame = _end;
				is_send_event = true;
			}
		}

		if (is_send_event && _loopScriptHandler != 0)
		{
			bool is_repeat = isRepeat();
			int handler = _loopScriptHandler;

			CommonScriptData data(handler, "end", this);
			ScriptEvent event(kCommonEvent, (void*)&data);
			ScriptEngineManager::getInstance()->getScriptEngine()->sendEvent(&event);

			if ((is_repeat == false) && (handler == _loopScriptHandler))
			{ 
				unregisterScriptLoopHandler();
			}
		}
	}
	else
	{
		_frame = 0.0f;
	}

	for (auto binded_vrp : _socket_binders)
	{
		if (!binded_vrp) continue;
		binded_vrp->update(deltaTime);
	}

	queryEventShape(_frame);
	updateSocket();

	if (_socketScriptHandler != 0)
	{
		int i_prevframe = static_cast<int>(prev_frame)+1;
		int i_frame = static_cast<int>(_frame);
		for (int i = i_prevframe; i <= i_frame; ++i)
		{
			VRP::TM tm;
			updateSocketEvent(_visual, static_cast<float>(i), tm);
		}
	}
}

void AzVRP_IMPL::draw(Renderer *renderer, const Mat4& transform, bool transformUpdated)
{
	if (!_visual) return;

	if (_rendered_frame != _frame)
	{
		_rendered_frame = _frame;

		auto c = getColor();
		auto o = getOpacity();

		auto vrp = _vrp.get();

		_quad_maker.begin(_sprite_pool, _socket_binders, transform, _globalZOrder, _check_visible_rect);
		_quad_maker.make(vrp, _visual, _frame, c.r, c.g, c.b, o);

		if (_draw_shapes) _quad_maker.make(getEventShapeList(), getEventShapeCount());
		if (_draw_sockets) _quad_maker.make(getSocketList(), getSocketCount());

		_quad_maker.flush();
	}
	else
	{
		if (transformUpdated)
		{
			_quad_maker.updateTransform(transform);
		}
	}
	
	_quad_maker.add(renderer);

    updateCustomShaderUniforms();
}
void AzVRP_IMPL::draw(QuadMaker& maker, VRP::TM& tm, VRP::BLEND& blend, int ref_index)
{
	if (_visual_index < 0) return;

	auto vrp = _vrp.get();

	auto visual = vrp->getVisual(_visual_index + ref_index, nullptr, nullptr);

//	CCLOG("%d : draw - '%s' / '%s'", _visual_index + ref_index, visual->getGroupName(_vrp), visual->getName(_vrp));

	maker.beginSocket(_sprite_pool, _socket_binders);
	maker.make(vrp, visual, _frame, tm, blend);

	if (_draw_shapes) maker.make(getEventShapeList(), getEventShapeCount());
 	if (_draw_sockets) maker.make(getSocketList(), getSocketCount());

	maker.endSocket();
}

void AzVRP_IMPL::setCustomShader(int customShaderType, float arg)
{
    AzVRP::setCustomShader(customShaderType, arg);
    _quad_maker.setCustomShader(_customShader);
}

static void makeQuad(QuadMaker& maker, AzVRP* vrp, VRP::TM& tm, VRP::BLEND& blend, int ref_index)
{
	((AzVRP_IMPL*)vrp)->draw(maker, tm, blend, ref_index);
}

NS_CC_END
