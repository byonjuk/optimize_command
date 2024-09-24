# 서버 기본 명령어 및 최적화 명령어

```bash
[ -f "optimize_vps.sh" ] && rm optimize_vps.sh; wget -q https://raw.githubusercontent.com/byonjuk/optimize_command/refs/heads/main/optimize_vps.sh && chmod +x optimize_vps.sh && ./optimize_vps.sh
```
를 입력하시면

![image](https://github.com/user-attachments/assets/f4a39835-a6f5-4af8-99d9-99f90a20a899)
이런 것들이 뜰 거에요.

원하는 명령어 실행해서 쓰세용~

## 저 리츄얼 돌리는 곳에 이거 (최적화 명령어) 실행해두 됨?
ㅇㅇ 실행해두 됨.

대신 실행하고 나서
```bash
docker restart hello-world
```
이거 한 번만 쳐주세용~ 그러고서

```bash
[ -f "Ritual.sh" ] && rm Ritual.sh; wget -q https://raw.githubusercontent.com/byonjuk/Ritual_Node/main/Ritual.sh && chmod +x Ritual.sh && ./Ritual.sh
```
이거 쳐서
![image](https://github.com/user-attachments/assets/9f72295f-86e9-4461-878d-54a8d20fd011)
재시작 명령어 해 준 뒤에
```bash
cd ~/infernet-container-starter/deploy && docker compose up
```
해주기~
