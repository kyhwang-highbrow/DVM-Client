local PARENT = UI_IndivisualTab

-------------------------------------
-- class UI_RuneForgeInfoTab
-------------------------------------
UI_RuneForgeInfoTab = class(PARENT,{
        m_talkList = 'list',
        m_talkIdx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RuneForgeInfoTab:init(owner_ui)
    local vars = self:load('rune_forge_info.ui')
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_RuneForgeInfoTab:onEnterTab(first)
    self.m_ownerUI:hideNpc() -- NPC 등장

    if (first == true) then
        self:initUI()

        require('TableTalkDeet')
        self.m_talkList = TableTalkDeet:getDeetRandomTalkList()
        self.m_talkIdx = 0
    end

    self:nextNpcTalk()

    self:refresh()
end

-------------------------------------
-- function onExitTab
-------------------------------------
function UI_RuneForgeInfoTab:onExitTab()
    local vars = self.vars
    vars['talkLabel']:stopAllActions()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RuneForgeInfoTab:initUI()
    local vars = self.vars

    do -- NPC
        local res = 'res/character/npc/deet/deet.spine'
        local animator = MakeAnimator(res)
        animator:setDockPoint(0.5, 0.5)
        animator:setAnchorPoint(0.5, 0.5)
        animator:changeAni('idle', true)
        self.vars['npcNode']:removeAllChildren()
        self.vars['npcNode']:addChild(animator.m_node)
    end

    -- NPC 버튼
    self.vars['npcButton']:registerScriptTapHandler(function() self:click_npcButton() end)
    self.vars['npcButton']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

    -- 말풍선 버튼
    self.vars['talkButton']:registerScriptTapHandler(function() self:click_npcButton() end)
    self.vars['talkButton']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    
    vars['infoBtn']:registerScriptTapHandler(function() UI_HelpRune() end) -- 룬 도움말
    vars['grindstonePackageBtn']:registerScriptTapHandler(function() self:click_grindstonePackageBtn() end) -- 룬 축복서
    vars['runBlessBuyBtn']:registerScriptTapHandler(function() self:click_runBlessBuyBtn() end) -- 룬 연마석
end

-------------------------------------
-- function nextNpcTalk
-------------------------------------
function UI_RuneForgeInfoTab:nextNpcTalk()
    self.m_talkIdx = (self.m_talkIdx + 1)
    if (self.m_talkIdx == #self.m_talkList) then
        self.m_talkIdx = 1
    end

    local talk = self.m_talkList[self.m_talkIdx] or ''
    self:setNpcTalk(Str(talk))

    -- 자동 넘김
    local vars = self.vars
    vars['talkLabel']:stopAllActions()
    local function func()
        SoundMgr:playEffect('UI', 'ui_touch') -- 자동 넘김일 때 사운드 재생
        self:nextNpcTalk()
    end
    cca.reserveFunc(vars['talkLabel'], 4, func)
end

-------------------------------------
-- function click_npcButton
-------------------------------------
function UI_RuneForgeInfoTab:click_npcButton()
    self:nextNpcTalk()
end

-------------------------------------
-- function setNpcTalk
-------------------------------------
function UI_RuneForgeInfoTab:setNpcTalk(msg)
    local vars = self.vars
    vars['talkLabel']:setString(msg)
        
    -- 라벨 늘어난 세로 길이에 따라 말풍선 세로 길이 조절
    local sprite_height = self:getTalkSpriteHeightByLabel(self.vars['talkLabel'])
    local sprite_width = self.vars['talkSprite']:getNormalSize()
    vars['talkSprite']:setNormalSize(math_max(500, sprite_width), sprite_height) -- 500은 최소 넓이를 보장하기 위함
end

-------------------------------------
-- function getTalkSpriteHeightByLabel
-- @brief (말풍선 세로 길이 계산을 위해)라벨 세로 길이 계산
-------------------------------------
function UI_RuneForgeInfoTab:getTalkSpriteHeightByLabel(label)
    local ori_height = 122
    if (not label) then
        return ori_height
    end
    
    local sprite_height = label:getStringHeight() * 1.5
    -- 원래 스프라이트 세로 길이보다 짧아지지 않도록
    sprite_height = math.max(ori_height, sprite_height)
    return sprite_height
end


-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_RuneForgeInfoTab:refresh()
    local vars = self.vars

    do -- 룬 강화 축복서
        vars['runeBlessNode']:removeAllChildren()
        local item_id = ITEM_ID_RUNE_BLESS
        local item_cnt = g_userData:get('rune_bless')
        local card = UI_ItemCard(item_id, item_cnt)
        vars['runeBlessNode']:addChild(card.root)

        -- 룬 축복서 product ID : 220017
        local product_struct = g_shopDataNew:getProduct('amethyst', 220017)
        
        -- 구매제한 설명 문구 
        local buy_count_desc = product_struct:getMaxBuyTermStr()
        vars['runeBlessBuyLabel']:setString(buy_count_desc)

        if (product_struct:checkMaxBuyCount() == true) then
            vars['runeBlessBuyLabel']:setColor(COLOR['green'])
        else
            vars['runeBlessBuyLabel']:setColor(COLOR['red'])
        end
    end
    
    do -- 룬 연마석
        vars['grindstoneNode']:removeAllChildren()
        local item_id = ITEM_ID_GRINDSTONE
        local item_cnt = g_userData:get('grindstone')
        local card = UI_ItemCard(item_id, item_cnt)
        vars['grindstoneNode']:addChild(card.root)

        -- 룬 연마석 product ID : 210022
        local product_struct = g_shopDataNew:getProduct('st', 210022)
        
        -- 구매제한 설명 문구 
        local buy_count_desc = product_struct:getMaxBuyTermStr()
        vars['grindstoneBuyLabel']:setString(buy_count_desc)

        
        if (product_struct:checkMaxBuyCount() == true) then
            vars['grindstoneBuyLabel']:setColor(COLOR['green'])
        else
            vars['grindstoneBuyLabel']:setColor(COLOR['red'])
        end
    end
end

-------------------------------------
-- function click_grindstonePackageBtn
-- @brief 룬 연마석 패키지
-------------------------------------
function UI_RuneForgeInfoTab:click_grindstonePackageBtn()
    local vars = self.vars
    
    -- 룬 연마석 product ID : 210022
    local product_struct = g_shopDataNew:getProduct('st', 210022)
    if (product_struct:isBuyable() == true) then
        product_struct:buy(function(ret)
            ItemObtainResult_Shop(ret) 
            self:refresh()
        end)
    end
end

-------------------------------------
-- function click_runBlessBuyBtn
-- @brief 룬 축복서 구매
-------------------------------------
function UI_RuneForgeInfoTab:click_runBlessBuyBtn()
    local vars = self.vars
    
    -- 룬 축복서 product ID : 220017
    local product_struct = g_shopDataNew:getProduct('amethyst', 220017)

    if (product_struct:isBuyable() == true) then
        product_struct:buy(function(ret)
            ItemObtainResult_Shop(ret) 
            self:refresh()
        end)
    end
end