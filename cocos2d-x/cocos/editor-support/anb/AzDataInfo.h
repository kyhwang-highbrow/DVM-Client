#ifndef __AZMODEL__AZDATAINFO__
#define __AZMODEL__AZDATAINFO__

#include "azmodel.pb.h"

#include "AzID.h"

#include <memory>

namespace azModel {

	typedef ::google::protobuf::Message AzData;

	class AzDataInfo
	{
	public:
		AzDataInfo(AzID rtid, AzID parent_rtid, AzData* data)
			: _rtid(rtid)
			, _parent_rtid(parent_rtid)
			, _data(nullptr)
		{
			if (parent_rtid == AzID::INVALID)
			{
				_data = std::shared_ptr<AzData>(data);
			}
			else
			{
				_data = std::shared_ptr<AzData>(data, [](AzData* d) {});
			}
		}
		~AzDataInfo()
		{
		}

		inline const AzID& getRuntimeID()			{ return _rtid; }
		inline const AzID& getParentRuntimeID()	{ return _parent_rtid; }
		inline AzData* getData() const
		{
			return _data.get();
		}

	private:
		AzID _rtid;
		AzID _parent_rtid;
		std::shared_ptr<AzData> _data;
	};

}

#endif//__AZMODEL__AZDATAINFO__
