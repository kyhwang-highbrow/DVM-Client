local PARENT = UI

-------------------------------------
-- class UI_CollectionRelationPointDraw
-------------------------------------
UI_CollectionRelationPointDraw = class(PARENT,{
        m_did = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_CollectionRelationPointDraw:init(did)
    self.m_did = did

    local vars = self:load('collection_point_summon.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_CollectionRelationPointDraw')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(did)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_CollectionRelationPointDraw:initUI()
    local vars = self.vars
    local did = self.m_did

    -- 드래곤 카드
    local card = MakeSimpleDragonCard(did)
    vars['dragonCardNode']:addChild(card.root)
    
    -- 드래곤 이름
    local name = TableDragon():getValue(did, 't_name')
    vars['nameLabel']:setString(Str(name))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_CollectionRelationPointDraw:initButton()
    local vars = self.vars
    vars['drawBtn']:registerScriptTapHandler(function() self:click_drawBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_CollectionRelationPointDraw:refresh()
end

-------------------------------------
-- function click_drawBtn
-------------------------------------
function UI_CollectionRelationPointDraw:click_drawBtn()
    local did = self.m_did

    local function finish_cb(ret)
        self:close()
        local dragon_name = TableDragon():getValue(did, 't_name')
        local msg = Str('{1}을(를) 소환하였습니다.', Str(dragon_name))
        MakeSimplePopup(POPUP_TYPE.OK, msg)
    end

    g_collectionData:request_useRelationPoint(did, finish_cb)
end

--@CHECK
UI:checkCompileError(UI_CollectionRelationPointDraw)
