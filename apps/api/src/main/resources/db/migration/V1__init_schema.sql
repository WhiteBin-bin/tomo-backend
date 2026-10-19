SET NAMES utf8mb4;

CREATE TABLE `document_versions` (
  `document_versions_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '문서 버전 아이디',
  `publication_status` ENUM('DRAFT','APPROVED') NOT NULL DEFAULT 'DRAFT' COMMENT '게시 상태',
  `effective_date` DATE NOT NULL COMMENT '시행일',
  `body` LONGTEXT NOT NULL COMMENT '본문',
  `version` VARCHAR(30) NOT NULL COMMENT '버전',
  `document_type` ENUM('AGE_14_OR_OLDER','TERMS_AGREED','PRIVACY_AGREED') NOT NULL COMMENT '문서 종류',
  PRIMARY KEY (`document_versions_id`),
  UNIQUE(document_type,version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `category` (
  `category_id` BIGINT NOT NULL COMMENT '카테고리 아이디',
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  `category_nm` VARCHAR(100) NOT NULL COMMENT '카테고리 명',
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 일시',
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '수정 일시',
  PRIMARY KEY (`category_id`),
  UNIQUE(users_id,category_nm)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `notification_settings` (
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '수정 일시',
  `todo_enabled_yn` CHAR(1) NOT NULL COMMENT 'To-do 알림 수신',
  PRIMARY KEY (`users_id`),
  CHECK(todo_enabled_yn IN ('0','1'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `login_sessions` (
  `login_session_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '로그인 세션 아이디',
  `expires_at` DATETIME(6) NOT NULL COMMENT '만료 일시',
  `issued_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '발급 일시',
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  PRIMARY KEY (`login_session_id`),
  CHECK(expires_at >= issued_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `social_identities` (
  `social_identities_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '소셜 인증 아이디',
  `linked_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '연결 일시',
  `email` VARCHAR(320) NULL DEFAULT NULL COMMENT '이메일',
  `provider_subject` VARCHAR(255) NOT NULL COMMENT '제공자 사용자 식별값',
  `provider` ENUM('GOOGLE','KAKAO') NOT NULL COMMENT '인증 제공자',
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  PRIMARY KEY (`social_identities_id`),
  UNIQUE(provider,provider_subject),
  UNIQUE(users_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `focus_reflections` (
  `focus_reflections_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '회고 아이디',
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '수정 일시',
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 일시',
  `note` VARCHAR(500) NULL DEFAULT NULL COMMENT '한 줄 회고',
  `other_distraction` VARCHAR(500) NULL DEFAULT NULL COMMENT '기타 방해요소',
  `focus_score` TINYINT NOT NULL COMMENT '집중도',
  `session_id` BIGINT NOT NULL COMMENT '집중 세션 아이디',
  PRIMARY KEY (`focus_reflections_id`),
  CHECK(focus_score BETWEEN 1 AND 5),
  UNIQUE(session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `focus_rounds` (
  `round_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '회차 아이디',
  `ended_at` DATETIME(6) NULL DEFAULT NULL COMMENT '종료 일시',
  `started_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '시작 일시',
  `focus_completed_at` DATETIME(6) NULL DEFAULT NULL COMMENT '집중 완료 일시',
  `planned_break_seconds` INT NOT NULL COMMENT '회차 휴식시간(초)',
  `planned_focus_seconds` INT NOT NULL COMMENT '회차 집중시간(초)',
  `round_no` INT NOT NULL COMMENT '회차 번호',
  `session_id` BIGINT NOT NULL COMMENT '집중 세션 아이디',
  PRIMARY KEY (`round_id`),
  CHECK(ended_at IS NULL OR ended_at >= started_at),
  CHECK(focus_completed_at IS NULL OR focus_completed_at >= started_at),
  CHECK(planned_break_seconds >= 0),
  CHECK(planned_focus_seconds > 0),
  CHECK(round_no >= 1),
  UNIQUE(session_id,round_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `reflection_distractions` (
  `distraction_code` ENUM('SMARTPHONE_SNS','NOISE','FATIGUE','DISTRACTING_THOUGHTS','OTHERS_INTERRUPTION','OTHER') NOT NULL COMMENT '방해요소 코드',
  `focus_reflections_id` BIGINT NOT NULL COMMENT '회고 아이디',
  PRIMARY KEY (`distraction_code`, `focus_reflections_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `users` (
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '수정 일시',
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 일시',
  `account_status` ENUM('PENDING','ACTIVE','VAN','DELETE') NOT NULL DEFAULT 'PENDING' COMMENT '가입 상태',
  `profile_image` VARCHAR(1000) NULL DEFAULT NULL COMMENT '프로필 이미지',
  `nickname` VARCHAR(50) NULL DEFAULT NULL COMMENT '닉네임',
  PRIMARY KEY (`users_id`),
  CHECK(account_status <> 'ACTIVE' OR nickname IS NOT NULL),
  UNIQUE(nickname)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `focus_sessions` (
  `session_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '집중 세션 아이디',
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '수정 일시',
  `started_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '시작 일시',
  `status` ENUM('FOCUSING','RESTING','PAUSED','COMPLETED','STOPPED') NOT NULL DEFAULT 'FOCUSING' COMMENT '진행 상태',
  `repeat_count` INT NOT NULL COMMENT '반복 횟수',
  `break_seconds` INT NOT NULL COMMENT '휴식시간(초)',
  `focus_seconds` INT NOT NULL COMMENT '집중시간(초)',
  `todo_id` BIGINT NULL DEFAULT NULL COMMENT 'To-do 아이디',
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  PRIMARY KEY (`session_id`),
  CHECK(repeat_count >= 1),
  CHECK(break_seconds >= 0),
  CHECK(focus_seconds > 0),
  UNIQUE(session_id,users_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `notifications` (
  `notification_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '알림 아이디',
  `read_at` DATETIME(6) NULL DEFAULT NULL COMMENT '읽음 일시',
  `expires_at` DATETIME(6) NOT NULL COMMENT '만료 일시',
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 일시',
  `scheduled_for` DATETIME(6) NULL DEFAULT NULL COMMENT '예약 일시',
  `todo_id` BIGINT NULL DEFAULT NULL COMMENT 'To-do 아이디',
  `body` LONGTEXT NOT NULL COMMENT '본문',
  `title` VARCHAR(200) NOT NULL COMMENT '제목',
  `type` ENUM('TODO_REMINDER','SYSTEM') NOT NULL COMMENT '알림 유형',
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  PRIMARY KEY (`notification_id`),
  CHECK(read_at IS NULL OR read_at >= created_at),
  CHECK(expires_at > created_at),
  CHECK((type='TODO_REMINDER' AND todo_id IS NOT NULL AND scheduled_for IS NOT NULL) OR (type='SYSTEM' AND todo_id IS NULL AND scheduled_for IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `todos` (
  `todo_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'To-do 아이디',
  `category_nm` VARCHAR(100) NOT NULL COMMENT '카테고리 명',
  `deleted_at` DATETIME(6) NULL DEFAULT NULL COMMENT '삭제 일시',
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '수정 일시',
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 일시',
  `completed_at` DATETIME(6) NULL DEFAULT NULL COMMENT '완료 일시',
  `estimated_minutes` INT NOT NULL COMMENT '예상 학습시간',
  `reminder_at` DATETIME(6) NULL DEFAULT NULL COMMENT '알림 일시',
  `due_date` DATE NOT NULL COMMENT '마감일',
  `priority` ENUM('HIGH','MEDIUM','LOW') NOT NULL COMMENT '우선순위',
  `title` VARCHAR(200) NOT NULL COMMENT '제목',
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  PRIMARY KEY (`todo_id`),
  CHECK(estimated_minutes > 0),
  UNIQUE(todo_id,users_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_agreement` (
  `user_agreement_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '가입 동의 아이디',
  `agreed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '동의 일시',
  `agreed_yn` CHAR(1) NOT NULL COMMENT '동의 여부',
  `document_versions_id` BIGINT NOT NULL COMMENT '문서 버전 아이디',
  `agreement_type` ENUM('AGE_14_OR_OLDER','TERMS_AGREED','PRIVACY_AGREED') NOT NULL COMMENT '동의 항목',
  `users_id` VARCHAR(36) NOT NULL COMMENT '사용자 아이디',
  PRIMARY KEY (`user_agreement_id`),
  CHECK(agreed_yn IN ('0','1')),
  UNIQUE(users_id,agreement_type,document_versions_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `focus_intervals` (
  `interval_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '시간 구간 아이디',
  `started_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '시작 일시',
  `ended_at` DATETIME(6) NULL DEFAULT NULL COMMENT '종료 일시',
  `kind` ENUM('FOCUS','BREAK','PAUSE') NOT NULL COMMENT '구간 종류',
  `round_id` BIGINT NOT NULL COMMENT '회차 아이디',
  PRIMARY KEY (`interval_id`),
  CHECK(ended_at IS NULL OR ended_at >= started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE `category` ADD CONSTRAINT `FK_users_TO_category_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `notification_settings` ADD CONSTRAINT `FK_users_TO_notification_settings_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `login_sessions` ADD CONSTRAINT `FK_users_TO_login_sessions_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `social_identities` ADD CONSTRAINT `FK_users_TO_social_identities_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `focus_reflections` ADD CONSTRAINT `FK_focus_sessions_TO_focus_reflections_1` FOREIGN KEY (`session_id`) REFERENCES `focus_sessions` (`session_id`);

ALTER TABLE `focus_rounds` ADD CONSTRAINT `FK_focus_sessions_TO_focus_rounds_1` FOREIGN KEY (`session_id`) REFERENCES `focus_sessions` (`session_id`);

ALTER TABLE `reflection_distractions` ADD CONSTRAINT `FK_focus_reflections_TO_reflection_distractions_1` FOREIGN KEY (`focus_reflections_id`) REFERENCES `focus_reflections` (`focus_reflections_id`);

ALTER TABLE `focus_sessions` ADD CONSTRAINT `FK_todos_TO_focus_sessions_1` FOREIGN KEY (`todo_id`, `users_id`) REFERENCES `todos` (`todo_id`, `users_id`);

ALTER TABLE `focus_sessions` ADD CONSTRAINT `FK_users_TO_focus_sessions_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `notifications` ADD CONSTRAINT `FK_todos_TO_notifications_1` FOREIGN KEY (`todo_id`, `users_id`) REFERENCES `todos` (`todo_id`, `users_id`);

ALTER TABLE `notifications` ADD CONSTRAINT `FK_users_TO_notifications_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `todos` ADD CONSTRAINT `FK_users_TO_todos_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `user_agreement` ADD CONSTRAINT `FK_document_versions_TO_user_agreement_1` FOREIGN KEY (`document_versions_id`) REFERENCES `document_versions` (`document_versions_id`);

ALTER TABLE `user_agreement` ADD CONSTRAINT `FK_users_TO_user_agreement_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`users_id`);

ALTER TABLE `focus_intervals` ADD CONSTRAINT `FK_focus_rounds_TO_focus_intervals_1` FOREIGN KEY (`round_id`) REFERENCES `focus_rounds` (`round_id`);
