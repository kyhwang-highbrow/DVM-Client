import threading
import datetime
import csv
import json
import html

import pandas as pd

# 원본 CSV 파일 경로
input_csv_path = 'result_2023-12-13_143926.csv'

# 새로운 CSV 파일 경로
output_csv_path = '추출된파일.csv'

# 추출할 컬럼명
target_column_name = '특정컬럼명'


def extract_and_save_columns(input_path, output_path, column_names):
    # CSV 파일 읽기
    df = pd.read_csv(input_path)

    # 특정 컬럼들 추출
    selected_columns = df[column_names]

    # 새로운 DataFrame 생성
    new_df = pd.DataFrame(selected_columns)

    # 새로운 CSV 파일로 저장
    new_df.to_csv(output_path, index=False)




# 메인 함수
def main():
    
    group_lang_list = [
        ['af', 'ak', 'am', 'ar'],
        ['as', 'ay', 'az', 'be', 'bg', 'bho', 'bm', 'bn', 'bs', 'ca'],
        ['ceb', 'ckb', 'co', 'cs', 'cy', 'da', 'de', 'doi', 'dv', 'ee'],
        ['el', 'eo', 'et', 'eu', 'fi', 'fr', 'fy', 'ga', 'gd', 'gl'],
        ['gn', 'gom', 'gu', 'ha', 'haw', 'he', 'hi', 'hmn', 'hr', 'ht'],

        ['hu', 'hy', 'id', 'ig', 'ilo', 'is', 'it', 'jv', 'ka', 'kk'],
        ['km', 'kn', 'kri', 'ku', 'ky', 'la', 'lb', 'lg', 'ln', 'lo'],
        ['lt', 'lus', 'lv', 'mai', 'mg', 'mi', 'mk', 'ml', 'mn', 'mni-Mtei'],
        ['mr', 'ms', 'mt', 'my', 'ne', 'nl', 'no', 'nso', 'ny', 'om'],
        ['or', 'pa', 'pl', 'ps', 'pt', 'qu', 'ro', 'ru', 'rw', 'sa'],

        ['sd', 'si', 'sk', 'sl', 'sm', 'sn', 'so', 'sq', 'sr', 'st'],
        ['su', 'sv', 'sw', 'ta', 'te', 'tg', 'ti', 'tk', 'tl', 'tr'],
        ['ts', 'tt', 'ug', 'uk', 'ur', 'uz', 'vi', 'xh', 'yi', 'yo'],
        ['zh-CN', 'zu'],
    ]

    for column_names in group_lang_list:
        result_string = ', '.join(column_names)
        file_name = result_string + '.csv'
        extract_and_save_columns(input_csv_path, file_name, column_names)


    # f = open('input.csv', 'r', encoding='utf-8')
    # rdr = csv.reader(f)
    
    # for idx, line in enumerate(rdr):
    #     if idx == 0:
    #         column_list.extend(line)

    # for line in rdr[1:]:


    # f.close()



if __name__ == '__main__':
    main()