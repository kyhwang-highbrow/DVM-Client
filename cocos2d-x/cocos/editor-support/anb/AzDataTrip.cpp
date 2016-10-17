#include "AzDataTrip.h"

#include <float.h>

#include "AzTM.h"
#include "AzBlend.h"


using namespace azModel;
using namespace azVisual;


namespace azModel {


	AzDataTrip::AzDataTrip()
		: _azddic(0)
		, _repeat(true)
		, _doBitmap([](const azVisual::Key*, const AzTM&, const AzBlend&, const Bitmap*) {return true; })
		, _doSprite([](const azVisual::Key*, const AzTM&, const AzBlend&, const Bitmap*, const Sprite*) {return true; })
		, _doSocket([](const azVisual::Key*, const AzTM&, const AzBlend&, const Socket*, float frame) {return true; })
		, _doEventShape([](const azVisual::Key*, const AzTM&, const AzBlend&, const azVisual::EventShape*) {return true; })
		, _doParticle([](const azVisual::Key*, const AzTM&, const AzBlend&, const azVisual::Particle*) {return true; })
		, _doFont([](const azVisual::Key*, const AzTM&, const AzBlend&, const azVisual::Font*) {return true; })
	{
	}
	AzDataTrip::~AzDataTrip()
	{
	}
	
	bool AzDataTrip::trip(const azVisual::Visual& visual, float frame)
	{
		if (!_azddic) return false;

		AzTM tm;
		AzBlend blend;
		return trip(tm, blend, &visual, frame);
	}
	bool AzDataTrip::trip(const azVisual::Visual& visual, float frame, float r, float g, float b, float a)
	{
		if (!_azddic) return false;

		AzTM tm;
		AzBlend blend(r, g, b, a);
		return trip(tm, blend, &visual, frame);
	}
	bool AzDataTrip::trip(const Key* key, const AzTM& tm, const AzBlend& blend, const AzID& rtid, float frame)
	{
		int type;
		auto* data = _azddic->getData(rtid, type);
		if (!data) return true;

		if (key)
		{
			AzTM curr_tm(key->transform());
			curr_tm.mul(tm);

			AzBlend curr_blend(*key);
			curr_blend.mul(blend);

			switch (type)
			{
			case VisualGroup::kTypeFieldNumber: return trip(key, curr_tm, curr_blend, dynamic_cast<VisualGroup*>(data), frame);
			case Visual::kTypeFieldNumber:		return trip(curr_tm, curr_blend, dynamic_cast<Visual*>(data), frame);
			case Layer::kTypeFieldNumber:		return trip(curr_tm, curr_blend, dynamic_cast<Layer*>(data), frame);
			case Bitmap::kTypeFieldNumber:		return trip(key, curr_tm, curr_blend, dynamic_cast<Bitmap*>(data), frame);
			case Sprite::kTypeFieldNumber:		return trip(key, curr_tm, curr_blend, dynamic_cast<Sprite*>(data), frame);
			case Socket::kTypeFieldNumber:		return trip(key, curr_tm, curr_blend, dynamic_cast<Socket*>(data), frame);
			case EventShape::kTypeFieldNumber:	return trip(key, curr_tm, curr_blend, dynamic_cast<EventShape*>(data), frame);
			case Particle::kTypeFieldNumber:	return trip(key, curr_tm, curr_blend, dynamic_cast<Particle*>(data), frame);
			case Font::kTypeFieldNumber:		return trip(key, curr_tm, curr_blend, dynamic_cast<Font*>(data), frame);
			}
		}
		else
		{
			switch (type)
			{
			case VisualGroup::kTypeFieldNumber: return trip(key, tm, blend, dynamic_cast<VisualGroup*>(data), frame);
			case Visual::kTypeFieldNumber:		return trip(tm, blend, dynamic_cast<Visual*>(data), frame);
			case Layer::kTypeFieldNumber:		return trip(tm, blend, dynamic_cast<Layer*>(data), frame);
			case Bitmap::kTypeFieldNumber:		return trip(key, tm, blend, dynamic_cast<Bitmap*>(data), frame);
			case Sprite::kTypeFieldNumber:		return trip(key, tm, blend, dynamic_cast<Sprite*>(data), frame);
			case Socket::kTypeFieldNumber:		return trip(key, tm, blend, dynamic_cast<Socket*>(data), frame);
			case EventShape::kTypeFieldNumber:	return trip(key, tm, blend, dynamic_cast<EventShape*>(data), frame);
			case Particle::kTypeFieldNumber:	return trip(key, tm, blend, dynamic_cast<Particle*>(data), frame);
			case Font::kTypeFieldNumber:		return trip(key, tm, blend, dynamic_cast<Font*>(data), frame);
			}
		}
		return true;
	}
	bool AzDataTrip::trip(const Key* key, const AzTM& tm, const AzBlend& blend, const VisualGroup* visual_group, float frame)
	{
		if (!key) return true;
		if (!visual_group) return true;

		for (auto& visual : visual_group->visual_list())
		{
			if (visual.base().name() == key->refrence_name())
			{
				trip(tm, blend, &visual, frame);
			}
		}

		return true;
	}
	bool AzDataTrip::trip(const AzTM& tm, const AzBlend& blend, const Visual* visual, float frame)
	{
		if (!visual) return true;
		if (!visual->has_layer()) return true;

		CheckRecusive check_recusive(_draw_list, visual->base().rtid());
		if (!check_recusive.isRecusive())
		{
			trip(tm, blend, &(visual->layer()), frame);
		}
		return true;
	}
	bool AzDataTrip::trip(const AzTM& tm, const AzBlend& blend, const Layer* layer, float frame)
	{
		if (!layer) return true;
		if (!layer->base().apply()) return true;

		if (layer->has_reference_rtid())
		{
			Key current_key;
			if (getSubLayerKey(*layer, frame, current_key))
			{
				trip(&current_key, tm, blend, layer->reference_rtid(), current_key.frame());
			}
		}

		for (auto& sublayer : layer->layer_list())
		{
			trip(tm, blend, &sublayer, frame);
		}
		return true;
	}

	bool AzDataTrip::trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const Bitmap* bitmap, float frame)
	{
		if (!bitmap) return true;
		if (!bitmap->base().apply()) return true;

		return _doBitmap(key, tm, blend, bitmap);
	}
	bool AzDataTrip::trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const Sprite* sprite, float frame)
	{
		if (!sprite) return true;
		if (!sprite->base().apply()) return true;

		return _doSprite(key, tm, blend, dynamic_cast<azModel::Bitmap*>(_azddic->getData(sprite->base().parent_rtid())), sprite);
	}
	bool AzDataTrip::trip(const Key* key, const AzTM& tm, const AzBlend& blend, const Socket* socket, float frame)
	{
		if (!socket) return true;

		return _doSocket(key, tm, blend, socket, frame);
	}
	bool AzDataTrip::trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const EventShape* event_shape, float frame)
	{
		if (!key) return true;
		if (!event_shape) return true;

		return _doEventShape(key, tm, blend, event_shape);
	}
	bool AzDataTrip::trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const azVisual::Particle* particle, float frame)
	{
		if (!key) return true;
		if (!particle) return true;

		return _doParticle(key, tm, blend, particle);
	}

	bool AzDataTrip::trip(const Key* key, const AzTM& tm, const AzBlend& blend, const Font* font, float frame)
	{
		if (!font) return true;

		return _doFont(key, tm, blend, font);
	}

	void AzDataTrip::interpolate(Transform2D& out, float bias, const Transform2D& begin, const Transform2D& end)
	{
		float inv_bias = 1.0f - bias;

		out.set_scale_x((begin.scale_x() * inv_bias) + (end.scale_x() * bias));
		out.set_scale_y((begin.scale_y() * inv_bias) + (end.scale_y() * bias));
		out.set_offset_x((begin.offset_x() * inv_bias) + (end.offset_x() * bias));
		out.set_offset_y((begin.offset_y() * inv_bias) + (end.offset_y() * bias));
		out.set_rotate_z((begin.rotate_z() * inv_bias) + (end.rotate_z() * bias));
		out.set_rotate_z((begin.rotate_z() * inv_bias) + (end.rotate_z() * bias));
		out.set_position_x((begin.position_x() * inv_bias) + (end.position_x() * bias));
		out.set_position_y((begin.position_y() * inv_bias) + (end.position_y() * bias));
		out.set_flip_h(begin.flip_h());
		out.set_flip_v(begin.flip_v());
	}
	void AzDataTrip::interpolate(Key& out, float bias, const Key& begin, const Key& end)
	{
		interpolate(*(out.mutable_transform()), bias, begin.transform(), end.transform());

		float inv_bias = 1.0f - bias;
		out.set_color_r((begin.color_r() * inv_bias) + (end.color_r() * bias));
		out.set_color_g((begin.color_g() * inv_bias) + (end.color_g() * bias));
		out.set_color_b((begin.color_b() * inv_bias) + (end.color_b() * bias));
		out.set_alpha((begin.alpha() * inv_bias) + (end.alpha() * bias));

		out.set_blank(begin.blank());
		out.set_blend_mode(begin.blend_mode());
		out.set_refrence_name(begin.refrence_name());
		out.set_shape_type(begin.shape_type());
	}

	bool AzDataTrip::getKey(const Layer& layer, float frame, Key& out_key) const
	{
		Key tmp;
		tmp.set_frame(frame);
		auto pick_key = std::lower_bound(layer.key_list().begin(), layer.key_list().end(), tmp,
			[](const Key& lhs, const Key& rhs)
		{
			return lhs.frame() < rhs.frame();
		});

		if (pick_key == layer.key_list().end())
		{
			auto last_key = layer.key_list().rbegin();
			float last_frame = last_key->frame();
			if (last_frame + 1 < frame) return false;

			out_key = *last_key;
			return true;
		}

		float pick_frame = pick_key->frame();
		if (pick_frame == frame)
		{
			out_key = *pick_key;
			return true;
		}

		if (pick_key == layer.key_list().begin()) return false;

		auto prev_key = pick_key;
		--prev_key;

		float prev_frame = prev_key->frame();
		float bias = (frame - prev_frame) / (pick_frame - prev_frame);
		interpolate(out_key, bias, *(prev_key), *(pick_key));

		return true;
	}

	bool AzDataTrip::getRange(const azVisual::Visual& visual, float& begin, float& end) const
	{
		return getRange(visual.layer(), begin, end);
	}
	bool AzDataTrip::getRange(const Layer& layer, float& begin, float& end) const
	{
		float curr_begin = FLT_MAX;
		float curr_end = -FLT_MAX;
		if (layer.key_list_size() > 0)
		{
			curr_begin = layer.key_list().begin()->frame();
			curr_end = layer.key_list().rbegin()->frame();
		}

		for (auto& sublayer : layer.layer_list())
		{
			float layer_begin;
			float layer_end;

			if (getRange(sublayer, layer_begin, layer_end))
			{
				if (curr_begin > layer_begin) curr_begin = layer_begin;
				if (curr_end < layer_end) curr_end = layer_end;
			}
		}

		if (curr_begin == FLT_MAX || curr_end == -FLT_MAX)
		{
			begin = 0;
			end = 0;
			return false;
		}

		begin = curr_begin;
		end = curr_end;

		return true;
	}
	bool AzDataTrip::getSubLayerKey(const azVisual::Layer& layer, float frame, azVisual::Key& key) const
	{
		float begin, end;
		if (!getRange(layer, begin, end)) return false;
		if (!getKey(layer, frame, key)) return false;

		auto* data = getTripableData(key, layer.reference_rtid());
		if (!data) return false;

		const Visual* ref_visual = dynamic_cast<const Visual*>(data);
		if (!ref_visual)
		{
			const VisualGroup* ref_visualgroup = dynamic_cast<const VisualGroup*>(data);
			if (!ref_visualgroup) return true;

			for (auto& visual : ref_visualgroup->visual_list())
			{
				if (visual.base().name() == key.refrence_name())
				{
					ref_visual = &visual;
					break;
				}
			}

			if (!ref_visual) return true;
		}

		if (begin == end)
		{
			key.set_frame(0);
			return true;
		}

		float visual_begin, visual_end;
		if (!getRange(ref_visual->layer(), visual_begin, visual_end)) return true;

		float length = end - begin;
		float visual_length = visual_end;

		key.set_frame((frame - begin) * visual_length / length);

		return true;
	}
	const AzData* AzDataTrip::getTripableData(const azVisual::Key& key, const AzID& id) const
	{
		auto* data = _azddic->getData(id);
		if (!data) return 0;

		VisualGroup* visual_group = dynamic_cast<VisualGroup*>(data);
		if (visual_group)
		{
			for (auto& visual : visual_group->visual_list())
			{
				if (visual.base().name() == key.refrence_name())
				{
					return data;
				}
			}
			return nullptr;
		}

		Socket* socket = dynamic_cast<Socket*>(data);
		if (socket)
		{
			auto socket_ref_data = getTripableData(key, socket->reference_rtid());
			if (socket_ref_data) return socket_ref_data;
			return data;
		}

		return data;
	}

}
