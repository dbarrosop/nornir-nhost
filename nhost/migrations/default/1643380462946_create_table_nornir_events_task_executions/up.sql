CREATE TABLE "nornir_events"."task_executions" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "name" text NOT NULL, "success" boolean NOT NULL DEFAULT false, "completed" boolean NOT NULL DEFAULT false, PRIMARY KEY ("id") , UNIQUE ("id"));
CREATE OR REPLACE FUNCTION "nornir_events"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_nornir_events_task_executions_updated_at"
BEFORE UPDATE ON "nornir_events"."task_executions"
FOR EACH ROW
EXECUTE PROCEDURE "nornir_events"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_nornir_events_task_executions_updated_at" ON "nornir_events"."task_executions" 
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;
