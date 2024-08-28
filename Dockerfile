ARG ERIC_ENM_SLES_BASE_IMAGE_NAME=eric-enm-sles-base
ARG ERIC_ENM_SLES_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-enm
ARG ERIC_ENM_SLES_BASE_IMAGE_TAG=1.64.0-33

FROM ${ERIC_ENM_SLES_BASE_IMAGE_REPO}/${ERIC_ENM_SLES_BASE_IMAGE_NAME}:${ERIC_ENM_SLES_BASE_IMAGE_TAG}

ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified
ARG SGUSER=164095

LABEL \
com.ericsson.product-number="CXC Placeholder" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ENM fmx rabbitmq Service Group" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

RUN zypper install -y libopenssl1_0_0 && \
    zypper install -y libwrap0 && \
    zypper install --repo sles_base_os_repo -y erlang && \
    OS_VERSION=$(cat /etc/os-release | grep VERSION= | cut -d'=' -f 2 | tr -d '"') && \
    SUSE_PKG_REPO_URL=https://arm.sero.gic.ericsson.se/artifactory/proj-suse-repos-rpm-local/SLE15/SLE-${OS_VERSION}-Module-Basesystem && \
    zypper addrepo -C -G -f ${SUSE_PKG_REPO_URL}?ssl_verify=no SUSE-REPO && \
    zypper install -y socat && \
    zypper removerepo SUSE-REPO && \
    zypper install -y rabbitmq-server && \
    zypper download ERICfmxrabbitmqcfg_CXP9031808 \
                    ERICfmxenmcfg_CXP9032402 && \
    rpm -ivh /var/cache/zypp/packages/enm_iso_repo/*.rpm --nodeps  --noscripts && \
    zypper clean -a

RUN mkdir -p /etc/rabbitmq && \
    ln -s /usr/lib/rabbitmq/bin /etc/rabbitmq/ && \
    ln -s /var/lib/rabbitmq /erlang && \
    touch /var/lib/rabbitmq/.start && \
    sed -i '/RMQ_HNAME/d' /etc/rabbitmq/rabbitmq-env.conf

COPY image_content/rabbitmq* /etc/rabbitmq/
COPY image_content/advanced.config /etc/rabbitmq/advanced.config
COPY image_content/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo "$SGUSER:x:$SGUSER:481:An Identity for fmx-rabbitmq:/nonexistent:/bin/false" >>/etc/passwd && \
echo "$SGUSER:!::0:::::" >>/etc/shadow

RUN chmod -R 775 /usr/sbin/rabbitmq* /etc/rabbitmq/ /var/lib/rabbitmq /var/log/rabbitmq && \
    mv /var/lib/rabbitmq/.erlang.cookie /tmp/.erlang.cookie && \
    chmod 440 /tmp/.erlang.cookie && \
    sed -i 's/\[ "$(id -un)" = "rabbitmq" ]/true/' /usr/sbin/rabbitmqctl && \
    sed -i 's/\[ "$(id -un)" = "rabbitmq" ]/true/' /usr/sbin/rabbitmq-upgrade && \
    sed -i 's/\[ "$(id -un)" = "rabbitmq" ]/true/' /usr/sbin/rabbitmq-server && \
    sed -i 's/\[ "$(id -un)" = "rabbitmq" ]/true/' /usr/sbin/rabbitmq-queues && \
    sed -i 's/\[ "$(id -un)" = "rabbitmq" ]/true/' /usr/sbin/rabbitmq-plugins && \
    sed -i 's/\[ "$(id -un)" = "rabbitmq" ]/true/' /usr/sbin/rabbitmq-diagnostics

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 4369 5671 5672 15671 15672 25672 15692

USER $SGUSER
