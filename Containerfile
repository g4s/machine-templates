FROM ubi9:latest
MAINTAINER Gregor A. "schlumpi" Segner gregor.segner@gmail.com
USER root
LABEL RUN="podman run --recreate -it -v $(pwd):/workspace:Z --name packer IMAGE"
LABEL HELP="podman run --recreate -it -v $(pwd):/workspace:Z --name packer IMAGE --help"

RUN mkdir /workspace

# install packer
RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN dnf update -y
RUN dnf install -y packer
RUN dnf install -y git
RUN dnf install -y python3 python3-pip
RUN dnf install -y jq

COPY assets/start.sh /start.sh

# launch
CMD ["/start.sh"]