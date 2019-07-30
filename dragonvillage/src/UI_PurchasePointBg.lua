local MAX_TYPE_CNT = 5


local PARENT = UI

-------------------------------------
-- class UI_PurchasePointBg
-------------------------------------
UI_PurchasePointBg = class(PARENT,{
        m_item_id = 'number',
        m_version = 'number',
        m_count = 'number',
        m_type = 'string', -- dragon_ticket, dragon, skill_slime, item, reinforce
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointBg:init(bg_type, item_id, item_count, version)
    
    local url = self:getUrl(bg_type)
    self:load(url)
    self.m_item_id = item_id
    self.m_version = version
    self.m_count = item_count
    self.m_type = bg_type

    self:doActionReset()
    self:doAction(nil, false)

    -- 타입에 맞추어 UI 세팅
    if (bg_type == 'dragon') then
        self:initDragon()
    elseif (bg_type == 'dragon_ticket') then
        self:initDragonTicket()
    else
        self:initItem()
    end

    self:setLimit()
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function getUrl
-------------------------------------
function UI_PurchasePointBg:getUrl(bg_type)
    local url = 'event_purchase_point_item_reward_03.ui'
    if (bg_type == 'dragon') then
        url = 'event_purchase_point_item_reward_02.ui'
    elseif (bg_type == 'dragon_ticket') then
        url = 'event_purchase_point_item_reward_01.ui'
    else
        url = 'event_purchase_point_item_reward_03.ui'
    end

    return url
end

function UI_PurchasePointBg:initDragonTicket()
    if (not self.m_item_id) then
        return
    end

    self:initUI_dragonTicket()
    self:initButton_dragonTicket()
end

function UI_PurchasePointBg:initDragon()
    if (not self.m_item_id) then
        return
    end

    self:initUI_dragon()
    self:initButton_dragon()
end

function UI_PurchasePointBg:initItem()
    if (not self.m_item_id) then
        return
    end
    
    self:initUI_Item()
end






-------------------------------------
-- function initUI_dragonTicket
-- @breif 누적결제 최종 상품이 [드래곤 뽑기권]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:initUI_dragonTicket()
    local vars = self.vars
    local item_id = self.m_item_id

    local ui_card = UI_ItemCard(item_id, 0)
    ui_card.root:setScale(0.66)
    vars['itemNode']:addChild(ui_card.root)

    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel']:setString(item_name)
    
    -- 드래곤 뽑기권에서 나올 드래곤들 출력
    local dragon_list_str = TablePickDragon:getCustomList(item_id)
    local dragon_list = plSplit(dragon_list_str, ',')

    for i, dragon_id in ipairs(dragon_list) do
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(tonumber(dragon_id), 3)
        dragon_animator:setTalkEnable(false)
        
        -- 2,3 번째 드래곤은 바라보는 방향이 다름        
        if (i >= 2) then
            dragon_animator.m_animator:setFlip(true)
        end

        if (vars['dragonNode'.. i]) then
            vars['dragonNode'.. i]:addChild(dragon_animator.m_node)
        end
    end

    local res = 'res/bg/ui/dragon_evolution_result/dragon_evolution_result.vrp'
    animator = MakeAnimator(res)    
    vars['bgNode']:addChild(animator.m_node)

end

-------------------------------------
-- function initButton_dragonTicket
-------------------------------------
function UI_PurchasePointBg:initButton_dragonTicket()
   local vars = self.vars
   local item_id = self.m_item_id
   
   vars['dragonInfoBtn']:registerScriptTapHandler(function() UI_SummonDrawInfo(item_id, false) end)
end





-------------------------------------
-- function initUI_dragon
-- @breif 누적결제 최종 상품이 [드래곤]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:initUI_dragon()
    local vars = self.vars
    local item_id = self.m_item_id
    local did = TableItem:getDidByItemId(item_id)
    local table_dragon = TableDragon()

    -- 이름
    local dragon_name = table_dragon:getDragonName(did)
    vars['dragonNameLabel']:setString(Str(dragon_name))
    
    -- 속성 ex) dark
    local dragon_attr = table_dragon:getDragonAttr(did)
    local attr_icon = IconHelper:getAttributeIconButton(dragon_attr)
    vars['attrNode']:addChild(attr_icon)
    vars['attrLabel']:setString(dragonAttributeName(dragon_attr))

    -- 역할 ex) healer
    local role_type = table_dragon:getDragonRole(did)
    local role_icon = IconHelper:getRoleIconButton(role_type)
    vars['typeNode']:addChild(role_icon)
    vars['typeLabel']:setString(dragonRoleTypeName(role_type))

    -- 희귀도 ex) legend
    local rarity_icon = IconHelper:getRarityIconButton('legend')
    vars['rarityNode']:addChild(rarity_icon)
    vars['rarityLabel']:setString(dragonRarityName('legend'))

    -- 진화도 by 별
    local res = string.format('res/ui/icons/star/star_%s_%02d%02d.png', 'yellow', 2, 5)
    local sprite = IconHelper:getIcon(res)
	vars['starNode']:addChild(sprite)

    local dragon_animator = UIC_DragonAnimator()
    dragon_animator:setDragonAnimator(did, 3)
    dragon_animator:setTalkEnable(false)
    vars['dragonNode4']:addChild(dragon_animator.m_node)

    
    -- 최종 상품이 드래곤일 경우 visual  세팅
    local animator
    local did = TableItem:getDidByItemId(item_id)
    local dragon_attr = TableDragon:getDragonAttr(did)
    animator = ResHelper:getUIDragonBG(dragon_attr, 'idle')
    vars['bgNode']:addChild(animator.m_node)


    local category_str = table_dragon:getDragonCartegory(did)
    if (category_str == 'cardpack') then
        category_str = Str('토파즈 드래곤')
    elseif (category_str == 'cardpack') then
        category_str = Str('한정 드래곤')
    else
        category_str = Str('')
    end
    vars['dscLabel']:setString(category_str)
end

-------------------------------------
-- function initButton_dragon
-------------------------------------
function UI_PurchasePointBg:initButton_dragon()
   local vars = self.vars
   local item_id = self.m_item_id
   
   local did = TableItem:getDidByItemId(item_id)
   vars['infoBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
end






-------------------------------------
-- function initUI_reinforce
-- @breif 누적결제 최종 상품이 아이템일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:initUI_Item()
    local vars = self.vars
    local item_id = self.m_item_id
    local reward_type = self.m_type
    if (not self.m_count) then
        return
    end
    
    if (reward_type == 'reinforce') then -- 전설 강화 포인트
        self:setReinforce()
    elseif (reward_type == 'skill_slime') then -- 전설 스킬 슬라임
        self:setSkillSlime()
    elseif (reward_type == 'item') then -- 아이템 공용 @jhakim 190709 현재는 절대적인 전설의 알에서만 사용
        self:setItem()
    end

    self:setCommom()
end

-------------------------------------
-- function setCommom
-------------------------------------
function UI_PurchasePointBg:setCommom()
    local vars = self.vars
    local item_id = self.m_item_id
    local item_name = TableItem:getItemName(item_id)
    local item_count = self.m_count

    vars['itemLabel']:setString(string.format('%s X %d', item_name, item_count))

    vars['effect']:setIgnoreLowEndMode(true) -- 저사양 모드 무시
    
    -- 설명이 있을 경우 라벨 출력
    self:setDescLabel()
end

-------------------------------------
-- function setReinforce
-- @breif 누적결제 최종 상품이 [강화 포인트]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:setReinforce()
    local vars = self.vars
    
    -- 강화 포인트 이미지
    local reinforce_sprite = cc.Sprite:create('ui/icons/purchase_point/reinforce_point.png')
    if (not reinforce_sprite) then
        return
    end

    reinforce_sprite:setAnchorPoint(CENTER_POINT)
    reinforce_sprite:setDockPoint(CENTER_POINT)
    vars['itemNode']:addChild(reinforce_sprite)

    -- 별 비주얼 출력
    vars['starVisual']:setVisible(true)

    -- 배경 visual  세팅
    local animator = MakeAnimator('res/bg/map_jewel/map_jewel.vrp')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function initUI_skillSlime
-- @breif 누적결제 최종 상품이 [스킬 슬라임]일 경우 세팅
-------------------------------------
function UI_PurchasePointBg:setSkillSlime()
    local vars = self.vars
    local item_id = self.m_item_id
    
    -- 스킬 슬라임 스파인
    local animator = MakeAnimator('res/character/monster/skill_slime_03/skill_slime_03.json') -- json...
    vars['slimeNode']:addChild(animator.m_node)

    -- 별 비주얼 출력
    vars['starVisual']:setVisible(true)

    -- 배경 visual  세팅
    local animator = MakeAnimator('res/bg/map_jewel/map_jewel.vrp')
    vars['bgNode']:addChild(animator.m_node)
end

-------------------------------------
-- function initUI_Item
-- @breif 누적결제 최종 상품이 [아이템]일 경우 세팅 (ex) 신화의 알.. 등등 여기서 하드코딩
-------------------------------------
function UI_PurchasePointBg:setItem()
    local vars = self.vars
    local item_id = self.m_item_id
    local item_count = self.m_count

    -- 갯수 라벨 세팅
    local item_name = TableItem:getItemName(item_id)
    vars['itemLabel']:setString(string.format('%s X %d', item_name, item_count))

    -- 아이템 Visual 세팅
    local animator = self:getItemVisual(item_id)
    if (animator) then
        vars['eggNode']:addChild(animator.m_node)
    end

    -- 배경 visual 세팅
    local animator = MakeAnimator('res/bg/ui/dragon_bg_earth/dragon_bg_earth.vrp')
    vars['bgNode']:addChild(animator.m_node)
end





-------------------------------------
-- function getItemVisual
-- @breif ItemVisual 세팅
-------------------------------------
function UI_PurchasePointBg:getItemVisual(item_id)
    local animator
    local item_full_type = TableItem:getItemFullType(tonumber(item_id))

    -- 아이템이 알 종류일 경우 (파일 이름에 규칙이 있다고 가정)
    if (string.match(item_full_type, 'egg')) then
        animator = MakeAnimator(string.format('res/item/egg/%s/%s.vrp', item_full_type, item_full_type)) -- ex) res/item/egg/egg_super_myth/egg_super_myth.vrp
        if (animator) then
            animator:changeAni('egg_move', true)
        end
    else
        animator = nil
    end

    return animator
end

-------------------------------------
-- function setDescLabel
-- @breif 
-------------------------------------
function UI_PurchasePointBg:setDescLabel(item_count)
    local version = self.m_version
    local vars = self.vars

    -- 설명 값 and 설명라벨 있다면 설명 출력
    local last_reward_desc = g_purchasePointData:getLastRewardDesc(version)
    if (last_reward_desc ~= '') then
        if (vars['dcsLabel'] and vars['dscSprite']) then
            vars['dscSprite']:setVisible(true)
            vars['dcsLabel']:setVisible(true)
            vars['dcsLabel']:setString(last_reward_desc)
            return
        end
    else
        -- 설명이 없다면 어색하게 공간 떨어지지 않도록 위치 조정 (스킬 슬라임, 아이템 타입만)
        self.root:setPositionY(-42)
    end

    if (dscSprite) then
        vars['dscSprite']:setVisible(false)
        vars['dcsLabel']:setVisible(false)
    end
end

-------------------------------------
-- function setLimit
-------------------------------------
function UI_PurchasePointBg:setLimit()
    local vars = self.vars
    local is_limit
    local remain_time

    if (vars['limitNode']) then
        remain_time = g_purchasePointData:getPurchasePointEventRemainTime_milliSecond(self.m_version)
        local day = math.floor(remain_time / 86400000)
        if (day < 2) then
            is_limit = true
        else
            is_limit = false
        end
    end

    if (is_limit) then
        -- 한정 표시
        vars['limitNode']:setVisible(true)
        vars['limitMenu']:setVisible(true)
        vars['limitNode']:runAction(cca.buttonShakeAction(3, 1)) 
        
        local desc_time = datetime.makeTimeDesc_timer_filledByZero(remain_time, false) -- param : milliseconds, from_day
        
        -- 남은 시간 이미지 텍스트로 보여줌
        local remain_time_label = cc.Label:createWithBMFont('res/font/tower_score.fnt', desc_time)
        remain_time_label:setAnchorPoint(cc.p(0.5, 0.5))
        remain_time_label:setDockPoint(cc.p(0.5, 0.5))
        remain_time_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        remain_time_label:setAdditionalKerning(0)
        vars['remainLabel'] = remain_time_label
        vars['timeNode']:addChild(remain_time_label)
    else
        vars['limitMenu']:setVisible(false)
        vars['limitNode']:setVisible(false)    
    end
end

-------------------------------------
-- function update
-------------------------------------
function UI_PurchasePointBg:update(dt)
    local vars = self.vars
    if (not vars['remainLabel']) then
        return
    end
    local remain_time = g_purchasePointData:getPurchasePointEventRemainTime_milliSecond(self.m_version)
    local desc_time = datetime.makeTimeDesc_timer_filledByZero(remain_time, false) -- param : milliseconds, from_day

    vars['remainLabel']:setString(desc_time)
end

