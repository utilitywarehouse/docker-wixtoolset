FROM i386/debian:stable-slim

LABEL maintainer="itops@utilitywarehouse.co.uk"

# misc prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https sudo gnupg2 ca-certificates curl bsdtar procps
RUN dpkg --add-architecture i386
RUN curl https://dl.winehq.org/wine-builds/Release.key -o /tmp/Release.key && apt-key add /tmp/Release.key
RUN echo "deb https://dl.winehq.org/wine-builds/debian stable main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends --allow-unauthenticated winehq-stable

# Copy resources
ADD exelink.sh /tmp/
ADD pwrap waiton /usr/local/bin/

# winetricks
RUN curl -SL https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    > /usr/local/bin/winetricks && chmod +x /usr/local/bin/*

# wix
RUN mkdir -p /opt/wix/bin && \
    curl -SL https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311-binaries.zip | \
    bsdtar -C /opt/wix/bin -xf - && sh /tmp/exelink.sh /opt/wix/bin && rm -f /tmp/exelink.sh

# create user and mount point
RUN useradd -m -s /bin/bash wix
RUN echo "wix ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN mkdir /work && chown wix:wix -R /work
VOLUME /work

# prep wine and install .NET Framework 4.0
# the insecure bit is needed temporarily for dotnet40
ENV WINEDEBUG=-all WD=/
RUN echo insecure > /home/wix/.curlrc && \
    su -c "wine wineboot --init && waiton wineserver && winetricks --unattended dotnet40 && waiton wineserver" wix \
    && rm /home/wix/.curlrc

ARG finaluser=wix
USER $finaluser
ENTRYPOINT ["pwrap"]
