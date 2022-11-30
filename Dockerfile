# ================================
# Build image
# ================================
FROM swift:5.7.1-focal as build

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install libssl-dev -y \
    && rm -rf /var/lib/apt/lists/*
    
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
FROM swift:5.6.1-focal-slim

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && apt-get -q install -y ca-certificates tzdata && apt-get install libssl-dev -y &&  \
    rm -r /var/lib/apt/lists/*
    
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

COPY --from=build --chown=vapor:vapor /staging /app

# ARS DB Environment ARG
ARG DB_HOST
ARG DB_PORT
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_NAME

# ARS APPLE Environment ARG
ARG APPLE_APN_PRIVATE_KEY
ARG APPLE_APN_KEY_ID
ARG APPLE_TEAM_ID

# JWT RSA Environment ARG
ARG RSA_PUBLIC_KEY
ARG RSA_PRIVATE_KEY

# ARS AWS Environment ARG
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SNS_SENDER_ID
ARG AWS_REGION

# ARS Redis Environment ARG
ARG REDIS_HOST
ARG REDIS_PORT

# ARS iOS Environment ARG
ARG IOS_APP_BUNDLE_ID

# ===== SET ENVIRONMENTS =====
RUN echo "DB_HOST=${DB_HOST}" >> .env.production
RUN echo "DB_PORT=${DB_PORT}" >> .env.production
RUN echo "DB_USERNAME=${DB_USERNAME}" >> .env.production
RUN echo "DB_PASSWORD=${DB_PASSWORD}" >> .env.production
RUN echo "DB_NAME=${DB_NAME}" >> .env.production

RUN echo "APPLE_APN_PRIVATE_KEY=${APPLE_APN_PRIVATE_KEY}" >> .env.production
RUN echo "APPLE_APN_KEY_ID=${APPLE_APN_KEY_ID}" >> .env.production
RUN echo "APPLE_TEAM_ID=${APPLE_TEAM_ID}" >> .env.production

RUN echo "RSA_PUBLIC_KEY=${RSA_PUBLIC_KEY}" >> .env.production
RUN echo "RSA_PRIVATE_KEY=${RSA_PRIVATE_KEY}" >> .env.production

RUN echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> .env.production
RUN echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> .env.production
RUN echo "AWS_SNS_SENDER_ID=${AWS_SNS_SENDER_ID}" >> .env.production
RUN echo "AWS_REGION=${AWS_REGION}" >> .env.production

RUN echo "REDIS_HOST=${REDIS_HOST}" >> .env.production
RUN echo "REDIS_PORT=${REDIS_PORT}" >> .env.production

RUN echo "IOS_APP_BUNDLE_ID=${IOS_APP_BUNDLE_ID}" >> .env.production

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
