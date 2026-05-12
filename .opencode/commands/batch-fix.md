# Batch Fix Orchestrator
Analyze @FIXES.md. For each unchecked item in the list:
1. **Analyze**: Read the code related to this specific fix.
2. **Branch**: Create a new git branch: `fix/[item-description]`.
3. **Implement**: Apply the fix according to the rules in @AGENTS.md.
4. **Verify**: Run `!shellcheck <file>` and any project tests to confirm it works.
5. **Finalise**: Commit the change, check the item off in @FIXES.md, and return to the main branch.
6. **Repeat**: Move to the next item until all are checked.

Once finished, list all the newly created branches.
