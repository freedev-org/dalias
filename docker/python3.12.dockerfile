FROM python:3.12-alpine

RUN wget -qO- https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:${PATH}"

CMD ["python3"]
