local PARENT = class(UI, IRankListItem:getCloneTable())

-------------------------------------
-- class UI_ArenaNewHistoryListItem
-------------------------------------
UI_ArenaNewHistoryListItem = class(PARENT, {
        m_rivalInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ArenaNewHistoryListItem:init(t_rival_info)
    self.m_rivalInfo = t_rival_info
    local vars = self:load('arena_new_popup_defense_item.ui')
    self.root:setSwallowTouch(true)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ArenaNewHistoryListItem:initUI()
    local vars = self.vars
    
    local t_rival_info = self.m_rivalInfo

    -- 승패 이미지
    local isWin = t_rival_info.m_matchResult == 1

    vars['winSprite']:setVisible(isWin)
    vars['loseSprite']:setVisible(not isWin)

    vars['userScoreLabel']:setString(comma_value(t_rival_info.m_rp))

    local matchScore = t_rival_info.m_matchScore == 0 and '-' or t_rival_info.m_matchScore

    vars['scoreLabel']:setString(tostring(matchScore))

    local passedTime = socket.gettime() - (t_rival_info.m_matchTime / 1000)
    local passedTimeText = Str('{1} 전', ServerTime:getInstance():makeTimeDescToSec(passedTime, true, true))

    vars['timeLabel']:setString(Str('{1}', passedTimeText))

    --vars['powerLabel']:setString(self.m_rivalInfo:getDeckCombatPower(true))

    -- 드래곤 리스트
    local t_deck_dragon_list = t_rival_info.m_dragonsObject
    local dragonMaxCount = 5
    local dragonSlotIndex = 1

    for i,v in pairs(t_deck_dragon_list) do
        local icon = UI_DragonCard(v)
        icon.root:setSwallowTouch(false)
        vars['dragonNode' .. dragonSlotIndex]:addChild(icon.root)

        dragonSlotIndex =  dragonSlotIndex + 1
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ArenaNewHistoryListItem:initButton()
    local vars = self.vars 
    --vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)    

    vars['reportBtn']:registerScriptTapHandler(function() self:click_reportBtn() end)    
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ArenaNewHistoryListItem:refresh()
end

-------------------------------------
-- function click_reportBtn
-------------------------------------
function UI_ArenaNewHistoryListItem:click_reportBtn()
    local vars = self.vars
    local t_rival_info = self.m_rivalInfo
    local uid = t_rival_info:getUid()

    --cclog('uid', uid)
    local enc_uid = HEX(AES_Encrypt(HEX2BIN(CONSTANT['AES_KEY']), uid))
    --cclog('enc uid', enc_uid)
    --local dec_uid = AES_Decrypt(HEX2BIN(CONSTANT['AES_KEY']), HEX2BIN(enc_uid))
    --cclog('dec uid', dec_uid)

    local hoid = 'code_' .. enc_uid
    if hoid == nil then
        return
    end

    SDKManager:copyOntoClipBoard(hoid)
    UIManager:toastNotificationRed(Str('신고를 위해 전투코드를 복사하였습니다.'))

    local ok_cb = function()
        SDKManager:goToWeb(GetCustomerCenterUrl())
    end
    
    local msg = Str('상대 유저를 신고하시겠습니까?')
    local sub_msg = Str('상세 설명과 함께 복사된 전투코드를 첨부 후\n[고객센터 > 전투 신고] 를 통해 문의 해주세요.')
    MakeSimplePopup2(POPUP_TYPE.YES_NO, msg, sub_msg, ok_cb)

end