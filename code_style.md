# ArjanCodes Python Code Style Guide (2024 Updated)

This guide reflects ArjanCodes' current Python style principles and modern best practices as of 2024.

## 1. Structural Philosophy: "Less is More"

Arjan often argues that Python developers over-engineer with classes when simple functions would suffice.

* **Prefer Functions Over Classes:** If a class only has an `__init__` and one method, it should probably just be a function.
* **Composition over Inheritance:** Instead of deep inheritance trees, use composition. Pass objects into other objects to build complex behavior.
* **Single Responsibility Principle (SRP):** A function or class should do exactly one thing. If you find yourself using the word "and" to describe what a function does, it’s too big.

## 1. Project Structure & Modern Setup

**Modern Python Project Layout:**
```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       └── modules...
├── tests/
├── docs/
├── pyproject.toml
└── README.md
```

**Key Configuration:**
- Use `pyproject.toml` for modern Python project configuration
- Isolate source code in `src/` directory
- Separate tests, documentation, and configuration
- Use proper package structure with `__init__.py` files

## 2. Structural Philosophy: "Less is More"

* **Prefer Functions Over Classes:** If a class only has an `__init__` and one method, it should probably just be a function
* **Composition over Inheritance:** Use composition instead of deep inheritance trees
* **Single Responsibility Principle (SRP):** A function or class should do exactly one thing
* **Avoid "God Objects":** Break down large classes into focused, single-responsibility components

## 3. Readability & Flow Control

**Guard Clauses:** Check for error/exit conditions first and return early
```python
def process(data):
    if data is None or "value" not in data:
        return
    # logic here...
```

**Registry Pattern:** Replace long if-elif chains with dictionaries
```python
operations = {
    "add": add_function,
    "multiply": multiply_function,
}
result = operations.get(operation, default_function)()

## 3. Modern Python Features (Python 3.9+)

**Python 3.12+ Generics:**
```python
# Modern syntax - replaces old TypeVar approach
def func[T]()-> T:
    return T()

# Bounded types
class Container[T: Mapping]:
    pass

# Constrained types  
class Calculator[T: (int, float)]:
    pass
```

**Dictionary Operators:**
```python
# Python 3.9+ merge and update
dict1 = {"a": 1, "b": 2}
dict2 = {"b": 3, "c": 4}
merged = dict1 | dict2  # {'a': 1, 'b': 3, 'c': 4}
```

**Pattern Matching:**
```python
# Python 3.10+ match statement
match command:
    case {"type": "move", "x": x, "y": y}:
        move(x, y)
    case {"type": "quit"}:
        quit()
```

**Assignment Expressions:**
```python
# Walrus operator for cleaner code
if (n := len(items)) > 10:
    print(f"List is too long ({n} elements)")
```

**Dataclasses:**
```python
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float
    # Automatically generates __init__, __repr__, __eq__
```

**Type Annotations:**
```python
from typing import List, Dict, Optional

def process_items(items: List[str]) -> Dict[str, int]:
    return {item: len(item) for item in items}
```

**Pathlib over os.path:**
```python
from pathlib import Path

# Modern approach
current_file = Path(__file__)
parent_dir = current_file.parent
config_path = parent_dir / "config" / "settings.json"
```

**Logging over Print:**
```python
import logging

logger = logging.getLogger(__name__)
logger.info("Processing started")
logger.error("Failed to process item", exc_info=True)

## 5. Defensive & Pythonic Programming

**EAFP over LBYL:** Use try/except instead of excessive if checks
```python
# Good: Pythonic approach
try:
    value = my_dict[key]
except KeyError:
    value = default_value
```

**Dependency Injection:** Pass objects as arguments instead of creating inside functions
```python
# Good: Easy to test
def process_data(data: str, validator: Validator) -> bool:
    return validator.validate(data)
```

**Immutable by Default:** Use frozen dataclasses and Final types
```python
from typing import Final
from dataclasses import dataclass

@dataclass(frozen=True)
class Config:
    name: str
    
MAX_SIZE: Final = 100
```

**Error Handling with Context:**
```python
# Python 3.11+ exception groups and add_note()
try:
    risky_operation()
except ValueError as e:
    e.add_note("Additional context about the error")
    raise

## 6. Code Quality & Testing

**Testing:**
- Use `pytest` for comprehensive testing
- Implement test-driven development (TDD)
- Write unit tests for individual components
- Use integration tests for system validation

**Code Smell Elimination:**
- Break down "god objects" into focused components
- Eliminate duplicate code (DRY principle)
- Replace "magic numbers" with named constants
- Flatten nested conditionals using `any()`/`all()`
- Refactor "long methods" into smaller functions

**Common Pitfalls to Avoid:**
- Floating-point comparisons (use `math.isclose()`)
- Mutable default arguments (use `None`)
- Variable scope issues in loops/lambdas
- Broad exception catching (catch specific exceptions)

## 6. Core Principles Summary

1. **Simplicity First** - Choose the simplest solution that works
2. **Readability Matters** - Code should be self-documenting  
3. **Test Thoroughly** - Comprehensive testing prevents regressions
4. **Stay Current** - Adopt modern Python features for cleaner code
5. **Design Patterns** - Use patterns strategically, not as golden hammers

---

**Would you like me to take a specific piece of your code and "Arjan-ify" it by applying these refactoring principles?**
