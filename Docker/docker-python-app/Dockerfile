# ---------- Stage 1 ----------
FROM python:3.12 AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir \
    --prefix=/install \
    -r requirements.txt

COPY . .

# ---------- Stage 2 ----------
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY --from=builder /app .

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]