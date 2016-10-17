#ifndef __AZMODEL_AZDATADICTIONARY__
#define __AZMODEL_AZDATADICTIONARY__

#include <unordered_map>

#include "AzDataInfo.h"

namespace azModel {

	class AzDataDictionary
	{
	public:
		struct Hasher
		{
			long long operator() (AzID const& key) const { return key.getValue(); }
		};
		struct EqualFn
		{
			bool operator() (AzID const& t1, AzID const& t2) const { return t1 == t2; }
		};

		typedef std::unordered_map< AzID, AzDataInfo*, Hasher, EqualFn > TYPE_OBJECT_LIST;

		AzDataDictionary();
		~AzDataDictionary();

		const AzDataInfo* get(const AzID& rtid) const;
		AzDataInfo* get(const AzID& rtid);
		void remove(const AzID& rtid);

		AzDataInfo* add(const AzData* data);

		AzData* getData(const AzID& rtid) const;
		AzData* getData(const AzID& rtid, int& type) const;

	private:
		TYPE_OBJECT_LIST _objects;
	};

}

#endif//__AZMODEL_AZDATADICTIONARY__
