
## OpenAPI client
https://openapi-generator.tech/docs/generators/go


```
rm -rf /Users/keiichi.hirobe/repos/package-test/go/gen
docker run --rm -v "/Users/keiichi.hirobe/repos/package-test:/local" openapitools/openapi-generator-cli:v7.8.0 generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g go \
                -o local/go/gen \
                --git-repo-id=package-test \
                --git-user-id=KeiichiHirobe \
                --global-property "modelTests=false,apiTests=false" \
                --additional-properties packageName=streamingapitest
```

You should move go.mod/go.sum manually to the top directory because Go basically assume the files are located on top directory of the repository.

## Client

To get the modules, you should set up the following.

```
    go env -w GOPRIVATE="github.com/KeiichiHirobe/*"
    git config --global url."ssh://git@github.com/KeiichiHirobe/".insteadOf "https://github.com/KeiichiHirobe/"
```

