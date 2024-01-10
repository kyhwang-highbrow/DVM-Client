import os
import subprocess

def svn_add_and_commit(new_file_path, commit_message):
    try:
        # SVN에 파일 추가
        subprocess.run(['svn', 'add', new_file_path])

        # SVN 커밋 명령어 실행
        subprocess.run(['svn', 'commit', '-m', commit_message, new_file_path])
        print(f'커밋이 성공적으로 완료되었습니다: {new_file_path}')
    except subprocess.CalledProcessError as e:
        print(f'커밋 도중 오류가 발생했습니다: {e}')