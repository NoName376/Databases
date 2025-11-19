CREATE TABLE users (
 user_id INT PRIMARY KEY,
 username VARCHAR(50),
 email VARCHAR(100),
 subscription_type VARCHAR(20),
 country VARCHAR(50)
);
CREATE TABLE videos (
 video_id INT PRIMARY KEY,
 title VARCHAR(200),
 genre VARCHAR(50),
 release_year INT,
 duration_minutes INT,
 rating DECIMAL(3,1)
);
CREATE TABLE watch_history (
 watch_id INT PRIMARY KEY,
 user_id INT,
 video_id INT,
 watch_date TIMESTAMP,
 watch_duration_minutes INT,
 completed BOOLEAN,
 FOREIGN KEY (user_id) REFERENCES users(user_id),
 FOREIGN KEY (video_id) REFERENCES videos(video_id)
);



-- Task 1
SELECT v.title, w.watch_date, w.completed
FROM watch_history w
JOIN videos v ON w.video_id = v.video_id
WHERE w.user_id = 12345
ORDER BY w.watch_date DESC;


CREATE INDEX wh_idx ON watch_history (user_id, watch_date DESC)
WHERE user_id == 12345;

-- Should be multicolumn index for find by user_id and sort by watch_date


-- Task 2
CREATE INDEX videos_idx ON videos (LOWER(TRIM(title)));

SELECT *
FROM videos v
WHERE LOWER(TRIM(v.title)) == LOWER(TRIM('My video'));



-- Task 3
CREATE INDEX wh_user_idx ON watch_history(user_id);
CREATE INDEX wh_user_date_idx ON watch_history(user_id, watch_date);
CREATE INDEX wh_date_idx ON watch_history(watch_date);

/*
A) wh_user_idx
B)
 */

 DROP INDEX wh_user_idx;


-- Task 4
CREATE INDEX watch_hist_idx ON watch_history (completed)
WHERE completed = TRUE;

SELECT *
FROM watch_history w
WHERE w.completed = TRUE;