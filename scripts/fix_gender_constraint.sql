-- Fix for user_measurements gender check constraint
-- The existing constraint only allows 'male' and 'female'.
-- We need to drop it and add a new one that includes 'other'.

ALTER TABLE user_measurements DROP CONSTRAINT IF EXISTS user_measurements_gender_check;
ALTER TABLE user_measurements ADD CONSTRAINT user_measurements_gender_check CHECK (gender IN ('male', 'female', 'other'));
