# dockerhub2oci
Simple shell tool to pull from DockerHub and create an OCI image

*Warning* This tool is still very basic and under development, no documentation exists yet. Use at your own risk!

## Known Issues

* No handling of opaque whiteout files (explicit whiteouts are handled)
* Untested with registries other than DockerHub
* Limited parameter handling
* No error handling
* No documentation
* Does not extract content of `/dev/`.

## Dependencies

* aria2c
* jq
* curl
* tar
