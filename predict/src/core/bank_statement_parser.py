from abc import ABC, abstractmethod
from typing import Any


class BankStatementParser(ABC):

    @abstractmethod
    def is_from_bank(self, filename: str) -> bool:
        ...

    @abstractmethod
    def parse(self, any: str) -> tuple[Any, str, float]:
        ...
