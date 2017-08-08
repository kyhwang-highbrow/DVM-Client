-------------------------------------
-- table QuickLinkHelper
-------------------------------------
QuickLinkHelper = {}

local T_LINK_FUNC

-------------------------------------
-- function quickLink
-------------------------------------
function QuickLinkHelper.quickLink(link_type, condition)
    local link_func = T_LINK_FUNC[link_type]
    if (link_func) then
        link_func(condition)
    else
        return false
    end
end

-------------------------------------
-- function possibleLink
-------------------------------------
function QuickLinkHelper.possibleLink(link_type)
    if (T_LINK_FUNC[link_type]) then
        return true
    else
        return false
    end
end

-------------------------------------
-- function gameModeLink
-------------------------------------
function QuickLinkHelper.gameModeLink(game_mode, dungeon_mode, condition)
    local link_type

    if (game_mode == GAME_MODE_NEST_DUNGEON) then
        -- 공통 진화 던전 플레이
        if (dungeon_mode == NEST_DUNGEON_EVO_STONE) then
            link_type = 'ply_ev'

        -- 거목 던전 플레이
        elseif (dungeon_mode == NEST_DUNGEON_TREE) then
            link_type = 'ply_tree'

        -- 악몽 던전 플레이
        elseif (dungeon_mode == NEST_DUNGEON_NIGHTMARE) then
            link_type = 'ply_nm'

        end

    -- 고대의 탑 플레이
    elseif (game_mode == GAME_MODE_ANCIENT_TOWER) then
        link_type = 'ply_tower'

    -- 콜로세움 플레이
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        link_type = 'ply_clsm'

    -- 인연던전 플레이
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        link_type = 'ply_rel'

    -- 모험 모드
    else
        link_type = 'ply_adv'

    end

    -- 바로 가기를 활용한다.
    QuickLinkHelper.quickLink(link_type, condition)
end


T_LINK_FUNC = {
    -- stage clear
    ['clr_stg'] = function(condition)
        local stage_id = condition
        UINavigator:goTo('adventure', stage_id)
    end,

    -- 모험 플레이
    ['ply_adv'] = function()
        UINavigator:goTo('adventure')
    end,

    -- 고대의 탑 플레이
    ['ply_tower'] = function()
        UINavigator:goTo('ancient')
    end,
    
    -- 고대의 탑 클리어
    ['clr_tower'] = function()
        UINavigator:goTo('ancient')
    end,

    -- 콜로세움 플레이
    ['ply_clsm'] = function()
        UINavigator:goTo('colosseum')
    end,

    -- 콜로세움 {1} 연승
    ['cwin_clsm'] = function()
        UINavigator:goTo('colosseum')
    end,

    -- 공통 진화 던전 플레이
    ['ply_ev'] = function(condition)
        local stage_id = condition
        UINavigator:goTo('nest_evo_stone', stage_id)
    end,

    -- 거목 던전 플레이
    ['ply_tree'] = function(condition)
        local stage_id = condition
        UINavigator:goTo('nest_tree', stage_id)
    end,

    -- 악몽 던전 플레이
    ['ply_nm'] = function(condition)
        local stage_id = condition
        UINavigator:goTo('nest_nightmare', stage_id)
    end,
    
    -- 악몽던전 클리어
    ['clr_nm'] = function(condition)
        local stage_id = condition
        UINavigator:goTo('nest_nightmare', stage_id)
    end,

    -- 탐험 플레이
    ['ply_epl'] = function()
        UINavigator:goTo('exploration')
    end,
    
    -- 인연 던전 플레이
    ['ply_rel'] = function()
        g_secretDungeonData:goToSecretDungeonScene(nil, true)
    end,

    -- 인연 던전 발견
    ['fnd_rel'] = function()
        g_secretDungeonData:goToSecretDungeonScene()
    end,



    -- 유저 레벨 달성
    ['u_lv'] = function()
        UINavigator:goTo('adventure')
    end,

    -- 친구 n명 달성
    ['make_frd'] = function()
        UI_FriendPopup()
    end,
    -- 우정포인트 주고 받기
    ['send_fp'] = function()
        UI_FriendPopup()
    end,
    ['get_fp'] = function()
        UI_FriendPopup()
    end,

    -- 테이머 겟
    ['t_get'] = function()
        UI_TamerManagePopup()
    end,
    -- 테이머 스킬 레벨 업
    ['t_sklvup'] = function()
        UI_TamerManagePopup()
    end,
    



    -- 룬 장착
    ['r_eq'] = function()
        UI_DragonManageInfo.goToDragonManage('rune')
    end,    

    -- 룬 강화
    ['r_enc'] = function()
        UI_DragonManageInfo.goToDragonManage('rune')
    end,
    -- 룬 강화 성공/실패
    ['r_enc_scs'] = function()
        UI_DragonManageInfo.goToDragonManage('rune')
    end,
    ['r_enc_fail'] = function()
        UI_DragonManageInfo.goToDragonManage('rune')
    end,




    -- 드래곤 스킬 레벨 업
    ['d_sklvup'] = function()
        UI_DragonManageInfo.goToDragonManage('skill_enc')
    end,
    -- X 등급 드래곤 스킬레벨업
    ['d_sklvup_r'] = function()
        UI_DragonManageInfo.goToDragonManage('skill_enc')
    end,
    ['d_sklvup_h'] = function()
        UI_DragonManageInfo.goToDragonManage('skill_enc')
    end,
    ['d_sklvup_l'] = function()
        UI_DragonManageInfo.goToDragonManage('skill_enc')
    end,

    -- 드래곤 진화
    ['d_evup'] = function()
        UI_DragonManageInfo.goToDragonManage('evolution')
    end,
    -- 진화로 X 드래곤 n종 획득
    ['d_evol_2'] = function()
        UI_DragonManageInfo.goToDragonManage('evolution')
    end,
    ['d_evol_3'] = function()
        UI_DragonManageInfo.goToDragonManage('evolution')
    end,

    -- 드래곤 레벨업
    ['d_lvup'] = function()
        UI_DragonManageInfo.goToDragonManage('level_up')
    end,
    -- 레벨업 재료 사용
    ['d_use_mtrl'] = function()
        UI_DragonManageInfo.goToDragonManage('level_up')
    end,

    -- 드래곤 등급업
    ['d_grup'] = function()
        UI_DragonManageInfo.goToDragonManage('grade')
    end,
    -- 승급으로 드래곤 n종 획득
    ['d_grup_4'] = function()
        UI_DragonManageInfo.goToDragonManage('grade')
    end,
    ['d_grup_5'] = function()
        UI_DragonManageInfo.goToDragonManage('grade')
    end,
    ['d_grup_6'] = function()
        UI_DragonManageInfo.goToDragonManage('grade')
    end,

    -- 친밀도 과일 먹임
    ['fruit'] = function()
        UI_DragonManageInfo.goToDragonManage('friendship')
    end,
    ['feed'] = function()
        UI_DragonManageInfo.goToDragonManage('friendship')
    end,
    -- 친밀도 일심동체 만들기
    ['d_flv_9'] = function()
        UI_DragonManageInfo.goToDragonManage('friendship')
    end,

    -- 작별
    ['goodbye'] = function()
        UI_DragonManageInfo.goToDragonManage()
    end,



    
    -- 알 부화
    ['egg'] = function()
        g_hatcheryData:openHatcheryUI(nil, 'incubate')
    end,
    -- 드래곤 n종 획득
    ['did_u'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    -- X 속성 드래곤 n종 획득
    ['attr_u_e'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    ['attr_u_w'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    ['attr_u_f'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    ['attr_u_l'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    ['attr_u_d'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    -- X 소환 하기
    ['smn'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    ['smn_fp'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    ['smn_rel'] = function()
        g_hatcheryData:openHatcheryUI(nil)
    end,
    -- 조합 하기
    ['comb'] = function()
        g_hatcheryData:openHatcheryUI(nil, 'combination')
    end,
    ['comb_120101'] = function()
        g_hatcheryData:openHatcheryUI(nil, 'combination')
    end,
    ['comb_120345'] = function()
        g_hatcheryData:openHatcheryUI(nil, 'combination')
    end,
    ['comb_120404'] = function()
        g_hatcheryData:openHatcheryUI(nil, 'combination')
    end,

    -- 바로가기 키를 띄우지 않을 것들
}