# Image for the hello-docker container action.
#
# Note: unlike production images, GitHub requires container actions to run as
# the default root user so the runner can mount and write its workspace and
# file-command paths — so no `USER` instruction here. Keep action images tiny
# instead: alpine + one script.
FROM alpine:3.22

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
