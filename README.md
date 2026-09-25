# fraud-check

Async fraud scoring for [Ledger & Rail](https://github.com/yosefbennywidyo/ledger-rail),
written in Python (aiokafka + scikit-learn). Consumes the `transactions` topic
that `ledger-service` publishes to after each applied transaction, scores each
one with an anomaly model, and logs the result. It is off the payment's
critical path: a slow or stopped fraud-check never blocks a payment.

The anomaly model is trained on synthetic data and is illustrative only.
Design notes, message format, and hand-testing with `rpk`:
[`BEST_PRACTICES.md`](BEST_PRACTICES.md).

## Run

Needs a Kafka-compatible broker. From the `ledger-rail` superproject root,
`docker compose up -d redpanda` provides one.

```bash
mise exec uv -- uv sync
mise exec uv -- uv run fraud-check
```

| Env var | Default |
|---|---|
| `KAFKA_BROKERS` | `localhost:9092` |
| `KAFKA_TOPIC` | `transactions` |
| `KAFKA_GROUP_ID` | `fraud-check` |
| `HEALTH_HOST` / `HEALTH_PORT` | `0.0.0.0` / `8090` |
| `ANOMALY_CONTAMINATION` | `0.05` |

`GET /healthz` on the health port returns `200` once the consumer is running.
Each processed message is logged as
`processed transaction idempotency_key=... amount_cents=... anomaly_score=... flagged=...`.

## Test

```bash
mise exec uv -- uv sync --extra dev
mise exec uv -- uv run pytest
```

Unit tests need no broker. End-to-end tests (ledger-service → Redpanda →
fraud-check) live in the superproject's
[`e2e/`](https://github.com/yosefbennywidyo/ledger-rail/tree/main/e2e).

## Docker

```bash
docker build -t fraud-check .
```

The superproject's `docker-compose.yml` builds and wires this image
(`docker compose up -d fraud-check`).
