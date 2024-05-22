variable "WITH_LATEST_TAG" {
  default = false
}

variable "BAGETTER_IMAGE_VER" {
  default = "1.4.1"
}

variable "BAGET_FLAVORS" {
  default = ["patched"]
}

variable "flavor_tags" {
  default = [for f in BAGET_FLAVORS : f == "" ? BAGETTER_IMAGE_VER : "${BAGETTER_IMAGE_VER}-${f}"]
}

function "all_tags" {
  params = [with_latest]
  result = concat(flavor_tags, with_latest ? ["latest"] : [])
}

group "default" {
  targets = ["bagetter-default", "bagetter-alpine"]
}

target "bagetter-default" {
  context = "./build"
  dockerfile="Dockerfile.default"
  args = {
    BAGETTER_VER = "${BAGETTER_IMAGE_VER}"
    BAGETTER_TAG = "v${BAGETTER_IMAGE_VER}"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v7",
  ]
  tags = concat(
    formatlist("toras9000/bagetter-mp:%s",             all_tags(WITH_LATEST_TAG)),
    formatlist("ghcr.io/toras9000/docker-bagetter:%s", all_tags(WITH_LATEST_TAG)),
  )
}

target "bagetter-alpine" {
  context = "./build"
  dockerfile="Dockerfile.alpine"
  args = {
    BAGETTER_VER = "${BAGETTER_IMAGE_VER}"
    BAGETTER_TAG = "v${BAGETTER_IMAGE_VER}"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v7",
  ]
  tags = concat(
    formatlist("toras9000/bagetter-mp:%s-alpine",             all_tags(WITH_LATEST_TAG)),
    formatlist("ghcr.io/toras9000/docker-bagetter:%s-alpine", all_tags(WITH_LATEST_TAG)),
  )
}

