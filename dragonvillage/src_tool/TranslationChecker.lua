require 'LuaStandAlone'

-------------------------------------
-- class TranslationChecker
-------------------------------------
TranslationChecker = class({
    m_allLuaFileList = 'List<string>',
    })

-------------------------------------
-- function init
-------------------------------------
function TranslationChecker:init()
    self.m_allLuaFileList = {'lang_en.lua', 'lang_jp.lua', 'lang_zhtw.lua', 'lang_th.lua', 'lang_es.lua', 'lang_fa.lua'}

    --'lang_af.lua', 'lang_ak.lua', 'lang_am.lua', 'lang_ar.lua', 'lang_as.lua', 'lang_ay.lua', 'lang_az.lua', 'lang_be.lua', 'lang_bg.lua', 'lang_bho.lua', 'lang_bm.lua', 'lang_bn.lua', 'lang_bs.lua', 'lang_ca.lua', 'lang_ceb.lua', 'lang_ckb.lua', 'lang_co.lua', 'lang_cs.lua', 'lang_cy.lua', 'lang_da.lua', 'lang_de.lua', 'lang_doi.lua', 'lang_dv.lua', 'lang_ee.lua', 'lang_el.lua', 'lang_eo.lua', 'lang_et.lua', 'lang_eu.lua', 'lang_fi.lua', 'lang_fr.lua', 'lang_fy.lua', 'lang_ga.lua', 'lang_gd.lua', 'lang_gl.lua', 'lang_gn.lua', 'lang_gom.lua', 'lang_gu.lua', 'lang_ha.lua', 'lang_haw.lua', 'lang_he.lua', 'lang_hi.lua', 'lang_hmn.lua', 'lang_hr.lua', 'lang_ht.lua', 'lang_hu.lua', 'lang_hy.lua', 'lang_id.lua', 'lang_ig.lua', 'lang_ilo.lua', 'lang_is.lua', 'lang_it.lua', 'lang_jv.lua', 'lang_ka.lua', 'lang_kk.lua', 'lang_km.lua', 'lang_kn.lua', 'lang_kri.lua', 'lang_ku.lua', 'lang_ky.lua', 'lang_la.lua', 'lang_lb.lua', 'lang_lg.lua', 'lang_ln.lua', 'lang_lo.lua', 'lang_lt.lua', 'lang_lus.lua', 'lang_lv.lua', 'lang_mai.lua', 'lang_mg.lua', 'lang_mi.lua', 'lang_mk.lua', 'lang_ml.lua', 'lang_mn.lua', 'lang_mni-Mtei.lua', 'lang_mr.lua', 'lang_ms.lua', 'lang_mt.lua', 'lang_my.lua', 'lang_ne.lua', 'lang_nl.lua', 'lang_no.lua', 'lang_nso.lua', 'lang_ny.lua', 'lang_om.lua', 'lang_or.lua', 'lang_pa.lua', 'lang_pl.lua', 'lang_ps.lua', 'lang_pt.lua', 'lang_qu.lua', 'lang_ro.lua', 'lang_ru.lua', 'lang_rw.lua', 'lang_sa.lua', 'lang_sd.lua', 'lang_si.lua', 'lang_sk.lua', 'lang_sl.lua', 'lang_sm.lua', 'lang_sn.lua', 'lang_so.lua', 'lang_sq.lua', 'lang_sr.lua', 'lang_st.lua', 'lang_su.lua', 'lang_sv.lua', 'lang_sw.lua', 'lang_ta.lua', 'lang_te.lua', 'lang_tg.lua', 'lang_ti.lua', 'lang_tk.lua', 'lang_tl.lua', 'lang_tr.lua', 'lang_ts.lua', 'lang_tt.lua', 'lang_ug.lua', 'lang_uk.lua', 'lang_ur.lua', 'lang_uz.lua', 'lang_vi.lua', 'lang_xh.lua', 'lang_yi.lua', 'lang_yo.lua', 'lang_zh-CN.lua', 'lang_zu.lua'
end

-------------------------------------
-- function run
-------------------------------------
function TranslationChecker:run(target_path)
    print("languages load check begin!!")

    for _, lua_file in ipairs(self.m_allLuaFileList) do
        local i, j = lua_file.find(lua_file, '.lua')
        local lua_base = string.sub(lua_file, 1, i - 1)
        local str = string.format('../translate/%s', lua_base)        
        require(str)
    end

    print(string.format('## {%d} languages load check perfect !!', #self.m_allLuaFileList))
end

-------------------------------------
-- ############ RUN ################
-- lua class 파일 자체에서 실행되도록 함
-------------------------------------
if (arg[1] == 'run') then
    TranslationChecker():run()
end