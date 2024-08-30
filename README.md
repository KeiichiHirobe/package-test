# What is this?

This repository is intended to generate client code for Go, Python, and TypeScript using `openapi-generator` based on the OpenAPI Spec of a virtual API that responds with [JSON Lines](https://jsonlines.org/) in a chunked transfer encoding format. The generated clients will be available for use from external repositories.

The version will be released with the same version as the API Spec via GitHub Actions. This repository is public, but it is intended to be managed in a private repository.

# Purpose

This repository was created to explore and verify the following three points to find better methods:

1. Manage packages for multiple programming languages in a single repository
   * Since packages are not located in the top directory of the repository, special considerations are required.
2. Use custom templates
   * `openapi-generator-cli` has a feature that allows customization of the generated code.
   * Consider how to manage customizations effectively.
3. Ensure that the client handles the streaming API appropriately.
   * In a streaming API, the response is split into chunks, so the generated code must not parse the response body.
   * Attention must be paid to prevent connection leaks on the client side using the generated code.

Please refer to the README in the directory of each language for detailed results. A supplement is provided only for point 3.

You may wonder if it's possible for the code generation tool to recognize that it is a streaming API and generate code that doesn't read the response body. However, I failed to achieve it even when I used [a good example from the OpenAPI-Specification issue discussion](https://github.com/OAI/OpenAPI-Specification/issues/1576#issuecomment-734513933), so it seems difficult.

In Python, the generated `test_stream_get_without_preload_content` function returns the response without reading the response body. For Go/Typescript, a custom template has been created to add a function with the suffix `without_preload_content` to match this name. The customization is very simple; it just copies the generated code and removes everything after the response parsing process so that it simply returns the response.

Additionally, there are points to be mindful of in the implementation on the application side using the generated code. Generally, the connection can be released when the response body is fully read, which usually occurs at the beginning of the application processing, and done by libraries behind the scene, but it is different for streaming APIs. For example, suppose an API sends four messages, and an exception occurs on the application side after receiving the first message, causing the remaining messages to be left unread. In this case, the connection status could be a. still in use, b. closed, or c. reused after reading the response. README under each language describes how this can be handled.

# How to update OpenAPI Spec

Update api version and just run

```
Make
````

It should generate the code, so just push it.

GHA creates a release tag and publishes the updated package to GitHub Package with the same version number as the API spec version. So, make sure to update the API spec version; otherwise, you might encounter a duplicated version error in GHA.

If, for some reason, you want to update without increasing the version, please make sure to delete them beforehand.

# How to update the version of the `openapi-generator`

When you update the version of the `openapi-generator`, you should update the custom templates as well. Just download the original template files you want to customize from GitHub and modify them as needed. Be sure to specify the version when obtaining the source code. For example, if the version is v7.8.0, download from https://github.com/OpenAPITools/openapi-generator/tree/v7.8.0/modules/openapi-generator/src/main/resources/

# Etc

For reference, below is an example implementation of a stream API server. It sends five messages as a response, one every second.


```python
import asyncio
from aiohttp import web
import json

async def stream_response(request):
    response = web.StreamResponse()
    response.headers["Content-Type"] = "text/plain"

    # send header
    # you should not change any header data after calling this
    await response.prepare(request)

    for i in range(4):
        chunk = f"Chunk {i}"
        payload = {"body": chunk, "event": "message"}
        text = json.dumps(payload) + "\n"
        await response.write(text.encode("utf-8"))
        await asyncio.sleep(1)

    # send finish
    payload = {"body": "finish!!!!", "event": "message"}
    text = json.dumps(payload) + "\n"
    await response.write(text.encode("utf-8"))

    # eof
    await response.write_eof()

    return response


app = web.Application()
app.router.add_get("/", stream_response)

if __name__ == "__main__":
    web.run_app(app, port=8888)

```