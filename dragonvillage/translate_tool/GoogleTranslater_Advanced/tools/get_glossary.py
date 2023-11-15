import json
from google.cloud import translate_v3 as translate

# search_root = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
with open('config.json', 'r', encoding='utf-8') as f: # config.json으로부터 데이터 읽기
    config_json = json.load(f)
    PROJECT_ID = config_json['project_id']
    GLOSSARY_PREFIX = config_json['glossary_id_prefix']
    SOURCE_LANG = config_json['source_lang']
    TARGET_LANG_LIST = config_json['target_lang_list']

def get_glossary(
    source_lang,
    target_lang,
) -> translate.Glossary:
    client = translate.TranslationServiceClient()

    glossary_id = f"{GLOSSARY_PREFIX}_{source_lang}_{target_lang}"
    name = client.glossary_path(PROJECT_ID, "us-central1", glossary_id)

    response = client.get_glossary(name=name)
    print(f"Glossary name: {response.name}")
    print(f"Entry count: {response.entry_count}")
    print(f"Input URI: {response.input_config.gcs_source.input_uri}")

    return response

# 생성된 단어집 체크
for target_lang in TARGET_LANG_LIST:
    get_glossary(SOURCE_LANG, target_lang)