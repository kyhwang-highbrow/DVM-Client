import os
import subprocess

def svn_add_and_commit(folder_path, commit_message):
    try:
        # 해당 폴더의 모든 파일에 대해 svn add 명령어 실행
        for root, dirs, files in os.walk(folder_path):
            for file_name in files:
                file_path = os.path.join(root, file_name)
                subprocess.run(['svn', 'add', file_path])

        # SVN 커밋 명령어 실행
        subprocess.run(['svn', 'commit', '-m', commit_message, folder_path])
        print(f'커밋이 성공적으로 완료되었습니다: {folder_path}')
        
    except subprocess.CalledProcessError as e:
        print(f'커밋 도중 오류가 발생했습니다: {e}')