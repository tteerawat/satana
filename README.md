# Satana

## Setup

First of all, we need working installations of Elixir and Erlang. The
easiest way to achieve this is via [Installation Page](https://elixir-lang.org/install.html).

## Running

- Install dependencies with `mix deps.get`
- Configure environment variables, check `.env.sample`
- Start Phoenix endpoint with `mix phx.server`

## API call Examples

- List pending transactions

```sh
curl http://localhost:4000/api/transactions/pending
```

- Add pending transaction(s)

```sh
curl -d '{"tx_ids": ["0x123", "0x456"]}' -H "Content-Type: application/json" -X POST http:/localhost:4000/api/transactions
```

## Tests

You can run tests with `mix test`
