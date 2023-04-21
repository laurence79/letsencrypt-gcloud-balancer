FROM debian:bullseye

WORKDIR /root

RUN apt-get clean && apt-get update \
    && apt-get install -y wget python xz-utils git apt-transport-https ca-certificates gnupg curl

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | tee /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk -y

RUN wget https://github.com/go-acme/lego/releases/download/v4.10.2/lego_v4.10.2_linux_amd64.tar.gz \
    && tar -xzf lego_v4.10.2_linux_amd64.tar.gz lego \
    && rm lego_v4.10.2_linux_amd64.tar.gz

COPY run.sh /root/run.sh

CMD /root/run.sh
