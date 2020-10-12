
def sum_DVM_plain_text(all_data_list, all_data_dic, datas, locale_list, date_str):
    for data_key in datas:
        if data_key not in all_data_dic.keys():
            all_data_dic[data_key] = {}
            all_data_dic[data_key]['hints'] = datas[data_key]['hints']
            
            temp_data = [data_key]
            for _ in range(len(locale_list)):
                temp_data.append('')
            temp_data.append(','.join(datas[data_key]['hints']))
            temp_data.append(date_str)
            all_data_list.append(temp_data)

        hints = datas[data_key]['hints']
        for hint in hints:
            if all_data_dic[data_key]['hints'].count(hint) == 0: # 겹치는 단어가 다른 파일에서 나온 경우
                all_data_dic[data_key]['hints'].append(hint) # 단어 힌트에 이 파일 이름을 추가합니다.
                for data in all_data_list:
                    if data[0] == data_key:
                        data[1 + len(locale_list)] += ',' + hint
                        break