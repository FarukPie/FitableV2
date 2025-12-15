-- Add body_shape column to user_measurements table
ALTER TABLE user_measurements 
ADD COLUMN body_shape text DEFAULT 'rectangular';

-- Optional: Add check constraint to ensure valid values
ALTER TABLE user_measurements 
ADD CONSTRAINT check_body_shape 
CHECK (body_shape IN ('rectangular', 'triangle', 'inverted_triangle', 'oval'));
