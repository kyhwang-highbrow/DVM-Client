#pragma once

#include "maker.pb.h"

#include <map>
#include <list>

class KLuaToken;

class CEntityMgr
{
public:
	typedef ::google::protobuf::uint64 ID;
	static const ID INVALID_ID = 0;


protected:
	CEntityMgr();
	~CEntityMgr();

public:
	static CEntityMgr* getInstance();
	static void destroyInstance();

private:
	static CEntityMgr* sm_instance;
	static ID sm_id;


public:
	bool init();
	void clear();

	maker::Entity* getRoot() const;
	maker::Entity* getCurrent() const;
	ID getCurrentID() const;
	void setCurrentID(ID id);
	maker::Entity* get(ID id) const;
	maker::Entity* getParent(ID id) const;
	maker::Entity* getParent(const maker::Entity* entity) const;
	maker::Entity* getPrevSibling(ID id) const;
	maker::Entity* getNextSibling(ID id) const;
	maker::Entity* getLastSibling(ID id) const;

	bool isChild(ID parent_id, ID id) const;
	bool isLabel(ID id) const;
	bool isLabel(const maker::Entity* entity) const;

	typedef std::list< maker::Entity* > TYPE_SELECTED_ENTITIES;
	void getSelectedChildren(TYPE_SELECTED_ENTITIES& selected_entities);
	void getSelectedNearestChildren(TYPE_SELECTED_ENTITIES& selected_entities);

	void clearAllSelectedFlag();

	// bookingId() 로 새로 만들 Entity의 ID를 발급받아 CMD로 던지면 툴에서 create( ... ) 를 이용 실제 객체를 만든다.
	ID bookingId() const;
	maker::Entity* create(ID booked_id, ID parent_id, const ::maker::Properties& src_properties, const ::google::protobuf::RepeatedPtrField< ::maker::Entity >& src_children);

protected:
	void appendChildren(::google::protobuf::RepeatedPtrField< ::maker::Entity >* children);
	void unbindChildren(::google::protobuf::RepeatedPtrField< ::maker::Entity >* children);

public:
	bool remove(ID id, ID parent_id);

	bool checkMoveNext(ID id, ID parent_id, ID dest_id, ID dest_parent_id);
	bool moveNext(ID id, ID parent_id, ID dest_id, ID dest_parent_id);

	std::string refineFilePath(const std::string& file_path);

	inline std::string getBaseFolderPath() const { return m_base_folder_path; }


private:
	std::string m_base_folder_path;

	typedef std::map< ID, maker::Entity* > TYPE_NODE_BIND_MAP;
	TYPE_NODE_BIND_MAP m_node_bind;

	maker::Entity* m_root;
	ID m_current;

	unsigned long m_file_version;
	unsigned long m_load_file_version;

	unsigned long makeVersion(unsigned long major, unsigned long minor, unsigned long maintenance);
	unsigned long getMajorVersion(unsigned long version);
	unsigned long getMinorVersion(unsigned long version);
	unsigned long getMaintenanceVersion(unsigned long version);

protected:
	bool SaveEnum(FILE* file, const std::string& field_name, const ::google::protobuf::EnumValueDescriptor* evdesc, const std::string& indent);
	bool SaveFieldMessage(FILE* file, const std::string& field_name, const ::google::protobuf::Message& msg, const std::string& indent);
	bool SaveFieldBytes(FILE* file, const std::string& field_name, const std::string& bytes, const std::string& indent);
	bool SaveField(FILE* file, const ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor* field, const std::string& indent);
	bool SaveNode(FILE* file, const maker::Node* node, const std::string& indent);
	bool SaveMessage(FILE* file, const ::google::protobuf::Message& msg, const std::string& indent);
	bool Save(FILE* file, const maker::Properties& properties, const std::string& indent);
	bool Save(FILE* file, const maker::Entity& entity, const std::string& indent = "");
    bool SaveHeader(FILE* file, const std::string& indent = "");
    bool Save(FILE* file, const std::string& indent = "");

    bool CheckActionField(const ::google::protobuf::Message& msg, const::google::protobuf::FieldDescriptor* field);
    bool CheckSizeField(FILE* file, const ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor* field, const std::string& indent);

public:
	bool Save(const std::string& filename);

protected:
	bool findField(const std::string& field_name, maker::Properties& properties, ::google::protobuf::Message*& msg, const ::google::protobuf::FieldDescriptor*& field);
	bool LoadEnum(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token);
	bool LoadFieldMessage(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token);
	bool LoadFieldBytes(KLuaToken& T, ::google::protobuf::Message& msg, const ::google::protobuf::FieldDescriptor& field, const char* token);
    bool LoadField(KLuaToken& T, google::protobuf::Message* msg, const google::protobuf::FieldDescriptor* field, const char* token);
    bool Load(KLuaToken& T, maker::Properties& properties);
	bool Load(KLuaToken& T, maker::Entity& entity);
    bool LoadHeader(KLuaToken& T);
    bool Load(KLuaToken& T);

public:
	bool Load(const std::string& filename);

public:
	static std::string getEnumNameforTool(const ::google::protobuf::EnumValueDescriptor* evdesc);
	static const ::google::protobuf::EnumValueDescriptor* getEnumValueformFile(const ::google::protobuf::EnumDescriptor* edesc, const std::string& name);

	static bool fillDefaultValue(maker::Properties& properties);

	static bool isFileProperty(const std::string& name);
	static bool isScriptProperty(const std::string& name);
	static bool isEnumNameProperty(const std::string& name);

	static bool canAppendChild(maker::ENTITY_TYPE parent, maker::ENTITY_TYPE child);

private:
	maker::Entity _clipboard;

public:
	void copySelectedEntitiesToClipboard();
	inline maker::Entity& getClipboard() { return _clipboard; }

private:
	std::list< maker::Entity*> m_lLuaEntity;
	void getLuaEntity(maker::Entity* root_entity);
public:
	std::list< maker::Entity*> getLuaEntitiesWithCalc();
	std::list< maker::Entity*> getLuaEntities();
};



