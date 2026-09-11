# Security policy

This is the security policy

## Reporting

- PR with fix
- Issue in github

## Best practicec

Use only on trusted input

## Known issues

### HTML injection

having something like
```
<script>alert('hello world');</script>
```
in the input file will have that in the output as well

### MarkDown injection

See HTML injection, but markdown instead
