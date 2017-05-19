#pragma once

#include "tsqueue.h"

#include "maker.pb.h"

#include "EntityMgr.h"

#include <list>


class CCMDPipe
{
public:
	typedef ::google::protobuf::uint64 ID;
	static const ID INVALID_ID = 0;


protected:
	CCMDPipe();
	~CCMDPipe();

public:
	static CCMDPipe* getInstance();
	static void destroyInstance();

	void clear();

	void send(const maker::CMD& cmd);
	bool recvAtTool(maker::CMD& cmd);
	bool recvAtView(maker::CMD& cmd);

	void clearCmdQueueForView();

	typedef std::list<maker::CMD> TYPE_HISTORY;
	inline const TYPE_HISTORY& getHistory() const { return m_history; }
	unsigned long long getCurrentCmdID() const;

    inline bool isEdited() const { return (_historyCountForCheckEdited != m_history.size() || _historyIterForCheckEdited != m_history_iter); }
    void resetEdited() { _historyCountForCheckEdited = m_history.size(); _historyIterForCheckEdited = m_history_iter; }

	void applyToViewer(const maker::Entity* entity);
	void applyToViewer();
	
private:
	static CCMDPipe* sm_instance;
	static ::google::protobuf::uint64 sm_id;

	tsqueue<maker::CMD> m_queue_to_view;
	tsqueue<maker::CMD> m_queue_to_tool;

	TYPE_HISTORY m_history;
	TYPE_HISTORY::iterator m_history_iter;
	const size_t m_max_history;
    int _historyCountForCheckEdited;
    TYPE_HISTORY::iterator _historyIterForCheckEdited;

	void undo();
	void redo();
	void updateToCmdID(const maker::CMD& cmd);

	void appendCmdHistory(const maker::CMD& cmd);

public:
	static std::string getNodeInfo(CEntityMgr::ID entity_id);
	static std::string getNodeInfo(const maker::Entity& entity);

public:
	class VAR
	{
	public:
		enum class TYPE
		{
			UNKNOWN = 0,
			INT32 = google::protobuf::FieldDescriptor::CPPTYPE_INT32,
			INT64 = google::protobuf::FieldDescriptor::CPPTYPE_INT64,
			UINT32 = google::protobuf::FieldDescriptor::CPPTYPE_UINT32,
			UINT64 = google::protobuf::FieldDescriptor::CPPTYPE_UINT64,
			DOUBLE = google::protobuf::FieldDescriptor::CPPTYPE_DOUBLE,
			FLOAT = google::protobuf::FieldDescriptor::CPPTYPE_FLOAT,
			BOOL = google::protobuf::FieldDescriptor::CPPTYPE_BOOL,
			ENUM = google::protobuf::FieldDescriptor::CPPTYPE_ENUM,
			STRING = google::protobuf::FieldDescriptor::CPPTYPE_STRING,
			MESSAGE = google::protobuf::FieldDescriptor::CPPTYPE_MESSAGE,
			COLOR,
			FILE,
			FILE_IMAGE,
			FILE_SOUND,
			FILE_BMFONT,
			FILE_TTF,
			FILE_VISUAL,
			FILE_PLIST,
			NAME_VISUAL_ID,
			MULTI_LINE_SCRIPT,
		};
		VAR() : m_type(CCMDPipe::VAR::TYPE::UNKNOWN) {}
		VAR(int v) : m_type(CCMDPipe::VAR::TYPE::INT32) { V.m_int32 = v; }
		VAR(long long v) : m_type(CCMDPipe::VAR::TYPE::INT64) { V.m_int64 = v; }
		VAR(unsigned int v) : m_type(CCMDPipe::VAR::TYPE::UINT32) { V.m_uint32 = v; }
		VAR(unsigned long long v) : m_type(CCMDPipe::VAR::TYPE::UINT64) { V.m_uint64 = v; }
		VAR(float v) : m_type(CCMDPipe::VAR::TYPE::FLOAT) { V.m_float = v; }
		VAR(double v) : m_type(CCMDPipe::VAR::TYPE::DOUBLE) { V.m_double = v; }
		VAR(const std::string& v) : m_type(CCMDPipe::VAR::TYPE::STRING) { m_string = v; }
		VAR(bool v) : m_type(CCMDPipe::VAR::TYPE::BOOL) { V.m_bool = v; }
		VAR(const ::google::protobuf::EnumValueDescriptor& v) : m_type(CCMDPipe::VAR::TYPE::ENUM) { V.m_enum = v.number(); }
		VAR(int r, int g, int b) : m_type(CCMDPipe::VAR::TYPE::COLOR) { V.m_color.r = r; V.m_color.g = g; V.m_color.b = b; }
		TYPE m_type;
		union value
		{
			int m_int32;
			unsigned int m_uint32;
			long long m_int64;
			unsigned long long m_uint64;
			float m_float;
			double m_double;
			bool m_bool;
			int m_enum;
			struct _COLOR
			{
				int r, g, b;
			} m_color;
		} V;
		std::string m_string;
	};

	static bool initCommon(maker::CMD& cmd);
	static bool initCreate(maker::CMD& cmd, CEntityMgr::ID booked_id, CEntityMgr::ID parent_id, maker::ENTITY_TYPE type);
	static maker::Entity* initCreateChildAtLast(maker::CMD& cmd, maker::ENTITY_TYPE type);
	static bool initRemove(maker::CMD& cmd);
    static bool initSizeToContent(maker::CMD& cmd);
	static bool initMove(maker::CMD& cmd, CEntityMgr::ID entity_id, CEntityMgr::ID prev_sibling_id, CEntityMgr::ID parent_id, CEntityMgr::ID dest_id, CEntityMgr::ID dest_parent_id);
	static bool initModify(maker::CMD& cmd, CEntityMgr::ID entity_id, const std::string& property_group_name, const std::string& property_name, const VAR& v);
	static bool initModify(maker::Properties* properties, const std::string& property_group_name, const std::string& property_name, const VAR& v, std::string& modify_info);
	static bool initBackup(maker::CMD& cmd, const maker::Entity& entity);
	static bool initBackup(maker::Properties* properties, const maker::Properties& original_properties, const maker::Properties& modified_properties);
	static bool initCopy(maker::CMD& cmd);
	static bool initCut(maker::CMD& cmd);
	static bool initPaste(maker::CMD& cmd, CEntityMgr::ID parent_id);
	static bool initSelect(maker::CMD& cmd, CEntityMgr::ID entity_id);
	static bool initSelect(maker::CMD& cmd, const maker::CMD& src_cmd);
	static bool initSelectAppend(maker::CMD& cmd, CEntityMgr::ID entity_id);
	static bool initSelectBoxAppend(maker::CMD& cmd, bool append_history);
	static bool initUndo(maker::CMD& cmd);
	static bool initRedo(maker::CMD& cmd);
	static bool initHistory(maker::CMD& cmd, ID cmd_id);
	static bool initLuaNames(maker::CMD& cmd, ID cmd_id);
	static bool initApplytoViewer(maker::CMD& cmd, const maker::Entity& entity);
	static bool initApplytoTool(maker::CMD& cmd, CEntityMgr::ID entity_id, const std::string& property_group_name, const std::string& property_name, const VAR& v);
	static bool initEventToTool(maker::CMD& cmd, maker::EVENT_TO_TOOL event_id);
	static bool initEventToViewer(maker::CMD& cmd, maker::EVENT_TO_VIEWER viewer_event_id);

	static bool isModified(const maker::Entity& entity1, const maker::Entity& entity2);

protected:
	static bool asignNewIDforChildren(CEntityMgr::ID parent_id, ::google::protobuf::RepeatedPtrField< ::maker::Entity >* children);
	static bool makeUndo(maker::CMD& cmd, const maker::CMD& original_cmd);
	static bool isModified(const ::google::protobuf::Message& dst, const ::google::protobuf::Message& src);
	static bool copyModifiedValue(::google::protobuf::Message* dst, const ::google::protobuf::Message& src, const ::google::protobuf::Message& ref);
};

