# ☀️ 굿모닝 프로젝트

이 문서는 굿모닝 프로젝트의 개발 환경을 구성하는 방법을 안내합니다.

## 🚀 시작하기

아래 순서를 따라 프로젝트 환경을 구성하세요.

### 1️⃣ 프로젝트 클론

```bash
git clone https://github.com/idealinsane/GoodMorning.git
cd GoodMorning/
```

### 2️⃣ Firebase 설정

#### 2-1. Firebase 로그인

터미널에서 다음 명령어를 실행해 Firebase에 로그인합니다.

```bash
firebase login
```

#### 2-2. FlutterFire 구성

다음 명령어로 Firebase를 Flutter 프로젝트에 구성합니다.

```bash
flutterfire configure --project=goodmorning-e2072
```


### 3️⃣ .env 파일 생성

프로젝트 루트 디렉토리에 `.env` 파일을 생성합니다.

```bash
cp env-template .env
```

`.env` 파일에 필요한 키 값을 입력하세요.