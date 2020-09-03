FROM adoptopenjdk/openjdk8:alpine-jre

ARG MINECRAFT_VERSION=1.12.2
ARG SPONGE_TYPE=spongeforge
ARG SPONGE_VERSION=2838-7.3.0
ARG FORGE_VERSION=14.23.5.2854

ENV SPONGE_TYPE=$SPONGE_TYPE \
    SPONGE_WORKSPACE=/var/local/sponge \
    SPONGE_ROOT=/opt/sponge \
    SPONGE_USER=sponge \
    SPONGE_GROUP=sponge \
    MINECRAFT_VERSION=$MINECRAFT_VERSION \
    SPONGE_VERSION=$SPONGE_VERSION \
    FORGE_VERSION=$FORGE_VERSION \
    JAVA_OPTS='-Xms1G -Xmx1G'

LABEL \
    name=spongeforge \
    version=$MINECRAFT_VERSION-$SPONGE_VERSION \
    maintainer='SettingDust <settingdust@gmail.com>'

RUN apk update \
    && apk add --virtual build-deps wget ca-certificates \
    && mkdir -p $SPONGE_ROOT/mods \
    && mkdir -p $SPONGE_WORKSPACE/mods \
    # Minecraft
    && wget -O $SPONGE_ROOT/minecraft_server.$MINECRAFT_VERSION.jar https://s3.amazonaws.com/Minecraft.Download/versions/$MINECRAFT_VERSION/minecraft_server.$MINECRAFT_VERSION.jar \
    # Forge
    && if [ $SPONGE_TYPE = spongeforge ]; then\
        cd $SPONGE_ROOT/ \
        && wget -O $SPONGE_ROOT/forge-$MINECRAFT_VERSION-$FORGE_VERSION-installer.jar http://files.minecraftforge.net/maven/net/minecraftforge/forge/$MINECRAFT_VERSION-$FORGE_VERSION/forge-$MINECRAFT_VERSION-$FORGE_VERSION-installer.jar \
        && java -jar $SPONGE_ROOT/forge-$MINECRAFT_VERSION-$FORGE_VERSION-installer.jar --installServer $SPONGE_ROOT/ \
        && rm $SPONGE_ROOT/forge-$MINECRAFT_VERSION-$FORGE_VERSION-installer.jar $SPONGE_ROOT/*.log; \
    fi \
    # SpongeForge
    && wget -O $SPONGE_ROOT/mods/$SPONGE_TYPE-$MINECRAFT_VERSION-$SPONGE_VERSION.jar https://repo.spongepowered.org/maven/org/spongepowered/$SPONGE_TYPE/$MINECRAFT_VERSION-$SPONGE_VERSION/$SPONGE_TYPE-$MINECRAFT_VERSION-$SPONGE_VERSION.jar \
    && ln -sf $SPONGE_ROOT/mods/$SPONGE_TYPE-$MINECRAFT_VERSION-$SPONGE_VERSION.jar $SPONGE_WORKSPACE/mods/$SPONGE_TYPE-$MINECRAFT_VERSION-$SPONGE_VERSION.jar \
    # Create user
    && addgroup -S $SPONGE_GROUP \
    && adduser -G $SPONGE_GROUP -S $SPONGE_USER \
    && chown -R $SPONGE_USER:$SPONGE_GROUP $SPONGE_WORKSPACE \
    # install utils
    && apk add su-exec \
    # clean up
    && apk del build-deps \
    && rm -rf /var/lib/apk/

WORKDIR $SPONGE_WORKSPACE
VOLUME $SPONGE_WORKSPACE

EXPOSE 25565

CMD echo eula=true > $SPONGE_WORKSPACE/eula.txt \
    && if [ ${SPONGE_TYPE} = spongeforge ]; then \
            java $JAVA_OPTS -jar $SPONGE_ROOT/forge-$MINECRAFT_VERSION-$FORGE_VERSION.jar --nogui; \
        else \
            java $JAVA_OPTS -jar $SPONGE_ROOT/minecraft_server.$MINECRAFT_VERSION.jar --nogui; \
        fi