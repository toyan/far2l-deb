# Сборка far2l-portable используя докер

## Простой вариант: Сборка непосредственно на целевой платформе

Официальная инструкция по установке докера https://docs.docker.com/engine/install 

Для сборки можно создать build.sh такого содержимого
```sh
docker build -t tmp-far2l-portable -<<END_TEXT
  FROM ubuntu:20.04 as builder

  ENV DEBIAN_FRONTEND noninteractive

  RUN apt-get update \
    && apt-get install -y wget gawk m4 libwxgtk3.0-gtk3-dev libx11-dev libxi-dev libpcre3-dev libxerces-c-dev libspdlog-dev libuchardet-dev libnss-mdns libssh-dev libssl-dev libsmbclient-dev libnfs-dev libneon27-dev cmake g++ git patchelf \
    && git clone https://github.com/elfmz/far2l \
    && cd far2l \
    && wget --no-check-certificate https://raw.githubusercontent.com/unxed/far2l-deb/master/portable/tty_tweaks.patch \
    && git apply tty_tweaks.patch \
    && mkdir _build \
    && cd _build \
    && cmake -DUSEWX=no -DLEGACY=no -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . -j$(nproc --all) \
    && make install \
    && cd install/ \
    && wget https://github.com/unxed/far2l-deb/raw/master/portable/autonomizer.sh \
    && chmod +x autonomizer.sh \
    && ./autonomizer.sh \
    && cd .. \
    && mv install far2l_portable \
    && git clone https://github.com/megastep/makeself.git \
    && makeself/makeself.sh far2l_portable far2l_portable.run far2l ./far2l

  FROM ubuntu:20.04
  COPY --from=builder /far2l/_build/far2l_portable.run /far2l_portable.run
END_TEXT

docker run -v `pwd`:/out tmp-far2l-portable cp /far2l_portable.run /out

```

## Сложный вариант: Кроссплатформенная сборка при помощи buildx
Взято в том числе отсюда: https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

### Устанавливаем сборочные образы и Создаем билдер
```sh
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use
```

### Создаем Dockerfile
```Dockerfile
FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y wget gawk m4 libwxgtk3.0-gtk3-dev libx11-dev libxi-dev libpcre3-dev libxerces-c-dev libspdlog-dev libuchardet-dev libnss-mdns libssh-dev libssl-dev libsmbclient-dev libnfs-dev libneon27-dev cmake g++ git patchelf \
  && git clone https://github.com/elfmz/far2l \
  && cd far2l \
  && wget --no-check-certificate https://raw.githubusercontent.com/unxed/far2l-deb/master/portable/tty_tweaks.patch \
  && git apply tty_tweaks.patch \
  && mkdir _build \
  && cd _build \
  && cmake -DUSEWX=no -DLEGACY=no -DCMAKE_BUILD_TYPE=Release .. \
  && cmake --build . -j$(nproc --all) \
  && make install \
  && cd install/ \
  && wget https://github.com/unxed/far2l-deb/raw/master/portable/autonomizer.sh \
  && chmod +x autonomizer.sh \
  && ./autonomizer.sh \
  && cd .. \
  && mv install far2l_portable \
  && git clone https://github.com/megastep/makeself.git \
  && makeself/makeself.sh far2l_portable far2l_portable.run far2l ./far2l

FROM scratch
COPY --from=builder /far2l/_build/far2l_portable.run /far2l_portable.run
```

### Запускам сборку для выбранной платформы
```sh
docker buildx build --platform=linux/amd64 -t tmp-far2l-portable-x86 --load . 
```
или

```sh
docker buildx build --platform=linux/arm64 -t tmp-far2l-portable-arm64 --load . 
```

### Извлекаем сборку из собранного образа
```sh
docker save tmp-far2l-portable-x86 | tar xO --wildcards '*.tar'  | tar xv far2l_portable.run
```

```sh
docker save tmp-far2l-portable-arm64 | tar xO --wildcards '*.tar'  | tar xv far2l_portable.run
```

