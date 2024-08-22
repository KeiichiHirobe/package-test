
## OpenAPI client

https://openapi-generator.tech/docs/generators/typescript-fetch/
https://github.com/OpenAPITools/openapi-generator/blob/master/samples/client/petstore/typescript-fetch/builds/with-npm-version/package.json

Name of package.json should not be upper-case, so you should change it to lower-case.

```
rm -rf /Users/keiichi.hirobe/repos/package-test/gen
docker run --rm -v "/Users/keiichi.hirobe/repos/package-test:/local" --pull=always openapitools/openapi-generator-cli:latest-release generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g typescript-fetch \
                -o local/typescript-fetch/gen \
                --git-repo-id=package-test \
                --git-user-id=KeiichiHirobe \
                --additional-properties=npmName=@keiichihirobe/streaming-api-test
```

You have to change package.json manually like this because you can't specify repositry->directory.

```
  "repository": {
    "type": "git",
    "url": "https://github.com/KeiichiHirobe/package-test.git",
    "directory": "typescript-fetch/gen"
  },
```

## NPM
https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry

https://zenn.dev/moneyforward/articles/20230620-github-packages

You should just update ~/.npmrc

```
//npm.pkg.github.com/:_authToken=ghp_xxxxxxx
@keiichihirobe:registry=https://npm.pkg.github.com
```

Accoreding to https://docs.npmjs.com/cli/v10/configuring-npm/package-json#git-urls-as-dependencies, npm does not support to specify subdirectory for git urls as dependency.
So if your module you want to publish as a package is in subdirectory you should use npm.
