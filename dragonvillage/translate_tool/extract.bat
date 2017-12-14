@echo off
set HOD_ROOT=%cd%
::node --max-old-space-size=4096 tools/extract.js test 1s3m5A7rl4JHngXFknMd3MTkbf0vVaAIPoRx3GPHJvoo
node --max-old-space-size=4096 tools/extract.js en 1TzxlNwZHMZxG4W0LsPokaQfnCsCoCM3qvozAt7tvICg
node --max-old-space-size=4096 tools/extract.js jp 1hYRS7hE6OTRNQ-2RJL14O0VmxXxbYoT0wtQ7-rFnAi4
node --max-old-space-size=4096 tools/extract.js zhtw 1Cv2vBmWpnVwK74KN6SnL0QKdTpMoAx8VPYDzOi9yks0
::python slack.py