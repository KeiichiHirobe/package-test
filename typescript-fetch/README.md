
## OpenAPI client

https://openapi-generator.tech/docs/generators/typescript-fetch/
https://github.com/OpenAPITools/openapi-generator/blob/master/samples/client/petstore/typescript-fetch/builds/with-npm-version/package.json

Name of package.json should not be upper-case, so I needed to change it to lower-case.

```
rm -rf /Users/keiichi.hirobe/repos/package-test/typescript-fetch/gen
docker run --rm -v "/Users/keiichi.hirobe/repos/package-test:/local" openapitools/openapi-generator-cli:v7.8.0 generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g typescript-fetch \
                -o local/typescript-fetch/gen \
                -t local/typescript-fetch/custom_template \
                --git-repo-id=package-test \
                --git-user-id=KeiichiHirobe \
                --additional-properties npmName=@keiichihirobe/streaming-api-test
```

I had to change package.json like this because the node package is not in the top directory of this repository

```
  "repository": {
    "type": "git",
    "url": "https://github.com/KeiichiHirobe/package-test.git",
    "directory": "typescript-fetch/gen"
  },
```

I used a custom template to adjust generated code. See https://openapi-generator.tech/docs/templating#modifying-templates

Template files are based on https://github.com/OpenAPITools/openapi-generator/tree/v7.8.0/modules/openapi-generator/src/main/resources/typescript-fetch, the commit for customize is at https://github.com/KeiichiHirobe/package-test/commit/b51c76e0accf88058e14d3bcd8b3dec05f99f6c1

## NPM
https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry

https://zenn.dev/moneyforward/articles/20230620-github-packages


You should just update ~/.npmrc

```
//npm.pkg.github.com/:_authToken=ghp_xxxxxxx
@keiichihirobe:registry=https://npm.pkg.github.com
```


To publish to GitHub Package, just

```
npm publish
```

Accoreding to https://docs.npmjs.com/cli/v10/configuring-npm/package-json#git-urls-as-dependencies, npm does not support to specify subdirectory in git urls as dependency.
So if your module you want to publish as a package is in subdirectory you should use npm.

## Client

In client side, you should also update ~/.npmrc

## Streaming API Client

All functions in the generated client code try to parse the response, so I added a new function. I just copid the original function and changed it to return the response before parsing the body of it.


### Source code reading for Node.js

Node.js supported `fetch` since 2022, and `response.body` returns a [ReadableStream](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API/Using_readable_streams). As long as you use asynchronous iteration to read the response body, you don't need additional consideration to release resources. [When the response body has been fully read, the stream will be closed](https://github.com/nodejs/undici/blob/57f1b4e636b84ceeef4f048ce26d2c2348479727/lib/web/fetch/index.js#L1984-L1991) and when the caller decides to exit iteration prematurely, [the return method of the iterator will be called, and it will close the stream](https://github.com/nodejs/node/blob/67357ba8ff3d71f837a100aacd76e5ed3b15592b/lib/internal/webstreams/readablestream.js#L547-L556). We can expect [the implementation of `fetch`](https://github.com/nodejs/undici/tree/main) closes/releases the underlining connection properly when the stream is closed.

### Example

```
import { ChatApi } from "@keiichihirobe/streaming-api-test";

async function fetchStream() {
    const api = new ChatApi();
    const response = await api.testStreamGetWithoutPreloadContent();
    console.log(`Status Code: ${response.status}`);

    if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
    }

    if (response.body === null) {
        throw new Error(`HTTP response.body is null`);
    }

    const decoder = new TextDecoder('utf-8');

    let buffer = '';
    for await (const chunk of response.body) {
        // Decode the chunk of data into a string
        buffer += decoder.decode(chunk, { stream: true });
        // Split the buffer into lines
        let lines = buffer.split('\n');
        // The last line might be incomplete, so keep it in the buffer
        buffer = lines.pop() ?? '';
        // Process each complete line
        for (const line of lines) {
            console.log(line)
        }
    }
}

fetchStream().catch(console.error);
```
