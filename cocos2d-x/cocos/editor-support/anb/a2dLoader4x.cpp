#include "a2dLoader4x.h"
#include "a2dToken4x.h"

#include "tinyxml2.h"

#if !defined(NO_COCOS2DX)
#include "cocos2d.h"
#endif

using namespace azModel;

#define STORAGE_INTEND_CHAR   "\t"
#define STORAGE_NAME          "name"
#define STORAGE_EXPEND        "expand"
#define STORAGE_NOT_EXPEND    "not_expand"
#define STORAGE_APPLY         "apply"
#define STORAGE_NOT_APPLY     "not_apply"
#define STORAGE_VISIBLE       "visible"
#define STORAGE_NOT_VISIBLE   "not_visible"
#define STORAGE_OBJECT_BEGIN  "{"
#define STORAGE_OBJECT_END    "}"
#define STORAGE_LIST_BEGIN    "["
#define STORAGE_LIST_END      "]"

#define azCLASS_TYPE(CLASS) azCLASSTYPE_##CLASS

enum
{
	azUNKNOWN = 0,
	azCLASS_TYPE(azUNKNOWN) = 0, // error return

	azCLASS_TYPE_BEGIN,

	azCLASS_TYPE(azObject) = azCLASS_TYPE_BEGIN,

	azCLASS_TYPE(azProject),

	azCLASS_TYPE(azVisualGroup),
	azCLASS_TYPE(azVisual),
	azCLASS_TYPE(azILayer),
	azCLASS_TYPE(azLayer),
	azCLASS_TYPE(azLayerGroup),
	azCLASS_TYPE(azLayerRes),
	azCLASS_TYPE(azSprite),
	azCLASS_TYPE(azEventBox),
	azCLASS_TYPE(azSocket),
	azCLASS_TYPE(azKey),

	azCLASS_TYPE(azBitmap),

	azCLASS_TYPE(azParticle),

	azCLASS_TYPE_END,
};

typedef unsigned long azCLASS_TYPE_ID;

#define azCLASS_NAME_2_ID_HELPER(CLASS)\
	ms_Name2ID[#CLASS] = azCLASSTYPE_##CLASS

class azCLASS_NAME_2_ID_HELPER_OBJECT
{
public:
	typedef std::map< std::string, azCLASS_TYPE_ID > TYPE_CONVERT_INFO;
	TYPE_CONVERT_INFO ms_Name2ID;
	azCLASS_NAME_2_ID_HELPER_OBJECT()
	{
		azCLASS_NAME_2_ID_HELPER(azObject);

		azCLASS_NAME_2_ID_HELPER(azProject);
		azCLASS_NAME_2_ID_HELPER(azBitmap);
		azCLASS_NAME_2_ID_HELPER(azVisualGroup);
		azCLASS_NAME_2_ID_HELPER(azVisual);
		azCLASS_NAME_2_ID_HELPER(azILayer);
		azCLASS_NAME_2_ID_HELPER(azLayer);
		azCLASS_NAME_2_ID_HELPER(azLayerGroup);
		azCLASS_NAME_2_ID_HELPER(azLayerRes);
		azCLASS_NAME_2_ID_HELPER(azSprite);
		azCLASS_NAME_2_ID_HELPER(azEventBox);
		azCLASS_NAME_2_ID_HELPER(azSocket);
		azCLASS_NAME_2_ID_HELPER(azKey);
		azCLASS_NAME_2_ID_HELPER(azParticle);

		ms_Name2ID["azTag"] = azCLASSTYPE_azSocket; // tag->socket으로 변경 하는 중..
	}
};

static azCLASS_TYPE_ID azCLASS_NAME_2_ID(const char* p_szClassName)
{
	static azCLASS_NAME_2_ID_HELPER_OBJECT helper;
	azCLASS_NAME_2_ID_HELPER_OBJECT::TYPE_CONVERT_INFO::iterator iinfo = helper.ms_Name2ID.find(p_szClassName);
	if (iinfo == helper.ms_Name2ID.end()) return azUNKNOWN;
	return iinfo->second;
}

static std::string GetSpriteName(int l, int t, int r, int b)
{
	char szbuf[256];
	sprintf(szbuf, "%d,%d,%d,%d", l, t, r - l, b - t);
	return szbuf;
}

static std::string GetObjectName(int id, const char* name)
{
	const char* class_name = "";
	switch (id)
	{
	case azCLASS_TYPE(azProject):		class_name = "azProject"; break;
	case azCLASS_TYPE(azVisualGroup):	class_name = "azVisualGroup"; break;
	case azCLASS_TYPE(azVisual):		class_name = "azVisual"; break;
	case azCLASS_TYPE(azILayer):		class_name = "azILayer"; break;
	case azCLASS_TYPE(azLayer):			class_name = "azLayer"; break;
	case azCLASS_TYPE(azLayerGroup):	class_name = "azLayerGroup"; break;
	case azCLASS_TYPE(azLayerRes):		class_name = "azLayerRes"; break;
	case azCLASS_TYPE(azEventBox):		class_name = "azEventBox"; break;
	case azCLASS_TYPE(azSocket):		class_name = "azTag"; break; // tag->socket으로 변경 하는 중..
	case azCLASS_TYPE(azKey):			class_name = "azKey"; break;
	case azCLASS_TYPE(azBitmap):		class_name = "azBitmap"; break;
	case azCLASS_TYPE(azSprite):		class_name = "azSprite"; break;
	case azCLASS_TYPE(azParticle):		class_name = "azPareticle"; break;
	}
	char szbuf[256];
	sprintf(szbuf, "<%s>'%s'", class_name, name);
	return szbuf;
}

std::string getRealPath(const std::string& file_name, std::string path)
{
	size_t pos = path.find(azModel::a2dLoader4x::PROJECT_PATH);
	if (pos != std::string::npos)
	{
		auto split_pos = file_name.rfind('\\');
		if (split_pos == std::string::npos) split_pos = file_name.rfind('/');
		path = path.substr(0, pos) + file_name.substr(0, split_pos + 1) + path.substr(pos + azModel::a2dLoader4x::PROJECT_PATH.size(), std::string::npos);

		while (true)
		{
			auto replace_pos = path.find('\\');
			if (replace_pos == std::string::npos) break;

			path[replace_pos] = '/';
		}
	}
	return path;
}

namespace azModel {

	const std::string a2dLoader4x::PROJECT_PATH("(PROJECT_PATH)");

	a2dLoader4x::a2dLoader4x(AzDataDictionary& azddic)
		: _azddic(azddic)
		, _log(false)
	{
	}
	a2dLoader4x::~a2dLoader4x()
	{
	}

	AzID a2dLoader4x::load(const std::string& filename, const std::string& name, const AzID& parent_rtid)
	{
		a2dToken4x token;
		token.readFile(filename);

		_file_name = filename;

		const char* szToken;

		if (!(szToken = token.getToken())) return 0;
		if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return 0;

		if (!(szToken = token.getToken())) return 0;
		if (strcmp(szToken, "AzraelVisual")) return 0;

		if (!(szToken = token.getToken())) return 0;
		std::string strversion(szToken);
		size_t nsep = strversion.find('.');

		auto* project = new azVisual::Project();
		project->mutable_base()->set_parent_rtid(parent_rtid.getValue());
		auto* azdi = _azddic.add(project);
		project->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azProject), name.c_str()));

		int nVarMajor;
		int nVarMinor;

		if (nsep >= strversion.size())
		{
			nVarMajor = atoi(szToken);
			nVarMinor = 0;
		}
		else
		{
			nVarMajor = atoi(strversion.substr(0, nsep).c_str());
			nVarMinor = atoi(strversion.substr(nsep + 1, strversion.size()).c_str());
		}

		_version = (nVarMajor << 16) + nVarMinor;

		if (_version < 0x00040008)
		{
			token.rereadUTF8();
		}

		if (_version < 0x00040001)
		{
			if (!(szToken = token.getToken())) return 0;
			if (strcmp(szToken, "azProject_mClass")) return 0;

			if (!(szToken = token.getToken())) return 0;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return 0;
		}

		if (!load(token, project, filename))
		{
			if (_log) printf("%s - '%s' a2d load - failed !!\n", __FUNCTION__, filename.c_str());
			return 0;
		}

		if (!bindLayer()) return 0;
		if (!bindSocket()) return 0;

		if (_log) printf("%s - '%s' a2d load - ok\n", __FUNCTION__, filename.c_str());

		return project->base().rtid();
	}
	bool a2dLoader4x::load(a2dToken4x& token, azVisual::Project* project, const std::string& filename)
	{
		if (_log) printf("%s - %s\n", __FUNCTION__, filename.c_str());


		const char* szToken;

		char prevTypeStr[64] = "";

		while (1)
		{
			if (!(szToken = token.getToken())) return false;
			if (!strcmp(szToken, STORAGE_OBJECT_END)) break;

			azCLASS_TYPE_ID classID = azCLASS_NAME_2_ID(szToken);

			if (!(szToken = token.getToken())) return false;
			if (isUnder45()) { if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false; }
			else { if (strcmp(szToken, STORAGE_LIST_BEGIN)) return false; }

			while (1)
			{
				if (!(szToken = token.getToken())) return false;
				if (isUnder45()) { if (!strcmp(szToken, STORAGE_OBJECT_END)) break; }
				else {
					if (!strcmp(szToken, STORAGE_LIST_END)) break;

					if (!(szToken = token.getToken())) return false;
					if (strcmp(szToken, STORAGE_NAME)) return false;

					if (!(szToken = token.getToken())) return false;
				}

				bool succeed = false;
				switch (classID)
				{
				case azCLASS_TYPE(azProject):		succeed = loadProject(token, project, szToken);		break;
				case azCLASS_TYPE(azVisualGroup):	succeed = loadVisualGroup(token, project, szToken);	break;
				case azCLASS_TYPE(azEventBox):		succeed = loadEventBox(token, project, szToken);	break;
				case azCLASS_TYPE(azSocket):		succeed = loadSocket(token, project, szToken);		break;
 				case azCLASS_TYPE(azBitmap):		succeed = loadBitmap(token, project, szToken);		break;
				case azCLASS_TYPE(azParticle):		succeed = loadParticle(token, project, szToken);	break;
				default: succeed = loadUnknown(token, szToken);	break;
				}

				if (!succeed)
					return false;
			}
		}

		std::sort(project->mutable_visual_group_list()->begin(), project->mutable_visual_group_list()->end(),
			[](const ::azVisual::VisualGroup& r, const ::azVisual::VisualGroup& l) { return r.base().name() < l.base().name(); });
		for (auto& visual_group : *(project->mutable_visual_group_list()))
		{
			std::sort(visual_group.mutable_visual_list()->begin(), visual_group.mutable_visual_list()->end(),
				[](const ::azVisual::Visual& r, const ::azVisual::Visual& l) { return r.base().name() < l.base().name(); });
		}

		std::sort(project->mutable_socket_group_list()->begin(), project->mutable_socket_group_list()->end(),
			[](const ::azVisual::SocketGroup& r, const ::azVisual::SocketGroup& l) { return r.base().name() < l.base().name(); });
		for (auto& socket_group : *(project->mutable_socket_group_list()))
		{
			std::sort(socket_group.mutable_socket_list()->begin(), socket_group.mutable_socket_list()->end(),
				[](const ::azVisual::Socket& r, const ::azVisual::Socket& l) { return r.base().name() < l.base().name(); });
		}

		std::sort(project->mutable_bitmap_list()->begin(), project->mutable_bitmap_list()->end(),
			[](const ::azModel::Bitmap& r, const ::azModel::Bitmap& l) { return r.base().name() < l.base().name(); });
		for (auto& bitmap : *(project->mutable_bitmap_list()))
		{
			std::sort(bitmap.mutable_sprite_list()->begin(), bitmap.mutable_sprite_list()->end(),
				[](const ::azModel::Sprite& r, const ::azModel::Sprite& l) { return r.base().name() < l.base().name(); });
		}

		return true;
	}

	bool a2dLoader4x::loadProject(a2dToken4x& token, azVisual::Project* project, const char* name)
	{
		std::string path(getRealPath(_file_name, name));

		auto backup_filename = _file_name;
		auto backup_version = _version;

		auto azid = load(path, name, project->base().rtid());

		_file_name = backup_filename;
		_version = backup_version;

		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_OBJECT_END)) return false;

		return true;
	}
	bool a2dLoader4x::loadVisualGroup(a2dToken4x& token, azVisual::Project* project, const char* name)
	{
		auto* visual_group = project->add_visual_group_list();
		visual_group->mutable_base()->set_parent_rtid(project->base().rtid());
		auto* azdi = _azddic.add(visual_group);
		visual_group->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		visual_group->mutable_base()->set_name(name);

		if (_log) printf("%s - 0x%llx:%s\n", __FUNCTION__, azdi->getRuntimeID().getValue(), GetObjectName(azCLASS_TYPE(azVisualGroup), name).c_str());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azVisualGroup), name));


		const char* szToken;
	
		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_EXPEND)) return false;

		if (!(szToken = token.getToken())) return false;
		//if (!strcmp(szToken, "false")) SetExpanded(false); else SetExpanded(true);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_APPLY)) return false;

		if (!(szToken = token.getToken())) return false;
		if (!strcmp(szToken, "false")) visual_group->mutable_base()->set_apply(false);

		if (!(szToken = token.getToken())) return false;
		if (isUnder45()) { if (strcmp(szToken, "Visual")) return false; }
		else { if (strcmp(szToken, "visual_list")) return false; }

		if (!(szToken = token.getToken())) return false;
		if (isUnder45()) { if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false; }
		else { if (strcmp(szToken, STORAGE_LIST_BEGIN)) return false; }

		while (1)
		{
			if (!(szToken = token.getToken())) return false;
			if (isUnder45()) {
				if (!strcmp(szToken, STORAGE_OBJECT_END))
				{
					if (!(szToken = token.getToken())) return false;
					break;
				}
			}
			else
			{
				if (!strcmp(szToken, STORAGE_LIST_END))
				{
					if (!(szToken = token.getToken())) return false;
					break;
				}

				if (!(szToken = token.getToken())) return false;
				if (strcmp(szToken, STORAGE_NAME)) return false;

				if (!(szToken = token.getToken())) return false;
			}

			if (!loadVisual(token, visual_group, szToken)) return false;
		}

		return true;
	}
	bool a2dLoader4x::loadVisual(a2dToken4x& token, azVisual::VisualGroup* visual_group, const char* name)
	{
		auto* visual = visual_group->add_visual_list();
		visual->mutable_base()->set_parent_rtid(visual_group->base().rtid());
		auto* azdi = _azddic.add(visual);
		visual->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		visual->mutable_base()->set_name(name);

		if (_log) printf("%s - 0x%llx:%s\n", __FUNCTION__, azdi->getRuntimeID().getValue(), GetObjectName(azCLASS_TYPE(azVisual), name).c_str());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azVisual), name));


		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_APPLY)) return false;

		if (!(szToken = token.getToken())) return false;
		if (!strcmp(szToken, "false")) visual->mutable_base()->set_apply(false);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, "fps")) return false;

		if (!(szToken = token.getToken())) return false;
		visual->set_fps(atof(szToken));

		if (!(szToken = token.getToken())) return false;
		if (isUnder45()) { if (strcmp(szToken, "LayerGroup")) return false; }
		else { if (strcmp(szToken, "layer_root")) return false; }

		auto* layer = visual->mutable_layer();
		layer->mutable_base()->set_parent_rtid(visual->base().rtid());
		auto* azdii = _azddic.add(layer);
		layer->mutable_base()->set_rtid(azdii->getRuntimeID().getValue());

		if (!isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
			
			if (!isUnder46())
			{
				if (!(szToken = token.getToken())) return false;
				if (strcmp(szToken, STORAGE_EXPEND)) return false;
			}
		}

		if (!loadLayerGroup(token, layer)) return false;

		if (strcmp(token.getToken(), STORAGE_OBJECT_END)) return false;

		return true;
	}
	bool a2dLoader4x::loadLayerGroup(a2dToken4x& token, azVisual::Layer* layer)
	{
		if (_log) printf("%s - %16lld\n", __FUNCTION__, layer->base().rtid());


		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;

			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, "vLayer"))
			{
				if (strcmp(szToken, STORAGE_EXPEND)) return false;

				if (!(szToken = token.getToken())) return false;
				//if (!strcmp(szToken, "false")) SetExpanded(false); else SetExpanded(true);

				if (!(szToken = token.getToken())) return false;
				if (strcmp(szToken, STORAGE_APPLY)) return false;

				if (!(szToken = token.getToken())) return false;
				if (!strcmp(szToken, "false")) layer->mutable_base()->set_apply(false);

				if (!(szToken = token.getToken())) return false;
			}
			if (strcmp(szToken, "vLayer")) return false;
		}
		else
		{
			if (isUnder46())
			{
				if (!(szToken = token.getToken())) return false;
				if (strcmp(szToken, STORAGE_EXPEND)) return false;
			}

			if (!(szToken = token.getToken())) return false;
			//if (!strcmp(szToken, "false")) SetExpanded(false); else SetExpanded(true);

			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_APPLY)) return false;

			if (!(szToken = token.getToken())) return false;
			if (!strcmp(szToken, "false")) layer->mutable_base()->set_apply(false);

			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, "layer_list")) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_LIST_BEGIN)) return false;

		while (1)
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN))
			{
				if (strcmp(szToken, STORAGE_LIST_END)) return false;

				break;
			}

			if (!(szToken = token.getToken())) return false;

			auto* child_layer = layer->add_layer_list();
			child_layer->mutable_base()->set_parent_rtid(layer->base().rtid());
			auto* azdi = _azddic.add(child_layer);
			child_layer->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());

			if (isUnder45())
			{
				if (!strcmp(szToken, "strResID"))
				{
					char szbuf[256];
					sprintf(szbuf, "%llx", azdi->getRuntimeID().getValue());
					insertBind(azdi, GetObjectName(azCLASS_TYPE(azLayer), szbuf));

					if (!loadLayer(token, child_layer)) return false;
				}
				else if (!strcmp(szToken, "LayerGroup"))
				{
					if (!loadLayerGroup(token, child_layer)) return false;
				}
				else
				{
					return false;
				}
			}
			else
			{
				if (!strcmp(szToken, "res_id"))
				{
					char szbuf[256];
					sprintf(szbuf, "%llx", azdi->getRuntimeID().getValue());
					insertBind(azdi, GetObjectName(azCLASS_TYPE(azLayer), szbuf));

					if (!loadLayer(token, child_layer)) return false;
				}
				else if (isUnder46() && !strcmp(szToken, STORAGE_OBJECT_BEGIN))
				{
					if (!loadLayerGroup(token, child_layer)) return false;

					if (!(szToken = token.getToken())) return false;
					if (strcmp(szToken, STORAGE_OBJECT_END)) return false;
				}
				else if (!isUnder46() && !strcmp(szToken, STORAGE_EXPEND))
				{
					if (!loadLayerGroup(token, child_layer)) return false;
				}
				else
				{
					return false;
				}
			}
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_OBJECT_END)) return false;

		return true;
	}
	bool a2dLoader4x::loadLayer(a2dToken4x& token, azVisual::Layer* layer)
	{
		const char* szToken;

		if (!(szToken = token.getToken())) return false;
		_layer_bind_info.push_back(TYPE_BIND_LIST::value_type(layer->base().rtid(), szToken));

		if (_log) printf("%s - 0x%llx:%s\n", __FUNCTION__, layer->base().rtid(), szToken);


		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_EXPEND)) return false;

		if (!(szToken = token.getToken())) return false;
		//if (!strcmp(szToken, "false")) SetExpanded(false); else SetExpanded(true);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_APPLY)) return false;

		if (!(szToken = token.getToken())) return false;
		if (!strcmp(szToken, "false")) layer->mutable_base()->set_apply(false);

		if (!(szToken = token.getToken())) return false;
		if (isUnder45()) { if (strcmp(szToken, "GetKeyList")) return false; }
		else { if (strcmp(szToken, "key_list")) return false; }

		if (!(szToken = token.getToken())) return false;
		if (isUnder45()) { if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false; }
		else { if (strcmp(szToken, STORAGE_LIST_BEGIN)) return false; }

		while (1)
		{
			if (!(szToken = token.getToken())) return false;
			if (isUnder45()) {
				if (!strcmp(szToken, STORAGE_OBJECT_END))
				{
					if (!(szToken = token.getToken())) return false;
					if (strcmp(szToken, STORAGE_OBJECT_END)) return false;
					break;
				}
			}
			else
			{
				if (!strcmp(szToken, STORAGE_LIST_END))
				{
					if (!(szToken = token.getToken())) return false;
					if (strcmp(szToken, STORAGE_OBJECT_END)) return false;
					break;
				}

				if (!(szToken = token.getToken())) return false;
				if (strcmp(szToken, "frame")) return false;

				if (!(szToken = token.getToken())) return false;
			}
			if (!loadKey(token, layer, atoi(szToken))) return false;
		}

		if (layer->key_list_size() > 0)
		{
			std::sort(layer->mutable_key_list()->begin(), layer->mutable_key_list()->end(),
				[](const azVisual::Key& lhs, const azVisual::Key& rhs) { return lhs.frame() < rhs.frame(); });
		}

		if (_log) printf("\n");

		return true;
	}
	bool a2dLoader4x::loadKey(a2dToken4x& token, azVisual::Layer* layer, int frame)
	{
		auto* key = layer->add_key_list();
		key->mutable_base()->set_parent_rtid(layer->base().rtid());
		auto* azdi = _azddic.add(key);
		key->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		key->set_frame(frame);

		auto* transform = key->mutable_transform();

		if (_log) printf("0x%llx:%d, ", azdi->getRuntimeID().getValue(), frame);


		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		std::string value_name;
		while (1)
		{
			if (!(szToken = token.getToken())) return false;
			if (!strcmp(szToken, STORAGE_OBJECT_END)) break;

			value_name = szToken;

			if (!(szToken = token.getToken())) return false;

			if      (value_name == "sX")		{ transform->set_scale_x((float)atof(szToken)); }
			else if (value_name == "sY")		{ transform->set_scale_y((float)atof(szToken)); }
			else if (value_name == "rotate")	{ if (isUnder48()) transform->set_rotate_z((float)atof(szToken)*360.0f); else transform->set_rotate_z((float)atof(szToken)); }
			else if (value_name == "pX")		{ transform->set_position_x((float)atof(szToken)); }
			else if (value_name == "pY")		{ transform->set_position_y((float)atof(szToken)); }
			else if (value_name == "cX")		{ transform->set_offset_x((float)atof(szToken)); }
			else if (value_name == "cY")		{ transform->set_offset_y((float)atof(szToken)); }
			else if (value_name == "hflip")		{ transform->set_flip_h((!strcmp(szToken, "H")) ? true : false); }
			else if (value_name == "vflip")		{ transform->set_flip_v((!strcmp(szToken, "V")) ? true : false); }

			else if (value_name == "blank")		{ key->set_blank((!strcmp(szToken, "B")) ? true : false); }
			else if (value_name == "alpha")		{ key->set_alpha(atoi(szToken) / 256.0f); }
			else if (value_name == "colorRGB")
			{
				if (strcmp(szToken, STORAGE_LIST_BEGIN)) return false;

				if (!(szToken = token.getToken())) return false;
				key->set_color_r(atoi(szToken) / 256.0f);
				if (!(szToken = token.getToken())) return false;
				key->set_color_g(atoi(szToken) / 256.0f);
				if (!(szToken = token.getToken())) return false;
				key->set_color_b(atoi(szToken) / 256.0f);

				if (!(szToken = token.getToken())) return false;
				if (strcmp(szToken, STORAGE_LIST_END)) return false;
			}
			else if (value_name == "mode")
			{
 				std::string blend_name(szToken);
				std::transform(blend_name.begin(), blend_name.end(), blend_name.begin(), ::toupper);
				for (int mode = ::azModel::NONE; mode < ::azModel::BLEND_MODE_ARRAYSIZE; ++mode)
				{
					if (::azModel::BLEND_MODE_Name((::azModel::BLEND_MODE)mode) == blend_name)
					{
						key->set_blend_mode((::azModel::BLEND_MODE)mode);
						break;
					}
				}
			}
			else if (value_name == "eventShape")
			{
				std::string shape_name(szToken);
				std::transform(shape_name.begin(), shape_name.end(), shape_name.begin(), ::toupper);
				for (int type = 0; type < ::azModel::SHAPE_TYPE_ARRAYSIZE; ++type)
				{
					if (::azModel::SHAPE_TYPE_Name((::azModel::SHAPE_TYPE)type) == shape_name)
					{
						key->set_shape_type((::azModel::SHAPE_TYPE)type);
						break;
					}
				}
			}
			else if (value_name == "index")
			{
				//_key_bind_info.push_back(TYPE_BIND_LIST::value_type(key->base().rtid(), szToken));

				key->set_refrence_name(szToken);
			}
		}

		return true;
	}
	bool a2dLoader4x::loadBitmap(a2dToken4x& token, azVisual::Project* project, const char* name)
	{
		auto* bitmap = project->add_bitmap_list();
		bitmap->mutable_base()->set_parent_rtid(project->base().rtid());
		auto* azdi = _azddic.add(bitmap);
		bitmap->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		bitmap->mutable_base()->set_name(name);

		if (_log) printf("%s - 0x%llx:%s\n", __FUNCTION__, azdi->getRuntimeID().getValue(), GetObjectName(azCLASS_TYPE(azBitmap), name).c_str());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azBitmap), name));


		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_EXPEND)) return false;

		if (!(szToken = token.getToken())) return false;
		//if (!strcmp(szToken, "false")) SetExpanded(false); else SetExpanded(true);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_APPLY)) return false;

		if (!(szToken = token.getToken())) return false;
		if (!strcmp(szToken, "false")) bitmap->mutable_base()->set_apply(false);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, "sprite_list")) return false;

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_LIST_BEGIN)) return false;

		while (1)
		{
			if (strcmp(token.getToken(), STORAGE_OBJECT_BEGIN))
			{
				if (!(szToken = token.getToken())) return false;
				break;
			}

			if (!loadSprite(token, bitmap)) return false;
		}

		std::string expand(name);
		expand = expand.substr(expand.rfind("."));
		std::transform(expand.begin(), expand.end(), expand.begin(), ::tolower);
		if (expand == ".plist")
		{
			std::string path(getRealPath(_file_name, name));

#if !defined(NO_COCOS2DX)
			path = cocos2d::FileUtils::getInstance()->fullPathForFilename(path.c_str());
#endif

			tinyxml2::XMLDocument doc;
			auto xml_error = doc.LoadFile(path.c_str());
			if (xml_error != tinyxml2::XMLError::XML_NO_ERROR) return false;

			auto plist_node = doc.FirstChildElement("plist");
			if (!plist_node) return false;

			auto dict_node = plist_node->FirstChildElement("dict");
			if (!dict_node) return false;

			auto key_node = dict_node->FirstChildElement("key");
			while (key_node)
			{
				auto text = key_node->GetText();

				if(!strcmp(text, "frames"))
				{
					auto dict_node = key_node->NextSiblingElement("dict");
					if (!dict_node) return false;
					 
					auto key_node = dict_node->FirstChildElement("key");
					while (key_node)
					{
						auto sprite_name = key_node->GetText();

						auto* sprite = bitmap->add_sprite_list();
						sprite->mutable_base()->set_parent_rtid(bitmap->base().rtid());
						auto* azdi = _azddic.add(sprite);
						sprite->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
						sprite->mutable_base()->set_name(sprite_name);

						insertBind(azdi, GetObjectName(azCLASS_TYPE(azSprite), sprite_name));

						if (_log) printf("%s - %s : %s\n", __FUNCTION__, text, sprite_name);

						key_node = key_node->NextSiblingElement("key");
					}
				}
				else if (!strcmp(text, "metadata"))
				{
					auto dict_node = key_node->NextSiblingElement("dict");
					if (!dict_node) return false;

					auto key_node = dict_node->FirstChildElement("key");
					while (key_node)
					{
						auto meta_key = key_node->GetText();

						if (!strcmp(meta_key, "realTextureFileName"))
						{
							auto value_node = key_node->NextSiblingElement();
							if (!value_node) return false;

							auto value = value_node->GetText();
							if (!value) return false;

							std::string file_name(name);
							auto split_pos = file_name.rfind('\\');
							if (split_pos == std::string::npos) split_pos = file_name.rfind('/');
							if (split_pos == std::string::npos)
							{
								file_name = PROJECT_PATH + value;
							}
							else
							{
								file_name = file_name.substr(0, split_pos) + value;
							}
						}

						if (_log) printf("%s - %s : %s\n", __FUNCTION__, text, meta_key);

						key_node = key_node->NextSiblingElement("key");
					}
				}
				else
				{
					return false;
				}

				key_node = key_node->NextSiblingElement("key");
			}
		}

		return true;
	}
	bool a2dLoader4x::loadSprite(a2dToken4x& token, ::azModel::Bitmap* bitmap)
	{
		auto* sprite = bitmap->add_sprite_list();
		sprite->mutable_base()->set_parent_rtid(bitmap->base().rtid());
		auto* azdi = _azddic.add(sprite);
		sprite->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());


		const char* szToken;

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, "rect")) return false;

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_LIST_BEGIN)) return false;

		if (!(szToken = token.getToken())) return false;
		sprite->set_left(atoi(szToken));

		if (!(szToken = token.getToken())) return false;
		sprite->set_top(atoi(szToken));

		if (!(szToken = token.getToken())) return false;
		sprite->set_right(atoi(szToken));

		if (!(szToken = token.getToken())) return false;
		sprite->set_bottom(atoi(szToken));

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_LIST_END)) return false;

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, "alias")) return false;

		if (!(szToken = token.getToken())) return false;
		sprite->mutable_base()->set_name(szToken);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_OBJECT_END)) return false;

		std::string strname = GetSpriteName(sprite->left(), sprite->top(), sprite->right(), sprite->bottom());
		const char* name = sprite->base().name().c_str();
		if ((!strcmp(name, "_")) || !strcmp(name, ""))
		{
			sprite->mutable_base()->set_name(strname.c_str());
		}

		if (_log) printf("%s - 0x%llx:%s / %s\n", __FUNCTION__, azdi->getRuntimeID().getValue(), name, GetObjectName(azCLASS_TYPE(azSprite), strname.c_str()).c_str());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azSprite), strname.c_str()));

		return true;
	}
	bool a2dLoader4x::loadSocket(a2dToken4x& token, azVisual::Project* project, const char* name)
	{
		azVisual::SocketGroup* socket_group = 0;
		if (project->socket_group_list_size() < 1)
		{
			socket_group = project->add_socket_group_list();
			socket_group->mutable_base()->set_parent_rtid(project->base().rtid());
			auto* azdi = _azddic.add(socket_group);
			socket_group->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		}
		else
		{
			socket_group = project->mutable_socket_group_list(0);
		}

		auto* socket = socket_group->add_socket_list();
		socket->mutable_base()->set_parent_rtid(socket_group->base().rtid());
		auto* azdi = _azddic.add(socket);
		socket->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		socket->mutable_base()->set_name(name);

		if (_log) printf("%s - 0x%llx:%s\n", __FUNCTION__, azdi->getRuntimeID().getValue(), GetObjectName(azCLASS_TYPE(azSocket), name).c_str());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azSocket), name), project);


		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_APPLY)) return false;

		if (!(szToken = token.getToken())) return false;
		if (!strcmp(szToken, "false")) socket->mutable_base()->set_apply(false);

		if (!(szToken = token.getToken())) return false;
		if (isUnder45()) { if (strcmp(szToken, "strResID")) return false; }
		else { if (strcmp(szToken, "res_id")) return false; }

		if (!(szToken = token.getToken())) return false;
		if (*szToken)
		{
			_socket_bind_info.push_back(TYPE_BIND_LIST::value_type(azdi->getRuntimeID().getValue(), szToken));
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_OBJECT_END)) return false;

		return true;
	}
	bool a2dLoader4x::loadEventBox(a2dToken4x& token, azVisual::Project* project, const char* name)
	{
		azVisual::EventShapeGroup* event_shape_group = 0;
		if (project->event_shape_group_list_size() < 1)
		{
			event_shape_group = project->add_event_shape_group_list();
			event_shape_group->mutable_base()->set_parent_rtid(project->base().rtid());
			auto* azdi = _azddic.add(event_shape_group);
			event_shape_group->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		}
		else
		{
			event_shape_group = project->mutable_event_shape_group_list(0);
		}

		auto* event_shape = event_shape_group->add_event_shape_list();
		event_shape->mutable_base()->set_parent_rtid(event_shape_group->base().rtid());
		auto* azdi = _azddic.add(event_shape);
		event_shape->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		event_shape->mutable_base()->set_name(name);

		if (_log) printf("%s - 0x%llx:%s\n", __FUNCTION__, azdi->getRuntimeID().getValue(), GetObjectName(azCLASS_TYPE(azEventBox), name).c_str());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azEventBox), name), project);


		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_APPLY)) return false;

		if (!(szToken = token.getToken())) return false;
		if (!strcmp(szToken, "false")) event_shape->mutable_base()->set_apply(false);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_OBJECT_END)) return false;

		return true;
	}
	bool a2dLoader4x::loadParticle(a2dToken4x& token, azVisual::Project* project, const char* name)
	{
		azVisual::ParticleGroup* particle_group = 0;
		if (project->particle_group_list_size() < 1)
		{
			particle_group = project->add_particle_group_list();
			particle_group->mutable_base()->set_parent_rtid(project->base().rtid());
			auto* azdi = _azddic.add(particle_group);
			particle_group->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		}
		else
		{
			particle_group = project->mutable_particle_group_list(0);
		}

		auto* particle = particle_group->add_particle_list();
		particle->mutable_base()->set_parent_rtid(particle_group->base().rtid());
		auto* azdi = _azddic.add(particle);
		particle->mutable_base()->set_rtid(azdi->getRuntimeID().getValue());
		particle->mutable_base()->set_name(name);

		if (_log) printf("%s - 0x%llx:%s\n", __FUNCTION__, azdi->getRuntimeID().getValue(), GetObjectName(azCLASS_TYPE(azParticle), name).c_str());

		insertBind(azdi, GetObjectName(azCLASS_TYPE(azParticle), name), project);


		const char* szToken;

		if (isUnder45())
		{
			if (!(szToken = token.getToken())) return false;
			if (strcmp(szToken, STORAGE_OBJECT_BEGIN)) return false;
		}

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_APPLY)) return false;

		if (!(szToken = token.getToken())) return false;
		if (!strcmp(szToken, "false")) particle->mutable_base()->set_apply(false);

		if (!(szToken = token.getToken())) return false;
		if (strcmp(szToken, STORAGE_OBJECT_END)) return false;

		return true;
	}
	bool a2dLoader4x::loadUnknown(a2dToken4x& token, const char* name)
	{
		const char* szToken;

		int depth = 1;
		while (szToken = token.getToken())
		{
			if (!strcmp(szToken, STORAGE_OBJECT_BEGIN))
			{
				++depth;
			}
			else if (!strcmp(szToken, STORAGE_OBJECT_END))
			{
				--depth;
				if (depth == 0) break;
				if (depth < 0) return false;
			}
		}

		if (!szToken) return false;

		return true;
	}

	void a2dLoader4x::insertBind(::azModel::AzDataInfo* azdi, const std::string& name)
	{
		auto rtid_n_name = _rtid_to_name.find(azdi->getParentRuntimeID().getValue());
		if (rtid_n_name == _rtid_to_name.end() || rtid_n_name->first != azdi->getParentRuntimeID().getValue())
		{
			_name_to_rtid.insert(TYPE_NAME_TO_RTID_LIST::value_type(name, azdi->getRuntimeID().getValue()));
			_rtid_to_name.insert(TYPE_RTID_TO_NAME_LIST::value_type(azdi->getRuntimeID().getValue(), name));
		}
		else
		{
			std::string fullname = rtid_n_name->second + name;
			_name_to_rtid.insert(TYPE_NAME_TO_RTID_LIST::value_type(fullname, azdi->getRuntimeID().getValue()));
			_rtid_to_name.insert(TYPE_RTID_TO_NAME_LIST::value_type(azdi->getRuntimeID().getValue(), fullname));
		}
	}
	void a2dLoader4x::insertBind(::azModel::AzDataInfo* azdi, const std::string& name, azVisual::Project* project)
	{
		auto rtid_n_name = _rtid_to_name.find(project->base().rtid());
		if (rtid_n_name == _rtid_to_name.end() || rtid_n_name->first != project->base().rtid())
		{
			_name_to_rtid.insert(TYPE_NAME_TO_RTID_LIST::value_type(name, azdi->getRuntimeID().getValue()));
			_rtid_to_name.insert(TYPE_RTID_TO_NAME_LIST::value_type(azdi->getRuntimeID().getValue(), name));
		}
		else
		{
			std::string fullname = rtid_n_name->second + name;
			_name_to_rtid.insert(TYPE_NAME_TO_RTID_LIST::value_type(fullname, azdi->getRuntimeID().getValue()));
			_rtid_to_name.insert(TYPE_RTID_TO_NAME_LIST::value_type(azdi->getRuntimeID().getValue(), fullname));
		}
	}

	bool a2dLoader4x::bindSocket()
	{
		if (_log) printf("%s - dump socket bind list\n", __FUNCTION__);
		for (auto& bind_info : _socket_bind_info)
		{
			if (_log) printf("0x%llx - %s\n", bind_info.first, bind_info.second.c_str());

			unsigned long long referencer_rtid = bind_info.first;
			auto* azdi = _azddic.get(referencer_rtid);
			if (!azdi)
			{
				if (_log) printf("bind failed !! \n");
				continue;
			}

			AzData* data = azdi->getData();
			if (!data) return false;

			azVisual::Socket* socket = dynamic_cast<azVisual::Socket*>(data);
			if (!socket) return false;

			std::string& referenced_name = bind_info.second;
			auto name_n_rtid = _name_to_rtid.find(referenced_name);
			if (name_n_rtid == _name_to_rtid.end())
			{
				if (_log) printf("bind failed !! \n");
				continue;
			}

			socket->set_reference_rtid(name_n_rtid->second);
		}
		if (_log) printf("dump socket bind list\n");

		return true;
	}
	bool a2dLoader4x::bindLayer()
	{
		if (_log) printf("%s - dump layer bind list\n", __FUNCTION__);
		for (auto& bind_info : _layer_bind_info)
		{
			if (_log) printf("0x%llx - %s  -  ", bind_info.first, bind_info.second.c_str());

			unsigned long long referencer_rtid = bind_info.first;
			std::string& referenced_name = bind_info.second;

			auto* azdi = _azddic.get(referencer_rtid);
			if (!azdi)
			{
				if (_log) printf("bind failed !! \n");
				continue;
			}

			AzData* data = azdi->getData();
			if (!data) return false;

			azVisual::Layer* layer = dynamic_cast<azVisual::Layer*>(data);
			if (!layer) return false;

			auto name_n_rtid = _name_to_rtid.find(referenced_name);
			if (name_n_rtid == _name_to_rtid.end())
			{
				if (_log) printf("bind failed !! \n");
				continue;
			}

			layer->set_reference_rtid(name_n_rtid->second);

			if (_log) printf("0x%llx\n", name_n_rtid->second);
		}
		if (_log) printf("dump layer bind list\n");

		return true;
	}
}
