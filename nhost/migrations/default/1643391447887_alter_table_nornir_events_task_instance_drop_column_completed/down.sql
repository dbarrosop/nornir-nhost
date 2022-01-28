alter table "nornir_events"."task_instance" alter column "completed" set default false;
alter table "nornir_events"."task_instance" alter column "completed" drop not null;
alter table "nornir_events"."task_instance" add column "completed" bool;
