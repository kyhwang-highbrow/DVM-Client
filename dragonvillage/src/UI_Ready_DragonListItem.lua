--  button
--  disableNode
--  selectedNode
--  attributeNode
--  levelLabel
--  iconNode

CHAMP_LIST_CELL_STATE_NONE = 0
CHAMP_LIST_CELL_STATE_SELECTED = 1
CHAMP_LIST_CELL_STATE_DISABLE = 2

-------------------------------------
-- class UI_Ready_DragonListItem
-------------------------------------
UI_Ready_DragonListItem = class(UI,{
        m_state = '',
        m_clickCB = '',

        m_charAnimator = '',
        m_charAnimatorEvolution = 'number', -- 지금 재생중인 드래곤의 진화 단계
        m_stageAttribute = 'ATTRUBUTE',
        m_charAnimatorAttrSynastry = 'sprite',

        -- data
        m_dragonData = 'table',
        m_dataDragonID = '',
        m_dataDeck = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Ready_DragonListItem:init(item)
    self.m_state = CHAMP_LIST_CELL_STATE_NONE

    -- data
    self.m_dragonData = item
    self.m_dataDragonID = tonumber(item['did'])
    self.m_dataDeck = nil

    local vars = self:load('dragon_item.ui')

    --self:getCharAnimator()

    self:refreshDragonInfo()
end

-------------------------------------
-- function changeState
-------------------------------------
function UI_Ready_DragonListItem:changeState(state)
    if (self.m_state == state) then
        return
    end

    local vars = self.vars

    -- 이전 상태 정리
    local prev_state = self.m_state
    if (prev_state == CHAMP_LIST_CELL_STATE_NONE) then

    elseif (prev_state == CHAMP_LIST_CELL_STATE_SELECTED) then
        vars['selectSprite']:setVisible(false)

    elseif (prev_state == CHAMP_LIST_CELL_STATE_DISABLE) then
        vars['disableSprite']:setVisible(false)
    end

    -- 신규 상태 정리
    if (state == CHAMP_LIST_CELL_STATE_NONE) then

    elseif (state == CHAMP_LIST_CELL_STATE_SELECTED) then
        vars['selectSprite']:setVisible(true)

    elseif (state == CHAMP_LIST_CELL_STATE_DISABLE) then
        vars['disableSprite']:setVisible(true)
    end

    self.m_state = state
end

-------------------------------------
-- function getCharAnimator
-------------------------------------
function UI_Ready_DragonListItem:getCharAnimator()
    local evolution = self.m_dragonData['evolution']

    if (not self.m_charAnimator) then
        local evolution = self.m_dragonData['evolution']
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[self.m_dataDragonID]
		local attr = t_dragon['attr']

        self.m_charAnimator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, attr)
        self.m_charAnimator.m_node:retain()
        self.m_charAnimator:setScale(0.6)
    elseif (evolution ~= self.m_charAnimatorEvolution) then
        self.m_charAnimator.m_node:release()
        self.m_charAnimator:release()

        local evolution = self.m_dragonData['evolution']
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[self.m_dataDragonID]
		local attr = t_dragon['attr']

        self.m_charAnimator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], evolution, attr)
        self.m_charAnimator.m_node:retain()
        self.m_charAnimator:setScale(0.6)
    end

    self.m_charAnimatorEvolution = evolution

    return self.m_charAnimator
end

-------------------------------------
-- function getCharAnimatorWithAttrSynastry
-------------------------------------
function UI_Ready_DragonListItem:getCharAnimatorWithAttrSynastry()
    local animator = self:getCharAnimator()

    -- 속성 상성 유불리 아이콘 출력
    if (not self.m_charAnimatorAttrSynastry) then
        local dragon_id = self.m_dragonData['did']
        local dragon_attr = g_dragonListData:getTableData(dragon_id, 'attr')
        local stage_attr = self.m_stageAttribute
        local attr_synastry = getCounterAttribute(dragon_attr, stage_attr)

        local animation_name = nil

        if (not attr_synastry) or (attr_synastry == 0) then
            
        elseif (attr_synastry == 1) then
            animation_name = 'up'
        elseif (attr_synastry == -1) then
            animation_name = 'down'
        end

        local node = nil
        if animation_name then
            local animator = MakeAnimator('res/ui/a2d/attr_synastry_arrow/attr_synastry_arrow.vrp')
            animator:changeAni(animation_name, true)
            node = animator.m_node
            node:setDockPoint(cc.p(0.5, 0.5))
            node:setAnchorPoint(cc.p(0.5, 0.5))
            node:setScale(1.5)
        else
            node = cc.Node:create()
        end
        animator.m_node:addChild(node)
        node:setPosition(100, -40)
        
        self.m_charAnimatorAttrSynastry = node
    end

    return animator
end

-------------------------------------
-- function refreshDragonInfo
-------------------------------------
function UI_Ready_DragonListItem:refreshDragonInfo()
    if (not self.m_dragonData) then
        return
    end

    local vars = self.vars
    local dragon_id = tonumber(self.m_dragonData['did'])

    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = g_dragonListData:getDragon(dragon_id)

    -- 테이블에 있는 드래곤의 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    do -- 역할 아이콘
        local res = 'res/ui/dragon_card/list_role_' .. t_dragon['role'] .. '.png'
        local sprite = cc.Sprite:create(res)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['roleNode']:removeAllChildren()
        vars['roleNode']:addChild(sprite)
    end

    do -- 배경 프레임
        local res = 'res/ui/dragon_card/list_frame_bg_' .. t_dragon['rarity'] .. '.png'
        local sprite = cc.Sprite:create(res)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['rarityNode']:removeAllChildren()
        vars['rarityNode']:addChild(sprite)
    end

    do -- 레어도 프레임
        local res = 'res/ui/dragon_card/list_frame_' .. t_dragon['rarity'] .. '.png'
        local sprite = cc.Sprite:create(res)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['frameNode']:removeAllChildren()
        vars['frameNode']:addChild(sprite)
    end    

    do -- 드래곤 아이콘
        local evolution = t_dragon_data['evolution']
		local attr = t_dragon['attr']
        local sprite = IconHelper:getHeroIcon(t_dragon['icon'], evolution, attr)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['iconsNode']:removeAllChildren()
        vars['iconsNode']:addChild(sprite)
    end

    do -- 레벨 표시
        vars['levelLabel']:setString(Str('{1}', t_dragon_data['lv']))
    end

    do -- 등급 별
        local grade_res = 'res/ui/star020' .. t_dragon_data['grade'] .. '.png'
        local sprite = cc.Sprite:create(grade_res)
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        sprite:setDockPoint(cc.p(0.5, 0.5))
        vars['starNode']:removeAllChildren()
        vars['starNode']:addChild(sprite)
    end

    do -- 물공/마공 아이콘
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[dragon_id]
        local char_type = t_dragon['char_type']
        local res = 'res/ui/dragon_card/list_attack_' .. char_type .. '.png'
        local icon = cc.Sprite:create(res)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['attackNode']:removeAllChildren()
            vars['attackNode']:addChild(icon)
        end
    end

    do -- 속성 아이콘
        local table_dragon = TABLE:get('dragon')
        local t_dragon = table_dragon[dragon_id]
        local attr_str = t_dragon['attr']
        local res = 'res/ui/dragon_card/dc_attr_' .. attr_str .. '.png'
        local icon = cc.Sprite:create(res)
        if icon then
            icon:setDockPoint(cc.p(0.5, 0.5))
            icon:setAnchorPoint(cc.p(0.5, 0.5))
            vars['attrNode']:removeAllChildren()
            vars['attrNode']:addChild(icon)
        end
    end

    do -- 카드 보유 갯수
        local rarity = dragonRarityStrToNum(t_dragon['rarity'])
        local table_upgrade = TABLE:get('upgrade')
        local t_upgrade = table_upgrade[rarity]

        local key = 'cost_card_0' .. t_dragon_data['grade']
        local max_count = t_upgrade[key]
        local count = t_dragon_data['cnt']

        if (max_count == 0) then
            vars['cardGg']:setPercentage(100)
            vars['cardLabel']:setString(Str('{1}/{2}', count, 'MAX'))
        else
            local percentage = math_floor((count / max_count) * 100)
            vars['cardGg']:setPercentage(percentage)
            vars['cardLabel']:setString(Str('{1}/{2}', count, max_count))
        end
    end

end
