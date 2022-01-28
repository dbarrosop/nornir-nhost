from nornir.core import Nornir
from nornir.init_nornir import InitNornir
import pytest
from _pytest.fixtures import SubRequest

from nornir_nhost.plugins.processors import SaveToGraphql


@pytest.fixture(scope="session", autouse=True)
def nr(request: SubRequest) -> Nornir:
    """Initializes nornir"""
    return InitNornir("tests/config.yaml")


@pytest.fixture(scope="session", autouse=True)
def processor(request: SubRequest) -> SaveToGraphql:
    """Initializes nornir"""
    url = "http://localhost:1337/v1/graphql"
    nhost_admin_secret = "nhost-admin-secret"
    return SaveToGraphql(url, nhost_admin_secret)
