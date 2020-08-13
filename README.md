
# Локальный запуск тесткейсов
1. Устаносить зависимости (только для первого запуска):
    - pip3 install robotframework
    - pip3 install neocore
    - pip3 install requests

(pip3 заменить на соответсвующий менеджер пакетов python в системе).

При этом должен быть запущен dev-env с тестируемым окружением.

2. Выпольнить `make run`

3. Логи будут доступны в папке artifacts/ после завершения тестов с любым из статусов.

### Запуск произвольного тесткейса
Для запуска произвольного тесткейса нужно выполнить команду: 
`robot --timestampoutputs --outputdir artifacts/ robot/testsuites/integration/<testsuite name>.robot `

Для запуска доступны следущие сценарии:
 * acl_basic.robot - базовый ACL
 * acl_extended.robot - extended ACL
 * object_complex.robot - операции над простым объектом
 * object_simple.robot - операции над большим объектом


### Запуск тесткейсов в докере
1. Задать переменные окружения для работы с dev-env:
```
    export REG_USR=<registry_user>
    export REG_PWD=<registry_pass>
    export JF_TOKEN=<JF_token>
```

2. Выполнить `make build`

3. Выполнить `make run_docker`

4. Логи будут доступны в папке artifacts/ после завершения тестов с любым из статусов.

### Запуск тесткейсов в докере с произвольными коммитами

На данный момент доступны произовльные коммиты для NeoFS Node и NeoFS CLI.
Для этого достаточно задать переменные окружения перед запуском `make build`.
```
export BUILD_NEOFS_NODE=<commit or branch>
export BUILD_CLI=<commit or branch>
```

## README #

Чтобы тесты из этого репозитория были доступны к запуску из Drone CI,
они должны быть упакованы в docker-имадж. Это делается в рамках CI,
сконфигурированного в этом репозитории. Вся сборка "тестового образа"
описывается в файлах `Dockerfile` и `.drone.yml` и осуществляется на
каждый пуш в master.

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

#### Локальная сборка
Чтобы локально собрать образ, нужно, стоя в корне репо, выполнить
команду:
```
drone exec --trusted --secret-file=secrets.txt --volume /var/run/docker.sock
```
В результате будет прогнан полный пайплайн, за исключением пуша образа в
docker registry. Чтобы запушить образ, нужно указать пароль к реджистри в
файле `secrets.txt`.
<p align="center">
  <img src="./.github/logo.svg" width="500px" alt="FrostFS">
</p>

<p align="center">
  <a href="https://frostfs.info">FrostFS</a> is a decentralized distributed object storage integrated with the <a href="https://neo.org">NEO Blockchain</a>.
</p>

---
[![Report](https://goreportcard.com/badge/github.com/TrueCloudLab/frostfs-node)](https://goreportcard.com/report/github.com/TrueCloudLab/frostfs-node)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/TrueCloudLab/frostfs-node?sort=semver)
![License](https://img.shields.io/github/license/TrueCloudLab/frostfs-node.svg?style=popout)

# Overview

FrostFS Nodes are organized in a peer-to-peer network that takes care of storing
and distributing user's data. Any Neo user may participate in the network and
get paid for providing storage resources to other users or store their data in
FrostFS and pay a competitive price for it.

Users can reliably store object data in the FrostFS network and have a transparent
data placement process due to a decentralized architecture and flexible storage
policies. Each node is responsible for executing the storage policies that the
users select for geographical location, reliability level, number of nodes, type
of disks, capacity, etc. Thus, FrostFS gives full control over data to users.

Deep [Neo Blockchain](https://neo.org) integration allows FrostFS to be used by
dApps directly from
[NeoVM](https://docs.neo.org/docs/en-us/basic/technology/neovm.html) on the
[Smart Contract](https://docs.neo.org/docs/en-us/intro/glossary.html)
code level. This way dApps are not limited to on-chain storage and can
manipulate large amounts of data without paying a prohibitive price.

FrostFS has a native [gRPC API](https://github.com/TrueCloudLab/frostfs-api) and has
protocol gateways for popular protocols such as [AWS
S3](https://github.com/TrueCloudLab/frostfs-s3-gw),
[HTTP](https://github.com/TrueCloudLab/frostfs-http-gw),
[FUSE](https://wikipedia.org/wiki/Filesystem_in_Userspace) and
[sFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol) allowing
developers to integrate applications without rewriting their code.

# Supported platforms

Now, we only support GNU/Linux on amd64 CPUs with AVX/AVX2 instructions. More
platforms will be officially supported after release `1.0`.

The latest version of frostfs-node works with frostfs-contract
[v0.16.0](https://github.com/TrueCloudLab/frostfs-contract/releases/tag/v0.16.0).

# Building

To make all binaries you need Go 1.18+ and `make`:
```
make all
```
The resulting binaries will appear in `bin/` folder.

To make a specific binary use:
```
make bin/frostfs-<name>
```
See the list of all available commands in the `cmd` folder.

## Building with Docker

Building can also be performed in a container:
```
make docker/all                     # build all binaries
make docker/bin/frostfs-<name> # build a specific binary
```

## Docker images

To make docker images suitable for use in [frostfs-dev-env](https://github.com/TrueCloudLab/frostfs-dev-env/) use:
```
make images
```

# Contributing

Feel free to contribute to this project after reading the [contributing
guidelines](CONTRIBUTING.md).

Before starting to work on a certain topic, create a new issue first, describing
the feature/topic you are going to implement.

# Credits

FrostFS is maintained by [True Cloud Lab](https://github.com/TrueCloudLab/) with the help and
contributions from community members.

Please see [CREDITS](CREDITS.md) for details.

# License

- [GNU General Public License v3.0](LICENSE)



* Repo owner or admin
* Other community or team contact