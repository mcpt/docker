FROM ghcr.io/mcpt/wlmoj-base:latest

ENTRYPOINT ["celery", "-A", "dmoj_celery", "worker", "-l", "info", "--concurrency=2"]
