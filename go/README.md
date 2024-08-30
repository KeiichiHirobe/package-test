
## OpenAPI client
https://openapi-generator.tech/docs/generators/go


```
rm -rf /Users/keiichi.hirobe/repos/package-test/go/gen
docker run --rm -v "/Users/keiichi.hirobe/repos/package-test:/local" openapitools/openapi-generator-cli:v7.8.0 generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g go \
                -o local/go/gen \
                -t local/go/custom_template \
                --git-repo-id=package-test \
                --git-user-id=KeiichiHirobe \
                --global-property "modelTests=false,apiTests=false" \
                --additional-properties packageName=streamingapitest
```

You should move go.mod/go.sum manually to the top directory because Go basically assume the files are located on top directory of the repository.

I used a custom template to adjust generated code. See https://openapi-generator.tech/docs/templating#modifying-templates

Template files are based on https://github.com/OpenAPITools/openapi-generator/tree/v7.8.0/modules/openapi-generator/src/main/resources/go, the commit for customize is at https://github.com/KeiichiHirobe/package-test/commit/eaa6dbb2514f135f131ab34cebc39a3e28b87f58

## Client

To get the modules, you should set up the following.

```
    go env -w GOPRIVATE="github.com/KeiichiHirobe/*"
    git config --global url."ssh://git@github.com/KeiichiHirobe/".insteadOf "https://github.com/KeiichiHirobe/"
```

## Streaming API Client


### Source code reading for net/http

When a response body has been fully read, [the underlying connection is automatically released](https://github.com/golang/go/blob/aeac0b6cbfb42bc9c9301913a191bb09454d316a/src/net/http/transport.go#L2326-L2334).

You should call `response.Body.Close()` explicitly to release/close connection when you stop reading the response body.
Interestingly, in such case, [net/http tries to read the body up to 262144 bytes and then release the connection if all the body has been read, and close the connection if not](https://github.com/golang/go/blob/aeac0b6cbfb42bc9c9301913a191bb09454d316a/src/net/http/transfer.go#L985-L1003)

### Example

```
package main

import (
	"bufio"
	"context"
	"fmt"
	"os"

	openapiclient "github.com/KeiichiHirobe/package-test/go/gen"
)

func main() {

	configuration := openapiclient.NewConfiguration()
	apiClient := openapiclient.NewAPIClient(configuration)
	request := apiClient.ChatAPI.TestStreamGet(context.Background())
	_, r, err := request.ApiService.TestStreamGetExecuteWithoutPreloadContent(request)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		return
	}
	if r.StatusCode != 200 {
		fmt.Fprintf(os.Stderr, "StatusCode: %v\n", r.StatusCode)
		return
	}
	defer r.Body.Close()
	scanner := bufio.NewScanner(r.Body)
	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		return
	}
}

```
