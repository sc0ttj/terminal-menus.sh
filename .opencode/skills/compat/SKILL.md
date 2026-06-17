---
name: compat
description: Run shell compatibility and syntax checks. Use when the user asks to check syntax, verify ash/bash compatibility, run the pty form test, or run shell compatibility tests.
---

# Compatibility Checks

Run syntax verification and pty-based functional tests under both bash and ash.

## Syntax check (bash + ash)

```bash
bash -n terminal-menus.sh && echo "bash OK" && ash -n terminal-menus.sh && echo "ash OK"
```

## Shell compatibility test suite

Runs syntax checks + pty form test + all widget integration tests under both shells:

```bash
./test/test_shell_compat.sh
```

## Pty-based form test

```bash
python3 test/test_form_pty.sh
```

Run under a specific shell:

```bash
SHELL=ash  python3 test/test_form_pty.sh
SHELL=bash python3 test/test_form_pty.sh
```

## ShellCheck (aspirational, not enforced in CI)

```bash
shellcheck terminal-menus.sh
```
