local PARENT = UI_RewardListPopup

-------------------------------------
-- class UI_ChapterAchieveRewardPopup
-------------------------------------
UI_ChapterAchieveRewardPopup = class(PARENT, {
        m_chapterID = 'number',
        m_numOfStars = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChapterAchieveRewardPopup:init(chapter_id, star)
    self.m_chapterID = chapter_id
    self.m_numOfStars = star

    self:setRewardItemCardList_byItemPackageStr('701112;5, 701111;10, 701230;10, 700002;15')

    local chapter_achieve_info = g_adventureData:getChapterAchieveInfo(chapter_id)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChapterAchieveRewardPopup')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChapterAchieveRewardPopup:initUI()
    local vars = self.vars
    vars['titleLabel']:setString(Str('챕터 달성 보상'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChapterAchieveRewardPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChapterAchieveRewardPopup:refresh()
    local vars = self.vars

    local chapter_achieve_info = g_adventureData:getChapterAchieveInfo(self.m_chapterID)
    local state = chapter_achieve_info:getRewardBoxState(self.m_numOfStars)

    -- 별 갯수를 달성하지 못한 경우
    if (state == 'lock') then
        vars['descLabel']:setString(Str('{1}개의 별 달성 시 수령 가능', self.m_numOfStars))
        vars['receiveLabel']:setString(Str('닫기'))
        vars['okBtn']:registerScriptTapHandler(function() self:close() end)

    -- 별 갯수를 달성하였지만 보상을 받지 않은 경우
    elseif (state == 'open') then
        vars['descLabel']:setString(Str('보상 수령 가능'))
        vars['receiveLabel']:setString(Str('수령'))
        vars['okBtn']:registerScriptTapHandler(function() self:click_receiveBtn() end)

    -- 보상까지 받은 경우
    elseif (state == 'received') then
        vars['descLabel']:setString(Str('보상 수령 완료'))
        vars['receiveLabel']:setString(Str('닫기'))
        vars['okBtn']:registerScriptTapHandler(function() self:close() end)

    end
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_ChapterAchieveRewardPopup:click_receiveBtn()
    local function finish_cb(ret)
        self:close()
        MakeSimplePopup(POPUP_TYPE.OK, Str('보상을 수령하였습니다.'))
    end

    local function fail_cb(ret)

    end

    g_adventureData:request_chapterAchieveReward(self.m_chapterID, self.m_numOfStars, finish_cb, fail_cb)
end