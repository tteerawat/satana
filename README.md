# Satana

## Setup

- [Elixir/Erlang installation](https://elixir-lang.org/install.html)
- [Blocknative account](https://explorer.blocknative.com/account)
- [Slack webhook setup](https://api.slack.com/messaging/webhooks)

## Running

- Install dependencies with `mix deps.get`
- Configure environment variables, check `.env.sample`
- Start Phoenix endpoint with `mix phx.server`

## Examples

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
