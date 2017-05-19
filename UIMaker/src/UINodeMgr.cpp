#include "stdafx.h"
#include "UINodeMgr.h"
#include "CMDPipe.h"

#include "KLuaToken.h"


CUINodeMgr* CUINodeMgr::sm_instance = nullptr;
::google::protobuf::uint64 CUINodeMgr::sm_id = 0;


extern "C" void shutdownCocos2d();

CUINodeMgr::CUINodeMgr() : m_root(nullptr), m_current(INVALID_ID), m_backup(nullptr)
{
	init();
}
CUINodeMgr::~CUINodeMgr()
{
	clear();
}

CUINodeMgr* CUINodeMgr::getInstance()
{
	if (!sm_instance)
	{
		sm_instance = new CUINodeMgr;
	}

	return sm_instance;
}
void CUINodeMgr::destroyInstance()
{
	if (!sm_instance) return;

	delete sm_instance;
	sm_instance = nullptr;

	::google::protobuf::ShutdownProtobufLibrary();
	shutdownCocos2d();
}

bool CUINodeMgr::init()
{
	maker::Properties properties;
	properties.set_type(maker::ENTITY__Menu);
	CUINodeMgr::fillDefaultValue(properties);

	m_root = create(bookingId(), INVALID_ID, properties, ::google::protobuf::RepeatedPtrField< ::maker::Entity >());
	if (!m_root)
	{
		return false;
	}
	m_root->set_selected(true);
	m_current = m_root->id();
	return true;
}
void CUINodeMgr::clear()
{
	if (getRoot())
	{
		delete m_root; 
		m_root = nullptr;
	}

	if (m_backup)
	{
		delete m_backup;
		m_backup = nullptr;
	}

	m_current = INVALID_ID;

	sm_id = 0;

	m_node_bind.clear();

	m_base_folder_path.clear();
}

maker::Entity* CUINodeMgr::getRoot() const
{
	return m_root;
}
maker::Entity* CUINodeMgr::getCurrent() const
{
	return get(m_current);
}
CUINodeMgr::ID CUINodeMgr::getCurrentID() const
{
	return m_current;
}
void CUINodeMgr::setCurrentID(ID id)
{
	m_current = id;
}
maker::Entity* CUINodeMgr::get(ID id) const
{
	auto iter = m_node_bind.find(id);
	if (iter == m_node_bind.end()) return nullptr;

	return iter->second;
}
static maker::Entity* getParent(const maker::Entity* parent, const maker::Entity* entity)
{
	if (!parent || !entity) return nullptr;
	if (parent == entity) return nullptr;

	auto& children = parent->children();
	for (auto i = children.begin(); i != children.end(); ++i)
	{
		auto child = &(*i);
		if (child == entity)
		{
			return const_cast<maker::Entity*>(parent);
		}

		auto result = getParent(child, entity);
		if (result) return result;
	}

	return nullptr;
}
maker::Entity* CUINodeMgr::getParent(ID id) const
{
	return ::getParent(getRoot(), get(id));
}
maker::Entity* CUINodeMgr::getPrevSibling(ID id) const
{
	auto entity = get(id);
	auto parent = ::getParent(getRoot(), entity);
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
maker::Entity* CUINodeMgr::getNextSibling(ID id) const
{
	auto entity = get(id);
	auto parent = ::getParent(getRoot(), entity);
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
maker::Entity* CUINodeMgr::getLastSibling(ID id) const
{
	auto entity = get(id);
	auto parent = ::getParent(getRoot(), entity);
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
bool CUINodeMgr::isChild(ID parent_id, ID id) const
{
	return ::isChild(get(parent_id), get(id));
}
static bool isLabel(const maker::Entity* entity)
{
	if (!entity) return false;

	auto properties = entity->properties();
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
bool CUINodeMgr::isLabel(ID id) const
{
	return ::isLabel(get(id));
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
void CUINodeMgr::clearAllSelectedFlag()
{
	::clearAllSelectedFlag(getRoot());
}

CUINodeMgr::ID CUINodeMgr::bookingId() const
{
	return ++sm_id;
}
maker::Entity* CUINodeMgr::create(ID booked_id, ID parent_id, const::maker::Properties& src_properties, const ::google::protobuf::RepeatedPtrField< ::maker::Entity >& src_children)
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

	entity->mutable_properties()->CopyFrom(src_properties);

	auto children = entity->mutable_children();
	children->CopyFrom(src_children);

	appendChildren(children);

	m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(booked_id, entity));

	return entity;
}
void CUINodeMgr::appendChildren(::google::protobuf::RepeatedPtrField< ::maker::Entity >* children)
{
	for (auto child = children->begin(); child != children->end(); ++child)
	{
		m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(child->id(), &(*child)));

		if (child->children_size() > 0)
		{
			auto children_of_child = child->mutable_children();
			appendChildren(children_of_child);
		}
	}
}

bool CUINodeMgr::remove(ID id, ID parent_id)
{
	auto iter = m_node_bind.find(id);
	if (iter == m_node_bind.end()) return false;

	auto entity = iter->second;

	maker::Entity* parent = nullptr;
	if (parent_id == CUINodeMgr::INVALID_ID)
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

	maker::Entity* extract_uinode;
	children->ExtractSubrange(remove_index, 1, &extract_uinode);

	// 
	for (auto i = entity->mutable_children()->begin(); i != entity->mutable_children()->end(); ++i)
	{
		auto iter = m_node_bind.find(i->id());
		if (iter == m_node_bind.end()) continue;

		m_node_bind.erase(iter);
	}

	delete extract_uinode;

	m_node_bind.erase(iter);

	return true;
}

bool CUINodeMgr::checkMoveNext(ID id, ID parent_id, ID dest_id, ID dest_parent_id)
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
	if (::isLabel(dest_parent)) return false;

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
bool CUINodeMgr::moveNext(ID id, ID parent_id, ID dest_id, ID dest_parent_id)
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
	if (::isLabel(dest_parent)) return false;

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

	maker::Entity* extract_uinode = nullptr;
	from_children->ExtractSubrange(from_index, 1, &extract_uinode);
	if (!extract_uinode) return false;

	assert(extract_uinode == entity&&"MoveNextUINode - extract entity failed !!");

	int to_index = 0;
	if (dest)
	{
		to_index = 1;
		for (auto i = to_children->begin(); i != to_children->end(); ++i, ++to_index)
		{
			if (dest == &(*i)) break;
		}
	}

	int next_uinodes_count = 0;
	maker::Entity** next_uinodes = nullptr;
	if (to_index >= to_children->size())
	{
		to_children->AddAllocated(extract_uinode);
	}
	else
	{
		next_uinodes_count = to_children->size() - to_index;
		next_uinodes = new maker::Entity*[next_uinodes_count];
		to_children->ExtractSubrange(to_index, next_uinodes_count, next_uinodes);

		to_children->AddAllocated(extract_uinode);
	}

	if (next_uinodes)
	{
		for (int i = 0; i < next_uinodes_count; ++i)
		{
			to_children->AddAllocated(next_uinodes[i]);
		}

		delete[] next_uinodes;
		next_uinodes = nullptr;
	}

	return true;
}


void CUINodeMgr::applyToViewer(const maker::Entity* entity, CUINodeMgr::ID parent_id)
{
	if (!entity) return;

	maker::CMD cmd;
	if (CCMDPipe::getInstance()->initApplytoViewer(cmd, *entity, parent_id))
	{
		CCMDPipe::getInstance()->send(cmd);
	}

	auto uinode_id = entity->id();
	for (int i = 0; i < entity->children_size(); ++i)
	{
		applyToViewer(&(entity->children().Get(i)), uinode_id);
	}
}
void CUINodeMgr::applyToViewer()
{
	maker::CMD cmd;
	cmd.set_type(maker::CMD__ClearViewer);
	CCMDPipe::getInstance()->send(cmd);

	applyToViewer(getRoot(), INVALID_ID);
}


std::string CUINodeMgr::getEnumNameforTool(const ::google::protobuf::EnumValueDescriptor* evdesc)
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
const ::google::protobuf::EnumValueDescriptor* CUINodeMgr::getEnumValueformFile(const ::google::protobuf::EnumDescriptor* edesc, const std::string& name)
{
	for (int i = 0; i < edesc->value_count(); ++i)
	{
		auto evdesc = edesc->value(i);
		if (!evdesc) continue;

		if (CUINodeMgr::getInstance()->getEnumNameforTool(evdesc) == name) return evdesc;
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
bool CUINodeMgr::fillDefaultValue(maker::Properties& properties)
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

	// 객체별 기본 값 설정
	if (type == maker::ENTITY__Menu ||
		type == maker::ENTITY__LayerColor ||
		type == maker::ENTITY__LayerGradient)
	{
		properties.mutable_node()->set_is_relative_size(true);
	}

	return true;
}

bool CUINodeMgr::isFileProperty(const std::string& name)
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
bool CUINodeMgr::isEnumNameProperty(const std::string& name)
{
	if (name == "NAME_VISUAL_GROUP" ||
		name == "NAME_VISUAL") return true;
	return false;
}
std::string CUINodeMgr::refineFilePath(const std::string& file_path)
{
	if (getBaseFolderPath().empty()) return file_path;

	auto pos = file_path.find(getBaseFolderPath());
	if (pos != 0) return file_path;

	return file_path.substr(getBaseFolderPath().size());
}

bool CUINodeMgr::SaveEnum(FILE* file, const std::string& field_name, const ::google::protobuf::EnumValueDescriptor* evdesc, const std::string& indent)
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
bool CUINodeMgr::SaveFieldMessage(FILE* file, const std::string& field_name, const ::google::protobuf::Message& msg, const std::string& indent)
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
bool CUINodeMgr::SaveField(FILE* file, const ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor* field, const std::string& indent)
{
	if (!field) return false;

	auto reflect = msg.GetReflection();
	if (!reflect) return false;

	switch (field->type())
	{
	case ::google::protobuf::FieldDescriptor::TYPE_INT32:  fprintf(file, "%s%s = %d;\n", indent.c_str(), field->name().c_str(), reflect->GetInt32(msg, field)); break;
	case ::google::protobuf::FieldDescriptor::TYPE_INT64:  fprintf(file, "%s%s = %lld;\n", indent.c_str(), field->name().c_str(), reflect->GetInt64(msg, field)); break;
	case ::google::protobuf::FieldDescriptor::TYPE_UINT32: fprintf(file, "%s%s = %u;\n", indent.c_str(), field->name().c_str(), reflect->GetUInt32(msg, field)); break;
	case ::google::protobuf::FieldDescriptor::TYPE_UINT64: fprintf(file, "%s%s = %llu;\n", indent.c_str(), field->name().c_str(), reflect->GetUInt64(msg, field)); break;
	case ::google::protobuf::FieldDescriptor::TYPE_FLOAT:  fprintf(file, "%s%s = %f;\n", indent.c_str(), field->name().c_str(), reflect->GetFloat(msg, field)); break;
	case ::google::protobuf::FieldDescriptor::TYPE_DOUBLE: fprintf(file, "%s%s = %lf;\n", indent.c_str(), field->name().c_str(), reflect->GetDouble(msg, field)); break;
	case ::google::protobuf::FieldDescriptor::TYPE_STRING: fprintf(file, "%s%s = '%s';\n", indent.c_str(), field->name().c_str(), reflect->GetString(msg, field).c_str()); break;
	case ::google::protobuf::FieldDescriptor::TYPE_BOOL:   fprintf(file, "%s%s = %s;\n", indent.c_str(), field->name().c_str(), reflect->GetBool(msg, field) ? "true" : "false"); break;
	case ::google::protobuf::FieldDescriptor::TYPE_ENUM: if (!SaveEnum(file, field->name(), reflect->GetEnum(msg, field), indent)) return false; break;
	case ::google::protobuf::FieldDescriptor::TYPE_MESSAGE: if (!SaveFieldMessage(file, field->name().c_str(), reflect->GetMessage(msg, field), indent)) return false; break;
	}
	return true;
}
bool CUINodeMgr::SaveNode(FILE* file, const maker::Node* node, const std::string& indent)
{
	if (!node) return false;

	auto desc = node->GetDescriptor();
	auto reflect = node->GetReflection();
	if (!desc || !reflect) return false;

	if (node->is_relative_size())
	{
		for (int i = 0; i< desc->field_count(); ++i) {
			const auto* field = desc->field(i);
			if (!field) continue;

			if (field->name() != "width" && field->name() != "height")
			{
				if (!SaveField(file, *node, field, indent)) return false;
			}
		}
	}
	else
	{
		for (int i = 0; i< desc->field_count(); ++i) {
			const auto* field = desc->field(i);
			if (!field) continue;

			if (field->name().find("rel_") == std::string::npos)
			{
				if (!SaveField(file, *node, field, indent)) return false;
			}
		}
	}
	return true;
}
bool CUINodeMgr::SaveMessage(FILE* file, const ::google::protobuf::Message& msg, const std::string& indent)
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
bool CUINodeMgr::Save(FILE* file, const maker::Properties& properties, const std::string& indent)
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
		if (property.GetTypeName() == "uimaker.Node")
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
bool CUINodeMgr::Save(FILE* file, const maker::Entity& entity, const std::string& indent)
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
bool CUINodeMgr::Save(const std::string& filename)
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

		result = Save(file, *m_root);

		fclose(file);
	}

	return result;
}

bool CUINodeMgr::findField(const std::string& field_name, maker::Properties& properties, ::google::protobuf::Message*& msg, const ::google::protobuf::FieldDescriptor*& field)
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
bool CUINodeMgr::LoadEnum(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token)
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
bool CUINodeMgr::LoadFieldMessage(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token)
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
bool CUINodeMgr::Load(KLuaToken& T, maker::Properties& properties)
{
	const char* token = nullptr;
	while (true)
	{
		if (!(token = T.Token())) return false;
		if (token[0] == '}') break;

		::google::protobuf::Message* msg = nullptr;
		const ::google::protobuf::FieldDescriptor* field = nullptr;
		if (!findField(token, properties, msg, field) || !msg || !field) return false;

		auto reflect = msg->GetReflection();
		if (!reflect) return false;

		if (!(token = T.Token())) return false;

		switch (field->type())
		{
		case ::google::protobuf::FieldDescriptor::TYPE_INT32: reflect->SetInt32(msg, field, strtol(token, nullptr, 0)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_INT64: reflect->SetInt64(msg, field, strtoll(token, nullptr, 0)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT32: reflect->SetUInt32(msg, field, strtoul(token, nullptr, 0)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT64: reflect->SetUInt64(msg, field, strtoll(token, nullptr, 0)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_FLOAT: reflect->SetFloat(msg, field, strtof(token, nullptr)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_DOUBLE: reflect->SetDouble(msg, field, strtod(token, nullptr)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_STRING: reflect->SetString(msg, field, token); break;
		case ::google::protobuf::FieldDescriptor::TYPE_BOOL: reflect->SetBool(msg, field, strcmp(token, "true") ? false : true); break;
		case ::google::protobuf::FieldDescriptor::TYPE_ENUM: LoadEnum(T, *msg, *field, token); break;
		case ::google::protobuf::FieldDescriptor::TYPE_MESSAGE: LoadFieldMessage(T, *msg, *field, token); break;
		}
	}
	return true;
}
bool CUINodeMgr::Load(KLuaToken& T, maker::Entity& entity)
{
	const char* token = nullptr;

	if (!(token = T.Token()) || token[0] != '{') return false;

	if (m_root != &entity)
	{
		auto booked_id = bookingId();
		entity.set_id(booked_id);
		m_node_bind.insert(TYPE_NODE_BIND_MAP::value_type(booked_id, &entity));
	}

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
bool CUINodeMgr::Load(const std::string& filename)
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

	return Load(token, *m_root);
}


maker::Entity* CUINodeMgr::backup(ID id)
{
	if (m_backup)
	{
		delete m_backup;
		m_backup = nullptr;
	}

	auto iter = m_node_bind.find(id);
	if (iter == m_node_bind.end()) return nullptr;

	m_backup = new maker::Entity;
	m_backup->CopyFrom(*iter->second);

	return m_backup;
}
maker::Entity* CUINodeMgr::getBackup()
{
	return m_backup;
}

