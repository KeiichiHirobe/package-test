# streamingapitest.ChatApi

All URIs are relative to *http://localhost:3978*

Method | HTTP request | Description
------------- | ------------- | -------------
[**test_stream_get**](ChatApi.md#test_stream_get) | **GET** /test/stream | get streaming data


# **test_stream_get**
> str test_stream_get()

get streaming data

get streaming data 

### Example


```python
import streamingapitest
from streamingapitest.rest import ApiException
from pprint import pprint

# Defining the host is optional and defaults to http://localhost:3978
# See configuration.py for a list of all supported configuration parameters.
configuration = streamingapitest.Configuration(
    host = "http://localhost:3978"
)


# Enter a context with an instance of the API client
async with streamingapitest.ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = streamingapitest.ChatApi(api_client)

    try:
        # get streaming data
        api_response = await api_instance.test_stream_get()
        print("The response of ChatApi->test_stream_get:\n")
        pprint(api_response)
    except Exception as e:
        print("Exception when calling ChatApi->test_stream_get: %s\n" % e)
```



### Parameters

This endpoint does not need any parameter.

### Return type

**str**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/plain

### HTTP response details

| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** | Successfully get streaming data  |  * Transfer-Encoding - chunked <br>  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

