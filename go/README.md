
## OpenAPI client

```
rm -rf /Users/keiichi.hirobe/repos/package-test/go/gen
docker run --rm -v "/Users/keiichi.hirobe/repos/package-test:/local" --pull=always openapitools/openapi-generator-cli:latest-release generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g go \
                -o local/go/gen \
                --git-repo-id=package-test \
                --git-user-id=KeiichiHirobe \
                --global-property "modelTests=false,apiTests=false" \
                --additional-properties packageName=streamingapitest
```

To get the modules, you should set up the following.

```
    go env -w GOPRIVATE="github.com/KeiichiHirobe/*"
    git config --global url."ssh://git@github.com/KeiichiHirobe/".insteadOf "https://github.com/KeiichiHirobe/"
```

