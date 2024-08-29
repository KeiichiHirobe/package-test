repo_root := $(shell git rev-parse --show-toplevel)
ver := v7.8.0
git_repo_id := package-test
git_user_id := KeiichiHirobe
# should be lower-case
npm_scope := keiichihirobe

all: go-gen python-gen typescript-fetch-gen

.PHONY: go-clean
go-clean:
	rm -rf go/gen

.PHONY: go-gen
go-gen: go-clean
	docker run --rm -v "${repo_root}:/local" openapitools/openapi-generator-cli:${ver} generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g go \
                -o local/go/gen \
                -t local/go/custom_template \
                --git-repo-id=${git_repo_id} \
                --git-user-id=${git_user_id} \
                --global-property "modelTests=false,apiTests=false" \
                --additional-properties packageName=streamingapitest && \
	mv ${repo_root}/go/gen/go.mod ${repo_root}/go.mod && \
	mv ${repo_root}/go/gen/go.sum ${repo_root}/go.sum

.PHONY: python-clean
python-clean:
	rm -rf python/gen

.PHONY: python-gen
python-gen: python-clean
	docker run --rm -v "${repo_root}:/local" openapitools/openapi-generator-cli:${ver} generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g python \
                -o local/python/gen \
                --git-repo-id=${git_repo_id} \
                --git-user-id=${git_user_id} \
                --library asyncio \
                --global-property "modelTests=false,apiTests=false" \
                --additional-properties packageName=streamingapitest

.PHONY: typescript-fetch-clean
typescript-fetch-clean:
	rm -rf typescript-fetch/gen

.PHONY: typescript-fetch-gen
typescript-fetch-gen: typescript-fetch-clean
	docker run --rm -v "${repo_root}:/local" openapitools/openapi-generator-cli:${ver} generate \
                -i local/openapi-spec/chatbots_api.yml \
                -g typescript-fetch \
                -o local/typescript-fetch/gen \
                -t local/typescript-fetch/custom_template \
                --git-repo-id=${git_repo_id} \
                --git-user-id=${git_user_id} \
                --additional-properties npmName=@${npm_scope}/streaming-api-test
