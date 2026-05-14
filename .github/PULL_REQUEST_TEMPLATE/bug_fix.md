### Summary

Describe the bug fixed in ribbon.wz and the user-visible formatted-text behavior
that changed.

### Reproduction

Provide the smallest setup that reproduced the issue.

```lua
-- ribbon builder or format item usage that reproduced the bug
```

### Root Cause

Explain why color resolution, attribute handling, text transforms, raw item
handling, atomic resets, or WezTerm formatting was wrong.

### Fix

Describe the implementation change and why it fixes the problem.

### Regression Test

Describe the regression test added or updated.

### Compatibility Impact

- [ ] Non-breaking
- [ ] Potentially breaking
- [ ] Breaking

If this changes behavior intentionally, explain why the new behavior is correct.

### Checklist

- [ ] The change is scoped to ribbon.wz.
- [ ] Public API changes are documented, if applicable.
- [ ] Format item, attribute, or chaining behavior is covered by tests, if applicable.
- [ ] Existing builder method semantics remain compatible.
- [ ] Required checks pass:
  - [ ] `busted --verbose`
  - [ ] `luacheck .`
  - [ ] `stylua --check .`
  - [ ] `selene --display-style=quiet .`

