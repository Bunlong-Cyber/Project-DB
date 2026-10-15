-- Security exercise for a disposable local learning database only.
-- This demonstrates database authorization, not application authentication.

-- TODO 1: Create NOLOGIN group roles for administrator, teacher, and student.
-- TODO 2: Grant only the table/view operations each role needs.
-- TODO 3: Ensure students can read only their own grades and cannot edit them.
-- TODO 4: Ensure teachers can insert/update only grades for their assignments.
-- TODO 5: Ensure administrators can manage the academic records and access data.
-- TODO 6: Test both allowed and denied actions using row-level security (RLS).

-- In this lab, app.student_id/app.teacher_id are test context only. A real
-- application must set identity through a trusted server-side connection.
-- Record the permission matrix and test evidence in your team notes.
