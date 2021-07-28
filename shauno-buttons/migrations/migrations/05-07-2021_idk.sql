ALTER TABLE developers
MODIFY COLUMN is_admin BOOLEAN DEFAULT false;

ALTER TABLE developers
MODIFY COLUMN id INTEGER AUTO_INCREMENT;

ALTER TABLE reasons
MODIFY COLUMN id INTEGER AUTO_INCREMENT;

ALTER TABLE explanations RENAME COLUMN `key` TO keyword;

ALTER TABLE explanations RENAME COLUMN `value` TO details;