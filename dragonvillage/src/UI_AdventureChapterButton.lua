-------------------------------------
-- class UI_AdventureChapterButton
-------------------------------------
UI_AdventureChapterButton = class(UI, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureChapterButton:init(item)
    local vars = self:load('chapter_select_btn.ui')

    self:initUI()
    self:initButton()
    self:refresh()

    local chapter = item

    local is_open = g_adventureData:isOpenGlobalChapter(chapter)
    vars['lockSprite']:setVisible(not is_open)

    if is_open then
        local res = Str('res/ui/btn/chapter_btn_0{1}.png', chapter)
        local icon = cc.Sprite:create(res)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['btnNode']:addChild(icon)
    else
        local res = Str('res/ui/btn/chapter_btn_0{1}_lock.png', chapter)
        local icon = cc.Sprite:create(res)
        icon:setDockPoint(cc.p(0.5, 0.5))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        vars['lockNode']:addChild(icon)
    end

    vars['chapterLabel']:setString(Str('{1}. ', chapter) .. chapterName(chapter))
    vars['bossNameLabel']:setString(bossChapterName(chapter))
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_AdventureChapterButton:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_AdventureChapterButton:initButton()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureChapterButton:refresh()
end

--@CHECK
UI:checkCompileError(UI_AdventureChapterButton)
