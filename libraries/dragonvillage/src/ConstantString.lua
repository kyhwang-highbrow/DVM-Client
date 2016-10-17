-------------------------------------
-- function chapterName
-- @breif 챕터의 명칭 리턴
-------------------------------------
function chapterName(chapter)
    if (chapter == 1) then
        return Str('정령의 숲')

    elseif (chapter == 2) then
        return Str('사파이어 해')

    elseif (chapter == 3) then
        return Str('칼바람 협곡')

    elseif (chapter == 4) then
        return Str('화룡의 땅')

    elseif (chapter == 5) then
        return Str('잊혀진 하늘의 유적')

    elseif (chapter == 6) then
        return Str('절규하는 칠흑의 성')

    else
        return Str('개발용')

    end
end

-------------------------------------
-- function bossChapterName
-- @breif 챕터별 보스 이름
-------------------------------------
function bossChapterName(chapter)
    if (chapter == 1) then
        return Str('퀸즈스네이크')

    elseif (chapter == 2) then
        return Str('드레이크')

    elseif (chapter == 3) then
        return Str('코카트리스')

    elseif (chapter == 4) then
        return Str('')

    elseif (chapter == 5) then
        return Str('')

    elseif (chapter == 6) then
        return Str('')

    else
        return Str('개발용')

    end
end