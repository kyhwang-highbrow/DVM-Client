#include "stdafx.h"
#include "CMDPipe.h"


void SendNewCmdNotifycation();


CCMDPipe* CCMDPipe::sm_instance = nullptr;
::google::protobuf::uint64 CCMDPipe::sm_id = 0;


CCMDPipe::CCMDPipe() : m_max_history(100), m_history_iter(m_history.end())
{
    _historyCountForCheckEdited = 0;
    _historyIterForCheckEdited = m_history.end();
}
CCMDPipe::~CCMDPipe()
{
}

CCMDPipe* CCMDPipe::getInstance()
{
	if (!sm_instance)
	{
		sm_instance = new CCMDPipe;
	}

	return sm_instance;
}
void CCMDPipe::destroyInstance()
{
	if (!sm_instance) return;

	delete sm_instance;
	sm_instance = nullptr;
}

void CCMDPipe::clear()
{
	m_queue_to_view.clear();
	m_queue_to_tool.clear();
	m_history.clear();
	m_history_iter = m_history.end();
    _historyCountForCheckEdited = 0;
    _historyIterForCheckEdited = m_history.end();

	sm_id = 0;
}

void CCMDPipe::send(const maker::CMD& cmd)
{
	switch (cmd.type())
	{
	case maker::CMD__Undo: undo(); break;
	case maker::CMD__Redo: redo(); break;
	case maker::CMD__History: updateToCmdID(cmd); break;

	case maker::CMD__LuaNames: updateToCmdID(cmd); break;

	case maker::CMD__ClearViewer:
	case maker::CMD__ApplyToViewer:
	case maker::CMD__MoveViewer:
	case maker::CMD__EventToViewer:
		m_queue_to_view.push(cmd);
		break;
	case maker::CMD__ApplyToTool:
	case maker::CMD__EventToTool:
		m_queue_to_tool.push(cmd);
		SendNewCmdNotifycation();
		break;
	default:
		m_queue_to_view.push(cmd);
		m_queue_to_tool.push(cmd);
		SendNewCmdNotifycation();

		appendCmdHistory(cmd);
		break;
	}

	switch (cmd.type())
	{
	case maker::CMD__Remove:
		CEntityMgr::getInstance()->setCurrentID(CEntityMgr::INVALID_ID);
		break;
    case maker::CMD__SizeToContent:
	case maker::CMD__SelectOne:
	case maker::CMD__SelectAppend:
	case maker::CMD__SelectBoxAppend:
		if (cmd.entities_size() > 0)
		{
			CEntityMgr::getInstance()->setCurrentID(cmd.entities().Get(0).id());
		}
		else
		{
			CEntityMgr::getInstance()->setCurrentID(CEntityMgr::INVALID_ID);
		}
		break;
	}
}
bool CCMDPipe::recvAtTool(maker::CMD& cmd)
{
	return m_queue_to_tool.pop(cmd);
}
bool CCMDPipe::recvAtView(maker::CMD& cmd)
{
	return m_queue_to_view.pop(cmd);
}
void CCMDPipe::clearCmdQueueForView()
{
	m_queue_to_view.clear();
}
void CCMDPipe::undo()
{
	TYPE_HISTORY::reverse_iterator riter(m_history_iter);
	if (riter == m_history.rend()) return;

	auto& original_cmd = *riter;
	maker::CMD cmd;
	makeUndo(cmd, original_cmd);

	m_queue_to_view.push(cmd);
	m_queue_to_tool.push(cmd);
	SendNewCmdNotifycation();

	--m_history_iter;
}
void CCMDPipe::redo()
{
	if (m_history_iter == m_history.end()) return;

	auto& cmd = *m_history_iter;
	m_queue_to_view.push(cmd);
	m_queue_to_tool.push(cmd);
	SendNewCmdNotifycation();

	++m_history_iter;
}
void CCMDPipe::updateToCmdID(const maker::CMD& cmd)
{
	auto cmd_id = cmd.update_to_cmd_id();

	bool found_target = false;
	auto target_cmd_iter = m_history.end();
	for (auto iter = m_history.begin(); iter != m_history.end(); ++iter)
	{
		if (iter->id() == cmd_id)
		{
			found_target = true;

			target_cmd_iter = iter;
			++target_cmd_iter; // 해당 커맨드까지 실행하기 위해 다음 커맨드까지 가도록 지정
		}
	}
	if (!found_target) return;
	if (target_cmd_iter == m_history_iter) return;

	bool undo = true;
	if (target_cmd_iter == m_history.end())
	{
		undo = false;
	}
	else
	{
		for (auto iter = m_history_iter; iter != m_history.end(); ++iter)
		{
			if (iter == target_cmd_iter)
			{
				undo = false;
				break;
			}
		}
	}

	auto begin_cmd_iter = m_history_iter;

	if (undo)
	{
		do {
			auto& original_cmd = *TYPE_HISTORY::reverse_iterator(m_history_iter);
			maker::CMD cmd;
			makeUndo(cmd, original_cmd);

			m_queue_to_view.push(cmd);
			m_queue_to_tool.push(cmd);

			--m_history_iter;
		} while (target_cmd_iter != m_history_iter);
	}
	else // redo
	{
		do {
			auto& cmd = *m_history_iter;

			m_queue_to_view.push(cmd);
			m_queue_to_tool.push(cmd);

			++m_history_iter;
		} while (target_cmd_iter != m_history_iter);
	}
	SendNewCmdNotifycation();
}
void CCMDPipe::appendCmdHistory(const maker::CMD& cmd)
{
	if (cmd.dont_append_history()) return;
	if (cmd.type() == maker::CMD__SelectOne)
	{
		return;
		//if (cmd.entities_size() <= 0) return;
		//if (!m_history.empty())
		//{
		//	auto& last_cmd = m_history.back();

		//	if (last_cmd.type() == maker::CMD__SelectOne)
		//	{
		//		*(last_cmd.mutable_entities()) = cmd.entities();
		//		last_cmd.set_description(cmd.description());
		//		return;
		//	}
		//}
	}

	for (auto iter = m_history_iter; iter != m_history.end();)
	{
		iter = m_history.erase(iter);
	}
	const_cast<maker::CMD&>(cmd).set_dont_append_history(true);
	if (cmd.can_merge_prev_cmd())
	{
		auto& last_cmd = m_history.back();
		bool is_same_entities = true;
		if (last_cmd.entities_size() != cmd.entities_size())
		{
			is_same_entities = false;
		}
		else
		{
			for (auto last_cmd_iter = last_cmd.entities().begin(), cmd_iter = cmd.entities().begin(); last_cmd_iter != last_cmd.entities().end() && cmd_iter != cmd.entities().end(); ++last_cmd_iter, ++cmd_iter)
			{
				if (last_cmd_iter->id() != cmd_iter->id())
				{
					is_same_entities = false;
					break;
				}
			}
		}
		if (is_same_entities && last_cmd.type() == cmd.type())
		{
			auto last_cmd_entities = last_cmd.mutable_entities();
			auto last_cmd_iter = last_cmd_entities->begin();
			for (auto cmd_iter = cmd.entities().begin(); last_cmd_iter != last_cmd_entities->end() && cmd_iter != cmd.entities().end(); ++last_cmd_iter, ++cmd_iter)
			{
				last_cmd_iter->mutable_properties()->CopyFrom(cmd_iter->properties());
			}
		}
		else
		{
			m_history.push_back(cmd);
		}
	}
	else
	{
		m_history.push_back(cmd);
	}
	while (m_history.size() > m_max_history)
	{
		m_history.pop_front();
	}
	m_history_iter = m_history.end();
}

std::string CCMDPipe::getNodeInfo(CEntityMgr::ID entity_id)
{
	auto entity = CEntityMgr::getInstance()->get(entity_id);
	if (!entity) return "<NONE>";

	return getNodeInfo(*entity);
}
std::string CCMDPipe::getNodeInfo(const maker::Entity& entity)
{
	auto type = entity.properties().type();
	std::string node_info = CEntityMgr::getInstance()->getEnumNameforTool(maker::ENTITY_TYPE_descriptor()->FindValueByNumber(type));

	auto& properties = entity.properties();
	if (properties.has_node())
	{
		auto& node = properties.node();
		if (node.has_lua_name() && !node.lua_name().empty())
		{
			node_info += ":";
			node_info += node.lua_name();
		}
	}

	return node_info;
}
bool CCMDPipe::makeUndo(maker::CMD& cmd, const maker::CMD& original_cmd)
{
	if (!initCommon(cmd)) return false;
	cmd.set_dont_append_history(true);

	switch (original_cmd.type())
	{
	case maker::CMD__Create:
		cmd.set_type(maker::CMD__Remove);

		for (auto& original_child : original_cmd.entities())
		{
			auto child = cmd.add_entities();
			if (!child) continue;

			child->set_id(original_child.id());
			child->set_parent_id(original_child.parent_id());
			child->set_lua_name_duplicated(false);
		}
		break;
	case maker::CMD__Cut:
	case maker::CMD__Remove:
		cmd.set_type(maker::CMD__Create);

		for (auto& original_child : original_cmd.backup_entities())
		{
			auto child = cmd.add_entities();
			*child = original_child;
			child->set_dest_id(original_child.prev_id());
			child->set_parent_id(original_child.dest_parent_id());
		}
		break;
	case maker::CMD__Move:
		cmd.set_type(maker::CMD__Move);

		for (auto& original_child : original_cmd.entities())
		{
			auto child = cmd.add_entities();
			if (!child) continue;

			child->set_id(original_child.id());
			child->set_prev_id(original_child.dest_id());
			child->set_parent_id(original_child.dest_parent_id());
			child->set_dest_id(original_child.prev_id());
			child->set_dest_parent_id(original_child.parent_id());
		}

		break;
    case maker::CMD__SizeToContent:
	case maker::CMD__Modify:
		cmd.set_type(maker::CMD__Modify);

		for (auto& original_child : original_cmd.backup_entities())
		{
			auto child = cmd.add_entities();
			*child = original_child;
		}
		break;
	case maker::CMD__Paste:
		cmd.set_type(maker::CMD__Remove);

		for (auto& original_child : original_cmd.entities())
		{
			auto child = cmd.add_entities();
			if (!child) continue;

			child->set_id(original_child.id());
			child->set_parent_id(original_child.parent_id());
		}
		break;
	case maker::CMD__SelectOne:
	case maker::CMD__SelectAppend:
		cmd.set_type(maker::CMD__SelectAppend);

		for (auto& original_child : original_cmd.entities())
		{
			auto child = cmd.add_entities();
			if (!child) continue;

			child->set_id(original_child.id());
			child->set_parent_id(original_child.parent_id());
		}
		break;
	}

	return true;
}
unsigned long long CCMDPipe::getCurrentCmdID() const
{
	if (m_history_iter == m_history.end()) return 0;

	TYPE_HISTORY::reverse_iterator riter(m_history_iter);
	if (riter == m_history.rend()) return 0; 
	return riter->id();
}

bool CCMDPipe::initCreate(maker::CMD& cmd, CEntityMgr::ID booked_id, CEntityMgr::ID parent_id, maker::ENTITY_TYPE type)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Create);

	auto entity = cmd.add_entities();
	if (!entity) return false;

	entity->set_id(booked_id);
	entity->set_parent_id(parent_id);
	entity->set_lua_name_duplicated(false);

	auto properties = entity->mutable_properties();
	if (!properties) return false;

	properties->set_type(type);
	CEntityMgr::fillDefaultValue(*properties);

	char szbuf[1024];
	sprintf_s(szbuf, "Create '%s'",
		CEntityMgr::getInstance()->getEnumNameforTool(maker::ENTITY_TYPE_descriptor()->FindValueByNumber(type)).c_str());
	cmd.set_description(szbuf);

	return true;
}
maker::Entity* CCMDPipe::initCreateChildAtLast(maker::CMD& cmd, maker::ENTITY_TYPE type)
{
	int count = cmd.entities_size();
	if (count <= 0) return nullptr;

	auto entity = cmd.mutable_entities()->Mutable(count - 1);
	if (!entity) return nullptr;

	auto child = entity->add_children();
	if (!child) return nullptr;

	child->set_id(CEntityMgr::getInstance()->bookingId());
	child->set_parent_id(entity->id());

	auto properties = child->mutable_properties();
	if (!properties) return false;

	properties->set_type(type);
	CEntityMgr::fillDefaultValue(*properties);

	return child;
}
bool CCMDPipe::initRemove(maker::CMD& cmd)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Remove);
	
	CEntityMgr::TYPE_SELECTED_ENTITIES selected_entities;
	CEntityMgr::getInstance()->getSelectedNearestChildren(selected_entities);

	for (auto entity : selected_entities)
	{
		auto parent = CEntityMgr::getInstance()->get(entity->parent_id());
		if (!parent) continue;

		auto child = cmd.add_entities();
		auto backup_child = cmd.add_backup_entities();
		if (!child || !backup_child) return false;

		child->set_id(entity->id());
		child->set_parent_id(entity->parent_id());

		CEntityMgr::ID prev_sibling_id = CEntityMgr::INVALID_ID;
		auto prev_sibling = CEntityMgr::getInstance()->getPrevSibling(entity->id());
		if (prev_sibling) prev_sibling_id = prev_sibling->id();

		*backup_child = *entity;
		backup_child->set_id(entity->id());
		backup_child->set_prev_id(prev_sibling_id);
		backup_child->set_parent_id(entity->parent_id());
		backup_child->set_dest_id(prev_sibling_id);
		backup_child->set_dest_parent_id(entity->parent_id());
	}
	if (cmd.entities_size() <= 0) return false;

	char szbuf[1024];
	if (cmd.entities_size() > 1)
	{
		sprintf_s(szbuf, "Remove '%s, ...' (%d) entities", getNodeInfo(cmd.entities().Get(0).id()).c_str(), cmd.entities_size());
	}
	else
	{
		sprintf_s(szbuf, "Remove '%s'", getNodeInfo(cmd.entities().Get(0).id()).c_str());
	}
	cmd.set_description(szbuf);

	return true;
}
bool CCMDPipe::initSizeToContent(maker::CMD& cmd)
{
    if (!initCommon(cmd)) return false;
    cmd.set_type(maker::CMD__SizeToContent);

    CEntityMgr::TYPE_SELECTED_ENTITIES selected_entities;
    CEntityMgr::getInstance()->getSelectedNearestChildren(selected_entities);

    for (auto entity : selected_entities)
    {
        auto aEntity = cmd.add_entities();
        auto aBackupEntity = cmd.add_backup_entities();

        if (!aEntity || !aBackupEntity) return false;

        aEntity->set_id(entity->id());

        *aBackupEntity = *entity;
        aBackupEntity->set_id(entity->id());
    }
    if (cmd.entities_size() <= 0) return false;

    char szbuf[1024];
    if (cmd.entities_size() > 1)
    {
        sprintf_s(szbuf, "Size to Content '%s, ...' (%d) entities", getNodeInfo(cmd.entities().Get(0).id()).c_str(), cmd.entities_size());
    }
    else
    {
        sprintf_s(szbuf, "Size to Content '%s'", getNodeInfo(cmd.entities().Get(0).id()).c_str());
    }
    cmd.set_description(szbuf);

    return true;
}
bool CCMDPipe::initMove(maker::CMD& cmd, CEntityMgr::ID entity_id, CEntityMgr::ID prev_sibling_id, CEntityMgr::ID parent_id, CEntityMgr::ID dest_id, CEntityMgr::ID dest_parent_id)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Move);

	auto entity = cmd.add_entities();
	if (!entity) return false;

	entity->set_id(entity_id);
	entity->set_prev_id(prev_sibling_id);
	entity->set_parent_id(parent_id);
	entity->set_dest_id(dest_id);
	entity->set_dest_parent_id(dest_parent_id);

	char szbuf[1024];
	sprintf_s(szbuf, "Move '%s': '%s' > '%s'",
		getNodeInfo(entity_id).c_str(), getNodeInfo(parent_id).c_str(), getNodeInfo(dest_parent_id).c_str());
	cmd.set_description(szbuf);

	return true;
}
bool CCMDPipe::initModify(maker::CMD& cmd, CEntityMgr::ID entity_id, const std::string& property_group_name, const std::string& property_name, const VAR& v)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Modify);

	if (entity_id == CEntityMgr::INVALID_ID) return true;

	auto entity = cmd.add_entities();
	if (!entity) return false;

	entity->set_id(entity_id);

	std::string modify_info;
	if (!initModify(entity->mutable_properties(), property_group_name, property_name, v, modify_info)) return false;

	if (cmd.description().empty())
	{
		cmd.set_description("Modify '" + getNodeInfo(entity_id) + "': " + modify_info);
	}
	else
	{
		cmd.set_description(cmd.description() + ", " + modify_info);
	}

	return true;
}
bool CCMDPipe::initModify(maker::Properties* properties, const std::string& property_group_name, const std::string& property_name, const VAR& v, std::string& modify_info)
{
	if (!properties) return false;

	auto desc = properties->GetDescriptor();
	auto reflect = properties->GetReflection();
	if (!desc || !reflect) return false;

	::google::protobuf::Message* msg = nullptr;
	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto field = desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;
		if (field->type() != ::google::protobuf::FieldDescriptor::TYPE_MESSAGE) continue;

		if (field->message_type()->name() == property_group_name)
		{
			msg = reflect->MutableMessage(properties, field);
			break;
		}
	}
	if (!msg) return false;

	desc = msg->GetDescriptor();
	reflect = msg->GetReflection();
	if (!desc || !reflect) return false;

	const ::google::protobuf::FieldDescriptor* field = nullptr;
	for (int i = 0; i < desc->field_count(); ++i)
	{
		auto current_field = desc->field(i);

		if (!current_field) continue;
		if (current_field->is_repeated()) continue;

		if (current_field->name() == property_name)
		{
			field = current_field;
			break;
		}
	}
	if (!field) return false;

	char szvalue[10240] = "";

	const ::google::protobuf::EnumDescriptor* edesc = nullptr;
	const ::google::protobuf::EnumValueDescriptor* evdesc = nullptr;
	const ::google::protobuf::Descriptor* msg_desc = nullptr;

	switch (v.m_type)
	{
	case CCMDPipe::VAR::TYPE::INT32: reflect->SetInt32(msg, field, v.V.m_int32); sprintf_s(szvalue, "int32[%d]", v.V.m_int32); break;
	case CCMDPipe::VAR::TYPE::INT64: reflect->SetInt64(msg, field, v.V.m_int64); sprintf_s(szvalue, "int64[%lld]", v.V.m_int64); break;
	case CCMDPipe::VAR::TYPE::UINT32: reflect->SetUInt32(msg, field, v.V.m_uint32); sprintf_s(szvalue, "uint32[%u]", v.V.m_uint32); break;
	case CCMDPipe::VAR::TYPE::UINT64: reflect->SetUInt64(msg, field, v.V.m_uint64); sprintf_s(szvalue, "uint64[%llu]", v.V.m_uint64); break;
	case CCMDPipe::VAR::TYPE::FLOAT: 
		if (v.V.m_float > 100000 || v.V.m_float < -100000)
		{
			reflect->SetFloat(msg, field, 0.0f); 
			sprintf_s(szvalue, "float[%f]", 0.0f);
		}
		else
		{
			reflect->SetFloat(msg, field, v.V.m_float);
			sprintf_s(szvalue, "float[%f]", v.V.m_float);
		}
		break;
	case CCMDPipe::VAR::TYPE::DOUBLE: reflect->SetDouble(msg, field, v.V.m_double); sprintf_s(szvalue, "double[%lf]", v.V.m_double); break;
	case CCMDPipe::VAR::TYPE::STRING: reflect->SetString(msg, field, v.m_string); sprintf_s(szvalue, "string[%s]", v.m_string.c_str()); break;
	case CCMDPipe::VAR::TYPE::BOOL: reflect->SetBool(msg, field, v.V.m_bool); sprintf_s(szvalue, "bool[%s]", v.V.m_bool?"true":"false"); break;
	case CCMDPipe::VAR::TYPE::ENUM:
		edesc = field->enum_type();
		if (!edesc) return false;

		evdesc = edesc->FindValueByNumber(v.V.m_enum);
		if (!evdesc) return false;

		reflect->SetEnum(msg, field, evdesc);
		break;
	case CCMDPipe::VAR::TYPE::COLOR:
		msg_desc = field->message_type();
		if (msg_desc && msg_desc->name() == "COLOR")
		{
			auto color_msg = reflect->MutableMessage(msg, field);
			auto color_desc = color_msg->GetDescriptor();
			auto color_reflect = color_msg->GetReflection();
			color_reflect->SetInt32(color_msg, color_desc->FindFieldByName("r"), v.V.m_color.r);
			color_reflect->SetInt32(color_msg, color_desc->FindFieldByName("g"), v.V.m_color.g);
			color_reflect->SetInt32(color_msg, color_desc->FindFieldByName("b"), v.V.m_color.b);

			sprintf_s(szvalue, "color[%d, %d, %d]", v.V.m_color.r, v.V.m_color.g, v.V.m_color.b);
		}
		else
		{
			return false;
		}
		break;
	case CCMDPipe::VAR::TYPE::FILE:
	case CCMDPipe::VAR::TYPE::FILE_IMAGE:
	case CCMDPipe::VAR::TYPE::FILE_SOUND:
	case CCMDPipe::VAR::TYPE::FILE_BMFONT:
	case CCMDPipe::VAR::TYPE::FILE_TTF:
	case CCMDPipe::VAR::TYPE::FILE_VISUAL:
	case CCMDPipe::VAR::TYPE::FILE_PLIST:
		msg_desc = field->message_type();
		if (msg_desc && CEntityMgr::getInstance()->isFileProperty(msg_desc->name()))
		{
			auto file_msg = reflect->MutableMessage(msg, field);
			auto file_desc = file_msg->GetDescriptor();
			auto file_reflect = file_msg->GetReflection();
			file_reflect->SetString(file_msg, file_desc->FindFieldByName("path"), v.m_string);

			sprintf_s(szvalue, "file[%s]", v.m_string.c_str());
		}
		else
		{
			return false;
		}
		break;
	case CCMDPipe::VAR::TYPE::NAME_VISUAL_ID:
		msg_desc = field->message_type();
		if (msg_desc && CEntityMgr::getInstance()->isEnumNameProperty(msg_desc->name()))
		{
			auto name_msg = reflect->MutableMessage(msg, field);
			auto name_desc = name_msg->GetDescriptor();
			auto name_reflect = name_msg->GetReflection();
			name_reflect->SetString(name_msg, name_desc->FindFieldByName("name"), v.m_string);

			sprintf_s(szvalue, "visual_id[%s]", v.m_string.c_str());
		}
		else
		{
			return false;
		}
		break;
	case CCMDPipe::VAR::TYPE::MULTI_LINE_SCRIPT:
		msg_desc = field->message_type();
		if (msg_desc && CEntityMgr::getInstance()->isScriptProperty(msg_desc->name()))
		{
			auto name_msg = reflect->MutableMessage(msg, field);
			auto name_desc = name_msg->GetDescriptor();
			auto name_reflect = name_msg->GetReflection();
			name_reflect->SetString(name_msg, name_desc->FindFieldByName("script"), v.m_string);

			auto tmp = v.m_string.substr(0, v.m_string.find('\n'));
			tmp += " ... ";

			sprintf_s(szvalue, "script[ '%s' ]", tmp.c_str());
		}
		else
		{
			return false;
		}
		break;
	case CCMDPipe::VAR::TYPE::MESSAGE:
		msg_desc = field->message_type();
		if (!msg_desc) return false;

		assert(0 && "unknown data type - "__FUNCTION__);
		return false;
	}

	modify_info = "'" + property_group_name + "." +property_name + "' = " + szvalue;

	return true;
}
bool CCMDPipe::initBackup(maker::CMD& cmd, const maker::Entity& entity)
{
	for (auto& child : cmd.entities())
	{
		if (child.id() == entity.id())
		{
			auto backup_child = cmd.add_backup_entities();
			if (!backup_child) return false;

			backup_child->set_id(entity.id());

			return initBackup(backup_child->mutable_properties(), entity.properties(), child.properties());
		}
	}
	return false;
}
bool CCMDPipe::initBackup(maker::Properties* backup_properties, const maker::Properties& original_properties, const maker::Properties& modified_properties)
{
	if (!backup_properties) return false;
	return copyModifiedValue(backup_properties, original_properties, modified_properties);
}
bool CCMDPipe::initCopy(maker::CMD& cmd)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Copy);

	CEntityMgr::getInstance()->copySelectedEntitiesToClipboard();

	auto& clipboard = CEntityMgr::getInstance()->getClipboard();
	if (clipboard.children_size() == 0) return false;

	auto& entity = clipboard.children().Get(0);

	char szbuf[1024];
	if (clipboard.children_size() > 1)
	{
		sprintf_s(szbuf, "Copy '%s, ...' (%d) entities",
			CEntityMgr::getInstance()->getEnumNameforTool(maker::ENTITY_TYPE_descriptor()->FindValueByNumber(entity.properties().type())).c_str(), clipboard.children_size());
	}
	else
	{
		sprintf_s(szbuf, "Copy '%s' and (%d) children",
			CEntityMgr::getInstance()->getEnumNameforTool(maker::ENTITY_TYPE_descriptor()->FindValueByNumber(entity.properties().type())).c_str(), entity.children().size());
	}
	cmd.set_description(szbuf);

	return true;
}
bool CCMDPipe::initCut(maker::CMD& cmd)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Cut);

	CEntityMgr::getInstance()->copySelectedEntitiesToClipboard();

	auto& clipboard = CEntityMgr::getInstance()->getClipboard();
	if (clipboard.children_size() == 0) return false;

	for (auto& entity : clipboard.children())
	{
		auto parent = CEntityMgr::getInstance()->get(entity.parent_id());
		if (!parent) continue;

		CEntityMgr::ID dest_id = CEntityMgr::INVALID_ID;
		auto& children = parent->children();
		for (auto& child : children)
		{
			if (child.id() == entity.id())
			{
				break;
			}
			dest_id = child.id();
		}

		auto child = cmd.add_entities();
		auto backup_child = cmd.add_backup_entities();
		if (!child || !backup_child) return false;

		*backup_child = entity;

		child->set_id(entity.id());
		child->set_parent_id(entity.parent_id());
		child->set_dest_id(dest_id);
		child->set_dest_parent_id(entity.parent_id());
	}

	auto& entity = clipboard.children().Get(0);

	char szbuf[1024];
	if (clipboard.children_size() > 1)
	{
		sprintf_s(szbuf, "Copy '%s, ...' (%d) entities",
			CEntityMgr::getInstance()->getEnumNameforTool(maker::ENTITY_TYPE_descriptor()->FindValueByNumber(entity.properties().type())).c_str(), clipboard.children_size());
	}
	else
	{
		sprintf_s(szbuf, "Copy '%s' and (%d) children",
			CEntityMgr::getInstance()->getEnumNameforTool(maker::ENTITY_TYPE_descriptor()->FindValueByNumber(entity.properties().type())).c_str(), entity.children().size());
	}
	cmd.set_description(szbuf);

	return true;
}
bool CCMDPipe::initPaste(maker::CMD& cmd, CEntityMgr::ID parent_id)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Paste);

	auto parent = CEntityMgr::getInstance()->get(parent_id);
	if (!parent) return false;

	auto parent_type = parent->properties().type();

	auto& clipboard = CEntityMgr::getInstance()->getClipboard();
	if (clipboard.children_size() <= 0) return false;

	for (auto& entity : clipboard.children())
	{
		if (!CEntityMgr::getInstance()->canAppendChild(parent_type, entity.properties().type())) continue;

		auto new_entity = cmd.add_entities();
		if (!new_entity) return false;

		*new_entity = entity;

		auto entity_id = CEntityMgr::getInstance()->bookingId();
		new_entity->set_id(entity_id);
		new_entity->set_parent_id(parent_id);

		if (entity.children_size() > 0)
		{
			asignNewIDforChildren(entity_id, new_entity->mutable_children());
		}
	}
	if (cmd.entities_size() <= 0) return false;

	char szbuf[1024];
	if (cmd.entities_size() > 1)
	{
		sprintf_s(szbuf, "Paste '%s, ...' (%d) entities", getNodeInfo(cmd.entities().Get(0)).c_str(), cmd.entities_size());
	}
	else
	{
		sprintf_s(szbuf, "Paste '%s'", getNodeInfo(cmd.entities().Get(0)).c_str());
	}
	cmd.set_description(szbuf);

	return true;
}
bool CCMDPipe::asignNewIDforChildren(CEntityMgr::ID parent_id, ::google::protobuf::RepeatedPtrField< ::maker::Entity >* children)
{
	if (!children) return true;
	for (auto child = children->begin(); child != children->end(); ++child)
	{
		auto entity_id = CEntityMgr::getInstance()->bookingId();
		child->set_id(entity_id);
		child->set_parent_id(parent_id);

		if (child->children_size() > 0)
		{
			asignNewIDforChildren(entity_id, child->mutable_children());
		}
	}
	return true;
}
bool CCMDPipe::initUndo(maker::CMD& cmd)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Undo);

	return true;
}
bool CCMDPipe::initRedo(maker::CMD& cmd)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__Redo);

	return true;
}
bool CCMDPipe::initHistory(maker::CMD& cmd, ID cmd_id)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__History);
	cmd.set_update_to_cmd_id(cmd_id);

	return true;
}
bool CCMDPipe::initLuaNames(maker::CMD& cmd, ID cmd_id)
{	
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__LuaNames);
	cmd.set_update_to_cmd_id(cmd_id);

	return true;
}
bool CCMDPipe::initSelect(maker::CMD& cmd, CEntityMgr::ID entity_id)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__SelectOne);

	if (entity_id != CEntityMgr::INVALID_ID)
	{
		auto entity = cmd.add_entities();
		if (!entity) return false;

		entity->set_id(entity_id);
	}

	//char szbuf[1024];
	//sprintf_s(szbuf, "Select '%s'",
	//	getNodeInfo(entity_id).c_str());
	//cmd.set_description(szbuf);

	return true;
}
bool CCMDPipe::initSelect(maker::CMD& cmd, const maker::CMD& src_cmd)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__SelectOne);
	cmd.set_dont_append_history(true);

	for (auto& child : src_cmd.entities())
	{
		auto entity = cmd.add_entities();
		if (!entity) return false;

		entity->set_id(child.id());
	}

	return true;
}
bool CCMDPipe::initSelectAppend(maker::CMD& cmd, CEntityMgr::ID entity_id)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__SelectAppend);

	if (entity_id != CEntityMgr::INVALID_ID)
	{
		auto entity = cmd.add_entities();
		if (!entity) return false;

		entity->set_id(entity_id);
	}

	char szbuf[1024];
	sprintf_s(szbuf, "Select append '%s'",
		getNodeInfo(entity_id).c_str());
	cmd.set_description(szbuf);

	return true;
}
bool CCMDPipe::initSelectBoxAppend(maker::CMD& cmd, bool append_history)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__SelectBoxAppend);
	cmd.set_dont_append_history(!append_history);

	if (append_history)
	{
		char szbuf[1024];
		sprintf_s(szbuf, "Select box append");
		cmd.set_description(szbuf);
	}

	return true;
}
bool CCMDPipe::initApplytoViewer(maker::CMD& cmd, const maker::Entity& entity)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__ApplyToViewer);

	auto apply_entity = cmd.add_entities();
	if (!apply_entity) return false;

	*apply_entity = entity;

	return true;
}
bool CCMDPipe::initApplytoTool(maker::CMD& cmd, CEntityMgr::ID entity_id, const std::string& property_group_name, const std::string& property_name, const VAR& v)
{
	initModify(cmd, entity_id, property_group_name, property_name, v);

	cmd.set_type(maker::CMD__ApplyToTool);
	return true;
}
bool CCMDPipe::initEventToTool(maker::CMD& cmd, maker::EVENT_TO_TOOL event_id)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__EventToTool);
	cmd.set_event_id(event_id);
	return true;
}
bool CCMDPipe::initEventToViewer(maker::CMD& cmd, maker::EVENT_TO_VIEWER viewer_event_id)
{
	if (!initCommon(cmd)) return false;
	cmd.set_type(maker::CMD__EventToViewer);
	cmd.set_viewer_event_id(viewer_event_id);
	return true;
}

bool CCMDPipe::initCommon(maker::CMD& cmd)
{
	auto current_id = ++sm_id;
	while (current_id == CCMDPipe::INVALID_ID) current_id = ++sm_id;
	cmd.set_id(current_id);

	return true;
}

bool CCMDPipe::isModified(const ::google::protobuf::Message& dst, const ::google::protobuf::Message& src)
{
	auto dst_desc = dst.GetDescriptor();
	auto src_desc = src.GetDescriptor();
	if (!dst_desc || !src_desc) return false;

	if (dst_desc != src_desc) return false;

	auto dst_reflect = dst.GetReflection();
	auto src_reflect = src.GetReflection();
	if (!dst_reflect || !src_reflect) return false;

	for (int i = 0; i < dst_desc->field_count(); ++i)
	{
		auto field = dst_desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!dst_reflect->HasField(dst, field)) continue;

		switch (field->type())
		{
		case ::google::protobuf::FieldDescriptor::TYPE_INT32: if (dst_reflect->GetInt32(dst, field) != src_reflect->GetInt32(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_INT64: if (dst_reflect->GetInt64(dst, field) != src_reflect->GetInt64(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT32: if (dst_reflect->GetUInt32(dst, field) != src_reflect->GetUInt32(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT64: if (dst_reflect->GetUInt64(dst, field) != src_reflect->GetUInt64(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_FLOAT: if (dst_reflect->GetFloat(dst, field) != src_reflect->GetFloat(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_DOUBLE: if (dst_reflect->GetDouble(dst, field) != src_reflect->GetDouble(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_STRING: if (dst_reflect->GetString(dst, field) != src_reflect->GetString(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_BOOL: if (dst_reflect->GetBool(dst, field) != src_reflect->GetBool(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_ENUM: if (dst_reflect->GetEnum(dst, field) != src_reflect->GetEnum(src, field)) return true; break;
		case ::google::protobuf::FieldDescriptor::TYPE_MESSAGE: if (isModified(dst_reflect->GetMessage(dst, field), src_reflect->GetMessage(src, field))) return true; break;
		}
	}

	return false;
}
bool CCMDPipe::isModified(const maker::Entity& entity1, const maker::Entity& entity2)
{
	return isModified(entity1.properties(), entity2.properties());
}

bool CCMDPipe::copyModifiedValue(::google::protobuf::Message* dst, const ::google::protobuf::Message& src, const ::google::protobuf::Message& ref)
{
	if (!dst) return false;

	auto dst_desc = dst->GetDescriptor();
	auto src_desc = src.GetDescriptor();
	auto ref_desc = ref.GetDescriptor();
	if (!dst_desc || !src_desc || !ref_desc) return false;

	if (dst_desc != src_desc) return false;
	if (dst_desc != ref_desc) return false;

	auto dst_reflect = dst->GetReflection();
	auto src_reflect = src.GetReflection();
	auto ref_reflect = ref.GetReflection();
	if (!dst_reflect || !src_reflect || !ref_reflect) return false;

	for (int i = 0; i < ref_desc->field_count(); ++i)
	{
		auto field = ref_desc->field(i);

		if (!field) continue;
		if (field->is_repeated()) continue;

		if (!ref_reflect->HasField(ref, field)) continue;

		switch (field->type())
		{
		case ::google::protobuf::FieldDescriptor::TYPE_INT32: dst_reflect->SetInt32(dst, field, src_reflect->GetInt32(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_INT64: dst_reflect->SetInt64(dst, field, src_reflect->GetInt64(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT32: dst_reflect->SetUInt32(dst, field, src_reflect->GetUInt32(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_UINT64: dst_reflect->SetUInt64(dst, field, src_reflect->GetUInt64(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_FLOAT: dst_reflect->SetFloat(dst, field, src_reflect->GetFloat(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_DOUBLE: dst_reflect->SetDouble(dst, field, src_reflect->GetDouble(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_STRING: dst_reflect->SetString(dst, field, src_reflect->GetString(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_BOOL: dst_reflect->SetBool(dst, field, src_reflect->GetBool(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_ENUM: dst_reflect->SetEnum(dst, field, src_reflect->GetEnum(src, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_MESSAGE: copyModifiedValue(dst_reflect->MutableMessage(dst, field), src_reflect->GetMessage(src, field), ref_reflect->GetMessage(ref, field)); break;
		case ::google::protobuf::FieldDescriptor::TYPE_BYTES: dst_reflect->SetString(dst, field, src_reflect->GetString(src, field)); break;
		}
	}

	return true;
}

void CCMDPipe::applyToViewer(const maker::Entity* entity)
{
	if (!entity) return;

	maker::CMD cmd;
	if (initApplytoViewer(cmd, *entity))
	{
		send(cmd);
	}
}
void CCMDPipe::applyToViewer()
{
	maker::CMD cmd;
	cmd.set_type(maker::CMD__ClearViewer);
	send(cmd);

	applyToViewer(CEntityMgr::getInstance()->getRoot());
}


