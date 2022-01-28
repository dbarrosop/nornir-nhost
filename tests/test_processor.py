import random

from nornir.core import Nornir
from nornir.core.task import Task, Result

from nornir_nhost.plugins.processors import SaveToGraphql


def dummy_task(task: Task, some_arg: int, another_arg: str, blah: bool) -> Result:
    return Result(host=task.host)


def task_sometimes_fails(
    task: Task, some_arg: int, another_arg: str, blah: bool
) -> Result:
    if random.randint(0, 1):
        raise Exception("sad trombone")
    return Result(host=task.host)


def test_task_success(nr: Nornir, processor: SaveToGraphql) -> None:
    nr.data.reset_failed_hosts()
    r = nr.with_processors([processor]).run(
        dummy_task, some_arg=123213, another_arg="asdasdasd", blah=True
    )
    r.raise_on_error()


def test_task_fails(nr: Nornir, processor: SaveToGraphql) -> None:
    nr.data.reset_failed_hosts()
    r = nr.with_processors([processor]).run(
        dummy_task, some_arg=123213, another_arg="asdasdasd", blah=True, qwe=False
    )
    r.raise_on_error()


def test_task_fails_sometimes(nr: Nornir, processor: SaveToGraphql) -> None:
    nr.data.reset_failed_hosts()
    r = nr.with_processors([processor]).run(
        task_sometimes_fails, some_arg=123213, another_arg="asdasdasd", blah=True
    )
    r.raise_on_error()
