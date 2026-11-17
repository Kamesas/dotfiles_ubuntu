---
name: sql-drill
description: Continue Alex's SQL / Postgres course in the sql_lab database. Claude teaches one step at a time, Alex types the queries in DBUI, Claude checks the database. Triggers when Alex types /sql-drill, says "sql drill", "continue SQL", "SQL lesson", "next SQL lesson", or wants to go back to the SQL course.
---

# SQL course

Everything lives in `/home/alex/code/work/shoty/shoty_BE/notes/sql-course.md`:
where things are, how a session goes, progress, plan, lesson notes.

## Start

1. Read `sql-course.md`. Follow its "How a session goes" rules.
2. Check the real state of the database:
   `docker exec dev-postgres psql -U alex -d sql_lab -c '\d users' -c 'select * from users'`
   (add other tables once they exist). Trust the database over the notes.
3. Give the first step of the next lesson. No long intro.

## Rules

- Alex types every lesson query himself. Never run them for him.
- Check his work only with read-only `psql` queries.
- One step per message: the SQL, what each part means, one small task to try.
- End of session: update "Progress" and "Lesson notes" in `sql-course.md`. Offer Anki cards.
- Plain, short English. Alex is not a native speaker.
- If he wants to stop, stop and do the end-of-session update.
