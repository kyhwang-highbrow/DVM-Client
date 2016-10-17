#ifndef __AZMODEL__A2D_LOADER__
#define __AZMODEL__A2D_LOADER__

#include <string>
#include <list>

#include "AzID.h"
#include "AzDataDictionary.h"
#include "a2dToken4x.h"
#include "azvisual.pb.h"

namespace azModel {

	class a2dLoader4x
	{
	public:
		static const std::string PROJECT_PATH;

		a2dLoader4x(AzDataDictionary& azddic);
		~a2dLoader4x();

		AzID load(const std::string& filename, const std::string& name = "", const AzID& parent_rtid = AzID::INVALID);

		inline void enableLog(bool v) { _log = v; }

	protected:
		bool load(a2dToken4x& token, azVisual::Project* project, const std::string& filename);
		bool loadProject(a2dToken4x& token, azVisual::Project* project, const char* name);
		bool loadVisualGroup(a2dToken4x& token, azVisual::Project* project, const char* name);
		bool loadVisual(a2dToken4x& token, azVisual::VisualGroup* visual_group, const char* name);
		bool loadLayerGroup(a2dToken4x& token, azVisual::Layer* layer);
		bool loadLayer(a2dToken4x& token, azVisual::Layer* layer);
		bool loadKey(a2dToken4x& token, azVisual::Layer* layer, int frame);
		bool loadBitmap(a2dToken4x& token, azVisual::Project* project, const char* name);
		bool loadSprite(a2dToken4x& token, ::azModel::Bitmap* bitmap);
		bool loadSocket(a2dToken4x& token, azVisual::Project* project, const char* name);
		bool loadEventBox(a2dToken4x& token, azVisual::Project* project, const char* name);
		bool loadParticle(a2dToken4x& token, azVisual::Project* project, const char* name);
		bool loadUnknown(a2dToken4x& token, const char* name);

		void insertBind(::azModel::AzDataInfo* azdi, const std::string& name);
		void insertBind(::azModel::AzDataInfo* azdi, const std::string& name, azVisual::Project* project);

		bool bindSocket();
		bool bindLayer();

	private:
		AzDataDictionary& _azddic;

		int _version;
		inline bool isUnder45() const { return _version < 0x00040005; }
		inline bool isUnder46() const { return _version < 0x00040006; }
		inline bool isUnder47() const { return _version < 0x00040007; }
		inline bool isUnder48() const { return _version < 0x00040008; }

		typedef std::list< std::pair< unsigned long long, std::string > > TYPE_BIND_LIST;
		TYPE_BIND_LIST _socket_bind_info;
		TYPE_BIND_LIST _layer_bind_info;

		typedef std::map< std::string, unsigned long long > TYPE_NAME_TO_RTID_LIST;
		typedef std::map< unsigned long long, std::string > TYPE_RTID_TO_NAME_LIST;
		TYPE_NAME_TO_RTID_LIST _name_to_rtid;
		TYPE_RTID_TO_NAME_LIST _rtid_to_name;

		bool _log;

		std::string _file_name;
	};

}

#endif//__AZMODEL__A2D_LOADER__
