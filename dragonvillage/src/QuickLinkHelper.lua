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
        local attr = g_attrTowerData:getSelAttr()
        if (attr) then
            link_type =  'ply_attr_tower'
        else
            link_type =  'ply_tower'
        end

    -- 콜로세움 플레이
    elseif (game_mode == GAME_MODE_COLOSSEUM) then
        link_type = 'ply_clsm'

    -- 인연던전 플레이
    elseif (game_mode == GAME_MODE_SECRET_DUNGEON) then
        link_type = 'ply_rel'

    -- 클랜던전 플레이
    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        link_type = 'ply_cldg'

    -- 고대 유적 던전 플레이
    elseif (game_mode == GAME_MODE_ANCIENT_RUIN) then
        link_type = 'ply_ancient_ruin'

    -- 룬 수호자 던전 플레이
    elseif (game_mode == GAME_MODE_RUNE_GUARDIAN) then
        link_type = 'play_rune_guardian'

    elseif (game_mode == GAME_MODE_DIMENSION_GATE) then
        link_type = 'ply_dmgate'

    -- 모험 모드
    else
        link_type = 'ply_adv'

    end

    -- 바로 가기를 활용한다.
    QuickLinkHelper.quickLink(link_type, condition)
end


T_LINK_FUNC = {
    -- stage clear / condition : stage_id
    ['clr_stg'] = function(condition)
        UINavigator:goTo('adventure', condition)
    end,

    -- stage clear 인데 readyScene으로 보내주는 경우
    ['stg_ready'] = function(condition)
        UINavigatorDefinition:goTo('battle_ready', condition)
    end,

    -- 던전으로 이동
    ['link_dungeon'] = function()
        UINavigator:goTo('battle_menu', 'dungeon')
    end,

    -- ancient clear / condition : stage_id
    ['clr_tower'] = function(condition)
        UINavigator:goTo('ancient', condition)
    end,

    -- stage clear / condition : stage_id
    ['clr_nm'] = function(condition)
        UINavigator:goTo('nestdungeon', condition)
    end,

    -- stage clear / condition : stage_id
    ['clr_ruin'] = function(condition)
        UINavigator:goTo('ancient_ruin', condition)
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

    -- 고대의 탑 또는 시험의 탑 {1}회 플레이
    ['ply_tower_ext'] = function()
        -- 시험의 탑이 오픈되었을 경우 시험의 탑으로 이동
        if g_attrTowerData then
            if g_attrTowerData:isContentOpen() then
                UINavigator:goTo('attr_tower')
                return
            end
        end
        
        -- 시험의 탑이 오픈되지 않았거나 정보가 없을 경우 고대의 탑으로 이동
        UINavigator:goTo('ancient')
    end,

    -- 시험의 탑 플레이
    ['ply_attr_tower'] = function()
        UINavigator:goTo('attr_tower')
    end,

	-- 시험의 탑 클리어
    ['clr_att_all'] = function()
        UINavigator:goTo('attr_tower')
    end,

    -- 콜로세움 승리하기
    ['col_win'] = function()
        UINavigator:goTo('colosseum')
    end,

    -- 콜로세움 승리하기
    ['arena_win'] = function()
        UINavigator:goTo('colosseum')
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
    ['ply_ev'] = function()
        UINavigator:goTo('nest_evo_stone')
    end,

    -- 거목 던전 플레이
    ['ply_tree'] = function()
        UINavigator:goTo('nest_tree')
    end,

    -- 악몽 던전 플레이
    ['ply_nm'] = function()
        UINavigator:goTo('nest_nightmare')
    end,
    
    -- 악몽던전 클리어
    ['clr_nm'] = function()
        UINavigator:goTo('nest_nightmare')
    end,

    -- 악몽던전 또는 고대 유적 던전 {1}회 플레이
    ['ply_nm_ruin'] = function()
        -- 고대 유적 던전이 오픈되었을 경우 고대 유적 던전으로 이동
        if g_ancientRuinData then
            if g_ancientRuinData:isOpenAncientRuin() then
                UINavigator:goTo('ancient_ruin')
                return
            end
        end

        -- 고대 유적 던전이 오픈되지 않았거나 정보가 없을 경우 악몽던전으로 이동
        UINavigator:goTo('nest_nightmare')
    end,

    -- 악몽던전 또는 고대 유적 던전, 룬 수호자 던전 {1}회 플레이
    ['ply_nm_ruin_grd'] = function()
        -- 고대 유적 던전이 오픈되었을 경우 고대 유적 던전으로 이동
        if g_ancientRuinData then
            if g_ancientRuinData:isOpenAncientRuin() then
                UINavigator:goTo('ancient_ruin')
                return
            end
        end

        -- 고대 유적 던전이 오픈되지 않았거나 정보가 없을 경우 악몽던전으로 이동
        UINavigator:goTo('nest_nightmare')
    end,

    -- 탐험 플레이
    ['ply_epl'] = function()
        UINavigator:goTo('exploration')
    end,
    
    -- 인연 던전 플레이
    ['ply_rel'] = function()
        UINavigator:goTo('secret_relation')
    end,

    -- 인연 던전 발견
    ['fnd_rel'] = function()
        UINavigator:goTo('secret_relation')
    end,

    -- 차원문
    ['ply_dmgate'] = function ()
        UINavigator:goTo('dmgate')
    end,

    -- 클랜 던전 플레이
    ['ply_cldg'] = function()
        UINavigator:goTo('clan_raid')
    end,

    -- 고대 유적 던전 플레이
    ['ply_ancient_ruin'] = function()
        UINavigator:goTo('ancient_ruin')
    end,

    -- 룬 수호자 던전 플레이
    ['play_rune_guardian'] = function()
        UINavigator:goTo('rune_guardian')
    end,

    -- 유저 레벨 달성
    ['u_lv'] = function()
        UINavigator:goTo('adventure')
    end,

    -- 드래곤 레벨 달성
    ['d_lv'] = function()
        UINavigator:goTo('adventure')
    end,

    -- 친구 n명 달성
    ['make_frd'] = function()
        UINavigator:goTo('friend')
    end,
    ['invt_frd'] = function()
        UINavigator:goTo('friend', 'recommend')
    end,
    -- 우정포인트 주고 받기
    ['send_fp'] = function()
        UINavigator:goTo('friend')
    end,
    ['get_fp'] = function()
        UINavigator:goTo('friend')
    end,

    -- 테이머 겟
    ['t_get'] = function()
        UINavigator:goTo('tamer')
    end,
    -- 테이머 스킬 레벨 업
    ['t_sklvup'] = function()
        UINavigator:goTo('tamer')
    end,
    



    -- 룬 장착
    ['r_eq'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,    
    -- 드래곤 성장일지 - 룬 장착
    ['r_eq_s'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'rune', start_dragon)
    end,
    -- 드래곤 성장일지 - 특정 능력치 체크 (룬 장착, 강화쪽 체크)
    ['check_d_stat'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'rune', start_dragon)
    end,

    -- 룬 강화
    ['r_enc'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,
    -- 룬 강화 성공/실패
    ['r_enc_scs'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,
    ['r_enc_fail'] = function()
        UINavigator:goTo('dragon_manage', 'rune')
    end,




    -- 드래곤 스킬 레벨 업
    ['d_sklvup'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,
    -- X 등급 드래곤 스킬레벨업
    ['d_sklvup_r'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,
    ['d_sklvup_h'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,
    ['d_sklvup_l'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,

    -- 드래곤 진화
    ['d_evup'] = function()
        UINavigator:goTo('dragon_manage', 'evolution')
    end,
    -- 진화로 X 드래곤 n종 획득
    ['d_evol_2'] = function()
        UINavigator:goTo('dragon_manage', 'evolution')
    end,
    ['d_evol_3'] = function()
        UINavigator:goTo('dragon_manage', 'evolution')
    end,
    -- 드래곤 성장일지 - 드래곤 진화
    ['d_evup_s'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'evolution', start_dragon)
    end,

    -- 드래곤 레벨업
    ['d_lvup'] = function()
        UINavigator:goTo('dragon_manage', 'level_up')
    end,
    -- 레벨업 재료 사용
    ['d_use_mtrl'] = function()
        UINavigator:goTo('dragon_manage', 'level_up')
    end,

    -- 드래곤 등급업
    ['d_grup'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    -- 승급으로 드래곤 n종 획득
    ['d_grup_4'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    ['d_grup_5'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    ['d_grup_6'] = function()
        UINavigator:goTo('dragon_manage', 'grade')
    end,
    -- 드래곤 성장일지 - 드래곤 성장일지
    ['d_grup_s'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'grade', start_dragon)
    end,

    -- 드래곤 승급 확인하기
    ['check_grup'] = function()
        UINavigator:goTo('dragon_manage')
    end,

    -- 친밀도 과일 먹임
    ['fruit'] = function()
        UINavigator:goTo('dragon_manage', 'friendship')
    end,
    ['feed'] = function()
        UINavigator:goTo('dragon_manage', 'friendship')
    end,
    -- 친밀도 일심동체 만들기
    ['d_flv_9'] = function()
        UINavigator:goTo('dragon_manage', 'friendship')
    end,
    -- 드래곤 성장일지 - 친밀도 올리기
    ['fr_lvup'] = function()
        local start_dragon = g_userData:get('start_dragon')
        UINavigator:goTo('dragon_manage', 'friendship', start_dragon)
    end,

    -- 드래곤 특성
    ['link_dragon_mastery'] = function()
        UINavigator:goTo('dragon_manage', 'mastery')
    end,

    -- 작별
    ['goodbye'] = function()
        UINavigator:goTo('dragon_manage')
    end,



    
    -- 알 부화
    ['egg'] = function()
        UINavigator:goTo('hatchery', 'incubate')
    end,
    -- 드래곤 n종 획득
    ['did_u'] = function()
        UINavigator:goTo('hatchery')
    end,
    -- X 속성 드래곤 n종 획득
    ['attr_u_e'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_w'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_f'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_l'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['attr_u_d'] = function()
        UINavigator:goTo('hatchery')
    end,
    -- X 소환 하기
    ['smn'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['smn_fp'] = function()
        UINavigator:goTo('hatchery')
    end,
    ['smn_rel'] = function()
        UINavigator:goTo('hatchery')
    end,
    -- 조합 하기
    ['comb'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,
    ['comb_120101'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,
    ['comb_120345'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,
    ['comb_120404'] = function()
        UINavigator:goTo('hatchery', 'combine')
    end,


	-- 스페셜 퀘스트
	['d_sklvup_sq'] = function()
        UINavigator:goTo('dragon_manage', 'skill_enc')
    end,
    ['ply_clsm_sq'] = function()
        UINavigator:goTo('colosseum')
    end,
	['ply_cldg_sq'] = function()
        UINavigator:goTo('clan_raid')
    end,
	['d_rlvup_sq'] = function()
        UINavigator:goTo('dragon_manage', 'reinforce')
    end,

    -- 2018-11-22 일일퀘스트에 추가
    -- 황금던전 {1}회 플레이
    ['ply_gold'] = function()
        UINavigator:goTo('gold_dungeon')
    end,

    -- 룬 대장간
    ['rune_forge'] = function () 
        UINavigator:goTo('rune_forge')
    end,
    ['rune_info'] = function () 
        UINavigator:goTo('rune_forge', 'info')
    end,
    ['rune_manage'] = function () 
        UINavigator:goTo('rune_forge', 'manage')
    end,
    ['rune_combine'] = function () 
        UINavigator:goTo('rune_forge', 'combine')
    end,
    ['rune_gacha'] = function () 
        UINavigator:goTo('rune_forge', 'gacha')
    end,
    ['raid_play'] = function()
        UINavigator:goTo('league_raid')
    end,

    -- 바로가기 키를 띄우지 않을 것들
	--[[
	r_6grcnt_sq : 6성 룬 획득
	d_lvmax_sq : 6성 60레벨 드래곤
	]]
}