ALTER TABLE buttons ADD is_active INTEGER DEFAULT 1;

ALTER TABLE buttons DROP uuid;
ALTER TABLE buttons ADD COLUMN uuid VARCHAR(36) NOT NULL UNIQUE;