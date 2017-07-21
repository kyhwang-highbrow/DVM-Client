-------------------------------------
-- table QuickLinkHelper
-------------------------------------
QuickLinkHelper = {}

local T_LINK_FUNC

-------------------------------------
-- function quickLink
-------------------------------------
function QuickLinkHelper.quickLink(clear_type, clear_cond)
    local link_func = T_LINK_FUNC[clear_type]
    if (link_func) then
        link_func(clear_cond)
    else
        return false
    end
end

-------------------------------------
-- function possibleLink
-------------------------------------
function QuickLinkHelper.possibleLink(clear_type)
    if (T_LINK_FUNC[clear_type]) then
        return true
    else
        return false
    end
end


T_LINK_FUNC = {
    -- stage clear
    ['clr_stg'] = function(clear_cond)
        local stage_id = clear_cond
        g_adventureData:goToAdventureScene(stage_id)
    end,

    -- 모험 플레이
    ['ply_adv'] = function()
        g_ancientTowerData:goToAdventureScene()
    end,

    -- 고대의 탑 플레이
    ['ply_tower'] = function()
        g_ancientTowerData:goToAncientTowerScene()
    end,

    -- 콜로세움 플레이
    ['ply_clsm'] = function()
        g_colosseumData:goToColosseum(true)
    end,

    -- 공통 진화 던전 플레이
    ['ply_ev'] = function()
        g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_EVO_STONE)
    end,

    -- 거목 던전 플레이
    ['ply_tree'] = function()
        g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_TREE)
    end,

    -- 악몽 던전 플레이
    ['ply_nm'] = function()
        g_nestDungeonData:goToNestDungeonScene(nil, NEST_DUNGEON_NIGHTMARE)
    end,

    -- 탐험 플레이
    ['ply_epl'] = function()
        g_explorationData:request_explorationInfo(function() UI_Exploration() end)
    end,

    -- 유저 레벨 달성
    ['u_lv'] = function()
        g_adventureData:goToAdventureScene()
    end,

    -- 친구 n명 달성
    ['make_frd'] = function()
        UI_FriendPopup()
    end,

    -- 테이머 겟
    ['t_get'] = function()
        UI_TamerManagePopup()
    end,

    -- 룬 강화
    ['r_enc'] = function()
        UI_DragonManageInfo.goToDragonManage('rune')
    end,

    -- 드래곤 스킬 레벨 업
    ['d_sklvup'] = function()
        UI_DragonManageInfo.goToDragonManage('skill_enc')
    end,

    -- 드래곤 진화
    ['d_evup'] = function()
        UI_DragonManageInfo.goToDragonManage('evolution')
    end,

    -- 룬 장착
    ['r_eq'] = function()
        UI_DragonManageInfo.goToDragonManage('rune')
    end,
    
    -- 룬 장착
    ['egg'] = function()
        g_hatcheryData:openHatcheryUI(nil, 'incubate')
    end,

    -- 친밀도 과일 먹임
    ['fruit'] = function()
        UI_DragonManageInfo.goToDragonManage('friendship')
    end,
    ['feed'] = function()
        UI_DragonManageInfo.goToDragonManage('friendship')
    end,

    -- 드래곤 레벨업
    ['d_lvup'] = function()
        UI_DragonManageInfo.goToDragonManage('level_up')
    end,

    -- 드래곤 레벨업
    ['d_grup'] = function()
        UI_DragonManageInfo.goToDragonManage('grade')
    end,

    -- 고대의 탑 클리어
    ['clr_tower'] = nil,

    -- 악몽던전 클리어
    ['clr_nm'] = nil,

    -- 콜로세움 {1} 연승
    ['cwin_clsm'] = nil,

    -- 인연 던전 발견
    ['fnd_rel'] = nil,

    -- 승급으로 드래곤 n종 획득
    ['d_grup_4'] = nil,
    ['d_grup_5'] = nil,
    ['d_grup_6'] = nil,

    -- 진화로 X 드래곤 n종 획득
    ['d_evol_2'] = nil,
    ['d_evol_3'] = nil,

    -- X 등급 드래곤 스킬레벨업
    ['d_sklvup_r'] = nil,
    ['d_sklvup_h'] = nil,
    ['d_sklvup_l'] = nil,

    -- 친밀도 일심동체 만들기
    ['d_flv_9'] = nil,

    -- X 속성 드래곤 n종 획득
    ['d_get_earth'] = nil,
    ['d_get_water'] = nil,
    ['d_get_fire'] = nil,
    ['d_get_light'] = nil,
    ['d_get_dark'] = nil,

    -- 레벨업 재료 사용
    ['d_use_mtrl'] = nil,
    
    -- 작별
    ['goodbye'] = nil,
    
    -- X 소환 하기
    ['smn'] = nil,
    ['smn_fp'] = nil,
    ['smn_rel'] = nil,

    -- 조합 하기
    ['comb'] = nil,
    ['comb_120101'] = nil,
    ['comb_120345'] = nil,
    ['comb_120404'] = nil,

    -- 룬 강화 성공/실패
    ['r_enc_scs'] = nil,
    ['r_enc_fail'] = nil,

    -- 우정포인트 주고 받기
    ['send_fp'] = nil,
    ['get_fp'] = nil,

    -- 바로가기 키를 띄우지 않을 것들
    -- 테이머 스킬 레벨 업
    ['t_sklvup'] = nil,
}