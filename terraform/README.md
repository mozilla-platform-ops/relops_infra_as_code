# terraform

## getting started

### os x

```
brew install pre-commit
brew install terraform-docs

pre-commit install
```

## structure

We manage state per-module. This allows us to work with some isolation to avoid
conflicts with other people's changes and reduces the number of objects synced
during `terraform apply`.

### creating new modules

```
./create_state.sh "descriptive_name_for_what_this_module_does"
```

Then follow the directions given.
