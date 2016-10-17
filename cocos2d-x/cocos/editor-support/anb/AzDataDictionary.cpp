#include "AzDataDictionary.h"

namespace azModel {

	AzDataDictionary::AzDataDictionary()
	{
	}

	AzDataDictionary::~AzDataDictionary()
	{
		for (auto& i : _objects)
		{
			auto azdi = i.second;
			if (azdi)
			{
				delete azdi;
			}
		}
	}

	const AzDataInfo* AzDataDictionary::get(const AzID& rtid) const
	{
		auto i = _objects.find(rtid);
		if (i == _objects.end()) return 0;

		return i->second;
	}

	AzDataInfo* AzDataDictionary::get(const AzID& rtid)
	{
		auto i = _objects.find(rtid);
		if (i == _objects.end()) return 0;

		return i->second;
	}

	void AzDataDictionary::remove(const AzID& rtid)
	{
		auto i = _objects.find(rtid);
		if (i == _objects.end()) return;

		if (i->second)
			delete i->second;

		_objects.erase(i);
	}

	AzDataInfo* AzDataDictionary::add(const AzData* data)
	{
		if (!data) return 0;

		unsigned long long rtid = 0;
		unsigned long long parent_rtid = 0;

		auto* base_field_desc = data->GetDescriptor()->FindFieldByName("base");
		if (base_field_desc)
		{
			if (base_field_desc->type() == ::google::protobuf::FieldDescriptor::TYPE_MESSAGE)
			{
				auto& base = data->GetReflection()->GetMessage(*data, base_field_desc);
				auto* base_desc = base.GetDescriptor();
				if (base_desc)
				{
					auto* rtid_field_desc = base_desc->FindFieldByName("rtid");
					if (rtid_field_desc)
					{
						if (rtid_field_desc->type() == ::google::protobuf::FieldDescriptor::TYPE_UINT64)
						{
							rtid = base.GetReflection()->GetUInt64(base, rtid_field_desc);
						}
					}
					auto* parent_rtid_field_desc = base_desc->FindFieldByName("parent_rtid");
					if (parent_rtid_field_desc)
					{
						if (parent_rtid_field_desc->type() == ::google::protobuf::FieldDescriptor::TYPE_UINT64)
						{
							parent_rtid = base.GetReflection()->GetUInt64(base, parent_rtid_field_desc);
						}
					}
				}
			}
		}

		AzDataInfo* azdi = new AzDataInfo(rtid ? AzID(rtid) : AzID::genID(), AzID(parent_rtid), const_cast<AzData*>(data));

		auto i = _objects.find(azdi->getRuntimeID());
		if (i != _objects.end() && i->first == azdi->getRuntimeID())
		{
			delete azdi;
			return 0;
		}

		_objects.insert(TYPE_OBJECT_LIST::value_type(azdi->getRuntimeID(), azdi));

		return azdi;
	}

	AzData* AzDataDictionary::getData(const AzID& rtid) const
	{
		auto* azdi = get(rtid);
		if (!azdi) return nullptr;

		return azdi->getData();
	}

	AzData* AzDataDictionary::getData(const AzID& rtid, int& type) const
	{
		auto* azdi = get(rtid);
		if (!azdi) return nullptr;

		auto* data = azdi->getData();
		if (!data) return nullptr;

		auto* extension = data->GetDescriptor()->extension(0);
		if (!extension || extension->name() != "type") return nullptr;

		type = extension->number();

		return data;
	}

}
