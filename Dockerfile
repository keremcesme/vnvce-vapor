# ================================
# Build image
# ================================

FROM swift:5.8-focal as build

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install libssl-dev -y \
    && rm -rf /var/lib/apt/lists/*
    
RUN git config --global url."https://${ACCESS_TOKEN}:@github.com/".insteadOf "https://github.com/"

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve

COPY . .

RUN swift build -c release --static-swift-stdlib

WORKDIR /staging

RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Run" ./
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true



# ================================
# Run image
# ================================

FROM swift:5.8-focal-slim

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && apt-get -q install -y ca-certificates tzdata && apt-get install libssl-dev -y &&  \
    rm -r /var/lib/apt/lists/*
    
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

COPY --from=build --chown=vapor:vapor /staging /app

# ARS AWS Environment ARG
ARG AWS_KEY_ID
ARG AWS_KEY

# ===== SET ENVIRONMENTS =====
RUN echo "AWS_KEY_ID=${AWS_KEY_ID}" >> .env.production
RUN echo "AWS_KEY=${AWS_KEY}" >> .env.production

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
