#ifndef __AZMODEL__AZDATATRIP__
#define __AZMODEL__AZDATATRIP__

#include "AzDataDictionary.h"
#include "azvisual.pb.h"

#include <list>
#include <functional>


namespace azModel {

	class AzTM;
	class AzBlend;

	class AzDataTrip
	{
	public:
		AzDataTrip();
		~AzDataTrip();

		inline void setAzDataDictionary(AzDataDictionary* azddic) { _azddic = azddic; }
		inline const AzDataDictionary* getAzDataDictionary() const { return _azddic; }

		using doBitmap = std::function<bool(const azVisual::Key*, const AzTM&, const AzBlend&, const Bitmap*)>;
		using doSprite = std::function<bool(const azVisual::Key*, const AzTM&, const AzBlend&, const Bitmap*, const Sprite*)>;
		using doSocket = std::function<bool(const azVisual::Key*, const AzTM&, const AzBlend&, const azVisual::Socket*, float)>;
		using doEventShape = std::function<bool(const azVisual::Key*, const AzTM&, const AzBlend&, const azVisual::EventShape*)>;
		using doParticle = std::function<bool(const azVisual::Key*, const AzTM&, const AzBlend&, const azVisual::Particle*)>;
		using doFont = std::function<bool(const azVisual::Key*, const AzTM&, const AzBlend&, const azVisual::Font*)>;

		inline void setRepeat(bool v) { _repeat = v; }
		inline void setDoBitmap(doBitmap f) { _doBitmap = f; }
		inline void setDoSprite(doSprite f) { _doSprite = f; }
		inline void setDoSocket(doSocket f) { _doSocket = f; }
		inline void setDoEventShape(doEventShape f) { _doEventShape = f; }
		inline void setDoParticle(doParticle f) { _doParticle = f; }
		inline void setDoFont(doFont f) { _doFont = f; }

		bool trip(const azVisual::Visual& visual, float frame);
		bool trip(const azVisual::Visual& visual, float frame, float r, float g, float b, float a);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const AzID& rtid, float frame);
		bool trip(const AzTM& tm, const AzBlend& blend, const azVisual::Visual* visual, float frame);

		bool getRange(const azVisual::Visual& visual, float& begin, float& end) const;

	protected:
		bool trip(const AzTM& tm, const AzBlend& blend, const azVisual::Layer* layer, float frame);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const azVisual::VisualGroup* visual_group, float frame);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const Bitmap* bitmap, float frame);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const Sprite* sprite, float frame);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const azVisual::Socket* socket, float frame);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const azVisual::EventShape* event_shape, float frame);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const azVisual::Particle* particle, float frame);
		bool trip(const azVisual::Key* key, const AzTM& tm, const AzBlend& blend, const azVisual::Font* font, float frame);

		static void interpolate(Transform2D& out, float bias, const Transform2D& begin, const Transform2D& end);
		static void interpolate(azVisual::Key& out, float bias, const azVisual::Key& begin, const azVisual::Key& end);

		bool getKey(const azVisual::Layer& layer, float frame, azVisual::Key& out_key) const;
		bool getRange(const azVisual::Layer& layer, float& begin, float& end) const;
		bool getSubLayerKey(const azVisual::Layer& layer, float frame, azVisual::Key& key) const;
		const AzData* getTripableData(const azVisual::Key& key, const AzID& id) const;

	private:
		AzDataDictionary* _azddic;

		typedef std::list< AzID > TYPE_DRAW_LIST;
		TYPE_DRAW_LIST _draw_list;

		class CheckRecusive
		{
		public:
			CheckRecusive(TYPE_DRAW_LIST& stack, AzID rtid) : _stack(stack), _is_recusive(false)
			{
				if (std::find(_stack.begin(), _stack.end(), rtid) != _stack.end())
				{
					_is_recusive = true;
				}
				else
				{
					_stack.push_back(rtid);
				}
			}
			~CheckRecusive()
			{
				if (!_is_recusive)
				{
					_stack.pop_back();
				}
			}

			inline bool isRecusive() const { return _is_recusive; }

		private:
			TYPE_DRAW_LIST& _stack;
			bool _is_recusive;
		};

		bool _repeat;
		doBitmap _doBitmap;
		doSprite _doSprite;
		doSocket _doSocket;
		doEventShape _doEventShape;
		doParticle _doParticle;
		doFont _doFont;
	};

}

#endif//__AZMODEL__AZDATATRIP__
