#include "EntityHelper.h"
#include "MakerScene.h"

USING_NS_CC;
USING_NS_CC_EXT;


Node* CEntityHelper::m_root = nullptr;


class SampleTableViewCell : public cocos2d::extension::TableViewCell
{
public:
	virtual void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4 &transform, bool transformUpdated) override
	{
		TableViewCell::draw(renderer, transform, transformUpdated);
	}
};

SampleTableViewDataSource::SampleTableViewDataSource()
	: _inner_width(0)
	, _inner_height(0)
	, _cell_width(60)
	, _cell_height(60)
{
}
SampleTableViewDataSource::~SampleTableViewDataSource()
{
}

Size SampleTableViewDataSource::tableCellSizeForIndex(TableView *table, ssize_t idx)
{
	auto size = table->getViewSize();
	int cell_width = size.width;
	int cell_height = size.height;
	switch (table->getDirection())
	{
	case ScrollView::Direction::HORIZONTAL: cell_width = _cell_width; break;
	case ScrollView::Direction::VERTICAL: cell_height = _cell_height; break;
	case ScrollView::Direction::BOTH: cell_height = _cell_height; cell_width = _cell_width; break;
	}
	return Size(cell_width, cell_height);
};
Size SampleTableViewDataSource::cellSizeForTable(TableView *table)
{
	return Size(_inner_width, _inner_height);
};
TableViewCell* SampleTableViewDataSource::tableCellAtIndex(TableView *table, ssize_t idx)
{
	auto cell_size = tableCellSizeForIndex(table, idx);

	auto string = String::createWithFormat("%ld", idx);
	TableViewCell *cell = table->dequeueCell();
	if (!cell) {
		cell = new SampleTableViewCell();
		cell->autorelease();

		auto background = LayerColor::create(Color4B(255, 0, 0, 255), cell_size.width - 2, cell_size.height - 2);
		background->setTag(122);
		cell->addChild(background);

		auto label = Label::createWithSystemFont(string->getCString(), "Helvetica", 20.0);
		label->setPosition(Vec2::ZERO);
		label->setAnchorPoint(Vec2::ZERO);
		label->setTag(123);
		cell->addChild(label);
	}
	else
	{
		auto background = (LayerColor*)cell->getChildByTag(122);
		background->changeWidthAndHeight(cell_size.width - 2, cell_size.height - 2);

		auto label = (Label*)cell->getChildByTag(123);
		label->setString(string->getCString());
	}


	return cell;
}
ssize_t SampleTableViewDataSource::numberOfCellsInTableView(TableView *table)
{
	return 20;
}

CEntityHelper::CEntityHelper(cocos2d::Node* node, long long entity_id, int entity_type)
	: m_node(node)
	, m_entity_id(entity_id)
	, m_entity_type(entity_type)
	, m_selected(false)
	, m_parent_selected(false)
	, m_draging(false)
	// for Node
	// for Label
	, m_text_color(Color4B(255, 255, 255, 255))
	, m_outline(false)
	, m_outline_color(Color4B(0, 0, 0, 255))
	, m_outline_size(0.0f)
	, m_shadow(false)
	, m_shadow_color(Color4B(0, 0, 0, 255))
	, m_shadow_distance(5)
	, m_shadow_direction(0)
	, m_shadow_blur(1)
	// for select box
	, m_select_box_pattern(0xf0f0)
	, m_select_box_dt(0)
	, m_select_box_pattern_update_unit(30)
{
}

CEntityHelper::~CEntityHelper()
{
}

void CEntityHelper::appendDrawCommand(Renderer *renderer, float z_order)
{
	m_customDebugDrawCommand.init(z_order);
	m_customDebugDrawCommand.func = CC_CALLBACK_0(CEntityHelper::drawSelected, this);
	renderer->addCommand(&m_customDebugDrawCommand);
}

void CEntityHelper::updateSelectBox()
{
	DWORD currentTime = GetTickCount();
	if (m_select_box_dt < currentTime)
	{
		m_select_box_dt = currentTime + m_select_box_pattern_update_unit;

		m_select_box_pattern <<= 1;
		if (!(m_select_box_pattern & 0x10)) m_select_box_pattern |= 1;
	}
	glLineStipple(1, ~m_select_box_pattern);
}
void CEntityHelper::drawSelected()
{
	auto oldModelView = Director::getInstance()->getMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW);
	Director::getInstance()->loadMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW, m_node->getNodeToWorldTransform());

	updateSelectBox();

	if (m_node->getTag() == CMakerScene::EDIT_ROOT_TAG)
	{
		drawWorkspace(m_node);
		return;
	}

	auto sprite = dynamic_cast<Sprite*>(m_node);
    if (sprite)
    {
        drawSelectedInfo(sprite);
    }

    auto scale9sprite = dynamic_cast<Scale9Sprite*>(m_node);
    if (scale9sprite)
    {
        drawSelectedInfo(scale9sprite);
    }

    auto rotate_plate = dynamic_cast<RotatePlate*>(m_node);
    if (rotate_plate)
    {
        drawSelectedInfo(rotate_plate);
    }
	
	auto visual = dynamic_cast<AzVisual*>(m_node);
	if (visual)
	{
		drawSelectedInfo(visual);
	}
	else
	{
		drawSelectedInfo(m_node);
	}

	Director::getInstance()->loadMatrix(MATRIX_STACK_TYPE::MATRIX_STACK_MODELVIEW, oldModelView);

	auto parent_origin = Point::ZERO;
	auto parent = m_node->getParent();
	if (parent)
	{
		parent_origin = parent->convertToWorldSpace(Point(parent->getNormalSize().width*m_node->getDockPointX(), parent->getNormalSize().height*m_node->getDockPointY()));
	}

	auto size = m_node->getNormalSize();

	Point origin(m_node->convertToWorldSpace(Point(m_node->getAnchorPoint().x * size.width, m_node->getAnchorPoint().y * size.height)));
	drawAnchor(origin, parent_origin);
}
void CEntityHelper::drawSelectedInfo(Sprite* sprite)
{
	if (!sprite) return;

	auto& quad = sprite->getQuad();
	drawRectBox(quad, Color4B(255, 255, 0, 255));
}
void CEntityHelper::drawSelectedInfo(Scale9Sprite* sprite)
{
    if (!sprite) return;

    auto oSize = sprite->getOriginalSize();
    auto pSize = sprite->getNormalSize();
    auto insets = sprite->getCapInsets();
    if (insets.origin.x == 0 && insets.origin.y == 0 && insets.size.width == 0 && insets.size.height == 0)
    {
        insets = Rect(oSize.width / 3, oSize.height / 3, oSize.width / 3, oSize.height / 3);
    }

    Rect rect1;
    rect1.origin = Vec2(0, pSize.height - insets.origin.y);
    rect1.size = Size(insets.origin.x, insets.origin.y);
    drawRectBox(rect1, Color4B(255, 255, 0, 255));

    Rect rect2;
    rect2.origin = Vec2(0, 0);
    rect2.size = Size(insets.origin.x, oSize.height - (insets.origin.y + insets.size.height));
    drawRectBox(rect2, Color4B(255, 255, 0, 255));

    Rect rect3;
    rect3.origin = Vec2(pSize.width - (oSize.width - (insets.origin.x + insets.size.width)), pSize.height - insets.origin.y);
    rect3.size = Size(oSize.width - (insets.origin.x + insets.size.width), insets.origin.y);
    drawRectBox(rect3, Color4B(255, 255, 0, 255));

    Rect rect4;
    rect4.origin = Vec2(pSize.width - (oSize.width - (insets.origin.x + insets.size.width)), 0);
    rect4.size = Size(oSize.width - (insets.origin.x + insets.size.width), oSize.height - (insets.origin.y + insets.size.height));
    drawRectBox(rect4, Color4B(255, 255, 0, 255));
}
void CEntityHelper::drawSelectedInfo(RotatePlate* plate)
{
    if (!plate) return;

    float angle = plate->getOriginAngle();
    auto size = plate->getNormalSize();

    drawCircle(Rect(0, 0, size.width, size.height), Color4B(255, 255, 0, 255), angle, 3);
}
void CEntityHelper::drawSelectedInfo(AzVisual* visual)
{
	if (!visual) return;

	auto& rect = visual->getValidRect();
	drawRectBox(rect, Color4B(0, 255, 0, 255));
}
void CEntityHelper::drawSelectedInfo(Node* node)
{
	if (!node) return;

	auto size = node->getNormalSize();
	drawRectBox(size, Color4B(0, 255, 0, 255));
}
void CEntityHelper::drawWorkspace(cocos2d::Node* node)
{
	if (!node) return;

	auto size = node->getNormalSize();
	drawRectBox(Rect(-2, -2, size.width + 4, size.height + 4), Color4B(0, 255, 255, 255));
}

void CEntityHelper::drawRectBox(const cocos2d::Size& size, const cocos2d::Color4B& color)
{
	drawRectBox(Rect(0, 0, size.width, size.height), color);
}
void CEntityHelper::drawCircle(const cocos2d::Rect& rect, const cocos2d::Color4B& color, float angle, int count)
{
    float radius_x = rect.size.width / 2;
    float radius_y = rect.size.height / 2;

    const int vtxCount = 36;
    int unit = 360 / vtxCount;

    Point vertices[vtxCount];
    int idx = 0;
    for (int i = 0; i < 360; i += unit)
    {
        float x = radius_x + radius_x * cosf(CC_DEGREES_TO_RADIANS(i));
        float y = radius_y + radius_y * sinf(CC_DEGREES_TO_RADIANS(i));
        vertices[idx++] = Point(x, y);
    }

    glEnable(GL_LINE_STIPPLE);

    GLfloat backup_line_width;
    glGetFloatv(GL_LINE_WIDTH, &backup_line_width);

    glLineWidth(3.0f);
    DrawPrimitives::setDrawColor4B(0, 0, 0, 255);
    DrawPrimitives::drawPoly(vertices, vtxCount, true);

    glLineWidth(2.0f);
    DrawPrimitives::setDrawColor4B(color.r, color.g, color.b, color.a);
    DrawPrimitives::drawPoly(vertices, vtxCount, true);

    glDisable(GL_LINE_STIPPLE);

    const float length = 5.0f;

    Point* pt = new Point[count];
    for (int i = 0; i < count; ++i)
    {
        pt[i].x = radius_x + radius_x * cosf(angle + CC_DEGREES_TO_RADIANS(i * (360 / count)));
        pt[i].y = radius_y + radius_y * sinf(angle + CC_DEGREES_TO_RADIANS(i * (360 / count)));

        Point point_vertices[] = {
            Point(pt[i].x - length, pt[i].y - length),
            Point(pt[i].x + length, pt[i].y - length),
            Point(pt[i].x + length, pt[i].y + length),
            Point(pt[i].x - length, pt[i].y + length),
        };

        glLineWidth(2.0f);
        DrawPrimitives::setDrawColor4B(255, 0, 0, 255);
        DrawPrimitives::drawPoly(point_vertices, 4, true);
    }
    delete[] pt;

    glLineWidth(backup_line_width);
}
void CEntityHelper::drawRectBox(const cocos2d::Rect& rect, const cocos2d::Color4B& color)
{
	Point vertices[] = {
		Point(rect.getMinX(), rect.getMinY()),
		Point(rect.getMaxX(), rect.getMinY()),
		Point(rect.getMaxX(), rect.getMaxY()),
		Point(rect.getMinX(), rect.getMaxY()),
	};
	glEnable(GL_LINE_STIPPLE);

	GLfloat backup_line_width;
	glGetFloatv(GL_LINE_WIDTH, &backup_line_width);

	glLineWidth(5.0f);
	DrawPrimitives::setDrawColor4B(0, 0, 0, 255);
	DrawPrimitives::drawPoly(vertices, 4, true);

	glLineWidth(3.0f);
	DrawPrimitives::setDrawColor4B(color.r, color.g, color.b, color.a);
	DrawPrimitives::drawPoly(vertices, 4, true);

	glLineWidth(backup_line_width);

	glDisable(GL_LINE_STIPPLE);
}
void CEntityHelper::drawRectBox(const cocos2d::V3F_C4B_T2F_Quad& quad, const cocos2d::Color4B& color)
{
	Point vertices[] = {
		Point(quad.bl.vertices.x, quad.bl.vertices.y),
		Point(quad.br.vertices.x, quad.br.vertices.y),
		Point(quad.tr.vertices.x, quad.tr.vertices.y),
		Point(quad.tl.vertices.x, quad.tl.vertices.y),
	};

	glEnable(GL_LINE_STIPPLE);

	GLfloat backup_line_width;
	glGetFloatv(GL_LINE_WIDTH, &backup_line_width);

	glLineWidth(5.0f);
	DrawPrimitives::setDrawColor4B(0, 0, 0, 255);
	DrawPrimitives::drawPoly(vertices, 4, true);

	glLineWidth(3.0f);
	DrawPrimitives::setDrawColor4B(color.r, color.g, color.b, color.a);
	DrawPrimitives::drawPoly(vertices, 4, true);

	glLineWidth(backup_line_width);

	glDisable(GL_LINE_STIPPLE);
}
void CEntityHelper::drawAnchor(Point origin, Point parent_origin)
{
	if (m_root)
	{
		origin = m_root->convertToNodeSpace(origin);
		parent_origin = m_root->convertToNodeSpace(parent_origin);
	}
	if (m_draging)
	{
		DrawPrimitives::setDrawColor4B(255, 0, 0, 255);
		DrawPrimitives::drawLine(Point(origin.x, origin.y), Point(parent_origin.x, parent_origin.y));
	}

	const float length = 6.0f;

	GLfloat backup_line_width;
	glGetFloatv(GL_LINE_WIDTH, &backup_line_width);

	glLineWidth(3.0f);
	DrawPrimitives::setDrawColor4B(255, 0, 0, 155);
	DrawPrimitives::drawLine(Point(origin.x - length, origin.y - length), Point(origin.x + length, origin.y + length));
	DrawPrimitives::drawLine(Point(origin.x + length, origin.y - length), Point(origin.x - length, origin.y + length));

	glEnable(GL_LINE_STIPPLE);
	glLineWidth(1.0f);
	DrawPrimitives::setDrawColor4B(255, 255, 0, 155);
	DrawPrimitives::drawLine(Point(origin.x - length, origin.y - length), Point(origin.x + length, origin.y + length));
	DrawPrimitives::drawLine(Point(origin.x + length, origin.y - length), Point(origin.x - length, origin.y + length));
	glDisable(GL_LINE_STIPPLE);

	glLineWidth(backup_line_width);

	Point parent_vertices[] = {
		Point(parent_origin.x - length, parent_origin.y - length),
		Point(parent_origin.x + length, parent_origin.y - length),
		Point(parent_origin.x + length, parent_origin.y + length),
		Point(parent_origin.x - length, parent_origin.y + length),
	};

	DrawPrimitives::setDrawColor4B(255, 0, 0, 255);
	DrawPrimitives::drawPoly(parent_vertices, 4, true);
}

void CEntityHelper::backupEntityInfo(const maker::Entity& entity)
{
	auto node = entity.properties().node();
	setPickPos(Point(node.x(), node.y()));

	auto size = m_node->getNormalSize();
	setPickSize(size);
}

