#include <string.h>
#include <algorithm>
#include "CCAzVisual.h"

// external

#include "AzDataDictionary.h"
#include "AzDataTrip.h"
#include "AzTM.h"
#include "AzBlend.h"
#include "a2dLoader4x.h"


#include <fstream>
#include <google/protobuf/io/zero_copy_stream_impl.h>
#include <google/protobuf/io/coded_stream.h>



using namespace std;

std::string getRealPath(const std::string& file_name, std::string path);

NS_CC_BEGIN

const std::string AzVisual::PROJECT_PATH("(PROJECT_PATH)");

AzVisual::TYPE_EVENT_SHAPE_IDS_CACHE AzVisual::s_event_shape_ids_cache;

AzVisual::TYPE_VISUAL_CACHE AzVisual::s_visual_cache;

#if CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__ARGS__) (ceil(__ARGS__))
#endif

AzVisual* AzVisual::create(const std::string& filename)
{
	AzVisual *azvisual = new AzVisual();
	if (azvisual && azvisual->initWithFile(filename))
	{
		azvisual->autorelease();
		return azvisual;
	}
	CC_SAFE_DELETE(azvisual);
	return nullptr;
}
AzVisual* AzVisual::create()
{
	AzVisual *azvisual = new AzVisual();
	if (azvisual && azvisual->init())
	{
		azvisual->autorelease();
		return azvisual;
	}
	CC_SAFE_DELETE(azvisual);
	return nullptr;
}
void AzVisual::removeCache(const std::string& filename)
{
	auto cache_iter = s_visual_cache.find(filename);
	if (cache_iter == s_visual_cache.end()) return;

	s_visual_cache.erase(cache_iter);
}
void AzVisual::removeCacheAll()
{
	s_visual_cache.clear();
}
void AzVisual::removeUnusedCache()
{
	for (auto cache_iter = s_visual_cache.begin(); cache_iter != s_visual_cache.end();)
	{
		if (cache_iter->second.first.use_count() <= 1)
		{
			cache_iter = s_visual_cache.erase(cache_iter);
		}
		else
		{
			++cache_iter;
		}
	}
}

void AzVisual::onEnter()
{
	Node::onEnter();

	scheduleUpdate();
}
void AzVisual::onExit()
{
	unscheduleUpdate();

	Node::onExit();
}

bool AzVisual::init(void)
{
	// shader state
	setGLProgramState(GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP));
	_color_program_state = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_COLOR_NO_MVP);

	return true;
}
bool AzVisual::initWithFile(const std::string& filename)
{
    if (filename.empty()) return false;

	auto cache_iter = s_visual_cache.find(filename);
	if (cache_iter != s_visual_cache.end())
	{
		_azddic = cache_iter->second.first;
		_project_id = cache_iter->second.second;

		_file_name = filename;

		_data_trip_draw.setAzDataDictionary(_azddic.get());
		_data_trip_socket.setAzDataDictionary(_azddic.get());
		_data_trip_event_shape.setAzDataDictionary(_azddic.get());
	}
	else
	{
		azModel::AzDataDictionary* azddic = nullptr;
		if (!load(filename, azddic, _project_id)) return false;

		_file_name = filename;

		_azddic = std::shared_ptr<azModel::AzDataDictionary>(azddic);
		_data_trip_draw.setAzDataDictionary(azddic);
		_data_trip_socket.setAzDataDictionary(azddic);
		_data_trip_event_shape.setAzDataDictionary(azddic);

		s_visual_cache.insert(TYPE_VISUAL_CACHE::value_type(filename, std::pair< std::shared_ptr< azModel::AzDataDictionary >, azModel::AzID >(_azddic, _project_id)));
	}

    // shader state
    setGLProgramState(GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_TEXTURE_COLOR_NO_MVP));
	_color_program_state = GLProgramState::getOrCreateWithGLProgramName(GLProgram::SHADER_NAME_POSITION_COLOR_NO_MVP);

	return true;
}

bool AzVisual::buildEventShapeID(const std::string& plist)
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

	_event_shape_ids.clear();
	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	if (project)
	{
		for (auto& event_shape_group : project->event_shape_group_list())
		{
			for (auto& event_shape : event_shape_group.event_shape_list())
			{
				auto id_iter = event_shape_ids->find(event_shape.base().name());
				if (id_iter == event_shape_ids->end()) continue;

				_event_shape_ids.insert(TYPE_EVENT_SHAPE_ID_LIST::value_type(event_shape.base().rtid(), id_iter->second.asInt()));
			}
		}
	}

	return true;
}

bool AzVisual::load(const std::string& filename, azModel::AzDataDictionary*& azddic, azModel::AzID& project_id)
{
	CCASSERT(filename.size()>0, "Invalid filename for azvisual");

	auto split_pos = filename.rfind(".");
	if (split_pos == std::string::npos) return false;

	std::string ext = filename.substr(split_pos);
	if (ext == ".a2d")
	{
		azModel::AzDataDictionary* azddic_tmp = new azModel::AzDataDictionary;
		azModel::a2dLoader4x a2dloader(*azddic_tmp);

		project_id = a2dloader.load(filename);
		if (project_id.getValue() <= 0)
		{
			delete azddic_tmp;
			return false;
		}

		azddic = azddic_tmp;
	}
	else if (ext == ".pb")
	{
		auto* project = new azVisual::Project();

		std::ifstream infs(filename, std::ios::in | std::ios::binary);
		if (!infs.good())
		{
			delete project;
			return false;
		}

		project->ParsePartialFromIstream(&infs);
		infs.close();

		azddic = new azModel::AzDataDictionary;
		project_id = project->base().rtid();
		appendDataToDic(azddic, project);
	}

	return true;
}
void AzVisual::appendDataToDic(azModel::AzDataDictionary* azddic, const azModel::AzData* data)
{
	auto* azdi = azddic->add(data);

	const ::google::protobuf::Reflection *ref = data->GetReflection();
	const ::google::protobuf::Descriptor *desc = data->GetDescriptor();
	for (int i = 0; i< desc->field_count(); ++i) {
		const ::google::protobuf::FieldDescriptor* field = desc->field(i);
		assert(field);
		::google::protobuf::FieldDescriptor::Type type = field->type();
		if (type == ::google::protobuf::FieldDescriptor::TYPE_MESSAGE
			&& field->name() != "base"
			&& field->name() != "transform") {
			if (field->is_repeated())
			{
				size_t array_size = ref->FieldSize(*data, field);
				for (size_t i = 0; i != array_size; ++i)
				{
					const azModel::AzData* value = &(ref->GetRepeatedMessage(*data, field, i));
					appendDataToDic(azddic, value);
				}
			}
			else
			{
				const azModel::AzData* value = &(ref->GetMessage(*data, field));
				appendDataToDic(azddic, value);
			}
		}
	}
}

AzVisual::AzVisual(void)
: _azddic(nullptr)
, _visual(nullptr)
, _frame(0.0f)
, _rendered_frame(-2)
, _quad_cmd_count(0)
, _quads(nullptr)
, _quads_max(0)
, _socket_info_count(0)
, _shape_info_count(0)
, _draw_visible_rect(false)
, _draw_sockets(false)
, _draw_shapes(false)
, _repeat(true)
, _opacityModifyRGB(false)
, _additiveColor(Color3B(255, 255, 255))
, _loopScriptHandler(0)
{
	initTripFunction_bitmap(_data_trip_draw);
	initTripFunction_sprite(_data_trip_draw);
	initTripFunction_socket(_data_trip_draw);

	initTripFunction_socket(_data_trip_socket);

	initTripFunction_eventshape(_data_trip_event_shape);
}
AzVisual::~AzVisual(void)
{
    unregisterScriptLoopHandler();
	releaseSprite();

	if (_quads) free(_quads);
	_quads = nullptr;
	_quads_max = 0;

	for (auto shape_info : _shape_infos)
	{
		if (!shape_info) delete shape_info;
		shape_info = nullptr;
	}
	_shape_infos.clear();
	for (auto socket_info : _socket_infos)
	{
		if (!socket_info) delete socket_info;
		socket_info = nullptr;
	}
	_socket_infos.clear();
	for (auto binder : _node_binders)
	{
		if (binder.second)
		{
			binder.second->release();
			removeChild(binder.second);
		}
	}
	_node_binders.clear();
	for (auto i : _socket_binders)
	{
		if (i.second) delete i.second;
	}
	_socket_binders.clear();
	for (auto* quad : _quad_cmds)
	{
		if (quad) delete quad;
	}
	_quad_cmds.clear();
}

void AzVisual::initTripFunction_bitmap(azModel::AzDataTrip& data_trip)
{
	data_trip.setDoBitmap([=](const azVisual::Key* key, const azModel::AzTM& tm, const azModel::AzBlend& blend, const azModel::Bitmap* bitmap) {
		if (!bitmap) return true;
		if (!bitmap->base().apply()) return true;

		std::string path(getRealPath(_file_name, bitmap->base().name()));

		auto* texture = Director::getInstance()->getTextureCache()->addImage(path);
		if (!texture) return true;

		int width = texture->getPixelsWide();
		int height = texture->getPixelsHigh();
		float l = (float)(-(width >> 1));
		float t = (float)(height - (height >> 1));
		float r = (float)(width - (width >> 1));
		float b = (float)(-(height >> 1));

		// 홀수 높이의 스프라이트의 높이관련 예외처리가 필요
		if (height & 1)
		{
			t -= 1.0f;
			b -= 1.0f;
		}

		float x0 = l, y0 = t;
		float x1 = l, y1 = b;
		float x2 = r, y2 = t;
		float x3 = r, y3 = b;

		tm.mul(x0, y0);
		tm.mul(x1, y1);
		tm.mul(x2, y2);
		tm.mul(x3, y3);

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

		float ul = 0.0f;
		float vt = 0.0f;
		float ur = 1.0f;
		float vb = 1.0f;
		 
		auto current_texture_name = texture->getName();
		auto current_blend_mode = blend.getMode();
		auto* current_shader_program_state = getGLProgramState();
		if (_current_texture_name != current_texture_name ||
			_current_blend_mode != current_blend_mode ||
			_current_shader_program_state != current_shader_program_state)
		{
			flushQuad();

			_current_texture_name = current_texture_name;
			_current_blend_mode = current_blend_mode;
			_current_shader_program_state = current_shader_program_state;
		}

		Color4B color(key->color_r() * 255, key->color_g() * 255, key->color_b() * 255, key->alpha() * 255);

        V3F_C4B_T2F_Quad& quad = getQuad();
		quad.tl.vertices = Vertex3F(x0, y0, 0);
		quad.bl.vertices = Vertex3F(x1, y1, 0);
		quad.tr.vertices = Vertex3F(x2, y2, 0);
		quad.br.vertices = Vertex3F(x3, y3, 0);
		quad.tl.colors = color;
		quad.bl.colors = color;
		quad.tr.colors = color;
		quad.br.colors = color;
		quad.tl.texCoords = Tex2F(ul, vt);
		quad.bl.texCoords = Tex2F(ul, vb);
		quad.tr.texCoords = Tex2F(ur, vt);
		quad.br.texCoords = Tex2F(ur, vb);

		return true;
	});
}
void AzVisual::initTripFunction_sprite(azModel::AzDataTrip& data_trip)
{
	data_trip.setDoSprite([=](const azVisual::Key* key, const azModel::AzTM& tm, const azModel::AzBlend& blend, const azModel::Bitmap* bitmap, const azModel::Sprite* sprite) {
		if (!bitmap) return true;
		if (!bitmap->base().apply()) return true;

		const auto& sprite_info = _sprite_pool[sprite->base().rtid()];

		auto texture = sprite_info._texture;
		if (!texture) return true;

		float x0 = sprite_info._l, y0 = sprite_info._t;
		float x1 = sprite_info._l, y1 = sprite_info._b;
		float x2 = sprite_info._r, y2 = sprite_info._t;
		float x3 = sprite_info._r, y3 = sprite_info._b;

		tm.mul(x0, y0);
		tm.mul(x1, y1);
		tm.mul(x2, y2);
		tm.mul(x3, y3);

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

		auto current_texture_name = texture->getName();
		auto current_blend_mode = blend.getMode();
		auto current_shader_program_state = getGLProgramState();
		if (_current_texture_name != current_texture_name ||
			_current_blend_mode != current_blend_mode ||
			_current_shader_program_state != current_shader_program_state)
		{
			flushQuad();

			_current_texture_name = current_texture_name;
			_current_blend_mode = current_blend_mode;
			_current_shader_program_state = current_shader_program_state;
		}

		Color4B color(blend.getRed() * 255, blend.getGreen() * 255, blend.getBlue() * 255, blend.getAlpha() * 255);

		V3F_C4B_T2F_Quad& quad = getQuad();
		quad.tl.vertices = Vertex3F(x0, y0, 0);
		quad.bl.vertices = Vertex3F(x1, y1, 0);
		quad.tr.vertices = Vertex3F(x2, y2, 0);
		quad.br.vertices = Vertex3F(x3, y3, 0);
		quad.tl.colors = color;
		quad.bl.colors = color;
		quad.tr.colors = color;
		quad.br.colors = color;
		quad.tl.texCoords = sprite_info._uv_tl;
		quad.bl.texCoords = sprite_info._uv_bl;
		quad.tr.texCoords = sprite_info._uv_tr;
		quad.br.texCoords = sprite_info._uv_br;

		return true;
	});
}
void AzVisual::initTripFunction_particle(azModel::AzDataTrip& data_trip)
{
	data_trip.setDoParticle([=](const azVisual::Key* key, const azModel::AzTM& tm, const azModel::AzBlend& blend, const azVisual::Particle* particle)
	{
		if (!particle) return true;
		if (!particle->base().apply()) return true;

		std::string path(getRealPath(_file_name, particle->base().name()));

		return true;
	});
}
void AzVisual::initTripFunction_socket(azModel::AzDataTrip& data_trip)
{
	data_trip.setDoSocket([=](const azVisual::Key* key, const azModel::AzTM& tm, const azModel::AzBlend& blend, const azVisual::Socket* socket, float frame) {
		if (!socket) return true;
		if (!socket->base().apply()) return true;

		// for SocketBinder
		const azVisual::Visual* current_visual = nullptr;

		auto i = _socket_binders.find(socket);
		if (i != _socket_binders.end())
		{
			SocketBinder* socket_binder = i->second;
			if (socket_binder->_visual_group)
			{
				for (auto& visual : socket_binder->_visual_group->visual_list())
				{
					if (visual.base().name() == key->refrence_name())
					{
						current_visual = &visual;
						if (socket_binder->_visual != current_visual)
						{
							data_trip.getRange(*current_visual, socket_binder->_begin, socket_binder->_end);
							socket_binder->_visual = current_visual;
						}
						break;
					}
				}
			}
			else if (socket_binder->_visual)
			{
				current_visual = socket_binder->_visual;
			}

			if (socket_binder->_end > 0.0f)
			{
				socket_binder->_frame += _deltaTime * current_visual->fps();
				while (socket_binder->_frame > socket_binder->_end) socket_binder->_frame -= socket_binder->_end;
			}
			socket_binder->_data_trip.trip(tm, blend, current_visual, socket_binder->_frame);
		}

		// for SocketInfo
		if (_socket_info_count >= _socket_infos.size())
		{
			_socket_infos.resize(_socket_info_count + 1);
			_socket_infos[_socket_info_count] = new SocketInfo;
		}
		auto socket_info = _socket_infos[_socket_info_count++];
		socket_info->_socket = socket;
		socket_info->_reference_index = key->refrence_name();
		socket_info->_tm.setIdentity();
		socket_info->_tm.m[0] = tm._m11;
		socket_info->_tm.m[1] = tm._m12;
		socket_info->_tm.m[4] = tm._m21;
		socket_info->_tm.m[5] = tm._m22;
		socket_info->_tm.m[12] = tm._m31;
		socket_info->_tm.m[13] = tm._m32;

		auto iter_binder = _node_binders.find(socket);
		if (iter_binder != _node_binders.end())
		{
			auto binder = iter_binder->second;
			if (binder)
			{
				binder->bind(socket_info);
			}
		}

		return true;
	});
}

void AzVisual::initTripFunction_eventshape(azModel::AzDataTrip& data_trip)
{
	data_trip.setDoEventShape([=](const azVisual::Key* key, const azModel::AzTM& tm, const azModel::AzBlend& blend, const azVisual::EventShape* event_shape)
	{
		// for ShapeInfo
		if (_shape_info_count >= _shape_infos.size())
		{
			_shape_infos.resize(_shape_info_count + 1);
			_shape_infos[_shape_info_count] = new ShapeInfo;
		}
		auto shape_info = _shape_infos[_shape_info_count++];
		shape_info->_shape = event_shape;
		shape_info->_type = key->shape_type();
		switch (key->shape_type())
		{
		case azModel::BOX:
		{
			auto& box = shape_info->_s._box;
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
			break;
		case azModel::CIRCLE:
		{
			auto& circle = shape_info->_s._circle;
			circle.x = circle.y = 0.0f;
			tm.mul(circle.x, circle.y);
			circle.radius = tm.getScale() * 0.5f;
		}
			break;
		}

		return true;
	});
}

bool AzVisual::setFile(const std::string& filename)
{
	releaseSprite();

	for (auto& i : _socket_binders)
	{
		if (i.second) delete i.second;
	}
	_socket_binders.clear();
	for (auto* quad : _quad_cmds)
	{
		if (quad) delete quad;
	}
	_quad_cmds.clear();

	_azddic = nullptr;

	return initWithFile(filename);
}
void AzVisual::setSpriteSubstitution(const std::string& src, const std::string& tar)
{
	auto sprite_iter = _sprite_substitutions.find(src);
	if (sprite_iter != _sprite_substitutions.end()) {
		CCLog("already set substitution.");
		return;
	}
	_sprite_substitutions.insert(TYPE_SPRITE_SUBSTITUTIONS::value_type(src, tar));
}
void AzVisual::loadPlistFiles(const std::string& prefix)
{
	if (!_azddic) return;

	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	if (!project) return;

	auto& bitmap_list = project->bitmap_list();
	for (auto& bitmap : bitmap_list)
	{
		std::string path(getRealPath(_file_name, bitmap.base().name()));

		auto ext = path.substr(path.rfind('.'));
		if (ext == ".plist")
		{
			CCSpriteFrameCache::getInstance()->addSpriteFramesWithFileNPrefix(prefix, path);
		}
	}
}
void AzVisual::buildSprite(const std::string& prefix)
{
	if (!_azddic) return;

	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	if (!project) return;

	_sprite_prefix = prefix;

	auto& bitmap_list = project->bitmap_list();
	for (auto& bitmap : bitmap_list)
	{
		auto& sprite_list = bitmap.sprite_list();
		for (auto& sprite : sprite_list)
		{
			auto& sprite_info = _sprite_pool[sprite.base().rtid()];

			std::string filename = sprite.base().name();
			auto sprite_substitutions_iter = _sprite_substitutions.find(filename);
			if (sprite_substitutions_iter != _sprite_substitutions.end())
			{
				filename = sprite_substitutions_iter->second;
			}

			auto sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(prefix + filename);
			if (!sprite_frame)
			{
				sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);
			}
			if (!sprite_frame)
			{
				std::string path(getRealPath(_file_name, bitmap.base().name()));

				auto* texture = Director::getInstance()->getTextureCache()->addImage(path);
				if (!texture) continue;

				texture->retain();

				sprite_info._texture = texture;

				int sprite_w = sprite.right() - sprite.left();
				int sprite_h = sprite.bottom() - sprite.top();
				int sprite_x = sprite.left();
				int sprite_y = sprite.top();

				sprite_info._l = -(int)(sprite_w >> 1);
				sprite_info._r = sprite_info._l + sprite_w;
				sprite_info._t = -(int)(sprite_h >> 1);
				sprite_info._b = sprite_info._t + sprite_h;

				int texture_w = texture->getPixelsWide();
				int texture_h = texture->getPixelsHigh();

				float uv_l = ((float)sprite_x + 0.5f) / texture_w;
				float uv_r = (((float)sprite_x - 0.5f) + sprite_w) / texture_w;
				float uv_t = ((float)sprite_y + 0.5f) / texture_h;
				float uv_b = (((float)sprite_y - 0.5f) + sprite_h) / texture_h;

				sprite_info._uv_tl = Tex2F(uv_l, uv_b);
				sprite_info._uv_bl = Tex2F(uv_l, uv_t);
				sprite_info._uv_tr = Tex2F(uv_r, uv_b);
				sprite_info._uv_br = Tex2F(uv_r, uv_t);

				continue;
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
				float uv_l = ((float)sprite_x + 0.5f) / texture_w;
				float uv_r = (((float)sprite_x - 0.5f) + sprite_h) / texture_w;
				float uv_t = ((float)sprite_y + 0.5f) / texture_h;
				float uv_b = (((float)sprite_y - 0.5f) + sprite_w) / texture_h;

				sprite_info._uv_tl = Tex2F(uv_l, uv_t);
				sprite_info._uv_bl = Tex2F(uv_r, uv_t);
				sprite_info._uv_tr = Tex2F(uv_l, uv_b);
				sprite_info._uv_br = Tex2F(uv_r, uv_b);
			}
			else
			{
				float uv_l = ((float)sprite_x + 0.5f) / texture_w;
				float uv_r = (((float)sprite_x - 0.5f) + sprite_w) / texture_w;
				float uv_t = ((float)sprite_y + 0.5f) / texture_h;
				float uv_b = (((float)sprite_y - 0.5f) + sprite_h) / texture_h;

				sprite_info._uv_tl = Tex2F(uv_l, uv_b);
				sprite_info._uv_bl = Tex2F(uv_l, uv_t);
				sprite_info._uv_tr = Tex2F(uv_r, uv_b);
				sprite_info._uv_br = Tex2F(uv_r, uv_t);
			}
		}
	}
}
void AzVisual::releaseSprite()
{
	if (!_azddic) return;

	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	if (!project) return;

	auto& bitmap_list = project->bitmap_list();
	for (auto& bitmap : bitmap_list)
	{
		auto& sprite_list = bitmap.sprite_list();
		for (auto& sprite : sprite_list)
		{
			auto& sprite_info = _sprite_pool[sprite.base().rtid()];

			std::string filename = sprite.base().name();
			auto sprite_substitutions_iter = _sprite_substitutions.find(filename);
			if (sprite_substitutions_iter != _sprite_substitutions.end())
			{
				filename = sprite_substitutions_iter->second;
			}

			auto sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(_sprite_prefix + filename);
			if (!sprite_frame)
			{
				sprite_frame = SpriteFrameCache::getInstance()->getSpriteFrameByName(filename);
			}
			if (!sprite_frame)
			{
				std::string path(getRealPath(_file_name, bitmap.base().name()));

				auto* texture = Director::getInstance()->getTextureCache()->addImage(path);
				if (!texture) continue;

				texture->release();

				continue;
			}

			sprite_frame->release();
		}
	}
}

bool AzVisual::setVisual(int visual_group_index, int visual_index)
{
	if (!_azddic) return false;

	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	if (!project || 0 > visual_group_index || project->visual_group_list_size() <= visual_group_index) return false;

	auto& visual_group = project->visual_group_list().Get(visual_group_index);
	if (0 > visual_index || visual_group.visual_list_size() <= visual_index) return false;

	_visual = &const_cast<azVisual::Visual&>(visual_group.visual_list().Get(visual_index));
	if (_visual)
	{
		_data_trip_draw.getRange(*_visual, _begin, _end);

		_data_trip_socket.trip(*_visual, 0);
	}

	_frame = 0.0f;
	_quad_cmd_count = 0;
	_rendered_frame = -1;
	_fps = _visual->fps();

	this->unregisterScriptLoopHandler();
	return true;
}
bool AzVisual::setVisual(const std::string& visual_group_name, const std::string& visual_name)
{
	_visual_group_name = visual_group_name;
	_visual_name = visual_name;

	if (_azddic.get() == nullptr) return false;

	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	for (auto& visual_group : project->visual_group_list())
	{
		if (visual_group.base().name() != visual_group_name) continue;

		for (auto& visual : visual_group.visual_list())
		{
			if (visual.base().name() != visual_name) continue;

			_visual = &const_cast<azVisual::Visual&>(visual);
			if (_visual)
			{
				_data_trip_draw.getRange(*_visual, _begin, _end);

				_data_trip_socket.trip(*_visual, 0);
			}

			_frame = 0.0f;
			_quad_cmd_count = 0;
			_rendered_frame = -1;
			_fps = _visual->fps();

			this->unregisterScriptLoopHandler();
			return true;
		}
	}
	return false;
}
bool AzVisual::setVisual(const std::string& visual_group_name)
{
	_visual_group_name = visual_group_name;
	_visual_name.clear();

	_visual = nullptr;
	_begin = 0;
	_end = 0;
	_fps = 0;
	_frame = 0.0f;
	_quad_cmd_count = 0;
	_rendered_frame = -1;

	if (_azddic.get() == nullptr) return false;

	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	for (auto& visual_group : project->visual_group_list())
	{
		if (visual_group.base().name() != visual_group_name) continue;

		if (visual_group.visual_list_size() > 0)
		{
			auto& visual = visual_group.visual_list().Get(0);
			_visual = &const_cast<azVisual::Visual&>(visual);
			if (_visual)
			{
				_data_trip_draw.getRange(*_visual, _begin, _end);
				_fps = _visual->fps();

				_visual_name = _visual->base().name();

				_data_trip_socket.trip(*_visual, 0);
			}
		}

		this->unregisterScriptLoopHandler();
		return true;
	}
	return false;
}
void AzVisual::getVisualList(const std::string& bind_token, std::list<std::string>& visual_list)
{
	visual_list.clear();

	if (_azddic.get() == nullptr) return;

	auto project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	if (project == nullptr) return;

	for (auto& visual_group : project->visual_group_list())
	{
		if (!visual_group.base().apply()) continue;

		auto& visual_group_name = visual_group.base().name();

		for (auto& visual : visual_group.visual_list())
		{
			if (!visual.base().apply()) continue;

			visual_list.push_back(visual_group_name + bind_token + visual.base().name());
		}
	}
}

bool AzVisual::bindVisual(const std::string& socket_name, const std::string& filename, const std::string& visual_group_name)
{
	if (_project_id.getValue() == 0) return false;

	const azVisual::Socket* socket = nullptr;
	auto* project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	for (auto& socket_group : project->socket_group_list())
	{
		for (auto& s : socket_group.socket_list())
		{
			if (s.base().name() == socket_name)
			{
				socket = &s;
				break;
			}
		}
	}
	if (socket == nullptr) return false;

	azModel::AzDataDictionary* azddic = nullptr;
	azModel::AzID project_id;
	if (!load(filename, azddic, project_id)) return false;

	SocketBinder* socket_binder = nullptr;
	if (_socket_binders.find(socket) == _socket_binders.end())
	{
		socket_binder = new SocketBinder;
		_socket_binders.insert(TYPE_SOCKET_BINDER_LIST::value_type(socket, socket_binder));
	}

	socket_binder->_azddic = std::shared_ptr<azModel::AzDataDictionary>(azddic);
	socket_binder->_project_id = project_id;
	socket_binder->_data_trip.setAzDataDictionary(azddic);
	socket_binder->_visual_group = nullptr;
	socket_binder->_visual = nullptr;

	project = dynamic_cast<azVisual::Project*>(azddic->getData(project_id));
	for (auto& visual_group : project->visual_group_list())
	{
		if (visual_group.base().name() == visual_group_name)
		{
			socket_binder->_visual_group = &visual_group;
			break;
		}
	}

	initTripFunction_bitmap(socket_binder->_data_trip);
	initTripFunction_sprite(socket_binder->_data_trip);
	initTripFunction_socket(socket_binder->_data_trip);

	return true;
}
Node* AzVisual::getSocketNode(const std::string& socket_name)
{
	if (_project_id.getValue() == 0) return nullptr;

	const azVisual::Socket* socket = nullptr;
	auto* project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	for (auto& socket_group : project->socket_group_list())
	{
		for (auto& s : socket_group.socket_list())
		{
			if (s.base().name() == socket_name)
			{
				socket = &s;
				break;
			}
		}
	}
	if (socket == nullptr) return nullptr;

	auto& binder = _node_binders[socket];
	if (!binder)
	{
		binder = BinderNode::create();
		binder->retain();
		addChild(binder);

 		for (auto socket_info : _socket_infos)
		{
			if (socket_info->_socket != socket) continue;

			binder->bind(socket_info);
			break;
		}
	}

	return binder;
}
void AzVisual::getSocketNodeList(std::list<std::string>& socket_node_list)
{
	socket_node_list.clear();

	if (!_azddic) return;
	if (_project_id.getValue() == 0) return;

	const azVisual::Socket* socket = nullptr;
	auto* project = dynamic_cast<azVisual::Project*>(_azddic->getData(_project_id));
	for (auto& socket_group : project->socket_group_list())
	{
		for (auto& s : socket_group.socket_list())
		{
			socket_node_list.push_back(s.base().name());
		}
	}
}

V3F_C4B_T2F_Quad& AzVisual::getQuad()
{
	if (_quads_count >= _quads_max)
	{
		int new_quads_max = _quads_max + _quads_alloc_unit;
		auto new_quads = (V3F_C4B_T2F_Quad*)realloc(_quads, new_quads_max * sizeof(V3F_C4B_T2F_Quad));
		if (!new_quads)
		{
			CCLOG("AzVisual failed - realloc for quad (%d -> %d)", _quads_max, new_quads_max);
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
void AzVisual::flushQuad()
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
	case azModel::NONE:		blend_func.src = GL_ONE;       blend_func.dst = GL_ZERO;                break;
	default:
	case azModel::ALPHA:	blend_func.src = GL_SRC_ALPHA; blend_func.dst = GL_ONE_MINUS_SRC_ALPHA; break;
	case azModel::SCREEN:	blend_func.src = GL_ONE;       blend_func.dst = GL_ONE_MINUS_SRC_COLOR; break;
	case azModel::MULTIPLY:	blend_func.src = GL_DST_COLOR; blend_func.dst = GL_ONE_MINUS_SRC_ALPHA; break;
	case azModel::ADD:		blend_func.src = GL_SRC_ALPHA; blend_func.dst = GL_ONE;                 break;
	case azModel::SUB:		blend_func.src = GL_ZERO;      blend_func.dst = GL_ONE_MINUS_SRC_COLOR; break;
	case azModel::LIGHTEN:	blend_func.src = GL_ZERO;      blend_func.dst = GL_ONE_MINUS_SRC_COLOR; break;
//	case azModel::OVERDRAW:
	}

	quad_cmd->init(_globalZOrder, _current_texture_name, _current_shader_program_state, blend_func, _quads + _flushed_quads_count, _quads_count - _flushed_quads_count, _modelViewTransform);

	_flushed_quads_count = _quads_count;
}

void AzVisual::update(float deltaTime)
{
	if (!_azddic) return;
	if (!_visual) return;

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
}
void AzVisual::addQuadVisibleRect()
{
	auto current_shader_program_state = _color_program_state;
	if (_current_blend_mode != azModel::ALPHA ||
		_current_shader_program_state != current_shader_program_state)
	{
		flushQuad();

		_current_blend_mode = azModel::ALPHA;
		_current_shader_program_state = current_shader_program_state;
	}

	Color4B color(0x10, 0x30, 0xff, 0x50);
	V3F_C4B_T2F_Quad& quad = getQuad();
	quad.tl.vertices = Vertex3F(_min_x, _min_y, 0);
	quad.bl.vertices = Vertex3F(_min_x, _max_y, 0);
	quad.tr.vertices = Vertex3F(_max_x, _min_y, 0);
	quad.br.vertices = Vertex3F(_max_x, _max_y, 0);
	quad.tl.colors = color;
	quad.bl.colors = color;
	quad.tr.colors = color;
	quad.br.colors = color;
	flushQuad();
}
void AzVisual::addQuadSocketInfo()
{
	flushQuad();
	Mat4 tm_backup(_modelViewTransform);
	for (int i = 0; i < _socket_info_count; ++i)
	{
		float x0 = 0.0f, y0 = 0.0f;
		float x1 = -5.0f, y1 = 10.0f;
		float x2 = 0.0f, y2 = 0.0f;
		float x3 = 5.0f, y3 = 10.0f;

		auto current_shader_program_state = _color_program_state;
		if (_current_blend_mode != azModel::ALPHA ||
			_current_shader_program_state != current_shader_program_state)
		{
			flushQuad();

			_current_blend_mode = azModel::ALPHA;
			_current_shader_program_state = current_shader_program_state;
		}

		Color4B color(0xff, 0x10, 0x30, 0x60);
		V3F_C4B_T2F_Quad& quad = getQuad();
		quad.tl.vertices = Vertex3F(x0, y0, 0);
		quad.bl.vertices = Vertex3F(x1, y1, 0);
		quad.tr.vertices = Vertex3F(x2, y2, 0);
		quad.br.vertices = Vertex3F(x3, y3, 0);
		quad.tl.colors = color;
		quad.bl.colors = color;
		quad.tr.colors = color;
		quad.br.colors = color;

		Mat4 tm;
		Mat4::multiply(tm_backup, _socket_infos[i]->_tm, &_modelViewTransform);

		flushQuad();
	}
	_modelViewTransform = tm_backup;
	flushQuad();
}
void AzVisual::addQuadShapeInfo()
{
	for (int i = 0; i < _shape_info_count; ++i)
	{
		auto* shape_info = _shape_infos[i];

		switch (shape_info->_type)
		{
		case azModel::BOX:
		{
			auto& box = shape_info->_s._box;

			auto current_shader_program_state = _color_program_state;
			if (_current_blend_mode != azModel::ALPHA ||
				_current_shader_program_state != current_shader_program_state)
			{
				flushQuad();

				_current_blend_mode = azModel::ALPHA;
				_current_shader_program_state = current_shader_program_state;
			}

			Color4B color(0x10, 0xff, 0x30, 0x60);
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
			break;
		case azModel::CIRCLE:
		{
			auto& circle = shape_info->_s._circle;

			auto current_shader_program_state = _color_program_state;
			if (_current_blend_mode != azModel::ALPHA ||
				_current_shader_program_state != current_shader_program_state)
			{
				flushQuad();

				_current_blend_mode = azModel::ALPHA;
				_current_shader_program_state = current_shader_program_state;
			}

			int segments = 20;
			const float coef = 2.0f * (float)M_PI / segments;
			GLfloat prev_arc_x = circle.radius + circle.x;
			GLfloat prev_arc_y = circle.y;
			Color4B color(0x10, 0xff, 0x30, 0x60);
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
			break;
		}
	}
	flushQuad();
}

void AzVisual::draw(Renderer *renderer, const Mat4& transform, bool transformUpdated)
{
	if (!_azddic) return;
	if (!_visual) return;

	if (_rendered_frame != _frame)
	{
		_rendered_frame = _frame;

		_quad_cmd_count = 0;
		_quads_count = 0;
		_flushed_quads_count = 0;
		_current_texture_name = -1;
		_current_shader_program_state = getGLProgramState();
		_socket_info_count = 0;

		_min_x = FLT_MAX;
		_min_y = FLT_MAX;
		_max_x = -FLT_MAX;
		_max_y = -FLT_MAX;

		for (auto binder : _node_binders)
		{
			if (!binder.second) continue;

			binder.second->bind(nullptr);
		}

		auto c = getColor();
		auto o = getOpacity();

		_data_trip_draw.trip(*_visual, _frame, c.r / 255.0f, c.g / 255.0f, c.b / 255.0f, o / 255.0f);

		flushQuad();

		if (_draw_visible_rect) addQuadVisibleRect();
		if (_draw_sockets) addQuadSocketInfo();
		if (_draw_shapes) addQuadShapeInfo();
	}
    else
    {
        if (transformUpdated)
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
                    transform
                );
            }
        }
    }

	for (int i = 0; i < _quad_cmd_count; ++i)
	{
		renderer->addCommand(_quad_cmds[i]);
	}
}

void AzVisual::registerScriptLoopHandler(int handler)
{
	unregisterScriptLoopHandler();
	_loopScriptHandler = handler;
}
void AzVisual::unregisterScriptLoopHandler()
{
	if (0 != _loopScriptHandler)
	{
		ScriptEngineManager::getInstance()->getScriptEngine()->removeScriptHandler(_loopScriptHandler);
		_loopScriptHandler = 0;
	}
}

void AzVisual::setOpacityModifyRGB(bool modify)
{
    if (_opacityModifyRGB != modify)
    {
        _opacityModifyRGB = modify;
    }
}
bool AzVisual::isOpacityModifyRGB(void) const
{
    return _opacityModifyRGB;
}

void AzVisual::initEventShapeList()
{
	_shape_info_count = 0;
}
void AzVisual::queryEventShape(float frame)
{
	_data_trip_event_shape.trip(*_visual, frame);
}

void AzVisual::buildPhysicBody()
{
	auto* body = getPhysicsBody();
	if (!body)	return;

	if (_frame - _rendered_frame > 1)
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

void AzVisual::buildShapes(PhysicsBody* body)
{
	for (auto& shape_info : _shape_infos)
	{
		auto id_iter = _event_shape_ids.find(shape_info->_shape->base().rtid());
		if (id_iter == _event_shape_ids.end()) continue;

		int event_id = id_iter->second;
		switch (shape_info->_type)
		{
		case AzVisual::ShapeInfo::CIRCLE:
		{
			Size size_ = Size((shape_info)->_s._circle.x, (shape_info)->_s._circle.y);
			auto shape = PhysicsShapeCircle::create((shape_info)->_s._circle.radius, PHYSICSBODY_MATERIAL_DEFAULT, size_);
			if (!body->getShape(event_id))
			{
				shape->setTag(event_id);
				body->addShape(shape);
			}
		}break;
		case AzVisual::ShapeInfo::BOX:
		{
			Point u = Point((shape_info)->_s._box.u_x, (shape_info)->_s._box.u_y);
			Point v = Point((shape_info)->_s._box.v_x, (shape_info)->_s._box.v_y);
			Size box_size_ = Size(u.getLength() * 2, v.getLength() * 2);

			float angle = CC_RADIANS_TO_DEGREES(u.getAngle());
			Size off_set_ = Size(shape_info->_s._box.x * getScaleX(), shape_info->_s._box.y * getScaleY());
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
};

NS_CC_END
