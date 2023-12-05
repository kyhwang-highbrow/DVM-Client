
def sum_DVM_scenario_text(all_data_list, all_data_dic, datas, locale_list, date_str):
    for data in datas:
        temp_data = [data[0], data[1], data[2]] # [file_name, page, speaker_kr]
        temp_data.extend(['' for _ in range(len(locale_list))])
        
        temp_data.append(data[3]) # text_kr
        temp_data.extend(['' for _ in range(len(locale_list))])
        temp_data.append(date_str)
        all_data_list.append(temp_data)