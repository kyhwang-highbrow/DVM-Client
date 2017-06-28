local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ColosseumAttackListItem
-------------------------------------
UI_ColosseumAttackListItem = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ColosseumAttackListItem:init(struct_user_info_colosseum)
    local vars = self:load('colosseum_scene_atk_item.ui')

    local info = struct_user_info_colosseum

    -- 대표 드래곤 아이콘
    local icon = info:getLeaderDragonCard()
    if icon then
        vars['profileNode']:addChild(icon.root)
    end

    -- 유저 정보
    local str = Str('레벨{1} {2}', info.m_lv, info.m_nickname)
    vars['userLabel']:setString(str)

    -- 전투력 표시
    vars['powerLabel']:setString(Str('전튜력 : {1}', 0))

    -- 점수 표시
    vars['scoreLabel']:setString(Str('{1}점', info.m_rp))
end