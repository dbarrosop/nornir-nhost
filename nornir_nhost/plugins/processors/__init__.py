import json

from nornir.core.inventory import Host
from nornir.core.task import AggregatedResult, MultiResult, Task

from gql import gql, Client
from gql.transport.aiohttp import AIOHTTPTransport


class SaveToGraphql:
    def __init__(self, url: str, hasura_admin_secret: str) -> None:
        transport = AIOHTTPTransport(
            url=url, headers={"x-hasura-admin-secret": hasura_admin_secret}
        )
        self.client = Client(transport=transport)

    def task_started(self, task: Task) -> None:
        params = json.dumps(task.params)

        query = gql(
            """
            mutation CreateEvent($name: String = "", $args: jsonb = "") {
              insert_nornir_events_task_executions_one(object: {args: $args, name: $name}) {
                id
              }
            }
            """
        )
        result = self.client.execute(
            query, variable_values={"name": task.name, "args": params}
        )
        self.event_id = result["insert_nornir_events_task_executions_one"]["id"]

    def task_completed(self, task: Task, result: AggregatedResult) -> None:
        objects = ", ".join(
            [
                f'{{host: "{host}", success: {not v.failed}, task: "{self.event_id}"}}'
                for host, v in result.items()
            ]
        )
        query = gql(
            f"""
            mutation UpdateEvent($success: Boolean = false, $id: uuid = "") {{
              update_nornir_events_task_executions_by_pk(
                  pk_columns: {{id: $id}},
                  _set: {{completed: true, success: $success}}) {{
                id
              }}

              insert_nornir_events_task_instance(objects: [{objects}]) {{
                affected_rows
              }}
            }}
            """
        )
        self.client.execute(
            query, variable_values={"id": self.event_id, "success": not result.failed}
        )

    def task_instance_started(self, task: Task, host: Host) -> None:
        return

    def task_instance_completed(
        self, task: Task, host: Host, results: MultiResult
    ) -> None:
        return

    def subtask_instance_started(self, task: Task, host: Host) -> None:
        return

    def subtask_instance_completed(
        self, task: Task, host: Host, result: MultiResult
    ) -> None:
        return
