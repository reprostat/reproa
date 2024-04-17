FROM reprostat/octave:8.4.4

ENV REPROA_VER=0.1.0

ARG DEBIAN_FRONTEND="noninteractive"

# Update
RUN apt update -qq && \
    apt remove needrestart && \
    apt install --no-install-recommends -q -y \
        ca-certificates curl apt-utils gnupg \
        libtinfo5 libtinfo6 \
        dc \
        libxml2-utils \
        graphviz && \
    rm -rf /var/lib/apt/lists/*

# BIDS validator
ENV NODE_MAJOR="18"
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install --no-install-recommends -q -y \
        nodejs && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN node --version && npm --version && npm install -g bids-validator@1.14.5

# Save specification to JSON.
RUN printf '{ \
  "pkg_manager": "apt", \
  "existing_users": [ \
    "root" \
  ], \
  "instructions": [ \
    { \
      "name": "from_", \
      "kwds": { \
        "base_image": "reprostat/octave:8.4.4" \
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

# reproa
ENV REPROA_DIR=/opt/software/reproanalysis
RUN wget --progress=dot:mega -P /opt https://github.com/reprostat/reproanalysis/releases/download/${REPROA_VER}/reproa-${REPROA_VER}.tar.gz && \
    tar -xzf /opt/reproa-${REPROA_VER}.tar.gz -C /opt/software && \
    mv /opt/software/reproa-${REPROA_VER} ${REPROA_DIR} && \
    rm /opt/reproa-${REPROA_VER}.tar.gz

COPY reproa_bidsapp.m run.sh version ${REPROA_DIR}/
RUN chmod +x ${REPROA_DIR}/run.sh

COPY version /version

ENTRYPOINT ["/opt/software/reproanalysis/run.sh"]
