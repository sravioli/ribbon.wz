### Summary

Describe the ribbon.wz documentation change.

### Documentation Changed

List the README, examples, contributing guide, issue templates, pull request
templates, or annotation docs changed by this pull request.

### Reader Impact

Explain who benefits from this documentation change:

- Users building formatted status or tab title text.
- Users configuring colors, attributes, or raw format items.
- Contributors changing ribbon.wz internals.

### Examples Touched

```lua
-- builder, format, or setup example changed by this pull request
```

### Behavior Change

- [ ] Documentation only
- [ ] Documents an existing behavior
- [ ] Documents a new behavior

If this documents a new behavior, link to the implementation pull request or
commit.

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

