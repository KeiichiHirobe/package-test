# \ChatAPI

All URIs are relative to *http://localhost:3978*

Method | HTTP request | Description
------------- | ------------- | -------------
[**TestStreamGet**](ChatAPI.md#TestStreamGet) | **Get** /test/stream | get streaming data



## TestStreamGet

> string TestStreamGet(ctx).Execute()

get streaming data



### Example

```go
package main

import (
	"context"
	"fmt"
	"os"
	openapiclient "github.com/KeiichiHirobe/package-test"
)

func main() {

	configuration := openapiclient.NewConfiguration()
	apiClient := openapiclient.NewAPIClient(configuration)
	resp, r, err := apiClient.ChatAPI.TestStreamGet(context.Background()).Execute()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error when calling `ChatAPI.TestStreamGet``: %v\n", err)
		fmt.Fprintf(os.Stderr, "Full HTTP response: %v\n", r)
	}
	// response from `TestStreamGet`: string
	fmt.Fprintf(os.Stdout, "Response from `ChatAPI.TestStreamGet`: %v\n", resp)
}
```

### Path Parameters

This endpoint does not need any parameter.

### Other Parameters

Other parameters are passed through a pointer to a apiTestStreamGetRequest struct via the builder pattern


### Return type

**string**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: text/plain

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints)
[[Back to Model list]](../README.md#documentation-for-models)
[[Back to README]](../README.md)

