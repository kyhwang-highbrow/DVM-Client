import os
import gspread
import shutil


if not os.path.isfile(os.getenv('APPDATA') + '/gspread/credentials.json'):
    os.mkdir(os.getenv('APPDATA') + '/gspread')
    shutil.copy('tools/G_sheet/credentials.json', os.getenv('APPDATA') + '/gspread/')

gspread.oauth()
