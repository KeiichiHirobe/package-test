
## OpenAPI client
https://openapi-generator.tech/docs/generators/python


```
rm -rf /Users/keiichi.hirobe/repos/package-test/python/gen
docker run --rm -v "/Users/keiichi.hirobe/repos/package-test:/local" --pull=always openapitools/openapi-generator-cli:latest-release generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g python \
                -o local/python/gen \
                --git-repo-id=package-test \
                --git-user-id=KeiichiHirobe \
                --library asyncio \
                --global-property "modelTests=false,apiTests=false" \
                --additional-properties packageName=streamingapitest
```


## Client

https://python-poetry.org/docs/dependency-specification/#git-dependencies

You can specify subdirectory like this.

```
poetry add "git+https://github.com/KeiichiHirobe/package-test#subdirectory=python/gen"
```


To get the modules, you should set up the following.

```
    git config --global url."ssh://git@github.com/KeiichiHirobe/".insteadOf "https://github.com/KeiichiHirobe/"
```

