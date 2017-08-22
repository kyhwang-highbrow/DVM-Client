local PARENT = UIC_Node

-------------------------------------
-- class UIC_IndivisualStats
-------------------------------------
UIC_IndivisualStats = class(UIC_Node, {
        -- 능력치 명칭 (왼쪽 정렬)
        m_statNameLabel = 'cc.Label',

        -- 이전 능력치 (오른쪽 정렬)
        m_beforeStatsLabel = 'cc.Label',

        -- 다음 능력치 (오른쪽 정렬)
        m_afterStatsLabel = 'cc.Label',

        -- 화살표 아이콘
        m_arrowIconSprite = 'Animator',

        --------------------------------------------
        m_statsName = '',
        m_beforeStats = '',
        m_afterStats = '',

        m_componentWidth = '',
        m_bDirty = 'boolean',

        --------------------------------------------
        -- 각종 설정값
        m_contentMargin = 'number',


        --------------------------------------------
        m_lNumberLabel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UIC_IndivisualStats:init()
    self.m_bDirty = true
    self.m_contentMargin = 10
end

-------------------------------------
-- function initUIComponent
-------------------------------------
function UIC_IndivisualStats:initUIComponent()
    self.m_node = cc.Node:create()
    self.m_node:setDockPoint(cc.p(0.5, 0.5))
    self.m_node:setAnchorPoint(cc.p(0.5, 0.5))

    local str = ''
    local font_name = 'res/font/common_font_01.ttf'
    local font_size = 24
    local stroke_tickness = 2
    local size = cc.size(256, 256)

    do
        str = '공격력'
        local node = cc.Label:createWithTTF(str, font_name, font_size, stroke_tickness, size, cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        node:setDockPoint(cc.p(0, 0.5))
        node:setAnchorPoint(cc.p(0, 0.5))

        --node:setTextColor(cc.c4b(r,g,b,a))
        node:setColor(cc.c3b(161, 125, 93))
        node:enableOutline(cc.c4b(0,0,0,255), stroke_tickness)

        self.m_node:addChild(node)
        self.m_statNameLabel = node
    end

    do
        str = '100'
        local node = cc.Label:createWithTTF(str, font_name, font_size, stroke_tickness, size, cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        node:setDockPoint(cc.p(0, 0.5))
        node:setAnchorPoint(cc.p(1, 0.5))

        --node:setTextColor(cc.c4b(r,g,b,a))
        node:setColor(cc.c3b(255, 255, 255))
        node:enableOutline(cc.c4b(0,0,0,255), stroke_tickness)

        self.m_node:addChild(node)
        self.m_beforeStatsLabel = node
    end

    do -- 화살표 아이콘
        local animator = MakeAnimator('res/ui/frames/temp/dragon_reserch_next.png')
        animator:setDockPoint(0, 0.5)
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_node:addChild(animator.m_node)
        self.m_arrowIconSprite = animator
    end

    do -- 변경 후 능력치
        str = '200'
        local node = cc.Label:createWithTTF(str, font_name, font_size, stroke_tickness, size, cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        node:setDockPoint(cc.p(0, 0.5))
        node:setAnchorPoint(cc.p(0, 0.5))

        --node:setTextColor(cc.c4b(r,g,b,a))
        node:setColor(cc.c3b(0, 255, 0))
        node:enableOutline(cc.c4b(0,0,0,255), stroke_tickness)

        self.m_node:addChild(node)
        self.m_afterStatsLabel = node
    end


    do
        self.m_lNumberLabel = {}
        self.m_lNumberLabel['before'] = NumberLabel(self.m_beforeStatsLabel, 0, 0.3)
        self.m_lNumberLabel['after'] = NumberLabel(self.m_afterStatsLabel, 0, 0.3)
    end
end

-------------------------------------
-- function calcComponentSize
-------------------------------------
function UIC_IndivisualStats:calcComponentSize()
    local name_width = self.m_statNameLabel:getStringWidth()
    local before_width = self.m_beforeStatsLabel:getStringWidth()
    local after_width = self.m_afterStatsLabel:getStringWidth()
    local icon_width = self.m_arrowIconSprite.m_node:getContentSize()['width']

    local total_width = name_width + before_width + after_width + icon_width
    total_width = total_width + (self.m_contentMargin * 3)
    
    ccdump(total_width)

    self.m_componentWidth = total_width
end

-------------------------------------
-- function align
-------------------------------------
function UIC_IndivisualStats:align()
    local name_width = self.m_statNameLabel:getStringWidth()
    local before_width = self.m_beforeStatsLabel:getStringWidth()
    local after_width = self.m_afterStatsLabel:getStringWidth()
    local icon_width = self.m_arrowIconSprite.m_node:getContentSize()['width']

    local pox_x = 0

    pox_x = pox_x + name_width + self.m_contentMargin + before_width
    self.m_beforeStatsLabel:setPositionX(pox_x)

    pox_x = pox_x + self.m_contentMargin + (icon_width/2)
    self.m_arrowIconSprite:setPositionX(pox_x)

    pox_x = pox_x + (icon_width/2) + self.m_contentMargin
    self.m_afterStatsLabel:setPositionX(pox_x)
end

-------------------------------------
-- function refresh
-------------------------------------
function UIC_IndivisualStats:refresh()
    if (not self.m_bDirty) then
        return
    end
end

-------------------------------------
-- function setStatsName
-- @brief 능력치 이름 설정
-------------------------------------
function UIC_IndivisualStats:setStatsName(stats_name)
    if (self.m_statsName == stats_name) then
        return
    end

    self.m_statsName = stats_name
    self.m_statNameLabel:setString(Str(stats_name))
end

-------------------------------------
-- function setBeforeStats
-- @brief 이전 능력치 설정
-------------------------------------
function UIC_IndivisualStats:setBeforeStats(stats)
    if (self.m_beforeStats == stats) then
        return
    end

    self.m_beforeStats = stats
    --self.m_beforeStatsLabel:setString(comma_value(stats))
    self.m_lNumberLabel['before']:setNumber(stats)
end

-------------------------------------
-- function setAfterStats
-- @brief 다음 능력치 설정
-------------------------------------
function UIC_IndivisualStats:setAfterStats(stats)
    if (self.m_afterStats == stats) then
        return
    end

    self.m_afterStats = stats
    --self.m_afterStatsLabel:setString(comma_value(stats))
    self.m_lNumberLabel['after']:setNumber(stats)
end

-------------------------------------
-- function setLayout
-- @brief
-------------------------------------
function UIC_IndivisualStats:setLayout(width, height, x1, x2, x3)
    self:setNormalSize(width, height)
    self.m_beforeStatsLabel:setPositionX(x1)
    self.m_arrowIconSprite:setPositionX(x2)
    self.m_afterStatsLabel:setPositionX(x3)
end



-------------------------------------
-- function setParentNode
-- @brief
-------------------------------------
function UIC_IndivisualStats:setParentNode(node)
    node:addChild(self.m_node)
    local width, height = node:getNormalSize()
    local arrow_pos = (width * 0.75)

    local x1 = arrow_pos - 20
    local x2 = arrow_pos
    local x3 = arrow_pos + 20
    self:setLayout(width, height, x1, x2, x3)
end
