
## OpenAPI client
https://openapi-generator.tech/docs/generators/python


```
rm -rf /Users/keiichi.hirobe/repos/package-test/python/gen
docker run --rm -v "/Users/keiichi.hirobe/repos/package-test:/local" openapitools/openapi-generator-cli:v7.8.0 generate \
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

## Streaming API Client

### Source code reading for aiohttp.client

When a response body has been fully read, [the underlying connection is automatically released](https://github.com/aio-libs/aiohttp/blob/48a5e07ad833bd1a8fcb2ce6f85a41ad0cef9dc6/aiohttp/client_reqrep.py#L969-L980)

Even if you stop reading a response body, the destructor will try to [release the underlying connection](https://github.com/aio-libs/aiohttp/blob/48a5e07ad833bd1a8fcb2ce6f85a41ad0cef9dc6/aiohttp/client_reqrep.py#L838-L853)

As far as I read the implementation of [_release](https://github.com/aio-libs/aiohttp/blob/48a5e07ad833bd1a8fcb2ce6f85a41ad0cef9dc6/aiohttp/connector.py#L663-L665)/[should_close](https://github.com/aio-libs/aiohttp/blob/48a5e07ad833bd1a8fcb2ce6f85a41ad0cef9dc6/aiohttp/client_proto.py#L57), it seems like the underlying connection will be closed instead of released when the response body has not been fully read. 

However, it would be better to close the connection explicitly in case an exception occurs within the implementation of the library reading the body or on the application side, as in the implementation of the [read function](https://github.com/aio-libs/aiohttp/blob/48a5e07ad833bd1a8fcb2ce6f85a41ad0cef9dc6/aiohttp/client_reqrep.py#L1062-L1071).


### Example


```
import asyncio
import codecs
from streamingapitest.api.chat_api import ChatApi

async def coro():
    chat_api = ChatApi()
    res = await chat_api.test_stream_get_without_preload_content()
    # We need this decoder to handle incomplete multibyte characters
    decoder = codecs.getincrementaldecoder("utf-8")()

    try:
        buffer: str = ""
        # `async for line in res.content:` is useful because it provides iteration by line, but the limit length of chunk size is 2^17 byte, and it is too small for image size.
        # Instead use `iter_chunked`
        # https://github.com/aio-libs/aiohttp/blob/48a5e07ad833bd1a8fcb2ce6f85a41ad0cef9dc6/aiohttp/streams.py#L76
        # https://github.com/aio-libs/aiohttp/blob/48a5e07ad833bd1a8fcb2ce6f85a41ad0cef9dc6/aiohttp/streams.py#L346-L347
        async for chunk in res.content.iter_chunked(65536):
            buffer += decoder.decode(chunk)
            lines = buffer.split("\n")
            buffer = lines.pop()
            for line in lines:
                trimmed = line.rstrip()
                print(trimmed)

    except BaseException:
        res.close()
        raise

    await chat_api.api_client.close()

asyncio.run(coro(), debug=True)
```
