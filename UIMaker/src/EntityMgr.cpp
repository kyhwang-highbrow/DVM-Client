#include "EntityMgr.h"
#include "CMDPipe.h"

#include "KLuaToken.h"

#include <string>

#include "CSLock.h"
#ifdef GetMessage
#undef GetMessage
#endif


std::wstring UTF16LE(const std::string& _str);
std::wstring UTF16(const std::string& _str);
std::string UTF8(const std::wstring& _str);
std::string ASCII(const std::wstring& _str);


CEntityMgr* CEntityMgr::sm_instance = nullptr;
::google::protobuf::uint64 CEntityMgr::sm_id = 0;


extern "C" void shutdownCocos2d();

CEntityMgr::CEntityMgr() : m_root(nullptr), m_current(INVALID_ID)
{
	m_file_version = makeVersion(1, 1, 2);
	init();
}
CEntityMgr::~CEntityMgr()
{
	clear();
}

CEntityMgr* CEntityMgr::getInstance()
{
	if (!sm_instance)
	{
		sm_instance = new CEntityMgr;
	}

	return sm_instance;
}
void CEntityMgr::destroyInstance()
{
	if (!sm_instance) return;

	delete sm_instance;
	sm_instance = nullptr;

	::google::protobuf::ShutdownProtobufLibrary();
	shutdownCocos2d();
}

bool CEntityMgr::init()
{
	maker::Properties properties;
	properties.set_type(maker::ENTITY__Menu);
	CEntityMgr::fillDefaultValue(properties);
    properties.mutable_node()->set_relative_size_type(maker::RELATIVE_SIZE_TYPE__BOTH);

	m_root = create(bookingId(), INVALID_ID, properties, ::google::protobuf::RepeatedPtrField< ::maker::Entity >());
	if (!m_root)
	{
		return false;
	}
	m_root->set_selected(true);
	m_current = m_root->id();
	return true;
}
void CEntityMgr::clear()
{
	if (getRoot())
	{
		delete m_root; 
		m_root = nullptr;
	}

	_clipboard.Clear();

	m_current = INVALID_ID;

	sm_id = 0;

    {
        CSLock cs;
        m_node_bind.clear();
    }

	m_base_folder_path.clear();
}

maker::Entity* CEntityMgr::getRoot() const
{
	return m_root;
}
maker::Entity* CEntityMgr::getCurrent() const
{
	return get(m_current);
}
CEntityMgr::ID CEntityMgr::getCurrentID() const
{
	return m_current;
}
void CEntityMgr::setCurrentID(ID id)
{
	m_current = id;
}
maker::Entity* CEntityMgr::get(ID id) const
{
    CSLock cs;

	auto iter = m_node_bind.find(id);
	if (iter == m_node_bind.end()) return nullptr;

	return iter->second;
}
maker::Entity* CEntityMgr::getParent(ID id) const
{
	return getParent(get(id));
}
maker::Entity* CEntityMgr::getParent(const maker::Entity* entity) const
{
	return get(entity->parent_id());
}
maker::Entity* CEntityMgr::getPrevSibling(ID id) const
{
	auto entity = get(id);
	auto parent = entity ? get(entity->parent_id()) : nullptr;
	if (!parent || !entity) return nullptr;
	if (parent == entity) return nullptr;

	const maker::Entity* prev_sibling = nullptr;

	auto& children = parent->children();
	for (auto i = children.begin(); i != children.end(); ++i)
	{
		auto child = &(*i);
		if (child == entity)
		{
			return const_cast<maker::Entity*>(prev_sibling);
		}

		prev_sibling = child;
	}

	return nullptr;
}
maker::Entity* CEntityMgr::getNextSibling(ID id) const
{
	auto entity = get(id);
	auto parent = entity ? get(entity->parent_id()) : nullptr;
	if (!parent || !entity) return nullptr;
	if (parent == entity) return nullptr;

	auto& children = parent->children();
	for (auto i = children.begin(); i != children.end(); ++i)
	{
		auto child = &(*i);
		if (child == entity)
		{
			++i;
			if (i == children.end()) return nullptr;
			return const_cast<maker::Entity*>(&(*i));
		}
	}

	return nullptr;
}
maker::Entity* CEntityMgr::getLastSibling(ID id) const
{
	auto entity = get(id);
	auto parent = entity ? get(entity->parent_id()) : nullptr;
	if (!parent || !entity) return nullptr;
	if (parent == entity) return nullptr;

	auto cildren_count = parent->children_size();
	if (cildren_count <= 0) return nullptr;

	auto& children = parent->children();
	auto& child = children.Get(cildren_count - 1);

	return const_cast<maker::Entity*>(&child);
}

static bool isChild(const maker::Entity* parent, const maker::Entity* entity)
{
	if (!parent || !entity) return false;
	if (parent == entity) return false;

	auto& children = parent->children();
	for (auto i = children.begin(); i != children.end(); ++i)
	{
		auto child = &(*i);
		if (child == entity)
		{
			return true;
		}
		if (isChild(child, entity)) return true;
	}
	return false;
}
bool CEntityMgr::isChild(ID parent_id, ID id) const
{
	return ::isChild(get(parent_id), get(id));
}
bool CEntityMgr::isLabel(ID id) const
{
	return isLabel(get(id));
}
bool CEntityMgr::isLabel(const maker::Entity* Entity) const
{
	if (!Entity) return false;

	auto properties = Entity->properties();
	auto desc = properties.GetDescriptor();
	auto reflect = properties.GetReflection();
	if (!desc || !reflect) return false;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;
		if (field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

		if (!reflect->HasField(properties, field)) continue;

		auto& message_name = field->message_type()->name();
		if (message_name.find("Label") != std::string::npos) return true;
	}
	return false;
}
void CEntityMgr::getSelectedChildren(TYPE_SELECTED_ENTITIES& selected_entities)
{
    CSLock cs;

	for (auto& iter_entity : m_node_bind)
	{
		auto entity = iter_entity.second;
		if (!entity) continue;
		if (!entity->selected()) continue;

		selected_entities.push_back(entity);
	}
}
void CEntityMgr::getSelectedNearestChildren(TYPE_SELECTED_ENTITIES& selected_entities)
{
    CSLock cs;

	for (auto& iter_entity : m_node_bind)
	{
		auto entity = iter_entity.second;
		if (!entity) continue;
		if (!entity->selected()) continue;

		auto parent = get(entity->parent_id());
		while (parent)
		{
			if (parent->selected())
			{
				entity->set_parent_selected(true);
				break;
			}
			parent = get(parent->parent_id());
		}
		if (entity->parent_selected()) continue;

		selected_entities.push_back(entity);
	}
}

static void clearAllSelectedFlag(maker::Entity* entity)
{
	if (!entity) return;

	entity->set_selected(false);

	for (int i = 0; i < entity->children_size(); ++i)
	{
		clearAllSelectedFlag(entity->mutable_children()->Mutable(i));
	}
}
void CEntityMgr::clearAllSelectedFlag()
{
	::clearAllSelectedFlag(getRoot());
}

CEntityMgr::ID CEntityMgr::bookingId() const
{
	return ++sm_id;
}
maker::Entity* CEntityMgr::create(ID booked_id, ID parent_id, const::maker::Properties& src_properties, const ::google::protobuf::RepeatedPtrField< ::maker::Entity >& src_children)
{
	auto entity = get(booked_id);
	if (entity)
	{
		if (entity->properties().type() != src_properties.type())
		{
			return nullptr;
		}
		return entity;
	}

	auto parent = get(parent_id);
	if (parent)
	{
		entity = parent->add_children();
	}
	else
	{
		entity = maker::Entity::default_instance().New();
	}
	if (!entity) return nullptr;

	entity->set_id(booked_id);
	entity->set_parent_id(parent_id);
	entity->mutable_properties()->CopyFrom(src_properties);

	auto children = entity->mutable_children();
	children->CopyFrom(src_children);

	appendChildren(children);

    {
        CSLock cs;
        m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(booked_id, entity));
    }

	return entity;
}
void CEntityMgr::appendChildren(::google::protobuf::RepeatedPtrField< ::maker::Entity >* children)
{
	for (auto& child : *children)
	{
        {
            CSLock cs;
            m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(child.id(), &(child)));
        }

		if (child.children_size() > 0)
		{
			auto children_of_child = child.mutable_children();
			appendChildren(children_of_child);
		}
	}
}

bool CEntityMgr::remove(ID id, ID parent_id)
{
    CSLock cs;

	auto iter = m_node_bind.find(id);
	if (iter == m_node_bind.end()) return false;

	auto entity = iter->second;

	maker::Entity* parent = nullptr;
	if (parent_id == CEntityMgr::INVALID_ID)
	{
		parent = m_root;
	}
	else
	{
		auto iter_parent = m_node_bind.find(parent_id);
		if (iter_parent == m_node_bind.end()) return false;

		parent = iter_parent->second;
	}

	if (!entity || !parent) return false;

	auto children = parent->mutable_children();
	if (!children) return false;

	int remove_index = 0;
	for (auto i = children->begin(); i != children->end(); ++i, ++remove_index)
	{
		if (entity == &(*i)) break;
	}
	if (remove_index >= children->size()) return false;

	maker::Entity* extract_entity;
	children->ExtractSubrange(remove_index, 1, &extract_entity);

	if (entity->children_size() > 0)
	{
		unbindChildren(entity->mutable_children());
	}

	delete extract_entity;

	m_node_bind.erase(iter);

	return true;
}
void CEntityMgr::unbindChildren(::google::protobuf::RepeatedPtrField< ::maker::Entity >* children)
{
    CSLock cs;

	for (auto& child : *children)
	{
		auto iter = m_node_bind.find(child.id());
		if (iter != m_node_bind.end())
		{
			m_node_bind.erase(iter);
		}

		if (child.children_size() > 0)
		{
			auto children_of_child = child.mutable_children();
			unbindChildren(children_of_child);
		}
	}
}

bool CEntityMgr::checkMoveNext(ID id, ID parent_id, ID dest_id, ID dest_parent_id)
{
	if (parent_id == dest_parent_id && id == dest_id) return false;

	const auto entity = get(id);
	const auto parent = get(parent_id);
	const auto dest = get(dest_id);
	const auto dest_parent = get(dest_parent_id);

	if (!entity) return false;
	if (!parent) return false;
	if (!dest_parent) return false;

	// Label 계열은 자식을 붙일 수 없다.
	if (isLabel(dest_parent)) return false;

	// 부모가 자식 객체의 자식으로 등록 할 수 없다.
	if (::isChild(entity, dest)) return false;
	if (::isChild(entity, dest_parent)) return false;

	auto from_children = const_cast<maker::Entity*>(parent)->mutable_children();
	if (!from_children) return false;

	int from_index = 0;
	for (auto i = from_children->begin(); i != from_children->end(); ++i, ++from_index)
	{
		if (entity == &(*i)) break;
	}

	if (parent == dest_parent && from_index == 0 && dest == nullptr)
	{
		return false;
	}

	auto to_children = const_cast<maker::Entity*>(dest_parent)->mutable_children();
	if (!to_children) return false;

	return true;
}
bool CEntityMgr::moveNext(ID id, ID parent_id, ID dest_id, ID dest_parent_id)
{
	if (parent_id == dest_parent_id && id == dest_id) return false;

	const auto entity = get(id);
	const auto parent = get(parent_id);
	const auto dest = get(dest_id);
	const auto dest_parent = get(dest_parent_id);

	if (!entity) return false;
	if (!parent) return false;
	if (!dest_parent) return false;

	// Label 계열은 자식을 붙일 수 없다.
	if (isLabel(dest_parent)) return false;

	// 부모가 자식 객체의 자식으로 등록 할 수 없다.
	if (::isChild(entity, dest)) return false;
	if (::isChild(entity, dest_parent)) return false;

	auto from_children = const_cast<maker::Entity*>(parent)->mutable_children();
	if (!from_children) return false;

	int from_index = 0;
	for (auto i = from_children->begin(); i != from_children->end(); ++i, ++from_index)
	{
		if (entity == &(*i)) break;
	}

	if (parent == dest_parent && from_index == 0 && dest == nullptr)
	{
		return false;
	}

	auto to_children = const_cast<maker::Entity*>(dest_parent)->mutable_children();
	if (!to_children) return false;

	maker::Entity* extract_entity;
	from_children->ExtractSubrange(from_index, 1, &extract_entity);

	assert(extract_entity == entity&&"MoveNextEntity - extract Entity failed !!");

	int to_index = 0;
	if (dest)
	{
		to_index = 1;
		for (auto i = to_children->begin(); i != to_children->end(); ++i, ++to_index)
		{
			if (dest == &(*i)) break;
		}
	}

	extract_entity->set_parent_id(dest_parent_id);

	int next_entityies_count = 0;
	maker::Entity** next_entityies = nullptr;
	if (to_index >= to_children->size())
	{
		to_children->AddAllocated(extract_entity);
	}
	else
	{
		next_entityies_count = to_children->size() - to_index;
		next_entityies = new maker::Entity*[next_entityies_count];
		to_children->ExtractSubrange(to_index, next_entityies_count, next_entityies);

		to_children->AddAllocated(extract_entity);
	}

	if (next_entityies)
	{
		for (int i = 0; i < next_entityies_count; ++i)
		{
			to_children->AddAllocated(next_entityies[i]);
		}

		delete[] next_entityies;
		next_entityies = nullptr;
	}

	return true;
}

std::string CEntityMgr::getEnumNameforTool(const ::google::protobuf::EnumValueDescriptor* evdesc)
{
	std::string enum_string(evdesc->name());
	std::string::size_type split_pos = enum_string.rfind("__");
	if (split_pos != std::string::npos &&
		split_pos + 2 < enum_string.length())
	{
		enum_string = enum_string.substr(split_pos + 2, std::string::npos);
	}
	return enum_string;
}
const ::google::protobuf::EnumValueDescriptor* CEntityMgr::getEnumValueformFile(const ::google::protobuf::EnumDescriptor* edesc, const std::string& name)
{
	for (int i = 0; i < edesc->value_count(); ++i)
	{
		auto evdesc = edesc->value(i);
		if (!evdesc) continue;

		if (CEntityMgr::getInstance()->getEnumNameforTool(evdesc) == name) return evdesc;
	}
	return nullptr;
}

static void fillDefaultValue(::google::protobuf::Message* msg)
{
	if (!msg) return;

	auto desc = msg->GetDescriptor();
	auto reflect = msg->GetReflection();
	if (!desc || !reflect) return;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		switch (field->type())
		{
		case ::google::protobuf::FieldDescriptor::TYPE_INT32: reflect->SetInt32(msg, field, field->default_value_int32()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_INT64: reflect->SetInt64(msg, field, field->default_value_int64()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT32: reflect->SetUInt32(msg, field, field->default_value_uint32()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT64: reflect->SetUInt64(msg, field, field->default_value_uint64()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_FLOAT: reflect->SetFloat(msg, field, field->default_value_float()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_DOUBLE: reflect->SetDouble(msg, field, field->default_value_double()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_STRING: reflect->SetString(msg, field, field->default_value_string()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_BOOL: reflect->SetBool(msg, field, field->default_value_bool()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_ENUM: reflect->SetEnum(msg, field, field->default_value_enum()); break;
		case ::google::protobuf::FieldDescriptor::TYPE_MESSAGE: fillDefaultValue(reflect->MutableMessage(msg, field)); break;
		}
	}
}
bool CEntityMgr::fillDefaultValue(maker::Properties& properties)
{
	auto desc = properties.GetDescriptor();
	auto reflect = properties.GetReflection();
	auto* edesc = maker::ENTITY_TYPE_descriptor();
	if (!desc || !reflect || !edesc) return false;

	auto type = properties.type();

	auto* evdesc = edesc->FindValueByNumber(type);
	if (!evdesc) return false;

	if (type < maker::ENTITY__NoNeedNode)
	{
		auto node = properties.mutable_node();
		if (!node) return false;

		::fillDefaultValue(node);
	}

	std::string type_name(getEnumNameforTool(evdesc));

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto* field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;
		if (field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

		if (field->message_type()->name() == type_name)
		{
			auto msg_field = reflect->MutableMessage(&properties, field);

			::fillDefaultValue(msg_field);
		}
	}

	return true;
}

bool CEntityMgr::isFileProperty(const std::string& name)
{
	if (name == "FILE" ||
		name == "FILE_IMAGE" ||
		name == "FILE_SOUND" ||
		name == "FILE_BMFONT" ||
		name == "FILE_TTF" ||
		name == "FILE_VISUAL" ||
		name == "FILE_PLIST") return true;
	return false;
}
bool CEntityMgr::isScriptProperty(const std::string& name)
{
	if (name == "MULTI_LINE_SCRIPT") return true;
	return false;
}
bool CEntityMgr::isEnumNameProperty(const std::string& name)
{
	if (name == "NAME_VISUAL_GROUP" ||
		name == "NAME_VISUAL") return true;
	return false;
}
std::string CEntityMgr::refineFilePath(const std::string& file_path)
{
	if (getBaseFolderPath().empty()) return file_path;

	auto pos = file_path.find(getBaseFolderPath());
	if (pos != 0) return file_path;

	return file_path.substr(getBaseFolderPath().size());
}

bool CEntityMgr::canAppendChild(maker::ENTITY_TYPE parent, maker::ENTITY_TYPE child)
{
	switch (parent)
	{
	case maker::ENTITY__LabelTTF:
	case maker::ENTITY__LabelSystemFont:
		return false;
	}
	return true;
}

bool CEntityMgr::SaveEnum(FILE* file, const std::string& field_name, const ::google::protobuf::EnumValueDescriptor* evdesc, const std::string& indent)
{
	if (!evdesc) return false;

	char szbuf[1024];
	auto& enum_name = evdesc->type()->name();
	if (enum_name == "DOCK_POINT")
	{
		switch (evdesc->number())
		{
		case maker::DOCK__BOTTOM_LEFT:   sprintf_s(szbuf, "{ %f; %f; }", 0.0f, 0.0f); break;
		case maker::DOCK__BOTTOM_CENTER: sprintf_s(szbuf, "{ %f; %f; }", 0.5f, 0.0f); break;
		case maker::DOCK__BOTTOM_RIGHT:  sprintf_s(szbuf, "{ %f; %f; }", 1.0f, 0.0f); break;
		case maker::DOCK__MIDDLE_LEFT:   sprintf_s(szbuf, "{ %f; %f; }", 0.0f, 0.5f); break;
		case maker::DOCK__MIDDLE_CENTER: sprintf_s(szbuf, "{ %f; %f; }", 0.5f, 0.5f); break;
		case maker::DOCK__MIDDLE_RIGHT:  sprintf_s(szbuf, "{ %f; %f; }", 1.0f, 0.5f); break;
		case maker::DOCK__TOP_LEFT:      sprintf_s(szbuf, "{ %f; %f; }", 0.0f, 1.0f); break;
		case maker::DOCK__TOP_CENTER:	   sprintf_s(szbuf, "{ %f; %f; }", 0.5f, 1.0f); break;
		case maker::DOCK__TOP_RIGHT:	   sprintf_s(szbuf, "{ %f; %f; }", 1.0f, 1.0f); break;
		default: return false;
		}
	}
	else if (enum_name == "ANCHOR_POINT")
	{
		switch (evdesc->number())
		{
		case maker::ANCHOR__BOTTOM_LEFT:   sprintf_s(szbuf, "{ %f; %f; }", 0.0f, 0.0f); break;
		case maker::ANCHOR__BOTTOM_CENTER: sprintf_s(szbuf, "{ %f; %f; }", 0.5f, 0.0f); break;
		case maker::ANCHOR__BOTTOM_RIGHT:  sprintf_s(szbuf, "{ %f; %f; }", 1.0f, 0.0f); break;
		case maker::ANCHOR__MIDDLE_LEFT:   sprintf_s(szbuf, "{ %f; %f; }", 0.0f, 0.5f); break;
		case maker::ANCHOR__MIDDLE_CENTER: sprintf_s(szbuf, "{ %f; %f; }", 0.5f, 0.5f); break;
		case maker::ANCHOR__MIDDLE_RIGHT:  sprintf_s(szbuf, "{ %f; %f; }", 1.0f, 0.5f); break;
		case maker::ANCHOR__TOP_LEFT:      sprintf_s(szbuf, "{ %f; %f; }", 0.0f, 1.0f); break;
		case maker::ANCHOR__TOP_CENTER:    sprintf_s(szbuf, "{ %f; %f; }", 0.5f, 1.0f); break;
		case maker::ANCHOR__TOP_RIGHT:     sprintf_s(szbuf, "{ %f; %f; }", 1.0f, 1.0f); break;
		default: return false;
		}
	}
	else // BLEND_FUNCTION, TEXT_ALIGNMENT_H, TEXT_ALIGNMENT_V 는 값만 저장
	{
		sprintf_s(szbuf, "%d", evdesc->number());
	}

	fprintf(file, "%s%s = %s;\n", indent.c_str(), field_name.c_str(), szbuf);

	return true;
}
bool CEntityMgr::SaveFieldMessage(FILE* file, const std::string& field_name, const ::google::protobuf::Message& msg, const std::string& indent)
{
	char szbuf[1024];
	auto& name = msg.GetDescriptor()->name();
	if (name == "COLOR")
	{
		auto color = dynamic_cast<const maker::COLOR*>(&msg);
		if (!color) return false;

		sprintf_s(szbuf, "{ %d; %d; %d; }", color->r(), color->g(), color->b());
	}
	else if (isFileProperty(name))
	{
		auto desc = msg.GetDescriptor();
		auto reflect = msg.GetReflection();
		auto& v = reflect->GetString(msg, desc->FindFieldByName("path"));

		auto refined_file_path = refineFilePath(v);

		sprintf_s(szbuf, "'%s'", refined_file_path.c_str());
	}
	else if (isScriptProperty(name))
	{
		auto desc = msg.GetDescriptor();
		auto reflect = msg.GetReflection();
		auto& v = reflect->GetString(msg, desc->FindFieldByName("script"));

		sprintf_s(szbuf, "'%s'", v.c_str());
	}
	else if (isEnumNameProperty(name))
	{
		auto desc = msg.GetDescriptor();
		auto reflect = msg.GetReflection();
		auto& v = reflect->GetString(msg, desc->FindFieldByName("name"));

		sprintf_s(szbuf, "'%s'", v.c_str());
	}
	else
	{
		return false;
	}

	fprintf(file, "%s%s = %s;\n", indent.c_str(), field_name.c_str(), szbuf);

	return true;
}
bool CEntityMgr::SaveFieldBytes(FILE* file, const std::string& field_name, const std::string& bytes, const std::string& indent)
{
	fprintf(file, "%s%s = '", indent.c_str(), field_name.c_str());
	for (auto c : bytes)
	{
		fprintf(file, "%02x", (unsigned char)c);
//		fprintf(file, "%s%s%s%s%s%s%s%s", c&(1<<0)?"1":"0", c&(1<<1)?"1":"0", c&(1<<2)?"1":"0", c&(1<<3)?"1":"0", c&(1<<4)?"1":"0", c&(1<<5)?"1":"0", c&(1<<6)?"1":"0", c&(1<<7)?"1":"0");
	}
	fprintf(file, "';\n");
	return true;
}
bool CEntityMgr::SaveField(FILE* file, const ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor* field, const std::string& indent)
{
	if (!field) return false;

	auto reflect = msg.GetReflection();
	if (!reflect) return false;

    std::string fieldName = field->name();

    // 예외 처리 상황
    if (field->name() == "rel_width")
    {
        fieldName = "width";
    }
    else if (field->name() == "rel_height")
    {
        fieldName = "height";
    }

	switch (field->type())
	{
    case ::google::protobuf::FieldDescriptor::TYPE_INT32:  fprintf(file, "%s%s = %d;\n", indent.c_str(), fieldName.c_str(), reflect->GetInt32(msg, field)); break;
    case ::google::protobuf::FieldDescriptor::TYPE_INT64:  fprintf(file, "%s%s = %lld;\n", indent.c_str(), fieldName.c_str(), reflect->GetInt64(msg, field)); break;
    case ::google::protobuf::FieldDescriptor::TYPE_UINT32: fprintf(file, "%s%s = %u;\n", indent.c_str(), fieldName.c_str(), reflect->GetUInt32(msg, field)); break;
    case ::google::protobuf::FieldDescriptor::TYPE_UINT64: fprintf(file, "%s%s = %llu;\n", indent.c_str(), fieldName.c_str(), reflect->GetUInt64(msg, field)); break;
    case ::google::protobuf::FieldDescriptor::TYPE_FLOAT:  fprintf(file, "%s%s = %f;\n", indent.c_str(), fieldName.c_str(), reflect->GetFloat(msg, field)); break;
    case ::google::protobuf::FieldDescriptor::TYPE_DOUBLE: fprintf(file, "%s%s = %lf;\n", indent.c_str(), fieldName.c_str(), reflect->GetDouble(msg, field)); break;
    case ::google::protobuf::FieldDescriptor::TYPE_STRING: fprintf(file, "%s%s = '%s';\n", indent.c_str(), fieldName.c_str(), reflect->GetString(msg, field).c_str()); break;
    case ::google::protobuf::FieldDescriptor::TYPE_BOOL:   fprintf(file, "%s%s = %s;\n", indent.c_str(), fieldName.c_str(), reflect->GetBool(msg, field) ? "true" : "false"); break;
    case ::google::protobuf::FieldDescriptor::TYPE_ENUM: if (!SaveEnum(file, fieldName, reflect->GetEnum(msg, field), indent)) return false; break;
    case ::google::protobuf::FieldDescriptor::TYPE_MESSAGE: if (!SaveFieldMessage(file, fieldName.c_str(), reflect->GetMessage(msg, field), indent)) return false; break;
    case ::google::protobuf::FieldDescriptor::TYPE_BYTES: if (!SaveFieldBytes(file, fieldName.c_str(), reflect->GetString(msg, field), indent)) return false; break;
	}
	return true;
}

bool CEntityMgr::CheckActionField(const ::google::protobuf::Message& msg, const::google::protobuf::FieldDescriptor* field)
{
    static bool isPassActionField = false;

    if (field->name() == "action_type")
    {
        auto reflect = msg.GetReflection();
        auto value = reflect->GetEnum(msg, field);
        if (value->number() == 0)
        {
            isPassActionField = true;
            return true;
        }

        return false;
    }
    else if (field->name() == "action_delay_1" ||
        field->name() == "action_delay_2" ||
        field->name() == "action_duration")
    {
        if (isPassActionField)
            return true;
        else
            return false;
    }

    isPassActionField = false;

    return false;
}

bool CEntityMgr::CheckSizeField(FILE* file, const ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor* field, const std::string& indent)
{
    static std::string fieldName[] = { "rel_width", "rel_height", "width", "height" };
    static int saveFields[2];

    static google::protobuf::Message* bkNode[2];
    static google::protobuf::FieldDescriptor* bkField[2];

    if (field->name() == "relative_size_type")
    {
        auto reflect = msg.GetReflection();
        auto value = reflect->GetEnum(msg, field);

        switch (value->number())
        {
        case 0: // kRelativeSizeNone
            saveFields[0] = 2;
            saveFields[1] = 3;
            break;
        case 1: // kRelativeSizeVertical
            saveFields[0] = 2;
            saveFields[1] = 1;
            break;
        case 2: // kRelativeSizeHorizontal
            saveFields[0] = 0;
            saveFields[1] = 3;
            break;
        case 3: // kRelativeSizeBoth
            saveFields[0] = 0;
            saveFields[1] = 1;
            break;
		case 4: // kRelativeSizeBoth와 동일
			saveFields[0] = 0;
			saveFields[1] = 1;
			break;
        }
    }
    else if (field->name() == fieldName[saveFields[0]])
    {
        bkNode[0] = const_cast<google::protobuf::Message*>(&msg);
        bkField[0] = const_cast<google::protobuf::FieldDescriptor*>(field);
    }
    else if (field->name() == fieldName[saveFields[1]])
    {
        bkNode[1] = const_cast<google::protobuf::Message*>(&msg);
        bkField[1] = const_cast<google::protobuf::FieldDescriptor*>(field);
    }

    if (field->name() == fieldName[0] ||
        field->name() == fieldName[1] ||
        field->name() == fieldName[2])
    {
        return true;
    }
    else if (field->name() == fieldName[3])
    {
        SaveField(file, *bkNode[0], bkField[0], indent);
        SaveField(file, *bkNode[1], bkField[1], indent);

        return true;
    }

    return false;
}

bool CEntityMgr::SaveNode(FILE* file, const maker::Node* node, const std::string& indent)
{
	if (!node) return false;

	auto desc = node->GetDescriptor();
	auto reflect = node->GetReflection();
	if (!desc || !reflect) return false;

    for (int i = 0; i < desc->field_count(); ++i)
    {
        const auto* field = desc->field(i);
        if (!field) continue;

        if (CheckActionField(*node, field))
        {
            continue;
        }

        if (CheckSizeField(file, *node, field, indent))
        {
            continue;
        }

        if (!SaveField(file, *node, field, indent)) return false;
    }

	return true;
}
bool CEntityMgr::SaveMessage(FILE* file, const ::google::protobuf::Message& msg, const std::string& indent)
{
	auto desc = msg.GetDescriptor();
	auto reflect = msg.GetReflection();
	if (!desc || !reflect) return false;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto field = desc->field(i);
		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!SaveField(file, msg, field, indent)) return false;
	}
	return true;
}
bool CEntityMgr::Save(FILE* file, const maker::Properties& properties, const std::string& indent)
{
	auto desc = properties.GetDescriptor();
	auto reflect = properties.GetReflection();
	if (!desc || !reflect) return false;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;
		if (field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

		if (!reflect->HasField(properties, field)) continue;

		auto& property = reflect->GetMessage(properties, field);
		if (property.GetTypeName() == "maker.Node")
		{
			if (!SaveNode(file, dynamic_cast<const maker::Node*>(&property), indent)) return false;
		}
		else
		{
			if (!SaveMessage(file, property, indent)) return false;
		}
	}
	return true;
}
bool CEntityMgr::Save(FILE* file, const maker::Entity& entity, const std::string& indent)
{
	fprintf(file, "%s{\n", indent.c_str());

	std::string current_indent(indent + "\t");

	int index = 0;
	auto& children = entity.children();
	for (auto i = children.begin(); i != children.end(); ++i)
	{
		fprintf(file, "%s[%d] =\n", current_indent.c_str(), ++index);
		if (!Save(file, *i, current_indent)) return false;
	}

	auto properties = entity.properties();
	auto desc = properties.GetDescriptor();
	auto reflect = properties.GetReflection();
	if (!desc || !reflect) return false;

	auto field = desc->FindFieldByName("type");
	auto evdesc = reflect->GetEnum(properties, field);

	fprintf(file, "%stype = '%s';\n", current_indent.c_str(), getEnumNameforTool(evdesc).c_str());
	if (!Save(file, entity.properties(), current_indent)) return false;

	fprintf(file, "%s};\n", indent.c_str());

	return true;
}

bool CEntityMgr::SaveHeader(FILE* file, const std::string& indent)
{
    fprintf(file, "%stype = 'Header';\n", indent.c_str());
    fprintf(file, "%sversion = '%d.%d.%d';\n", indent.c_str(), getMajorVersion(m_file_version), getMinorVersion(m_file_version), getMaintenanceVersion(m_file_version));
    fprintf(file, "%s[1] =\n", indent.c_str());

    return true;
}

bool CEntityMgr::Save(FILE* file, const std::string& indent)
{
    fprintf(file, "%s{\n", indent.c_str());

    std::string current_indent(indent + "\t");

    SaveHeader(file, current_indent);
    bool result = Save(file, *m_root, current_indent);

    fprintf(file, "%s};\n", indent.c_str());

    return result;
}

bool CEntityMgr::Save(const std::string& filename)
{
	if (!m_root) return false;

	bool result = false;
	FILE* file = _fsopen(filename.c_str(), "wb", _SH_DENYNO);
	if (file)
	{
		std::string::size_type split_pos = filename.rfind('/');
		if (split_pos != std::string::npos)
		{
			m_base_folder_path = filename.substr(0, split_pos + 1);
		}
		else
		{
			m_base_folder_path.clear();
		}

		result = Save(file);

		fclose(file);
	}

	return result;
}

bool CEntityMgr::findField(const std::string& field_name, maker::Properties& properties, ::google::protobuf::Message*& msg, const ::google::protobuf::FieldDescriptor*& field)
{
	auto desc = properties.GetDescriptor();
	auto reflect = properties.GetReflection();
	if (!desc || !reflect) return false;

	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto property_field = desc->field(i);

		if (!property_field) continue;
		if (property_field->is_repeated()) continue;
		if (property_field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

		if (!reflect->HasField(properties, property_field)) continue;

		auto& property = reflect->GetMessage(properties, property_field);
		auto property_desc = property.GetDescriptor();
		auto property_reflect = property.GetReflection();
		if (!property_desc || !property_reflect) return false;

		for (int j = 0; j < property_desc->field_count(); ++j)
		{
			field = property_desc->field(j);

			if (!field) continue;
			if (field->is_repeated()) continue;

			if (field_name == field->name())
			{
				msg = const_cast<::google::protobuf::Message*>(&property);
				return true;
			}
		}
	}
	return false;
}

unsigned long CEntityMgr::makeVersion(unsigned long major, unsigned long minor, unsigned long maintenance)
{
	return ((major & 0xff) << 24) | ((minor & 0xff) << 16) | (maintenance & 0xffff);
}
unsigned long CEntityMgr::getMajorVersion(unsigned long version)
{
	return (version >> 24) & 0xff;
}
unsigned long CEntityMgr::getMinorVersion(unsigned long version)
{
	return (version >> 16) & 0xff;
}
unsigned long CEntityMgr::getMaintenanceVersion(unsigned long version)
{
	return version & 0xffff;
}

static int getIndexFromPosition(float x, float y)
{
	/*
	0.0f, 0.0f      BOTTOM_LEFT =    0
	0.5f, 0.0f      BOTTOM_CENTER =  1
	1.0f, 0.0f      BOTTOM_RIGHT =   2
	0.0f, 0.5f      MIDDLE_LEFT =    3
	0.5f, 0.5f      MIDDLE_CENTER =  4
	1.0f, 0.5f      MIDDLE_RIGHT =   5
	0.0f, 1.0f      TOP_LEFT =       6
	0.5f, 1.0f      TOP_CENTER =     7
	1.0f, 1.0f      TOP_RIGHT =      8
	*/
	if (y == 0.0f)
	{
		if (x == 0.0f) return 0;
		else if (x == 0.5f) return 1;
		else if (x == 1.0f) return 2;
	}
	else if (y == 0.5f)
	{
		if (x == 0.0f) return 3;
		else if (x == 0.5f) return 4;
		else if (x == 1.0f) return 5;
	}
	else if (y == 1.0f)
	{
		if (x == 0.0f) return 6;
		else if (x == 0.5f) return 7;
		else if (x == 1.0f) return 8;
	}
	return -1;
}
bool CEntityMgr::LoadEnum(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token)
{
	auto evdesc = field.default_value_enum();
	if (!evdesc) return false;

	int enum_value = -1;

	auto& enum_name = evdesc->type()->name();
	if (enum_name == "DOCK_POINT")
	{
		if (token[0] != '{') return false;

		if (!(token = T.Token())) return false;
		float x = strtof(token, nullptr);
		if (!(token = T.Token())) return false;
		float y = strtof(token, nullptr);

		if (!(token = T.Token()) || token[0] != '}') return false;

		enum_value = getIndexFromPosition(x, y);
	}
	else if (enum_name == "ANCHOR_POINT")
	{
		if (token[0] != '{') return false;

		if (!(token = T.Token())) return false;
		float x = strtof(token, nullptr);
		if (!(token = T.Token())) return false;
		float y = strtof(token, nullptr);

		if (!(token = T.Token()) || token[0] != '}') return false;

		enum_value = getIndexFromPosition(x, y);
	}
	else if (enum_name == "LAYER_TYPE")
	{
		enum_value = strtol(token, nullptr, 0);
	}
	else // BLEND_FUNCTION, TEXT_ALIGNMENT_H, TEXT_ALIGNMENT_V 는 값만 저장
	{
		enum_value = strtol(token, nullptr, 0);
	}

	auto edesc = evdesc->type();
	if (!edesc) return false;

	auto ev = edesc->FindValueByNumber(enum_value);
	if (!ev) return false;

	auto reflect = msg.GetReflection();
	if (!reflect) return false;

	reflect->SetEnum(&msg, &field, ev);

	return true;
}
bool CEntityMgr::LoadFieldMessage(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token)
{
	auto& name = field.message_type()->name();
	if (name == "COLOR")
	{
		if (token[0] != '{') return false;

		if (!(token = T.Token())) return false;
		int r = strtol(token, nullptr, 0);
		if (!(token = T.Token())) return false;
		int g = strtol(token, nullptr, 0);
		if (!(token = T.Token())) return false;
		int b = strtol(token, nullptr, 0);

		if (!(token = T.Token()) || token[0] != '}') return false;

		auto reflect = msg.GetReflection();
		if (!reflect) return false;
		auto color_msg = reflect->MutableMessage(&msg, &field);
		auto color = dynamic_cast<maker::COLOR*>(color_msg);
		if (!color) return false;

		color->set_r(r);
		color->set_g(g);
		color->set_b(b);
	}
	else if (isFileProperty(name))
	{
		auto reflect = msg.GetReflection();
		if (!reflect) return false;
		auto file_msg = reflect->MutableMessage(&msg, &field);

		std::string file_path(token);
		std::replace(file_path.begin(), file_path.end(), '\\', '/');
		if (!file_path.empty() && file_path.find(':') == std::string::npos)
		{
			file_path = getBaseFolderPath() + file_path;
		}

		auto file_desc = file_msg->GetDescriptor();
		auto file_reflect = file_msg->GetReflection();
		if (!file_desc || !file_reflect) return false;
		file_reflect->SetString(file_msg, file_desc->FindFieldByName("path"), file_path);
	}
	else if (isScriptProperty(name))
	{
		auto reflect = msg.GetReflection();
		if (!reflect) return false;
		auto script_msg = reflect->MutableMessage(&msg, &field);

		auto file_desc = script_msg->GetDescriptor();
		auto file_reflect = script_msg->GetReflection();
		if (!file_desc || !file_reflect) return false;
		file_reflect->SetString(script_msg, file_desc->FindFieldByName("script"), token);
	}
	else if (isEnumNameProperty(name))
	{
		auto reflect = msg.GetReflection();
		if (!reflect) return false;
		auto name_msg = reflect->MutableMessage(&msg, &field);

		auto name_desc = name_msg->GetDescriptor();
		auto name_reflect = name_msg->GetReflection();
		if (!name_desc || !name_reflect) return false;
		name_reflect->SetString(name_msg, name_desc->FindFieldByName("name"), token);
	}
	else
	{
		return false;
	}

	return true;
}
bool CEntityMgr::LoadFieldBytes(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token)
{
	auto reflect = msg.GetReflection();
	if (!reflect) return false;

	std::string buf;

	auto bytes_size = strlen(token);
	buf.resize(bytes_size / 2);
	for (unsigned int i = 0; i < bytes_size;)
	{
		char c = 0;

		auto h = token[i++];
		if (h >= '0' && h <= '9') { c = (h - '0') << 4; }
		else if (h >= 'a' && h <= 'f') { c = (h - 'a' + 10) << 4; }
		
		auto l = token[i++];
		if (l >= '0' && l <= '9') { c |= l - '0'; }
		else if (l >= 'a' && l <= 'f') { c |= l - 'a' + 10; }

		buf.at((i - 1) >> 1) = c;
	}

	reflect->SetString(&msg, &field, buf);

	return true;
}
bool CEntityMgr::LoadField(KLuaToken& T, google::protobuf::Message* msg, const google::protobuf::FieldDescriptor* field, const char* token)
{
    auto reflect = msg->GetReflection();
    if (!reflect)
        return false;

    switch (field->type())
    {
    case ::google::protobuf::FieldDescriptor::TYPE_INT32:
        reflect->SetInt32(msg, field, strtol(token, nullptr, 0));
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_INT64:
        reflect->SetInt64(msg, field, strtoll(token, nullptr, 0));
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_UINT32:
        reflect->SetUInt32(msg, field, strtoul(token, nullptr, 0));
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_UINT64:
        reflect->SetUInt64(msg, field, strtoll(token, nullptr, 0));
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_FLOAT:
        reflect->SetFloat(msg, field, strtof(token, nullptr));
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_DOUBLE:
        reflect->SetDouble(msg, field, strtod(token, nullptr));
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_STRING:
        reflect->SetString(msg, field, token);
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_BOOL:
        reflect->SetBool(msg, field, strcmp(token, "true") ? false : true);
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_ENUM:
        if (!LoadEnum(T, *msg, *field, token))
            return false;
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_MESSAGE:
        if (!LoadFieldMessage(T, *msg, *field, token))
            return false;
        break;
    case ::google::protobuf::FieldDescriptor::TYPE_BYTES:
        if (!LoadFieldBytes(T, *msg, *field, token))
            return false;
        break;
    }

    return true;
}

bool CEntityMgr::Load(KLuaToken& T, maker::Properties& properties)
{
    struct FieldName
    {
        std::string oldName;
        std::string newName;
    };

    struct FieldValue
    {
        std::string oldValue;
        std::string newValue;
    };

    struct ChangeList
    {
        FieldName name;
        FieldValue value1;
        FieldValue value2;
    };

    static ChangeList checkList[] =
    {
        { { "is_relative_size", "relative_size_type" }, { "true", "3" }, { "false", "0" } }
    };

    int relativeSizeType = 0;

	const char* token = nullptr;
	while (true)
	{
		if (!(token = T.Token())) return false;
		if (token[0] == '}') break;

		::google::protobuf::Message* msg = nullptr;
		const ::google::protobuf::FieldDescriptor* field = nullptr;

        // 버전 별 처리
        int majorVersion = getMajorVersion(m_load_file_version);
        int minorVersion = getMinorVersion(m_load_file_version);
        int maintenanceVersion = getMaintenanceVersion(m_load_file_version);

        // 1.1.2 이전 버전
        if (m_load_file_version < makeVersion(1, 1, 2))
        {
            if (std::string(token) == checkList[0].name.oldName)
            {
                token = checkList[0].name.newName.c_str();

                findField(token, properties, msg, field);

                token = T.Token();

                if (std::string(token) == checkList[0].value1.oldValue)
                {
                    token = checkList[0].value1.newValue.c_str();
                }
                else if (std::string(token) == checkList[0].value2.oldValue)
                {
                    token = checkList[0].value2.newValue.c_str();
                }

                if (!LoadField(T, msg, field, token))
                {
                    return false;
                }

                continue;
            }
            else if (std::string(token) == "rel_width" || std::string(token) == "rel_height")
            {
                findField(token, properties, msg, field);

                token = T.Token();
                int value = atoi(token);
                value = -value;
                char buf[128];
                token = _itoa(value, buf, 10);

                if (!LoadField(T, msg, field, token))
                {
                    return false;
                }

                continue;
            }
        }
        // 1.1.2 이후 버전
        else
        {
            if (std::string(token) == "relative_size_type")
            {
                findField(token, properties, msg, field);
                token = T.Token();

                relativeSizeType = atoi(token);

                if (!LoadField(T, msg, field, token))
                {
                    return false;
                }
                
                continue;
            }
            else if (std::string(token) == "width")
            {
                switch (relativeSizeType)
                {
                case 2: // horizontal
                case 3: // both
                    token = "rel_width";
                    break;
                }

                findField(token, properties, msg, field);
                token = T.Token();

                if (!LoadField(T, msg, field, token))
                {
                    return false;
                }

                continue;
            }
            else if (std::string(token) == "height")
            {
                switch (relativeSizeType)
                {
                case 1: // vertical
                case 3: // both
                    token = "rel_height";
                    break;
                }

                findField(token, properties, msg, field);
                token = T.Token();

                if (!LoadField(T, msg, field, token))
                {
                    return false;
                }

                continue;
            }
        }

		if (!findField(token, properties, msg, field) || !msg || !field)
		{
			T.PassNextValue();
			continue;
		}

		if (!(token = T.Token())) return false;

        if (!LoadField(T, msg, field, token))
        {
            return false;
        }
	}

	return true;
}

bool CEntityMgr::Load(KLuaToken& T, maker::Entity& entity)
{
	const char* token = nullptr;

	if (!(token = T.Token()) || token[0] != '{') return false;

	int child_count = 0;
	while (true)
	{
		if (!(token = T.Token())) return false;

		if (token[0] == '[')
		{
			if (!(token = T.Token()) || atoi(token) != ++child_count) return false;
			if (!(token = T.Token()) || token[0] != ']') return false;

			auto child = entity.add_children();
			if (!child) return false;

			auto booked_id = bookingId();
			child->set_id(booked_id);
			child->set_parent_id(entity.id());

            {
                CSLock cs;
                m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(booked_id, child));
            }

			if (!Load(T, *child)) return false;
		}
		else
		{
			if (strcmp(token, "type")) return false;
			if (!(token = T.Token())) return false;

			auto properties = entity.mutable_properties();
			if (!properties) return false;
			auto desc = properties->GetDescriptor();
			auto reflect = properties->GetReflection();
			if (!desc || !reflect) return false;
			auto field = desc->FindFieldByName("type");
			if (!field) return false;
			auto ev = getEnumValueformFile(field->default_value_enum()->type(), token);
			if (!ev) return false;
			reflect->SetEnum(properties, field, ev);

			if (!fillDefaultValue(*properties)) return false;

			if (!Load(T, *properties)) return false;

			return true;
		}
	}
	return true;
}

bool CEntityMgr::LoadHeader(KLuaToken& T)
{
    const char* token = nullptr;

    if (!(token = T.Token()) || token[0] != '{') return false;
    if (!(token = T.Token())) return false;

    if (strcmp(token, "type")) return false;
    if (!(token = T.Token())) return false;

    if (strcmp(token, "Header")) return false;
    if (!(token = T.Token())) return false;

    if (!strcmp(token, "version"))
    {
        if (!(token = T.Token())) return false;

        unsigned long version_value[3] = { 1, 0, 0 };

        std::string version(token);
        std::string::size_type begin_pos = 0;
        std::string::size_type split_pos = 0;
        for (int i = 0; i < 3; ++i)
        {
            split_pos = version.find('.', begin_pos);
            if (split_pos != std::string::npos)
            {
                version_value[i] = atoi(version.substr(begin_pos, split_pos - begin_pos).c_str());
            }
            else
            {
                version_value[i] = atoi(version.substr(begin_pos, std::string::npos).c_str());
                break;
            }
            begin_pos = split_pos + 1;
        }

        m_load_file_version = makeVersion(version_value[0], version_value[1], version_value[2]);

        if (!(token = T.Token())) return false;
    }

    if (token[0] != '[') return false;
    if (!(token = T.Token()) || atoi(token) != 1) return false;
    if (!(token = T.Token()) || token[0] != ']') return false;

    return true;
}

bool CEntityMgr::Load(KLuaToken& T)
{
    if (!LoadHeader(T))
    {
        T.ResetOffset();
    }

    return Load(T, *m_root);
}

bool CEntityMgr::Load(const std::string& filename)
{
	clear();
	if (!init()) return false;

	KLuaToken token;
	if (!token.ReadFile(filename.c_str())) return false;

	std::string::size_type split_pos = filename.rfind('/');
	if (split_pos != std::string::npos)
	{
		m_base_folder_path = filename.substr(0, split_pos+1);
	}
	else
	{
		m_base_folder_path.clear();
	}

	m_load_file_version = makeVersion(1, 0, 0); // 버전 정보가 없던 버전은 1.0.0

	return Load(token);
}


void CEntityMgr::copySelectedEntitiesToClipboard()
{
	_clipboard.Clear();

	TYPE_SELECTED_ENTITIES selected_entities;
	getSelectedNearestChildren(selected_entities);

	for (auto iter : selected_entities)
	{
		auto entity = _clipboard.add_children();
		entity->CopyFrom(*iter);
	}
}

bool compare_luaname(const maker::Entity* a, const maker::Entity* b){
	auto lua_name_1 = a->properties().node().lua_name();
	auto lua_name_2 = b->properties().node().lua_name();

	return (lua_name_1.compare(lua_name_2) < 0);
}
std::list< maker::Entity*> CEntityMgr::getLuaEntitiesWithCalc()
{
	// 편의상 멤버 변수로 리스트 관리
	// 초기화
	m_lLuaEntity.clear();
	
	// 리스트 가져옴
	getLuaEntity(m_root);
	
	// 정렬
	m_lLuaEntity.sort(compare_luaname);

	return m_lLuaEntity;
}
std::list< maker::Entity*> CEntityMgr::getLuaEntities()
{
	// 단순하게 정리되어 있는 것을 반환
	return m_lLuaEntity;
}
void CEntityMgr::getLuaEntity(maker::Entity* root_entity)
{
	for (int i = root_entity->children_size() - 1; i >= 0; --i)
	{
		maker::Entity* child_entity = root_entity->mutable_children()->Mutable(i);

		// lua name 있다면 리스트에 추가
		if (child_entity->properties().node().lua_name() != "")
		{
			m_lLuaEntity.push_back(child_entity);
		}
		
		// child 있다면 재귀호출
		if (child_entity->children_size() > 0) 
		{
			getLuaEntity(child_entity);
		}
	}
}