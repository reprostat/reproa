FROM reprostat/octave:9.2.0

ENV REPROA_VER=0.2.0

LABEL org.opencontainers.image.authors="ReproStat <https://github.com/reprostat>"
LABEL org.opencontainers.image.source="https://github.com/reprostat/reproanalysis"
LABEL org.opencontainers.image.url="https://github.com/reprostat/reproanalysis"
LABEL org.opencontainers.image.documentation="https://github.com/reprostat/reproanalysis"
LABEL org.opencontainers.image.version="${REPROA_VER}"
LABEL org.opencontainers.image.vendor="ReproStat"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="Reproducible Analysis"
LABEL org.opencontainers.image.description="Multimodal pipeline system for ReproStat"

# Update
RUN apt update -qq && DEBIAN_FRONTEND="noninteractive" && \
    apt install -q -y \
        curl \
        libtinfo5 \
        dc \
        libxml2-utils

# BIDS validator + Save specification to JSON.
ENV NODE_MAJOR="18"
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt install --no-install-recommends -q -y \
        nodejs && \
    node --version && npm --version && npm install -g bids-validator@1.14.5 && \
    printf '{ \
  "pkg_manager": "apt", \
  "existing_users": [ \
    "root" \
  ], \
  "instructions": [ \
    { \
      "name": "from_", \
      "kwds": { \
        "base_image": "reprostat/octave:9.2.0" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "apt update -qq" \
      } \
    }, \
    { \
      "name": "install", \
      "kwds": { \
        "pkgs": [ \
          "ca-certificates curl apt-utils gnupg nodejs libtinfo5 libtinfo6 dc libxml2-utils graphviz" \
        ], \
        "opts": null \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*" \
      } \
    }, \
    { \
      "name": "env", \
      "kwds": { \
        "NODE_MAJOR": "18" \
      } \
    }, \    
    { \
      "name": "run", \
      "kwds": { \
        "command": "mkdir -p /etc/apt/keyrings" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "echo \\"deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main\\" | tee /etc/apt/sources.list.d/nodesource.list" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "curl -sL https://deb.nodesource.com/setup_18.x | bash -" \
      } \
    }, \
    { \
      "name": "run", \
      "kwds": { \
        "command": "node --version && npm --version && npm install -g bids-validator@1.14.5" \
      } \
    } \
  ] \
}' > /.reproenv.json

# Clean
RUN apt-get clean && \
    rm -rf \
      /tmp/hsperfdata* \
      /var/*/apt/*/partial \
      /var/lib/apt/lists/* \
      /var/log/apt/term* \
      /tmp/* /var/tmp/*

ENV TOOLS_DIR=/opt/software

# spm12 + reproa
ENV SPM_VER=7771
RUN mkdir -p ${TOOLS_DIR}/spm12 && \
    curl -SL https://github.com/spm/spm12/archive/r${SPM_VER}.tar.gz \
      | tar -xzC ${TOOLS_DIR}/spm12 --strip-components 1 && \
    curl -SL https://raw.githubusercontent.com/spm/spm-octave/main/spm12_r${SPM_VER}.patch \
      | patch -p3 -d ${TOOLS_DIR}/spm12 && \
    cd ${TOOLS_DIR}/spm12/src && make PLATFORM=octave && make PLATFORM=octave install && \
    mkdir ${TOOLS_DIR}/reproanalysis && \
    curl -SL https://github.com/reprostat/reproanalysis/releases/download/${REPROA_VER}/reproa-${REPROA_VER}.tar.gz \
      | tar -xzC ${TOOLS_DIR}/reproanalysis --strip-components 1 && \
    mkdir ${TOOLS_DIR}/reproa_bidsapp
COPY reproa_bidsapp ${TOOLS_DIR}/reproa_bidsapp/
RUN chmod +x ${TOOLS_DIR}/reproa_bidsapp/run.sh

COPY reproa_bidsapp/version /version

ENTRYPOINT ["/opt/software/reproa_bidsapp/run.sh"]
