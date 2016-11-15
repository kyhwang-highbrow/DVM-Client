-------------------------------------
-- class UI_AdventureChapterButton
-------------------------------------
UI_AdventureChapterButton = class(UI, {
        m_chapter = 'number',
        m_cbDifficultyBtn = 'function',
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
    self.m_chapter = chapter

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

    do
        local open_difficulty = 0
        for i=1, MAX_ADVENTURE_DIFFICULTY do
            if g_adventureData:isOpenChapter(i, chapter) then
                open_difficulty = i
            end
        end

        local res = string.format('res/ui/frame/chapter_difficulty_open_%.2d.png', open_difficulty)
        local sprite = cc.Sprite:create(res)
        sprite:setDockPoint(cc.p(0.5, 0.5))
        sprite:setAnchorPoint(cc.p(0.5, 0.5))
        vars['difficultyNode']:addChild(sprite)

        vars['easyBtn']:setVisible(1 <= open_difficulty)
        vars['normalBtn']:setVisible(2 <= open_difficulty)
        vars['hardBtn']:setVisible(3 <= open_difficulty)
    end
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
    vars['easyBtn']:registerScriptTapHandler(function() self:click_difficultyBtn(1) end)
    vars['normalBtn']:registerScriptTapHandler(function() self:click_difficultyBtn(2) end)
    vars['hardBtn']:registerScriptTapHandler(function() self:click_difficultyBtn(3) end)
end

-------------------------------------
-- function click_difficultyBtn
-------------------------------------
function UI_AdventureChapterButton:click_difficultyBtn(difficulty)
    if (self.m_cbDifficultyBtn) then
        local chapter = self.m_chapter
        self.m_cbDifficultyBtn(chapter, difficulty)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_AdventureChapterButton:refresh()
end

--@CHECK
UI:checkCompileError(UI_AdventureChapterButton)
