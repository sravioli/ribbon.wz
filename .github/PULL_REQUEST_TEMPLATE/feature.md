### Summary

Describe the new ribbon.wz feature and the user-facing formatted-text workflow
it enables.

### Motivation

Explain why this belongs in ribbon.wz. Focus on WezTerm format items, chainable
builders, attributes, colors, raw format segments, or status/tab title rendering.

### API Sketch

```lua
-- show intended builder, items, format, or setup usage
```

### Behavior

Describe how the feature behaves, including default options, color and attribute
handling, item order, atomic resets, raw format items, and failure cases.

### Compatibility

- [ ] Non-breaking
- [ ] Potentially breaking
- [ ] Breaking

If this is potentially breaking or breaking, explain the migration path.

### Tests

Describe the tests added or updated for this behavior.

### Documentation

Describe the README, examples, annotation, or template changes made for this
feature.

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

