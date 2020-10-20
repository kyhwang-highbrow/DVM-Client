
# 각종 특수문자들을 올바르게 처리합니다.
def quote(text):
    value = text.replace("\'", "\\'").replace('\"', '\\"').replace('\\\\n', '\\n')
    return value


def quote_row_dics(row_dics):
    for row_dic in row_dics:
        for key in row_dic:
            row_dic[key] = quote(row_dic[key])

    return row_dics